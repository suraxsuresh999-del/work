-- Complete registration data, private verification documents, and role-safe access.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS date_of_birth DATE,
  ADD COLUMN IF NOT EXISTS country TEXT,
  ADD COLUMN IF NOT EXISTS state TEXT,
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS gender TEXT,
  ADD COLUMN IF NOT EXISTS profile_completion SMALLINT NOT NULL DEFAULT 0
    CHECK (profile_completion BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS account_status TEXT NOT NULL DEFAULT 'active'
    CHECK (account_status IN ('active', 'suspended', 'pending_review'));

ALTER TABLE public.client_profiles
  ADD COLUMN IF NOT EXISTS organization_type TEXT,
  ADD COLUMN IF NOT EXISTS job_title TEXT,
  ADD COLUMN IF NOT EXISTS required_skills TEXT[],
  ADD COLUMN IF NOT EXISTS project_requirements TEXT,
  ADD COLUMN IF NOT EXISTS experience_level TEXT,
  ADD COLUMN IF NOT EXISTS budget_range TEXT;

ALTER TABLE public.freelancer_profiles
  ADD COLUMN IF NOT EXISTS primary_skill TEXT,
  ADD COLUMN IF NOT EXISTS secondary_skills TEXT[],
  ADD COLUMN IF NOT EXISTS years_experience NUMERIC(4,1),
  ADD COLUMN IF NOT EXISTS current_status TEXT,
  ADD COLUMN IF NOT EXISTS availability TEXT,
  ADD COLUMN IF NOT EXISTS education_summary TEXT,
  ADD COLUMN IF NOT EXISTS certifications TEXT,
  ADD COLUMN IF NOT EXISTS portfolio_url TEXT,
  ADD COLUMN IF NOT EXISTS website TEXT,
  ADD COLUMN IF NOT EXISTS other_profiles TEXT,
  ADD COLUMN IF NOT EXISTS status_details JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE TABLE IF NOT EXISTS public.verification_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  status verification_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, document_type)
);

ALTER TABLE public.verification_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own verification documents" ON public.verification_documents;
CREATE POLICY "Users view own verification documents" ON public.verification_documents
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Admins view verification documents" ON public.verification_documents;
CREATE POLICY "Admins view verification documents" ON public.verification_documents
  FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.user_type = 'admin'));

-- The bucket is private. Object policies deliberately grant access only to the owner folder.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('verification-documents', 'verification-documents', false, 5242880,
  ARRAY['image/jpeg', 'image/png', 'application/pdf'])
ON CONFLICT (id) DO UPDATE SET public = false, file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Owners read private verification files" ON storage.objects;
CREATE POLICY "Owners read private verification files" ON storage.objects FOR SELECT
  USING (bucket_id = 'verification-documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Populate full profile records from the server-validated registration payload.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  selected_role user_type := COALESCE(NEW.raw_user_meta_data->>'user_type', 'freelancer')::user_type;
BEGIN
  INSERT INTO public.profiles (
    id, email, full_name, phone, user_type, onboarding_status, date_of_birth,
    country, state, city, gender, profile_completion, account_status
  ) VALUES (
    NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.raw_user_meta_data->>'phone', selected_role, 'active',
    NULLIF(NEW.raw_user_meta_data->>'date_of_birth', '')::date,
    NEW.raw_user_meta_data->>'country', NEW.raw_user_meta_data->>'state',
    NEW.raw_user_meta_data->>'city', NEW.raw_user_meta_data->>'gender', 100, 'active'
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
  ELSE
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

-- Dashboard/profile reads can never be used to change a role or account status.
REVOKE UPDATE ON public.profiles FROM authenticated;
GRANT UPDATE (full_name, avatar_url, date_of_birth, country, state, city, gender) ON public.profiles TO authenticated;
