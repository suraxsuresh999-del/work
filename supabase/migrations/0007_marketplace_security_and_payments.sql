-- WorkSphere marketplace security, payment methods, and payment transactions.

ALTER TYPE public.user_type ADD VALUE IF NOT EXISTS 'role_pending';

ALTER TABLE public.profiles
  ALTER COLUMN user_type SET DEFAULT 'role_pending';

ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (payment_status IN ('pending', 'payment_submitted', 'under_review', 'verified', 'rejected', 'cancelled', 'refunded'));

CREATE TABLE IF NOT EXISTS public.freelancer_payment_methods (
  user_id UUID PRIMARY KEY REFERENCES public.freelancer_profiles(user_id) ON DELETE CASCADE,
  upi_id TEXT,
  account_holder_name TEXT,
  qr_code_path TEXT,
  payment_note TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'verified')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.freelancer_payment_methods ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_freelancer_payment_methods_updated_at
  BEFORE UPDATE ON public.freelancer_payment_methods
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP POLICY IF EXISTS "Freelancers manage own payment methods" ON public.freelancer_payment_methods;
CREATE POLICY "Freelancers manage own payment methods"
  ON public.freelancer_payment_methods
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins view freelancer payment methods" ON public.freelancer_payment_methods;
CREATE POLICY "Admins view freelancer payment methods"
  ON public.freelancer_payment_methods
  FOR SELECT TO authenticated
  USING (public.is_platform_admin());

DROP POLICY IF EXISTS "Project clients can read freelancer payment methods" ON storage.objects;
CREATE POLICY "Project clients can read freelancer payment methods"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'freelancer-payment-assets'
    AND (
      (storage.foldername(name))[1] = auth.uid()::text
      OR public.is_platform_admin()
      OR EXISTS (
        SELECT 1
        FROM public.projects p
        WHERE p.client_id = auth.uid()
          AND p.freelancer_id::text = (storage.foldername(name))[1]
      )
    )
  );

DROP POLICY IF EXISTS "Freelancers upload payment assets" ON storage.objects;
CREATE POLICY "Freelancers upload payment assets"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'freelancer-payment-assets'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "Freelancers update payment assets" ON storage.objects;
CREATE POLICY "Freelancers update payment assets"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'freelancer-payment-assets'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'freelancer-payment-assets'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'freelancer-payment-assets',
  'freelancer-payment-assets',
  false,
  5242880,
  ARRAY['image/jpeg', 'image/png']
)
ON CONFLICT (id) DO UPDATE
SET public = false,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

CREATE TABLE IF NOT EXISTS public.project_payment_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id TEXT NOT NULL UNIQUE DEFAULT 'WS-TXN-' || upper(replace(uuid_generate_v4()::text, '-', '')),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES public.client_profiles(user_id) ON DELETE CASCADE,
  freelancer_id UUID NOT NULL REFERENCES public.freelancer_profiles(user_id) ON DELETE CASCADE,
  project_name TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'INR',
  payment_method TEXT NOT NULL DEFAULT 'UPI',
  freelancer_upi_id TEXT,
  account_holder_name TEXT,
  utr TEXT,
  payment_screenshot_path TEXT,
  payment_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (payment_status IN ('pending', 'payment_submitted', 'under_review', 'verified', 'rejected', 'cancelled', 'refunded')),
  rejection_reason TEXT,
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.project_payment_transactions ENABLE ROW LEVEL SECURITY;

CREATE TRIGGER update_project_payment_transactions_updated_at
  BEFORE UPDATE ON public.project_payment_transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP POLICY IF EXISTS "Clients view own payment transactions" ON public.project_payment_transactions;
CREATE POLICY "Clients view own payment transactions"
  ON public.project_payment_transactions
  FOR SELECT TO authenticated
  USING (auth.uid() = client_id OR auth.uid() = freelancer_id);

DROP POLICY IF EXISTS "Admins manage payment transactions" ON public.project_payment_transactions;
CREATE POLICY "Admins manage payment transactions"
  ON public.project_payment_transactions
  FOR ALL TO authenticated
  USING (public.is_platform_admin())
  WITH CHECK (public.is_platform_admin());

