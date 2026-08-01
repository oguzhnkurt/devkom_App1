-- =============================================
-- AUTO-CREATE USER PROFILE ON SIGNUP
-- Fixes: "new row violates row-level security policy for table users" (42501)
-- =============================================
--
-- Root cause: the Flutter app calls `supabase.auth.signUp()` and then
-- immediately does a client-side INSERT into public.users. If the Supabase
-- project has "Confirm email" enabled (the default for new projects),
-- signUp() does NOT return an active session until the user clicks the
-- confirmation link. Without a session, the INSERT request is sent with
-- no JWT, so auth.uid() is NULL on the server, and the RLS check
-- (auth.uid() = id) always evaluates to false/NULL -> the insert is
-- rejected with error 42501, regardless of which role the policy targets.
--
-- Fix: create the profile row server-side via a SECURITY DEFINER trigger
-- on auth.users, which runs with elevated privileges and bypasses RLS.
-- This is the pattern recommended by Supabase for this exact issue and
-- works whether or not email confirmation is enabled.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    display_name,
    role,
    age_group,
    parent_id,
    created_at,
    last_login_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'role', '')::user_role, 'student'),
    NULLIF(NEW.raw_user_meta_data->>'age_group', '')::age_group,
    NULLIF(NEW.raw_user_meta_data->>'parent_id', '')::uuid,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Keep a permissive insert policy too, for the case where a session IS
-- already active right after signUp (email confirmation disabled) and the
-- client performs its own upsert - this makes that path idempotent instead
-- of erroring on the row the trigger already created.
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;

CREATE POLICY "Users can insert own profile during signup"
ON users FOR INSERT
TO public
WITH CHECK (auth.uid() = id);
