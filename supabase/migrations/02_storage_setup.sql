-- =============================================
-- STORAGE BUCKETS & POLICIES
-- =============================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('chat-images', 'chat-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('homework-submissions', 'homework-submissions', false, 52428800, ARRAY['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'video/mp4', 'video/quicktime']),
  ('post-media', 'post-media', true, 52428800, ARRAY['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'video/mp4']),
  ('profile-pictures', 'profile-pictures', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('portfolio-images', 'portfolio-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('arduino-thumbnails', 'arduino-thumbnails', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/gif']),
  ('voice-messages', 'voice-messages', false, 10485760, ARRAY['audio/mpeg', 'audio/ogg', 'audio/wav', 'audio/mp4'])
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- STORAGE POLICIES - CHAT IMAGES
-- =============================================

CREATE POLICY "Authenticated users can view chat images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'chat-images');

CREATE POLICY "Users can upload chat images to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'chat-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own chat images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'chat-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- STORAGE POLICIES - HOMEWORK SUBMISSIONS
-- =============================================

CREATE POLICY "Teachers and submitters can view homework files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'homework-submissions' AND
  (
    (storage.foldername(name))[1] = auth.uid()::text OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin')) OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
        AND role = 'parent'
        AND (storage.foldername(name))[1] = ANY(student_ids::text[])
    )
  )
);

CREATE POLICY "Users can upload homework files to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'homework-submissions' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own homework files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'homework-submissions' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- STORAGE POLICIES - POST MEDIA
-- =============================================

CREATE POLICY "Everyone can view post media"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'post-media');

CREATE POLICY "Users can upload post media to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'post-media' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own post media, admins can delete any"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-media' AND
  (
    (storage.foldername(name))[1] = auth.uid()::text OR
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  )
);

-- =============================================
-- STORAGE POLICIES - PROFILE PICTURES
-- =============================================

CREATE POLICY "Everyone can view profile pictures"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'profile-pictures');

CREATE POLICY "Users can upload their own profile picture"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own profile picture"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own profile picture"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- STORAGE POLICIES - PORTFOLIO IMAGES
-- =============================================

CREATE POLICY "Everyone can view portfolio images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'portfolio-images');

CREATE POLICY "Teachers can upload portfolio images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'portfolio-images' AND
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

CREATE POLICY "Teachers can delete portfolio images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'portfolio-images' AND
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('teacher', 'admin'))
);

-- =============================================
-- STORAGE POLICIES - ARDUINO THUMBNAILS
-- =============================================

CREATE POLICY "Everyone can view arduino thumbnails"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'arduino-thumbnails');

CREATE POLICY "Users can upload arduino thumbnails to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'arduino-thumbnails' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own arduino thumbnails"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'arduino-thumbnails' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- STORAGE POLICIES - VOICE MESSAGES
-- =============================================

CREATE POLICY "Users can view voice messages where they are sender or receiver"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'voice-messages' AND
  (
    (storage.foldername(name))[1] = auth.uid()::text OR
    (storage.foldername(name))[2] = auth.uid()::text
  )
);

CREATE POLICY "Users can upload voice messages to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'voice-messages' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own voice messages"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'voice-messages' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON POLICY "Authenticated users can view chat images" ON storage.objects IS 'All authenticated users can view chat images';
COMMENT ON POLICY "Users can upload chat images to their own folder" ON storage.objects IS 'Users can only upload to their own user ID folder';
COMMENT ON POLICY "Teachers and submitters can view homework files" ON storage.objects IS 'Students can view their own, teachers can view all, parents can view their children''s';