CREATE OR REPLACE FUNCTION public.require_verified_marketplace_user(required_role user_type)
RETURNS VOID AS $$
DECLARE
  current_user_type user_type;
  current_status verification_status;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication is required';
  END IF;

  SELECT user_type, verification_status
  INTO current_user_type, current_status
  FROM public.profiles
  WHERE id = auth.uid();

  IF current_user_type IS DISTINCT FROM required_role THEN
    RAISE EXCEPTION 'User role is not permitted';
  END IF;

  IF current_status IS DISTINCT FROM 'approved'::verification_status THEN
    RAISE EXCEPTION 'User verification is required';
  END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.upsert_freelancer_payment_method(
  upi_id_input TEXT,
  account_holder_name_input TEXT,
  qr_code_path_input TEXT DEFAULT NULL,
  payment_note_input TEXT DEFAULT NULL
)
RETURNS public.freelancer_payment_methods AS $$
DECLARE
  saved_row public.freelancer_payment_methods;
BEGIN
  PERFORM public.require_verified_marketplace_user('freelancer');

  IF upi_id_input IS NULL OR upi_id_input !~ '^[A-Za-z0-9._-]+@(upi|okaxis|oksbi|ybl|paytm|axl|ibl|idbi|kotak|unionbank|paytm)$' THEN
    RAISE EXCEPTION 'Invalid UPI ID';
  END IF;

  INSERT INTO public.freelancer_payment_methods (
    user_id, upi_id, account_holder_name, qr_code_path, payment_note, status
  ) VALUES (
    auth.uid(),
    lower(trim(upi_id_input)),
    NULLIF(trim(account_holder_name_input), ''),
    NULLIF(trim(qr_code_path_input), ''),
    NULLIF(trim(payment_note_input), ''),
    'pending'
  )
  ON CONFLICT (user_id) DO UPDATE SET
    upi_id = EXCLUDED.upi_id,
    account_holder_name = EXCLUDED.account_holder_name,
    qr_code_path = EXCLUDED.qr_code_path,
    payment_note = EXCLUDED.payment_note,
    status = 'pending'
  RETURNING * INTO saved_row;

  RETURN saved_row;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_public_freelancer_profile(freelancer_id_input UUID)
RETURNS JSONB AS $$
DECLARE
  profile_record JSONB;
  method_record JSONB;
BEGIN
  SELECT jsonb_build_object(
    'id', p.id,
    'email', p.email,
    'full_name', p.full_name,
    'avatar_url', p.avatar_url,
    'user_type', p.user_type::TEXT,
    'verification_status', p.verification_status::TEXT,
    'date_of_birth', p.date_of_birth,
    'country', p.country,
    'state', p.state,
    'city', p.city,
    'gender', p.gender,
    'profile_completion', p.profile_completion,
    'bio', f.bio,
    'title', f.title,
    'hourly_rate', f.hourly_rate,
    'district', f.district,
    'city_profile', f.city,
    'languages', f.languages,
    'is_available', f.is_available,
    'resume_url', f.resume_url,
    'portfolio_url', f.portfolio_url,
    'website', f.website,
    'certifications', f.certifications,
    'education_summary', f.education_summary,
    'availability', f.availability,
    'preferred_work_type', f.preferred_work_type,
    'experience_level', f.experience_level,
    'total_earnings', f.total_earnings,
    'jobs_completed', f.jobs_completed,
    'rating', f.rating,
    'reviews_count', f.reviews_count,
    'has_payment_method', EXISTS (
      SELECT 1 FROM public.freelancer_payment_methods pm
      WHERE pm.user_id = freelancer_id_input
    )
  )
  INTO profile_record
  FROM public.profiles p
  LEFT JOIN public.freelancer_profiles f ON f.user_id = p.id
  WHERE p.id = freelancer_id_input
    AND p.user_type = 'freelancer';

  IF profile_record IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT jsonb_build_object(
    'status', pm.status,
    'upi_id', pm.upi_id,
    'account_holder_name', pm.account_holder_name,
    'qr_code_path', pm.qr_code_path,
    'payment_note', pm.payment_note
  )
  INTO method_record
  FROM public.freelancer_payment_methods pm
  WHERE pm.user_id = freelancer_id_input;

  RETURN profile_record || jsonb_build_object('payment_method', COALESCE(method_record, '{}'::jsonb));
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.submit_project_payment_confirmation(
  project_id_input UUID,
  utr_input TEXT,
  payment_screenshot_path_input TEXT DEFAULT NULL
)
RETURNS public.project_payment_transactions AS $$
DECLARE
  project_record public.projects%ROWTYPE;
  payment_method_record public.freelancer_payment_methods%ROWTYPE;
  transaction_row public.project_payment_transactions;
