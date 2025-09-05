-- Note: RLS is already enabled on storage.objects table by default in Supabase
-- We don't need to modify the table structure, only create policies

-- ============================================================================
-- 3. صلاحيات bucket travel_guides / travel_guides bucket policies
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated users to upload travel guide images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to travel guide images" ON storage.objects;
DROP POLICY IF EXISTS "Allow admin to manage travel guide images" ON storage.objects;

-- Policy 1: Allow authenticated users to upload images to travel_guides bucket
CREATE POLICY "Allow authenticated users to upload travel guide images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'travel_guides' AND
    auth.role() = 'authenticated'
  );

-- Policy 2: Allow public read access to travel guide images
CREATE POLICY "Allow public read access to travel guide images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'travel_guides'
  );

-- Policy 3: Allow admin to manage (update/delete) travel guide images
CREATE POLICY "Allow admin to manage travel guide images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'travel_guides' AND
    (
      auth.uid()::text = owner OR
      EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.users.id = auth.uid() 
        AND auth.users.email = 'admin@rizervitoo.dz'
      )
    )
  );

-- ============================================================================
-- 4. صلاحيات bucket accommodation-images / accommodation-images bucket policies
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated users to upload accommodation images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to accommodation images" ON storage.objects;
DROP POLICY IF EXISTS "Allow owners to manage accommodation images" ON storage.objects;

-- Policy 1: Allow authenticated users to upload accommodation images
CREATE POLICY "Allow authenticated users to upload accommodation images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'accommodation-images' AND
    auth.role() = 'authenticated'
  );

-- Policy 2: Allow public read access to accommodation images
CREATE POLICY "Allow public read access to accommodation images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'accommodation-images'
  );

-- Policy 3: Allow owners to manage their accommodation images
CREATE POLICY "Allow owners to manage accommodation images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'accommodation-images' AND
    auth.uid()::text = owner
  );

-- ============================================================================
-- 5. صلاحيات bucket avatars / avatars bucket policies
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow users to upload their avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to manage their avatars" ON storage.objects;

-- Policy 1: Allow users to upload their own avatars
CREATE POLICY "Allow users to upload their avatars" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    auth.uid()::text = owner
  );

-- Policy 2: Allow public read access to avatars
CREATE POLICY "Allow public read access to avatars" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars'
  );

-- Policy 3: Allow users to manage their own avatars
CREATE POLICY "Allow users to manage their avatars" ON storage.objects
  FOR ALL USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = owner
  );

-- ============================================================================
-- 6. صلاحيات bucket reviews / reviews bucket policies
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow users to upload review images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to review images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to manage their review images" ON storage.objects;

-- Policy 1: Allow users to upload review images
CREATE POLICY "Allow users to upload review images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'reviews' AND
    auth.role() = 'authenticated' AND
    auth.uid()::text = owner
  );

-- Policy 2: Allow public read access to review images
CREATE POLICY "Allow public read access to review images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'reviews'
  );

-- Policy 3: Allow users to manage their own review images
CREATE POLICY "Allow users to manage their review images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'reviews' AND
    auth.uid()::text = owner
  );

-- ============================================================================
-- 7. التحقق من الصلاحيات / Verify policies
-- ============================================================================

-- Check all storage policies
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
ORDER BY policyname;

--