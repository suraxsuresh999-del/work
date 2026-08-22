-- WorkSphere Initial Schema Migration
-- Designed for PostgreSQL on Supabase

-- ─── EXTENSIONS ───────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── ENUMS ────────────────────────────────────────────────────
CREATE TYPE user_type AS ENUM ('freelancer', 'client', 'admin');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'approved', 'rejected', 'reupload_required');
CREATE TYPE job_status AS ENUM ('draft', 'open', 'paused', 'in_progress', 'closed', 'completed', 'cancelled');
CREATE TYPE application_status AS ENUM ('pending', 'shortlisted', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE project_status AS ENUM ('pending', 'active', 'on_hold', 'completed', 'cancelled', 'disputed');
CREATE TYPE milestone_status AS ENUM ('pending', 'in_progress', 'submitted', 'approved', 'revision_required', 'completed');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled');
CREATE TYPE message_type AS ENUM ('text', 'image', 'document', 'voice_note', 'system');
CREATE TYPE transaction_type AS ENUM ('credit', 'debit', 'withdrawal', 'refund');
CREATE TYPE notification_type AS ENUM ('job_posted', 'application_received', 'application_accepted', 'application_rejected', 'message', 'payment', 'milestone_update', 'review', 'verification', 'system');

-- ─── CORE TABLES ──────────────────────────────────────────────

-- 1. Profiles (Base User Data, extends auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    avatar_url TEXT,
    user_type user_type NOT NULL DEFAULT 'freelancer',
    verification_status verification_status NOT NULL DEFAULT 'unverified',
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Freelancer Profiles (Extended Data)
CREATE TABLE freelancer_profiles (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT,
    bio TEXT,
    hourly_rate NUMERIC(10, 2),
    district TEXT,
    city TEXT,
    languages TEXT[],
    is_available BOOLEAN DEFAULT TRUE,
    total_earnings NUMERIC(12, 2) DEFAULT 0,
    jobs_completed INTEGER DEFAULT 0,
    rating NUMERIC(3, 2) DEFAULT 0.0,
    reviews_count INTEGER DEFAULT 0,
    resume_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Client Profiles (Extended Data)
CREATE TABLE client_profiles (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    company_name TEXT,
    industry TEXT,
    description TEXT,
    website TEXT,
    district TEXT,
    city TEXT,
    total_spent NUMERIC(12, 2) DEFAULT 0,
    jobs_posted INTEGER DEFAULT 0,
    rating NUMERIC(3, 2) DEFAULT 0.0,
    reviews_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── CATEGORIES & SKILLS ──────────────────────────────────────

-- 4. Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    icon_url TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Skills Master List
CREATE TABLE skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Freelancer Skills (Junction Table)
CREATE TABLE freelancer_skills (
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (freelancer_id, skill_id)
);

-- ─── FREELANCER PORTFOLIO & DETAILS ───────────────────────────

-- 7. Portfolio Items
CREATE TABLE portfolio_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    image_urls TEXT[],
    project_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Experience
CREATE TABLE experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    company TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Education
CREATE TABLE education (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    degree TEXT NOT NULL,
    institution TEXT NOT NULL,
    start_year INTEGER NOT NULL,
    end_year INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── JOBS & APPLICATIONS ──────────────────────────────────────

-- 10. Jobs
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES client_profiles(user_id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    budget_min NUMERIC(10, 2),
    budget_max NUMERIC(10, 2),
    is_fixed_price BOOLEAN DEFAULT TRUE,
    duration_text TEXT,
    experience_level TEXT,
    required_skills UUID[],
    location_preference TEXT, -- e.g., 'Tamil Nadu', 'Chennai', 'Remote'
    status job_status NOT NULL DEFAULT 'open',
    proposals_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Job Applications (Proposals)
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    cover_letter TEXT NOT NULL,
    bid_amount NUMERIC(10, 2) NOT NULL,
    estimated_duration TEXT,
    attachments TEXT[],
    status application_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(job_id, freelancer_id)
);

-- 12. Saved Jobs
CREATE TABLE saved_jobs (
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE CASCADE,
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (freelancer_id, job_id)
);

-- ─── PROJECTS & MILESTONES ────────────────────────────────────

-- 13. Projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES jobs(id) ON DELETE SET NULL,
    client_id UUID REFERENCES client_profiles(user_id) ON DELETE RESTRICT,
    freelancer_id UUID REFERENCES freelancer_profiles(user_id) ON DELETE RESTRICT,
    title TEXT NOT NULL,
    description TEXT,
    total_amount NUMERIC(12, 2) NOT NULL,
    amount_paid NUMERIC(12, 2) DEFAULT 0,
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deadline TIMESTAMPTZ,
    status project_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. Milestones
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    amount NUMERIC(10, 2) NOT NULL,
    deadline TIMESTAMPTZ,
    status milestone_status NOT NULL DEFAULT 'pending',
    submission_notes TEXT,
    submission_files TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── CHAT & MESSAGING ─────────────────────────────────────────

-- 15. Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. Conversation Participants
CREATE TABLE conversation_participants (
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    last_read_at TIMESTAMPTZ,
    PRIMARY KEY (conversation_id, user_id)
);

-- 17. Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT,
    message_type message_type NOT NULL DEFAULT 'text',
    attachment_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── PAYMENTS & WALLET ────────────────────────────────────────

-- 18. Wallets
CREATE TABLE wallets (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'INR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 19. Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID REFERENCES wallets(user_id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    type transaction_type NOT NULL,
    reference_id TEXT, -- e.g., Razorpay Payment ID, Milestone ID
    description TEXT,
    status payment_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. Payments (Platform logic)
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES profiles(id) ON DELETE RESTRICT,
    freelancer_id UUID REFERENCES profiles(id) ON DELETE RESTRICT,
    milestone_id UUID REFERENCES milestones(id) ON DELETE SET NULL,
    amount NUMERIC(10, 2) NOT NULL,
    platform_fee NUMERIC(10, 2) NOT NULL,
    gst_amount NUMERIC(10, 2) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    status payment_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── REVIEWS & NOTIFICATIONS ──────────────────────────────────

-- 21. Reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reviewee_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 22. Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── IDENTITY VERIFICATION ────────────────────────────────────

-- 23. Verification Requests
CREATE TABLE verification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL, -- e.g., 'aadhaar', 'pan'
    document_url TEXT NOT NULL,
    selfie_url TEXT NOT NULL,
    status verification_status NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ─── FUNCTIONS & TRIGGERS ─────────────────────────────────────

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update_updated_at_column trigger to all relevant tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_freelancer_profiles_updated_at BEFORE UPDATE ON freelancer_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_client_profiles_updated_at BEFORE UPDATE ON client_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON job_applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_milestones_updated_at BEFORE UPDATE ON milestones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  -- Insert base profile
  INSERT INTO public.profiles (id, email, full_name, user_type)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    CAST(COALESCE(NEW.raw_user_meta_data->>'user_type', 'freelancer') AS user_type)
  );

  -- Insert specific profile based on user_type
  IF NEW.raw_user_meta_data->>'user_type' = 'client' THEN
    INSERT INTO public.client_profiles (user_id) VALUES (NEW.id);
  ELSE
    INSERT INTO public.freelancer_profiles (user_id) VALUES (NEW.id);
  END IF;

  -- Create wallet
  INSERT INTO public.wallets (user_id) VALUES (NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ─── ROW LEVEL SECURITY (RLS) ─────────────────────────────────

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE freelancer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE freelancer_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE education ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone can read, users can update their own
CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile." ON profiles FOR UPDATE USING (auth.uid() = id);

-- Freelancer Profiles: Anyone can read, owners can update
CREATE POLICY "Public freelancer profiles are viewable by everyone." ON freelancer_profiles FOR SELECT USING (true);
CREATE POLICY "Freelancers can update own profile." ON freelancer_profiles FOR UPDATE USING (auth.uid() = user_id);

-- Client Profiles: Anyone can read, owners can update
CREATE POLICY "Public client profiles are viewable by everyone." ON client_profiles FOR SELECT USING (true);
CREATE POLICY "Clients can update own profile." ON client_profiles FOR UPDATE USING (auth.uid() = user_id);

-- Master Data (Categories, Skills): Anyone can read, only admin can write
CREATE POLICY "Categories are viewable by everyone." ON categories FOR SELECT USING (true);
CREATE POLICY "Skills are viewable by everyone." ON skills FOR SELECT USING (true);

-- Jobs: Anyone can read open jobs, clients can manage their own jobs
CREATE POLICY "Open jobs are viewable by everyone." ON jobs FOR SELECT USING (status = 'open' OR auth.uid() = client_id);
CREATE POLICY "Clients can insert jobs." ON jobs FOR INSERT WITH CHECK (auth.uid() = client_id);
CREATE POLICY "Clients can update own jobs." ON jobs FOR UPDATE USING (auth.uid() = client_id);

-- Job Applications: Clients can read applications for their jobs, freelancers can read/manage their own
CREATE POLICY "Clients can view applications for their jobs." ON job_applications FOR SELECT USING (
    EXISTS (SELECT 1 FROM jobs WHERE jobs.id = job_applications.job_id AND jobs.client_id = auth.uid())
);
CREATE POLICY "Freelancers can view own applications." ON job_applications FOR SELECT USING (auth.uid() = freelancer_id);
CREATE POLICY "Freelancers can insert applications." ON job_applications FOR INSERT WITH CHECK (auth.uid() = freelancer_id);
CREATE POLICY "Freelancers can update own applications." ON job_applications FOR UPDATE USING (auth.uid() = freelancer_id);

-- Projects: Only participants (client/freelancer) can read/update
CREATE POLICY "Participants can view their projects." ON projects FOR SELECT USING (auth.uid() = client_id OR auth.uid() = freelancer_id);
CREATE POLICY "Clients can update projects." ON projects FOR UPDATE USING (auth.uid() = client_id);
CREATE POLICY "Freelancers can update their assigned projects." ON projects FOR UPDATE USING (auth.uid() = freelancer_id);

-- Messages: Only participants can read/insert
CREATE POLICY "Participants can view messages." ON messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_id = auth.uid())
);
CREATE POLICY "Participants can insert messages." ON messages FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_id = auth.uid())
);

-- Wallets: Users can only read their own wallet
CREATE POLICY "Users can view own wallet." ON wallets FOR SELECT USING (auth.uid() = user_id);

-- Notifications: Users can only read/update their own notifications
CREATE POLICY "Users can view own notifications." ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications." ON notifications FOR UPDATE USING (auth.uid() = user_id);