BEGIN
  PERFORM public.require_verified_marketplace_user('client');

  IF utr_input IS NULL OR length(trim(utr_input)) < 4 THEN
    RAISE EXCEPTION 'UTR is required';
  END IF;

  SELECT * INTO project_record
  FROM public.projects
  WHERE id = project_id_input
    AND client_id = auth.uid();

  IF project_record.id IS NULL THEN
    RAISE EXCEPTION 'Project not found';
  END IF;

  IF project_record.status <> 'completed' THEN
    RAISE EXCEPTION 'Project must be completed before payment confirmation';
  END IF;

  SELECT * INTO payment_method_record
  FROM public.freelancer_payment_methods
  WHERE user_id = project_record.freelancer_id;

  IF payment_method_record.user_id IS NULL OR payment_method_record.status <> 'verified' THEN
    RAISE EXCEPTION 'Freelancer payment details are not available yet';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.project_payment_transactions t
    WHERE t.project_id = project_id_input
      AND t.payment_status IN ('payment_submitted', 'under_review', 'verified')
  ) THEN
    RAISE EXCEPTION 'A payment confirmation already exists for this project';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.project_payment_transactions t
    WHERE lower(t.utr) = lower(trim(utr_input))
  ) THEN
    RAISE EXCEPTION 'This UTR has already been submitted';
  END IF;

  INSERT INTO public.project_payment_transactions (
    project_id, client_id, freelancer_id, project_name, amount, currency,
    payment_method, freelancer_upi_id, account_holder_name, utr,
    payment_screenshot_path, payment_status
  ) VALUES (
    project_record.id,
    project_record.client_id,
    project_record.freelancer_id,
    project_record.title,
    project_record.total_amount,
    'INR',
    'UPI',
    payment_method_record.upi_id,
    payment_method_record.account_holder_name,
    trim(utr_input),
    NULLIF(trim(payment_screenshot_path_input), ''),
    'under_review'
  )
  RETURNING * INTO transaction_row;

  UPDATE public.projects
  SET payment_status = 'under_review'
  WHERE id = project_record.id;

  INSERT INTO public.notifications (user_id, type, title, body, data)
  VALUES
    (project_record.client_id, 'payment', 'Payment confirmation submitted',
      'Your payment confirmation has been submitted and is waiting for verification.',
      jsonb_build_object('project_id', project_record.id, 'transaction_id', transaction_row.transaction_id)),
    (project_record.freelancer_id, 'payment', 'Payment confirmation received',
      'Payment confirmation has been submitted for your completed project.',
      jsonb_build_object('project_id', project_record.id, 'transaction_id', transaction_row.transaction_id))
  ON CONFLICT DO NOTHING;

  RETURN transaction_row;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.review_project_payment(
  transaction_id_input TEXT,
  decision_input TEXT,
  rejection_reason_input TEXT DEFAULT NULL
)
RETURNS public.project_payment_transactions AS $$
DECLARE
  transaction_row public.project_payment_transactions;
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  SELECT * INTO transaction_row
  FROM public.project_payment_transactions
  WHERE transaction_id = transaction_id_input;

  IF transaction_row.id IS NULL THEN
    RAISE EXCEPTION 'Transaction not found';
  END IF;

  IF decision_input NOT IN ('verified', 'rejected') THEN
    RAISE EXCEPTION 'Invalid administrator action';
  END IF;

  UPDATE public.project_payment_transactions
  SET payment_status = decision_input,
      verified_at = CASE WHEN decision_input = 'verified' THEN now() ELSE NULL END,
      verified_by = CASE WHEN decision_input = 'verified' THEN auth.uid() ELSE verified_by END,
      rejection_reason = CASE WHEN decision_input = 'rejected' THEN NULLIF(trim(rejection_reason_input), '') ELSE NULL END
  WHERE id = transaction_row.id
  RETURNING * INTO transaction_row;

  UPDATE public.projects
  SET payment_status = CASE
    WHEN decision_input = 'verified' THEN 'verified'
    ELSE 'rejected'
  END,
      amount_paid = CASE WHEN decision_input = 'verified' THEN total_amount ELSE amount_paid END
  WHERE id = transaction_row.project_id;

  INSERT INTO public.notifications (user_id, type, title, body, data)
  VALUES
    (transaction_row.client_id, 'payment',
      CASE WHEN decision_input = 'verified' THEN 'Payment verified' ELSE 'Payment needs attention' END,
      CASE WHEN decision_input = 'verified'
        THEN 'Your payment has been verified successfully.'
        ELSE 'Your payment could not be verified. Please review the details and resubmit.'
      END,
      jsonb_build_object('project_id', transaction_row.project_id, 'transaction_id', transaction_row.transaction_id)),
    (transaction_row.freelancer_id, 'payment',
      CASE WHEN decision_input = 'verified' THEN 'Payment verified' ELSE 'Payment rejected' END,
      CASE WHEN decision_input = 'verified'
        THEN 'Payment for ' || transaction_row.project_name || ' has been verified.'
        ELSE 'Payment verification was rejected for ' || transaction_row.project_name || '.'
      END,
      jsonb_build_object('project_id', transaction_row.project_id, 'transaction_id', transaction_row.transaction_id))
  ON CONFLICT DO NOTHING;

  RETURN transaction_row;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_admin_transactions_overview()
