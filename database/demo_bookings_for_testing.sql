-- Demo booking data for testing reviews functionality
-- This will create test bookings with past checkout dates

-- Insert demo bookings (you'll need to replace UUIDs with actual ones from your database)
-- These are example bookings with checkout dates in the past for testing

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
-- Demo booking 1 - Past booking for testing reviews
(
  gen_random_uuid(),
  (SELECT id FROM auth.users LIMIT 1), -- Gets first user ID
  (SELECT id FROM public.accommodations LIMIT 1), -- Gets first accommodation ID
  CURRENT_DATE - INTERVAL '10 days',
  CURRENT_DATE - INTERVAL '7 days',
  2,
  3,
  5000.00,
  15000.00,
  'DZD',
  'confirmed', -- Can be confirmed instead of completed
  'paid',
  NOW() - INTERVAL '10 days',
  NOW() - INTERVAL '7 days'
),
-- Demo booking 2 - Another past booking
(
  gen_random_uuid(),
  (SELECT id FROM auth.users LIMIT 1),
  (SELECT id FROM public.accommodations OFFSET 1 LIMIT 1), -- Gets second accommodation if exists
  CURRENT_DATE - INTERVAL '15 days',
  CURRENT_DATE - INTERVAL '12 days',
  1,
  3,
  4000.00,
  12000.00,
  'DZD',
  'confirmed',
  'paid',
  NOW() - INTERVAL '15 days',
  NOW() - INTERVAL '12 days'
);

-- Note: This is demo data for testing. In production, you would:
-- 1. Replace the user_id and accommodation_id with actual values
-- 2. Ensure the dates make sense for your testing scenario
-- 3. Remove this data after testing is complete