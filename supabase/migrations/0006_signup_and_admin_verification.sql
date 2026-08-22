-- Compact sign-up metadata and richer admin verification review data.
ALTER TABLE public.freelancer_profiles
  ADD COLUMN IF NOT EXISTS subcategory TEXT,
  ADD COLUMN IF NOT EXISTS experience_level TEXT,
  ADD COLUMN IF NOT EXISTS pricing_model TEXT,
  ADD COLUMN IF NOT EXISTS preferred_work_type TEXT,
  ADD COLUMN IF NOT EXISTS minimum_project_budget NUMERIC(12, 2),
  ADD COLUMN IF NOT EXISTS is_student BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL,
  target_id UUID,
  category TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users create reports" ON public.reports;
CREATE POLICY "Users create reports" ON public.reports
  FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Users read own reports" ON public.reports;
CREATE POLICY "Users read own reports" ON public.reports
  FOR SELECT TO authenticated
  USING (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Admins manage reports" ON public.reports;
CREATE POLICY "Admins manage reports" ON public.reports
  FOR ALL TO authenticated
  USING (public.is_platform_admin())
  WITH CHECK (public.is_platform_admin());

CREATE OR REPLACE FUNCTION public.apply_compact_freelancer_signup()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.raw_user_meta_data->>'user_type' = 'freelancer' THEN
    UPDATE public.freelancer_profiles
    SET subcategory = NEW.raw_user_meta_data->>'subcategory',
        experience_level = NEW.raw_user_meta_data->>'experience_level',
        pricing_model = NEW.raw_user_meta_data->>'pricing_model',
        preferred_work_type = NEW.raw_user_meta_data->>'preferred_work_type',
        minimum_project_budget = NULLIF(NEW.raw_user_meta_data->>'minimum_project_budget', '')::numeric,
        is_student = COALESCE((NEW.raw_user_meta_data->>'is_student')::boolean, false)
    WHERE user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS apply_compact_freelancer_signup ON auth.users;
DROP TRIGGER IF EXISTS zz_apply_compact_freelancer_signup ON auth.users;
CREATE TRIGGER zz_apply_compact_freelancer_signup
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.apply_compact_freelancer_signup();

-- No mobile/OTP state is used in onboarding or verification flows.
DROP FUNCTION IF EXISTS public.get_admin_verification_queue();
CREATE OR REPLACE FUNCTION public.get_admin_verification_queue()
RETURNS TABLE (
  id UUID, user_id UUID, full_name TEXT, email TEXT, account_type TEXT,
  avatar_path TEXT, email_verified BOOLEAN, document_type TEXT,
  document_path TEXT, selfie_path TEXT, student_id_path TEXT,
  status TEXT, created_at TIMESTAMPTZ
) AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  RETURN QUERY
  SELECT request.id, request.user_id, profile.full_name, profile.email,
         profile.user_type::TEXT, profile.avatar_url,
         (profile.is_email_verified OR EXISTS (
           SELECT 1 FROM auth.users u WHERE u.id = profile.id AND u.email_confirmed_at IS NOT NULL
         )),
         request.document_type, request.document_path, request.selfie_path,
         student_document.storage_path, request.status::TEXT, request.created_at
  FROM public.identity_verification_requests request
  JOIN public.profiles profile ON profile.id = request.user_id
  LEFT JOIN public.verification_documents student_document
    ON student_document.user_id = profile.id AND student_document.document_type = 'student_id'
  WHERE request.status = 'pending'
  ORDER BY request.created_at ASC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, auth;

CREATE OR REPLACE FUNCTION public.get_admin_dashboard_summary()
RETURNS JSONB AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;
  RETURN jsonb_build_object(
    'total_users', (SELECT COUNT(*) FROM public.profiles WHERE user_type <> 'admin'),
    'open_jobs', (SELECT COUNT(*) FROM public.jobs WHERE status = 'open'),
    'pending_verifications', (SELECT COUNT(*) FROM public.identity_verification_requests WHERE status = 'pending'),
    'active_projects', (SELECT COUNT(*) FROM public.projects WHERE status = 'active'),
    'total_transactions', (SELECT COUNT(*) FROM public.transactions),
    'reports_disputes', (SELECT COUNT(*) FROM public.reports WHERE status IN ('open', 'in_progress')) + (SELECT COUNT(*) FROM public.projects WHERE status = 'disputed')
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;
