-- Complete fix for review functionality
-- Execute this script in your Supabase SQL Editor

-- ============================================================================
-- 1. First, check current state
-- ============================================================================

-- Check current RLS policies for reviews table
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    cmd, 
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'reviews' 
  AND cmd = 'INSERT'
ORDER BY policyname;

-- Check if you have bookings with past checkout dates
SELECT 
    b.id,
    b.guest_id,
    b.accommodation_id,
    b.status,
    b.check_in_date,
    b.check_out_date,
    CASE 
        WHEN b.check_out_date <= CURRENT_DATE THEN 'Past checkout - Can review'
        ELSE 'Future checkout - Cannot review yet'
    END as review_eligibility,
    a.title as accommodation_title
FROM public.bookings b
JOIN public.accommodations a ON b.accommodation_id = a.id
WHERE b.check_out_date <= CURRENT_DATE
  AND b.status != 'cancelled'
ORDER BY b.check_out_date DESC
LIMIT 10;

-- ============================================================================
-- 2. Update RLS policies to match app logic
-- ============================================================================

-- Drop the existing restrictive INSERT policy
DROP POLICY IF EXISTS "Guests can insert reviews for their completed bookings" ON public.reviews;

-- Drop any other conflicting policies
DROP POLICY IF EXISTS "Guests can insert accommodation reviews" ON public.reviews;

-- Create new INSERT policy that allows reviews after checkout date
CREATE POLICY "Guests can insert reviews after checkout" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    (
      -- Case 1: booking_id is provided - check that specific booking
      (
        booking_id IS NOT NULL AND
        EXISTS (
          SELECT 1 FROM public.bookings 
          WHERE id = booking_id 
            AND guest_id = auth.uid() 
            AND status != 'cancelled'
            AND check_out_date <= CURRENT_DATE
        )
      )
      OR
      -- Case 2: booking_id is null - check if user has ANY eligible booking for this accommodation
      (
        booking_id IS NULL AND
        accommodation_id IN (
          SELECT DISTINCT b.accommodation_id 
          FROM public.bookings b
          WHERE b.guest_id = auth.uid()
            AND b.status != 'cancelled'
            AND b.check_out_date <= CURRENT_DATE
        )
      )
    )
  );

-- ============================================================================
-- 3. Create debug function to test review insertion
-- ============================================================================

CREATE OR REPLACE FUNCTION test_review_insertion()
RETURNS TABLE (
    test_result text,
    details text
) AS $$
DECLARE
    test_user_id uuid;
    test_accommodation_id uuid;
    test_booking_id uuid;
    review_id uuid;
BEGIN
    -- Get a test user (current user or first available)
    SELECT auth.uid() INTO test_user_id;
    
    IF test_user_id IS NULL THEN
        SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    END IF;
    
    -- Get a booking with past checkout date for this user
    SELECT 
        b.id,
        b.accommodation_id
    INTO test_booking_id, test_accommodation_id
    FROM public.bookings b
    WHERE b.guest_id = test_user_id
      AND b.status != 'cancelled'
      AND b.check_out_date <= CURRENT_DATE
      AND NOT EXISTS (
          SELECT 1 FROM public.reviews r 
          WHERE r.booking_id = b.id
      )
    LIMIT 1;
    
    IF test_booking_id IS NULL THEN
        RETURN QUERY SELECT 
            'NO_ELIGIBLE_BOOKING'::text,
            'No eligible bookings found for testing. User needs a non-cancelled booking with past checkout date.'::text;
        RETURN;
    END IF;
    
    -- Try to insert a test review
    BEGIN
        INSERT INTO public.reviews (
            booking_id,
            guest_id,
            accommodation_id,
            rating,
            title,
            comment
        ) VALUES (
            test_booking_id,
            test_user_id,
            test_accommodation_id,
            5,
            'Test Review',
            'This is a test review to verify the review functionality is working.'
        ) RETURNING id INTO review_id;
        
        -- If successful, clean up the test review
        DELETE FROM public.reviews WHERE id = review_id;
        
        RETURN QUERY SELECT 
            'SUCCESS'::text,
            format('Review insertion test passed. Booking ID: %s, Accommodation ID: %s', test_booking_id, test_accommodation_id)::text;
        
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT 
            'FAILED'::text,
            format('Review insertion failed: %s. Booking ID: %s, Accommodation ID: %s', SQLERRM, test_booking_id, test_accommodation_id)::text;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 4. Run tests
-- ============================================================================

-- Test the review insertion
SELECT * FROM test_review_insertion();

-- Verify the new policy exists
SELECT 
    policyname, 
    cmd, 
    with_check
FROM pg_policies 
WHERE tablename = 'reviews' 
  AND cmd = 'INSERT'
  AND policyname = 'Guests can insert reviews after checkout';

-- ============================================================================
-- 5. Optional: Create demo data if no eligible bookings exist
-- ============================================================================

-- Only run this if you need test data and no eligible bookings exist
/*
-- Create a demo booking with past checkout date
DO $$
DECLARE
    demo_user_id uuid;
    demo_accommodation_id uuid;
    demo_booking_id uuid;
BEGIN
    -- Get current user or first user
    SELECT COALESCE(auth.uid(), (SELECT id FROM auth.users LIMIT 1)) INTO demo_user_id;
    
    -- Get first accommodation
    SELECT id INTO demo_accommodation_id FROM public.accommodations LIMIT 1;
    
    -- Check if user already has eligible bookings
    IF NOT EXISTS (
        SELECT 1 FROM public.bookings
        WHERE guest_id = demo_user_id
          AND accommodation_id = demo_accommodation_id
          AND status != 'cancelled'
          AND check_out_date <= CURRENT_DATE
    ) THEN
        -- Insert demo booking
        INSERT INTO public.bookings (
            id,
            guest_id,
            accommodation_id,
            check_in_date,
            check_out_date,
            guests_count,
            total_nights,
            price_per_night,
            total_amount,
            currency,
            status,
            payment_status
        ) VALUES (
            gen_random_uuid(),
            demo_user_id,
            demo_accommodation_id,
            CURRENT_DATE - INTERVAL '10 days',
            CURRENT_DATE - INTERVAL '7 days',
            2,
            3,
            5000.00,
            15000.00,
            'DZD',
            'confirmed',
            'paid'
        );
        
        RAISE NOTICE 'Demo booking created for user % and accommodation %', demo_user_id, demo_accommodation_id;
    ELSE
        RAISE NOTICE 'User already has eligible bookings, no demo data needed';
    END IF;
END $$;
*/

-- ============================================================================
-- Instructions for next steps:
-- ============================================================================

/*
1. Execute this script in Supabase SQL Editor
2. Check the test results - should show "SUCCESS"
3. If test fails, check the error details
4. If no eligible bookings exist, uncomment and run the demo data section
5. Test the review functionality in your Flutter app
6. The app should now properly save reviews to the database

If you still have issues:
- Check Supabase logs for any errors
- Verify user authentication in your app
- Check that bookings exist with past checkout dates
- Enable debug logging in ReviewService to trace the issue
*/