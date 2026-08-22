-- Role-safe profile updates for both marketplace sides.
ALTER TABLE public.freelancer_profiles
  ADD COLUMN IF NOT EXISTS preferred_work_type TEXT
    CHECK (preferred_work_type IN ('remote', 'onsite', 'hybrid'));

ALTER TABLE public.client_profiles
  ADD COLUMN IF NOT EXISTS company_size TEXT;

CREATE OR REPLACE FUNCTION public.update_my_profile(
  full_name_input TEXT DEFAULT NULL,
  country_input TEXT DEFAULT NULL,
  state_input TEXT DEFAULT NULL,
  city_input TEXT DEFAULT NULL,
  gender_input TEXT DEFAULT NULL,
  title_input TEXT DEFAULT NULL,
  bio_input TEXT DEFAULT NULL,
  primary_skill_input TEXT DEFAULT NULL,
  secondary_skills_input TEXT[] DEFAULT NULL,
  years_experience_input NUMERIC DEFAULT NULL,
  education_input TEXT DEFAULT NULL,
  certifications_input TEXT DEFAULT NULL,
  languages_input TEXT[] DEFAULT NULL,
  hourly_rate_input NUMERIC DEFAULT NULL,
  availability_input TEXT DEFAULT NULL,
  preferred_work_type_input TEXT DEFAULT NULL,
  company_name_input TEXT DEFAULT NULL,
  company_description_input TEXT DEFAULT NULL,
  industry_input TEXT DEFAULT NULL,
  website_input TEXT DEFAULT NULL,
  company_size_input TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  account_role user_type;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication is required';
  END IF;

  SELECT user_type INTO account_role FROM public.profiles WHERE id = auth.uid();
  IF account_role IS NULL OR account_role = 'admin' THEN
    RAISE EXCEPTION 'This account cannot update a marketplace profile';
  END IF;

  UPDATE public.profiles
  SET full_name = COALESCE(NULLIF(full_name_input, ''), full_name),
      country = COALESCE(NULLIF(country_input, ''), country),
      state = COALESCE(NULLIF(state_input, ''), state),
      city = COALESCE(NULLIF(city_input, ''), city),
      gender = COALESCE(NULLIF(gender_input, ''), gender)
  WHERE id = auth.uid();

  IF account_role = 'freelancer' THEN
    IF preferred_work_type_input IS NOT NULL
      AND preferred_work_type_input NOT IN ('remote', 'onsite', 'hybrid') THEN
      RAISE EXCEPTION 'Invalid preferred work type';
    END IF;
    UPDATE public.freelancer_profiles
    SET title = COALESCE(NULLIF(title_input, ''), title),
        bio = COALESCE(NULLIF(bio_input, ''), bio),
        primary_skill = COALESCE(NULLIF(primary_skill_input, ''), primary_skill),
        secondary_skills = COALESCE(secondary_skills_input, secondary_skills),
        years_experience = COALESCE(years_experience_input, years_experience),
        education_summary = COALESCE(NULLIF(education_input, ''), education_summary),
        certifications = COALESCE(NULLIF(certifications_input, ''), certifications),
        languages = COALESCE(languages_input, languages),
        hourly_rate = COALESCE(hourly_rate_input, hourly_rate),
        availability = COALESCE(NULLIF(availability_input, ''), availability),
        preferred_work_type = COALESCE(NULLIF(preferred_work_type_input, ''), preferred_work_type),
        city = COALESCE(NULLIF(city_input, ''), city)
    WHERE user_id = auth.uid();
  ELSE
    UPDATE public.client_profiles
    SET company_name = COALESCE(NULLIF(company_name_input, ''), company_name),
        description = COALESCE(NULLIF(company_description_input, ''), description),
        industry = COALESCE(NULLIF(industry_input, ''), industry),
        website = COALESCE(NULLIF(website_input, ''), website),
        company_size = COALESCE(NULLIF(company_size_input, ''), company_size),
        city = COALESCE(NULLIF(city_input, ''), city)
    WHERE user_id = auth.uid();
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.update_my_profile(
  TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT[], NUMERIC, TEXT,
  TEXT, TEXT[], NUMERIC, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT
) TO authenticated;