RETURNS JSONB AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  RETURN jsonb_build_object(
    'total_transactions', (SELECT COUNT(*) FROM public.project_payment_transactions),
    'pending_payments', (SELECT COUNT(*) FROM public.project_payment_transactions WHERE payment_status = 'payment_submitted'),
    'under_review', (SELECT COUNT(*) FROM public.project_payment_transactions WHERE payment_status = 'under_review'),
    'verified_payments', (SELECT COUNT(*) FROM public.project_payment_transactions WHERE payment_status = 'verified'),
    'rejected_payments', (SELECT COUNT(*) FROM public.project_payment_transactions WHERE payment_status = 'rejected'),
    'total_payment_value', COALESCE((SELECT SUM(amount) FROM public.project_payment_transactions WHERE payment_status = 'verified'), 0)
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_admin_verification_queue()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  full_name TEXT,
  email TEXT,
  date_of_birth DATE,
  avatar_path TEXT,
  location TEXT,
  bio TEXT,
  skills TEXT,
  education_summary TEXT,
  experience_summary TEXT,
  availability TEXT,
  preferred_work_type TEXT,
  portfolio_url TEXT,
  certifications TEXT,
  document_type TEXT,
  document_path TEXT,
  selfie_path TEXT,
  student_id_path TEXT,
  status TEXT,
  created_at TIMESTAMPTZ,
  admin_notes TEXT
) AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Administrator access is required';
  END IF;

  RETURN QUERY
  SELECT
    request.id,
    request.user_id,
    profile.full_name,
    profile.email,
    profile.date_of_birth,
    profile.avatar_url,
    COALESCE(freelancer.district, client.district, profile.city, profile.state, profile.country),
    COALESCE(freelancer.bio, client.description),
    COALESCE(array_to_string(freelancer.languages, ', '), client.required_skills::text),
    COALESCE(freelancer.education_summary, client.project_requirements),
    COALESCE(freelancer.current_status, freelancer.availability, client.experience_level),
    COALESCE(freelancer.availability, client.experience_level),
    COALESCE(freelancer.preferred_work_type, client.job_title),
    COALESCE(freelancer.portfolio_url, client.website),
    COALESCE(freelancer.certifications, client.description),
    request.document_type,
    request.document_path,
    request.selfie_path,
    student_document.storage_path,
    request.status::TEXT,
    request.created_at,
    request.admin_notes
  FROM public.identity_verification_requests request
  JOIN public.profiles profile ON profile.id = request.user_id
  LEFT JOIN public.freelancer_profiles freelancer ON freelancer.user_id = profile.id
  LEFT JOIN public.client_profiles client ON client.user_id = profile.id
  LEFT JOIN public.verification_documents student_document
    ON student_document.user_id = profile.id AND student_document.document_type = 'student_id'
  WHERE request.status = 'pending'
  ORDER BY request.created_at ASC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, auth;

