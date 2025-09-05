-- إصلاح شامل للمشاكل المتبقية (محدث)
-- Comprehensive fix for remaining issues (Updated)
-- 1. Storage RLS policies (رفع الصور)
-- 2. Travel agencies RLS policies (إنشاء الوكالات)
-- 3. Users table permissions (جلب التقييمات قيد المراجعة)
-- Fixed: UUID comparison issues

-- معرف المدير الصحيح
-- Correct admin UUID
-- Admin ID: 78abcc88-0d36-4b5a-bb8f-809db1dfe10c

-- ============================================================================
-- 1. إصلاح سياسات التخزين / Fix Storage RLS Policies
-- ============================================================================

-- حذف السياسات الموجودة للتخزين
-- Drop existing storage policies
DROP POLICY IF EXISTS "Allow authenticated users to upload travel guide images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to travel guide images" ON storage.objects;
DROP POLICY IF EXISTS "Allow admin to manage travel guide images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload accommodation images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to accommodation images" ON storage.objects;
DROP POLICY IF EXISTS "Allow owners to manage accommodation images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to upload their avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to manage their avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to upload review images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access to review images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to manage their review images" ON storage.objects;

-- سياسات bucket travel_guides
-- Travel guides bucket policies
CREATE POLICY "Allow authenticated users to upload travel guide images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'travel_guides' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow public read access to travel guide images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'travel_guides'
  );

CREATE POLICY "Allow admin to manage travel guide images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'travel_guides' AND
    (
      auth.uid() = owner OR
      auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
      auth.jwt() ->> 'role' = 'admin'
    )
  );

-- سياسات bucket accommodation-images
-- Accommodation images bucket policies
CREATE POLICY "Allow authenticated users to upload accommodation images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'accommodation-images' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow public read access to accommodation images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'accommodation-images'
  );

CREATE POLICY "Allow owners to manage accommodation images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'accommodation-images' AND
    (
      auth.uid() = owner OR
      auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
      auth.jwt() ->> 'role' = 'admin'
    )
  );

-- سياسات bucket avatars
-- Avatars bucket policies
CREATE POLICY "Allow users to upload their avatars" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    auth.uid() = owner
  );

CREATE POLICY "Allow public read access to avatars" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'avatars'
  );

CREATE POLICY "Allow users to manage their avatars" ON storage.objects
  FOR ALL USING (
    bucket_id = 'avatars' AND
    (
      auth.uid() = owner OR
      auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
      auth.jwt() ->> 'role' = 'admin'
    )
  );

-- سياسات bucket reviews
-- Reviews bucket policies
CREATE POLICY "Allow users to upload review images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'reviews' AND
    auth.role() = 'authenticated' AND
    auth.uid() = owner
  );

CREATE POLICY "Allow public read access to review images" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'reviews'
  );

CREATE POLICY "Allow users to manage their review images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'reviews' AND
    (
      auth.uid() = owner OR
      auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
      auth.jwt() ->> 'role' = 'admin'
    )
  );

-- ============================================================================
-- 2. إصلاح سياسات الوكالات السياحية / Fix Travel Agencies RLS Policies
-- ============================================================================

-- التأكد من أن السياسات الصحيحة موجودة للوكالات السياحية
-- Ensure correct policies exist for travel agencies

-- حذف السياسات المتضاربة إذا كانت موجودة
-- Drop conflicting policies if they exist
DROP POLICY IF EXISTS "Admin can insert travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can update travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can delete travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can view all travel agencies" ON travel_agencies;

DROP POLICY IF EXISTS "Admin can insert offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can update offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can delete offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can view all offers" ON travel_agency_offers;

