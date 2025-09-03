-- Complete fix for reviews functionality
-- This script fixes the RLS policies and provides setup instructions

-- ============================================================================
-- 1. Update RLS policies to allow reviews after checkout date (not just completed bookings)
-- ============================================================================

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Guests can insert reviews for their completed bookings" ON public.reviews;

-- Create new policy that allows reviews after checkout date has passed
CREATE POLICY "Guests can insert reviews after checkout" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    (
      -- Allow if booking_id is provided and meets criteria
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
      -- Allow if no booking_id but user has eligible booking for this accommodation
      (
        booking_id IS NULL AND
        EXISTS (
          SELECT 1 FROM public.bookings
          WHERE guest_id = auth.uid()
            AND accommodation_id = NEW.accommodation_id
            AND status != 'cancelled'
            AND check_out_date <= CURRENT_DATE
        )
      )
    )
  );

-- ============================================================================
-- 2. Create demo booking data for testing (OPTIONAL - for testing only)
-- ============================================================================

-- Only run this if you need test data
-- Replace the UUIDs with actual ones from your database

/*
-- Get your user ID first:
SELECT id, email FROM auth.users LIMIT 5;

-- Get accommodation IDs:
SELECT id, title FROM public.accommodations LIMIT 5;

-- Then insert demo bookings with past checkout dates:
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
  payment_status,
  created_at,
  updated_at
) VALUES 
-- Replace 'YOUR_USER_ID' and 'YOUR_ACCOMMODATION_ID' with actual values
(
  gen_random_uuid(),
  'YOUR_USER_ID', -- Use actual user ID from auth.users
  'YOUR_ACCOMMODATION_ID', -- Use actual accommodation ID
  CURRENT_DATE - INTERVAL '10 days',
  CURRENT_DATE - INTERVAL '7 days', -- Past checkout date
  2,
  3,
  5000.00,
  15000.00,
  'DZD',
  'confirmed', -- Status doesn't need to be 'completed'
  'paid',
  NOW() - INTERVAL '10 days',
  NOW() - INTERVAL '7 days'
);
*/

-- ============================================================================
-- 3. Verify the setup
-- ============================================================================

-- Check if policies exist:
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'reviews' 
AND policyname LIKE '%insert%';

-- Check if you have test bookings with past checkout dates:
SELECT 
  b.id,
  b.status,
  b.check_out_date,
  CASE 
    WHEN b.check_out_date <= CURRENT_DATE THEN 'Past checkout'
    ELSE 'Future checkout'
  END as checkout_status,
  a.title as accommodation_title
FROM public.bookings b
JOIN public.accommodations a ON b.accommodation_id = a.id
WHERE b.guest_id = auth.uid()
ORDER BY b.check_out_date DESC;

-- ============================================================================
-- INSTRUCTIONS FOR USE:
-- ============================================================================

/*
1. Run this script in Supabase SQL Editor
2. If you need test data, uncomment the INSERT statement and replace:
   - 'YOUR_USER_ID' with your actual user ID
   - 'YOUR_ACCOMMODATION_ID' with an actual accommodation ID
3. The app should now show review buttons for bookings with past checkout dates
4. Reviews will be properly saved to the reviews table
5. Use the debug print statements in the Flutter app to troubleshoot if needed

Debug info will show in Flutter logs:
- "Debug: Booking XYZ - checkoutDatePassed: true/false, status: confirmed, canReview: true/false"
- "Debug: Showing review button - canReview: true/false"
- Review service debug logs for database queries

If the review button still doesn't show:
1. Check that you have bookings with past checkout dates
2. Verify the user is logged in
3. Check the browser console/Flutter logs for debug messages
4. Ensure the booking status is not 'cancelled'
*/