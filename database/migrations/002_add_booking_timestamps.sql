-- Add missing timestamp columns to bookings table
-- This migration adds confirmed_at, checked_in_at, completed_at, and cancelled_at columns

ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE;

-- Add comments for documentation
COMMENT ON COLUMN public.bookings.confirmed_at IS 'Timestamp when booking was confirmed by host';
COMMENT ON COLUMN public.bookings.checked_in_at IS 'Timestamp when guest checked in';
COMMENT ON COLUMN public.bookings.completed_at IS 'Timestamp when booking was completed';
COMMENT ON COLUMN public.bookings.cancelled_at IS 'Timestamp when booking was cancelled';