-- إنشاء السياسات الصحيحة للوكالات السياحية
-- Create correct policies for travel agencies
CREATE POLICY "Admin can insert travel agencies" ON travel_agencies
    FOR INSERT WITH CHECK (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can update travel agencies" ON travel_agencies
    FOR UPDATE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can delete travel agencies" ON travel_agencies
    FOR DELETE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can view all travel agencies" ON travel_agencies
    FOR SELECT USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

-- إنشاء السياسات الصحيحة لعروض الوكالات السياحية
-- Create correct policies for travel agency offers
CREATE POLICY "Admin can insert offers" ON travel_agency_offers
    FOR INSERT WITH CHECK (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can update offers" ON travel_agency_offers
    FOR UPDATE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can delete offers" ON travel_agency_offers
    FOR DELETE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can view all offers" ON travel_agency_offers
    FOR SELECT USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

-- ============================================================================
-- 3. إصلاح صلاحيات جدول المستخدمين / Fix Users Table Permissions
-- ============================================================================

-- التأكد من وجود دالة get_users_with_email وأنها تعمل بشكل صحيح
-- Ensure get_users_with_email function exists and works correctly

DROP FUNCTION IF EXISTS get_users_with_email();

CREATE OR REPLACE FUNCTION get_users_with_email()
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    avatar_url TEXT,
    date_of_birth DATE,
    nationality TEXT,
    preferred_language TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
SECURITY DEFINER
AS $$
BEGIN
    -- التحقق من أن المستخدم هو المدير
    -- Check if user is admin
    IF auth.uid() != '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid AND auth.jwt() ->> 'role' != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin role required.';
    END IF;
    
    -- إرجاع بيانات المستخدمين مع البريد الإلكتروني
    -- Return user data with email
    RETURN QUERY
    SELECT 
        p.id,
        p.full_name,
        au.email,
        p.phone,
        p.avatar_url,
        p.date_of_birth,
        p.nationality,
        p.preferred_language,
        p.is_active,
        p.created_at,
        p.updated_at
    FROM profiles p
    JOIN auth.users au ON p.id = au.id
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- منح الصلاحيات للدالة
-- Grant permissions to the function
GRANT EXECUTE ON FUNCTION get_users_with_email() TO authenticated;

-- ============================================================================
-- 4. إضافة سياسات للتقييمات إذا لم تكن موجودة / Add Reviews Policies if Missing
-- ============================================================================

-- التأكد من وجود سياسات للمدير للتقييمات
-- Ensure admin policies exist for reviews
DROP POLICY IF EXISTS "Admin can view all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can update all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can delete reviews" ON reviews;

CREATE POLICY "Admin can view all reviews" ON reviews
    FOR SELECT USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can update all reviews" ON reviews
    FOR UPDATE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

CREATE POLICY "Admin can delete reviews" ON reviews
    FOR DELETE USING (
        auth.uid() = '78abcc88-0d36-4b5a-bb8f-809db1dfe10c'::uuid OR
        auth.jwt() ->> 'role' = 'admin'
    );

-- ============================================================================
-- 5. التحقق من النتائج / Verify Results
-- ============================================================================

-- فحص سياسات التخزين
-- Check storage policies
SELECT 
    'Storage Policies' as category,
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
ORDER BY policyname;

-- فحص سياسات الوكالات السياحية
-- Check travel agencies policies
SELECT 
    'Travel Agencies Policies' as category,
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename IN ('travel_agencies', 'travel_agency_offers')
ORDER BY tablename, policyname;

-- فحص سياسات التقييمات
-- Check reviews policies
SELECT 
    'Reviews Policies' as category,
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE tablename = 'reviews'
ORDER BY policyname;

-- اختبار دالة get_users_with_email
-- Test get_users_with_email function
SELECT 'Function Test' as category, 'get_users_with_email function exists' as status
WHERE EXISTS (
    SELECT 1 FROM pg_proc 
    WHERE proname = 'get_users_with_email'
);

-- رسالة تأكيد
-- Confirmation message
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'تم تطبيق جميع الإصلاحات بنجاح!';
    RAISE NOTICE 'All fixes applied successfully!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '1. ✅ Storage RLS policies fixed (UUID corrected)';
    RAISE NOTICE '2. ✅ Travel agencies RLS policies fixed';
    RAISE NOTICE '3. ✅ Users table permissions fixed';
    RAISE NOTICE '4. ✅ Reviews policies added';
    RAISE NOTICE 'Admin UUID: 78abcc88-0d36-4b5a-bb8f-809db1dfe10c';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'يمكنك الآن اختبار التطبيق';
    RAISE NOTICE 'You can now test the application';
    RAISE NOTICE '============================================';
END $$;