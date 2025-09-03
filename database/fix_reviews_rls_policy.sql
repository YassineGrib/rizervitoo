-- Fix reviews RLS policy to allow reviews after checkout date has passed
-- instead of requiring booking status to be 'completed'

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Guests can insert reviews for their completed bookings" ON public.reviews;

-- Create new policy that allows reviews after checkout date has passed
CREATE POLICY "Guests can insert reviews after checkout" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    EXISTS (
      SELECT 1 FROM public.bookings 
      WHERE id = booking_id 
        AND guest_id = auth.uid() 
        AND status != 'cancelled'
        AND check_out_date <= CURRENT_DATE
    )
  );

-- Also ensure guests can still insert reviews without booking_id 
-- (for accommodations they've stayed at)
CREATE POLICY "Guests can insert accommodation reviews" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    (
      booking_id IS NULL OR
      EXISTS (
        SELECT 1 FROM public.bookings 
        WHERE id = booking_id 
          AND guest_id = auth.uid() 
          AND status != 'cancelled'
          AND check_out_date <= CURRENT_DATE
      )
    ) AND
    EXISTS (
      SELECT 1 FROM public.bookings
      WHERE guest_id = auth.uid()
        AND accommodation_id = NEW.accommodation_id
        AND status != 'cancelled'
        AND check_out_date <= CURRENT_DATE
    )
  );