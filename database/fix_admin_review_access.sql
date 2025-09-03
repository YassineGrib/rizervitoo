-- Fix admin access to all reviews for management purposes
-- This ensures the admin can view all reviews regardless of RLS policies

-- ============================================================================
-- 1. Check current RLS policies for reviews
-- ============================================================================

SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd, 
    permissive,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'reviews'
ORDER BY cmd, policyname;

-- ============================================================================
-- 2. Check if admin can access reviews table
-- ============================================================================

-- Test admin access (run this when logged in as admin)
SELECT 
    id,
    guest_id,
    accommodation_id,
    rating,
    title,
    comment,
    is_verified,
    created_at
FROM public.reviews 
ORDER BY created_at DESC
LIMIT 5;

-- ============================================================================
-- 3. Create admin policy for viewing all reviews
-- ============================================================================

-- Drop existing admin policy if it exists
DROP POLICY IF EXISTS "Admin can view all reviews" ON public.reviews;

-- Create policy that allows admin to view all reviews
CREATE POLICY "Admin can view all reviews" ON public.reviews
  FOR SELECT USING (
    auth.jwt() ->> 'email' = 'admin@rizervitoo.dz'
  );

-- ============================================================================
-- 4. Create admin policy for updating reviews (for approval/rejection)
-- ============================================================================

-- Drop existing admin update policy if it exists
DROP POLICY IF EXISTS "Admin can update all reviews" ON public.reviews;

-- Create policy that allows admin to update all reviews
CREATE POLICY "Admin can update all reviews" ON public.reviews
  FOR UPDATE USING (
    auth.jwt() ->> 'email' = 'admin@rizervitoo.dz'
  );

-- ============================================================================
-- 5. Create admin policy for deleting reviews (for rejection)
-- ============================================================================

-- Drop existing admin delete policy if it exists
DROP POLICY IF EXISTS "Admin can delete all reviews" ON public.reviews;

-- Create policy that allows admin to delete all reviews
CREATE POLICY "Admin can delete all reviews" ON public.reviews
  FOR DELETE USING (
    auth.jwt() ->> 'email' = 'admin@rizervitoo.dz'
  );

-- ============================================================================
-- 6. Verify the new policies were created
-- ============================================================================

SELECT 
    policyname, 
    cmd, 
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'reviews' 
  AND policyname LIKE '%Admin%'
ORDER BY cmd;

-- ============================================================================
-- 7. Test admin access again
-- ============================================================================

-- Count reviews by verification status
SELECT 
    is_verified,
    COUNT(*) as count
FROM public.reviews 
GROUP BY is_verified;

-- Show sample of unverified reviews
SELECT 
    id,
    rating,
    title,
    is_verified,
    created_at
FROM public.reviews 
WHERE is_verified = false
ORDER BY created_at DESC
LIMIT 3;

-- ============================================================================
-- Instructions:
-- ============================================================================

/*
1. Run this script in Supabase SQL Editor while logged in as admin
2. Check the output of the test queries to see if admin can access reviews
3. If you see reviews in the SQL results but not in the app, the issue is in the Flutter code
4. If you don't see reviews in SQL either, there might be other RLS policies blocking access
5. Check the Flutter console logs for debug messages after running this script

The debug logs will help identify where the issue is:
- If SQL queries return data but Flutter doesn't, it's a client-side issue
- If SQL queries return empty results, it's a database policy issue
*/