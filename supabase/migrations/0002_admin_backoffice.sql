-- Internal marketplace administration. Admin access is assigned only by a
-- trusted database operator; it is never available from client-side signup.

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND user_type = 'admin' AND onboarding_status = 'active'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

CREATE TABLE IF NOT EXISTS public.admin_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Platform admins can read audit logs"
  ON public.admin_logs FOR SELECT USING (public.is_platform_admin());

CREATE OR REPLACE FUNCTION public.get_admin_dashboard_summary()
RETURNS JSONB AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;
  RETURN jsonb_build_object(
    'total_users', (SELECT COUNT(*) FROM public.profiles WHERE user_type <> 'admin'),
    'open_jobs', (SELECT COUNT(*) FROM public.jobs WHERE status = 'open'),
    'pending_verifications', (SELECT COUNT(*) FROM public.verification_requests WHERE status = 'pending'),
    'active_projects', (SELECT COUNT(*) FROM public.projects WHERE status = 'active')
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.is_platform_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_dashboard_summary() TO authenticated;

-- Secure identity-verification workflow.
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', FALSE)
ON CONFLICT (id) DO UPDATE SET public = FALSE;

CREATE POLICY "Users upload their own verification documents"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users read their own verification documents"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'documents'
    AND (
      (storage.foldername(name))[1] = auth.uid()::text
      OR public.is_platform_admin()
    )
  );

CREATE OR REPLACE FUNCTION public.submit_verification_request(
  document_type_input TEXT,
  document_path_input TEXT,
  selfie_path_input TEXT
)
RETURNS UUID AS $$
DECLARE
  request_id UUID;
BEGIN
  IF auth.uid() IS NULL
    OR document_type_input IS NULL
    OR document_path_input IS NULL
    OR selfie_path_input IS NULL
    OR (storage.foldername(document_path_input))[1] <> auth.uid()::text
    OR (storage.foldername(selfie_path_input))[1] <> auth.uid()::text
  THEN
    RAISE EXCEPTION 'Invalid verification request';
  END IF;

  UPDATE public.verification_requests
  SET status = 'reupload_required'
  WHERE user_id = auth.uid() AND status = 'pending';

  INSERT INTO public.verification_requests (
    user_id, document_type, document_url, selfie_url, status
  ) VALUES (
    auth.uid(), document_type_input, document_path_input, selfie_path_input, 'pending'
  ) RETURNING id INTO request_id;

  UPDATE public.profiles
  SET verification_status = 'pending'
  WHERE id = auth.uid();

  RETURN request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_admin_verification_queue()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  full_name TEXT,
  email TEXT,
  document_type TEXT,
  document_path TEXT,
  selfie_path TEXT,
  status TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  RETURN QUERY
  SELECT vr.id, vr.user_id, p.full_name, p.email, vr.document_type,
         vr.document_url, vr.selfie_url, vr.status::TEXT, vr.created_at
  FROM public.verification_requests vr
  JOIN public.profiles p ON p.id = vr.user_id
  WHERE vr.status = 'pending'
  ORDER BY vr.created_at ASC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.review_verification_request(
  request_id_input UUID,
  decision_input TEXT,
  admin_notes_input TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  target_user UUID;
BEGIN
  IF NOT public.is_platform_admin()
    OR decision_input NOT IN ('approved', 'rejected', 'reupload_required') THEN
    RAISE EXCEPTION 'Invalid administrator action';
  END IF;

  UPDATE public.verification_requests
  SET status = decision_input::verification_status,
      admin_notes = admin_notes_input
  WHERE id = request_id_input AND status = 'pending'
  RETURNING user_id INTO target_user;

  IF target_user IS NULL THEN
    RAISE EXCEPTION 'Verification request is no longer pending';
  END IF;

  UPDATE public.profiles
  SET verification_status = decision_input::verification_status
  WHERE id = target_user;

  INSERT INTO public.admin_logs (admin_id, action, target_type, target_id, metadata)
  VALUES (
    auth.uid(),
    'review_verification',
    'verification_request',
    request_id_input,
    jsonb_build_object('decision', decision_input)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.submit_verification_request(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_verification_queue() TO authenticated;
GRANT EXECUTE ON FUNCTION public.review_verification_request(UUID, TEXT, TEXT) TO authenticated;

-- Create an administrator manually in the Supabase SQL editor (replace email):
-- UPDATE public.profiles SET user_type = 'admin', onboarding_status = 'active'
-- WHERE email = 'owner@example.com';
