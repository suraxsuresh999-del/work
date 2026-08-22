-- One private workflow for government-ID and live-selfie verification.
-- The older verification_requests table is retained for migration safety, but
-- all current RPCs below use this table and the verification-documents bucket.
CREATE TABLE IF NOT EXISTS public.identity_verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  document_path TEXT NOT NULL,
  selfie_path TEXT NOT NULL,
  status verification_status NOT NULL DEFAULT 'pending',
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

ALTER TABLE public.identity_verification_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own identity verification requests" ON public.identity_verification_requests;
CREATE POLICY "Users view own identity verification requests"
  ON public.identity_verification_requests FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Platform admins view identity verification requests" ON public.identity_verification_requests;
CREATE POLICY "Platform admins view identity verification requests"
  ON public.identity_verification_requests FOR SELECT
  USING (public.is_platform_admin());

DROP POLICY IF EXISTS "Users upload private identity verification files" ON storage.objects;
CREATE POLICY "Users upload private identity verification files"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'verification-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Admins read private identity verification files" ON storage.objects;
CREATE POLICY "Admins read private identity verification files"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'verification-documents' AND public.is_platform_admin());

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
    OR document_type_input IS NULL OR document_path_input IS NULL OR selfie_path_input IS NULL
    OR (storage.foldername(document_path_input))[1] <> auth.uid()::text
    OR (storage.foldername(selfie_path_input))[1] <> auth.uid()::text
    OR NOT EXISTS (
      SELECT 1 FROM storage.objects
      WHERE bucket_id = 'verification-documents' AND name = document_path_input
    )
    OR NOT EXISTS (
      SELECT 1 FROM storage.objects
      WHERE bucket_id = 'verification-documents' AND name = selfie_path_input
    )
  THEN
    RAISE EXCEPTION 'Invalid verification request';
  END IF;

  UPDATE public.identity_verification_requests
  SET status = 'reupload_required'
  WHERE user_id = auth.uid() AND status = 'pending';

  INSERT INTO public.identity_verification_requests (
    user_id, document_type, document_path, selfie_path
  ) VALUES (
    auth.uid(), document_type_input, document_path_input, selfie_path_input
  ) RETURNING id INTO request_id;

  UPDATE public.profiles SET verification_status = 'pending' WHERE id = auth.uid();
  RETURN request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_admin_verification_queue()
RETURNS TABLE (
  id UUID, user_id UUID, full_name TEXT, email TEXT, document_type TEXT,
  document_path TEXT, selfie_path TEXT, status TEXT, created_at TIMESTAMPTZ
) AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  RETURN QUERY
  SELECT request.id, request.user_id, profile.full_name, profile.email,
         request.document_type, request.document_path, request.selfie_path,
         request.status::TEXT, request.created_at
  FROM public.identity_verification_requests request
  JOIN public.profiles profile ON profile.id = request.user_id
  WHERE request.status = 'pending'
  ORDER BY request.created_at ASC;
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

  UPDATE public.identity_verification_requests
  SET status = decision_input::verification_status,
      admin_notes = admin_notes_input,
      reviewed_at = now(),
      reviewed_by = auth.uid()
  WHERE id = request_id_input AND status = 'pending'
  RETURNING user_id INTO target_user;

  IF target_user IS NULL THEN
    RAISE EXCEPTION 'Verification request is no longer pending';
  END IF;

  UPDATE public.profiles
  SET verification_status = decision_input::verification_status
  WHERE id = target_user;

  INSERT INTO public.admin_logs (admin_id, action, target_type, target_id, metadata)
  VALUES (auth.uid(), 'review_verification', 'identity_verification_request', request_id_input,
          jsonb_build_object('decision', decision_input));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

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
    'active_projects', (SELECT COUNT(*) FROM public.projects WHERE status = 'active')
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;
