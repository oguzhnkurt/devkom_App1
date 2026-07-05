-- =============================================
-- FIX USERS INSERT POLICY FOR REGISTRATION
-- =============================================

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Users can insert own profile" ON users;

-- Create new policy that allows both authenticated and anon users to insert
-- This is needed during registration when user just signed up but INSERT happens before session is fully established
CREATE POLICY "Users can insert own profile during signup"
ON users FOR INSERT
TO public  -- Allow both authenticated and anon
WITH CHECK (auth.uid() = id);

-- Also ensure view policy works for everyone
DROP POLICY IF EXISTS "Users can view all profiles" ON users;

CREATE POLICY "Users can view all profiles"
ON users FOR SELECT
TO public  -- Allow both authenticated and anon
USING (true);