DROP POLICY IF EXISTS "Admins read all jobs" ON public.jobs;
CREATE POLICY "Admins read all jobs"
  ON public.jobs
  FOR SELECT TO authenticated
  USING (public.is_platform_admin());

DROP POLICY IF EXISTS "Admins read all projects" ON public.projects;
CREATE POLICY "Admins read all projects"
  ON public.projects
  FOR SELECT TO authenticated
  USING (public.is_platform_admin());

DROP POLICY IF EXISTS "Admins read all transactions" ON public.transactions;
CREATE POLICY "Admins read all transactions"
  ON public.transactions
  FOR SELECT TO authenticated
  USING (public.is_platform_admin());

DROP POLICY IF EXISTS "Admins read all reports" ON public.reports;
CREATE POLICY "Admins read all reports"
  ON public.reports
  FOR SELECT TO authenticated
  USING (public.is_platform_admin());

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  selected_role user_type := COALESCE(NULLIF(NEW.raw_user_meta_data->>'user_type', ''), 'role_pending')::user_type;
BEGIN
  INSERT INTO public.profiles (
    id, email, full_name, phone, user_type, onboarding_status, date_of_birth,
    country, state, city, gender, profile_completion, account_status
  ) VALUES (
    NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.raw_user_meta_data->>'phone', selected_role, 'role_pending',
    NULLIF(NEW.raw_user_meta_data->>'date_of_birth', '')::date,
    NEW.raw_user_meta_data->>'country', NEW.raw_user_meta_data->>'state',
    NEW.raw_user_meta_data->>'city', NEW.raw_user_meta_data->>'gender', 0, 'active'
  );

  IF selected_role = 'client' THEN
    INSERT INTO public.client_profiles (
      user_id, company_name, organization_type, job_title, industry, website,
      description, district, city, required_skills, project_requirements,
      experience_level, budget_range
    ) VALUES (
      NEW.id, NEW.raw_user_meta_data->>'company_name', NEW.raw_user_meta_data->>'organization_type',
      NEW.raw_user_meta_data->>'job_title', NEW.raw_user_meta_data->>'industry',
      NULLIF(NEW.raw_user_meta_data->>'website', ''), NEW.raw_user_meta_data->>'company_description',
      NEW.raw_user_meta_data->>'state', NEW.raw_user_meta_data->>'city',
      ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'required_skills', '[]'::jsonb))),
      NEW.raw_user_meta_data->>'project_requirements', NEW.raw_user_meta_data->>'experience_level',
      NEW.raw_user_meta_data->>'budget_range'
    );
  ELSIF selected_role = 'freelancer' THEN
    INSERT INTO public.freelancer_profiles (
      user_id, title, bio, hourly_rate, district, city, languages, primary_skill,
      secondary_skills, years_experience, current_status, availability,
      education_summary, certifications, portfolio_url, website, other_profiles, status_details
    ) VALUES (
      NEW.id, NEW.raw_user_meta_data->>'headline', NEW.raw_user_meta_data->>'bio',
      NULLIF(NEW.raw_user_meta_data->>'hourly_rate', '')::numeric,
      NEW.raw_user_meta_data->>'state', NEW.raw_user_meta_data->>'city',
      ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'languages', '[]'::jsonb))),
      NEW.raw_user_meta_data->>'primary_skill',
      ARRAY(SELECT jsonb_array_elements_text(COALESCE(NEW.raw_user_meta_data->'secondary_skills', '[]'::jsonb))),
      NULLIF(NEW.raw_user_meta_data->>'years_experience', '')::numeric,
      NEW.raw_user_meta_data->>'current_status', NEW.raw_user_meta_data->>'availability',
      NEW.raw_user_meta_data->>'education', NEW.raw_user_meta_data->>'certifications',
      NULLIF(NEW.raw_user_meta_data->>'portfolio_url', ''), NULLIF(NEW.raw_user_meta_data->>'website', ''),
      NULLIF(NEW.raw_user_meta_data->>'other_profiles', ''),
      COALESCE(NEW.raw_user_meta_data->'status_details', '{}'::jsonb)
    );
  END IF;

  INSERT INTO public.wallets (user_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
