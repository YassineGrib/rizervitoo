-- Simple and reliable fix for review functionality
-- This fixes the core RLS policy issue preventing review insertion

-- ============================================================================
-- 1. Check current policies
-- ============================================================================

SELECT policyname, cmd, with_check
FROM pg_policies 
WHERE tablename = 'reviews' AND cmd = 'INSERT';

-- ============================================================================
-- 2. Drop existing problematic policy
-- ============================================================================

DROP POLICY IF EXISTS "Guests can insert reviews for their completed bookings" ON public.reviews;
DROP POLICY IF EXISTS "Guests can insert accommodation reviews" ON public.reviews;
DROP POLICY IF EXISTS "Guests can insert reviews after checkout" ON public.reviews;

-- ============================================================================
-- 3. Create simple and working policy
-- ============================================================================

-- This policy allows users to insert reviews if they have ANY non-cancelled booking
-- with a past checkout date for the accommodation they're reviewing
CREATE POLICY "Allow reviews after checkout" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    EXISTS (
      SELECT 1 FROM public.bookings 
      WHERE guest_id = auth.uid() 
        AND accommodation_id = reviews.accommodation_id
        AND status != 'cancelled'
        AND check_out_date <= CURRENT_DATE
    )
  );

-- ============================================================================
-- 4. Verify the policy was created
-- ============================================================================

SELECT policyname, cmd, with_check
FROM pg_policies 
WHERE tablename = 'reviews' 
  AND cmd = 'INSERT'
  AND policyname = 'Allow reviews after checkout';

-- ============================================================================
-- 5. Test insertion (optional - for debugging)
-- ============================================================================

-- This will show you if there are any eligible bookings
SELECT 
    b.id as booking_id,
    b.guest_id,
    b.accommodation_id,
    b.status,
    b.check_out_date,
    a.title as accommodation_title,
    CASE 
        WHEN b.check_out_date <= CURRENT_DATE THEN 'Can review'
        ELSE 'Cannot review yet'
    END as review_status
FROM public.bookings b
JOIN public.accommodations a ON b.accommodation_id = a.id
WHERE b.status != 'cancelled'
  AND b.check_out_date <= CURRENT_DATE
ORDER BY b.check_out_date DESC
LIMIT 5;

-- ============================================================================
-- Instructions:
-- ============================================================================

/*
1. Run this script in Supabase SQL Editor
2. Check that the policy was created successfully
3. Test the review functionality in your app
4. The app should now be able to save reviews to the database

If you still get errors:
- Check the output of the test query to see if there are eligible bookings
- Verify that users are properly authenticated
- Check the Flutter debug logs for more detailed error messages
*/