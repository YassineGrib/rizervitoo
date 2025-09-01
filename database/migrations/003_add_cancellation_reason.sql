-- Migration: Add cancellation_reason column to bookings table
-- This fixes the issue where booking modifications fail due to missing cancellation_reason column

-- Add cancellation_reason column to bookings table
ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- Add comment to document the column purpose
COMMENT ON COLUMN public.bookings.cancellation_reason IS 'Reason provided when a booking is cancelled';

-- Update any existing cancelled bookings to have a default reason if null
UPDATE public.bookings 
SET cancellation_reason = 'لم يتم تحديد السبب'
WHERE status = 'cancelled' AND cancellation_reason IS NULL;