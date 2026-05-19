-- ============================================================
-- TPG316C Group Assignment — Supabase Database Schema
-- Student Assistant Application System
-- ============================================================
-- Run this SQL in your Supabase SQL Editor to set up the database.
-- ============================================================

-- ─── 1. USER PROFILES TABLE ─────────────────────────────────────────────────
-- Stores role info (student / admin) linked to auth.users
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  role        TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  full_name   TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create a profile on new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ─── 2. APPLICATIONS TABLE ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.applications (
  id                  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id             UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  student_name        TEXT NOT NULL,
  student_email       TEXT NOT NULL,
  year_of_study       INTEGER NOT NULL CHECK (year_of_study BETWEEN 1 AND 3),

  -- Module 1 (required)
  module1_level       TEXT NOT NULL,
  module1_code        TEXT NOT NULL,
  module1_name        TEXT NOT NULL,

  -- Module 2 (optional)
  module2_level       TEXT,
  module2_code        TEXT,
  module2_name        TEXT,

  -- Eligibility
  meets_requirements  BOOLEAN NOT NULL DEFAULT FALSE,
  document_url        TEXT,
  document_name       TEXT DEFAULT '',

  -- Status workflow
  status              TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_comment       TEXT,

  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW(),

  -- One application per student
  CONSTRAINT one_application_per_student UNIQUE (user_id)
);

-- Updated_at auto-update trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_applications_updated_at ON public.applications;
CREATE TRIGGER set_applications_updated_at
  BEFORE UPDATE ON public.applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── 3. ROW LEVEL SECURITY (RLS) ────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications  ENABLE ROW LEVEL SECURITY;

-- user_profiles: users can only read their own profile
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = user_id);

-- applications: students can only see/manage their own application
CREATE POLICY "Students can view own application"
  ON public.applications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Students can insert own application"
  ON public.applications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students can update own pending application"
  ON public.applications FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Students can delete own pending application"
  ON public.applications FOR DELETE
  USING (auth.uid() = user_id AND status = 'pending');

-- Admin policies: admins can access ALL applications
CREATE POLICY "Admins can view all applications"
  ON public.applications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update any application"
  ON public.applications FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete any application"
  ON public.applications FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- ─── 4. STORAGE BUCKET ───────────────────────────────────────────────────────
-- Run in Supabase Storage Settings or via SQL:
INSERT INTO storage.buckets (id, name, public)
VALUES ('application_documents', 'application_documents', false)
ON CONFLICT DO NOTHING;

-- Storage policy: only authenticated users can upload
CREATE POLICY "Auth users can upload documents"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'application_documents' AND auth.role() = 'authenticated');

-- Storage policy: users can only access their own documents (by path prefix)
CREATE POLICY "Users can view own documents"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'application_documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ─── 5. SAMPLE ADMIN ACCOUNT SETUP ──────────────────────────────────────────
-- After creating an admin user via Supabase Auth, run:
-- UPDATE public.user_profiles SET role = 'admin' WHERE user_id = '<admin_user_uuid>';

-- ─── 6. USEFUL QUERIES ───────────────────────────────────────────────────────
-- View all applications with user info:
-- SELECT a.*, u.role FROM applications a JOIN user_profiles u ON a.user_id = u.user_id;

-- Count by status:
-- SELECT status, COUNT(*) FROM applications GROUP BY status;
