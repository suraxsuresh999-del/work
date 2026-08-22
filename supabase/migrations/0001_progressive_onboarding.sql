-- Progressive marketplace onboarding. Run after 0000_initial_schema.sql.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_status TEXT NOT NULL DEFAULT 'role_pending'
  CHECK (onboarding_status IN ('role_pending', 'profile_pending', 'active'));

-- Preserve completed legacy profiles; incomplete records resume role selection.
UPDATE public.profiles p
SET onboarding_status = CASE
  WHEN p.user_type = 'freelancer'::user_type AND EXISTS (
    SELECT 1 FROM public.freelancer_profiles fp
    WHERE fp.user_id = p.id AND fp.title IS NOT NULL AND fp.bio IS NOT NULL
  ) THEN 'active'
  WHEN p.user_type = 'client'::user_type AND EXISTS (
    SELECT 1 FROM public.client_profiles cp
    WHERE cp.user_id = p.id AND cp.company_name IS NOT NULL
  ) THEN 'active'
  ELSE 'role_pending'
END;

-- New accounts get only a base profile. Their role profile is created after
-- explicit role selection, not from an untrusted client-side default.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, onboarding_status)
  VALUES (
    NEW.id, 
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    'role_pending'
  );
  INSERT INTO public.wallets (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.select_account_type(selected_role TEXT)
RETURNS VOID AS $$
DECLARE
  chosen_role user_type;
BEGIN
  IF auth.uid() IS NULL OR selected_role NOT IN ('freelancer', 'client') THEN
    RAISE EXCEPTION 'Invalid account type';
  END IF;
  chosen_role := selected_role::user_type;

  UPDATE public.profiles
  SET user_type = chosen_role, onboarding_status = 'profile_pending'
  WHERE id = auth.uid() AND onboarding_status = 'role_pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account type has already been selected';
  END IF;

  IF chosen_role = 'client' THEN
    INSERT INTO public.client_profiles (user_id) VALUES (auth.uid()) ON CONFLICT DO NOTHING;
  ELSE
    INSERT INTO public.freelancer_profiles (user_id) VALUES (auth.uid()) ON CONFLICT DO NOTHING;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.complete_client_onboarding(
  company_name_input TEXT, district_input TEXT, description_input TEXT
)
RETURNS VOID AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND user_type = 'client' AND onboarding_status = 'profile_pending'
  ) THEN RAISE EXCEPTION 'Client onboarding is not available'; END IF;

  UPDATE public.client_profiles
  SET company_name = company_name_input, district = district_input, description = description_input
  WHERE user_id = auth.uid();
  UPDATE public.profiles SET onboarding_status = 'active' WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.complete_freelancer_onboarding(
  title_input TEXT, bio_input TEXT, hourly_rate_input NUMERIC, district_input TEXT, languages_input TEXT[]
)
RETURNS VOID AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND user_type = 'freelancer' AND onboarding_status = 'profile_pending'
  ) THEN RAISE EXCEPTION 'Freelancer onboarding is not available'; END IF;

  UPDATE public.freelancer_profiles
  SET title = title_input, bio = bio_input, hourly_rate = hourly_rate_input,
      district = district_input, languages = languages_input, is_available = TRUE
  WHERE user_id = auth.uid();
  UPDATE public.profiles SET onboarding_status = 'active' WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.sync_verified_phone()
RETURNS VOID AS $$
DECLARE
  verified_phone TEXT;
BEGIN
  SELECT phone INTO verified_phone
  FROM auth.users
  WHERE id = auth.uid() AND phone_confirmed_at IS NOT NULL;

  IF verified_phone IS NULL THEN
    RAISE EXCEPTION 'Phone verification is incomplete';
  END IF;

  UPDATE public.profiles
  SET phone = verified_phone, is_phone_verified = TRUE
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE UPDATE ON public.profiles FROM authenticated;
GRANT UPDATE (full_name, avatar_url) ON public.profiles TO authenticated;
GRANT EXECUTE ON FUNCTION public.select_account_type(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_client_onboarding(TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_freelancer_onboarding(TEXT, TEXT, NUMERIC, TEXT, TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.sync_verified_phone() TO authenticated;
