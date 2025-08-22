-- Initial database setup for Rizervitoo travel booking app
-- This script creates all necessary tables and functions

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis" SCHEMA extensions;

-- Run schema files in order
\i '../schema/01_profiles.sql'
\i '../schema/02_accommodations.sql'
\i '../schema/03_bookings.sql'
\i '../schema/04_reviews.sql'
\i '../schema/05_messages.sql'
\i '../schema/06_travel_guides.sql'

-- Insert sample data for testing
-- Sample travel guides for popular Algerian destinations
INSERT INTO public.travel_guides (
  title, description, city, state, category, 
  best_season, estimated_duration, images, highlights, tips,
  is_published, is_featured
) VALUES 
(
  'قصبة الجزائر التاريخية',
  'موقع تراث عالمي يضم العمارة العثمانية والأندلسية التقليدية',
  'الجزائر العاصمة', 'الجزائر', 'historical',
  'الربيع والخريف', '3-4 ساعات',
  '["https://example.com/casbah1.jpg", "https://example.com/casbah2.jpg"]'::jsonb,
  '["جامع كتشاوة", "قصر الداي", "الأسواق التقليدية", "المنازل العثمانية"]'::jsonb,
  '["ارتدي أحذية مريحة للمشي", "احترم التقاليد المحلية", "تجنب الزيارة في الظهيرة صيفاً"]'::jsonb,
  true, true
),
(
  'تيمقاد الأثرية',
  'مدينة رومانية قديمة محفوظة بشكل استثنائي في جبال الأوراس',
  'تيمقاد', 'باتنة', 'historical',
  'الربيع والخريف', 'يوم كامل',
  '["https://example.com/timgad1.jpg", "https://example.com/timgad2.jpg"]'::jsonb,
  '["المسرح الروماني", "قوس تراجان", "الحمامات الرومانية", "المكتبة القديمة"]'::jsonb,
  '["احضر قبعة وواقي شمس", "اشرب الكثير من الماء", "استأجر مرشد محلي"]'::jsonb,
  true, true
),
(
  'الهقار - جبال الطاسيلي',
  'منظر طبيعي صحراوي خلاب مع رسوم صخرية قديمة',
  'تمنراست', 'تمنراست', 'natural',
  'الشتاء', '3-5 أيام',
  '["https://example.com/hoggar1.jpg", "https://example.com/hoggar2.jpg"]'::jsonb,
  '["شروق الشمس من الأسكرام", "الرسوم الصخرية", "التكوينات الجيولوجية", "النجوم الصحراوية"]'::jsonb,
  '["احجز مع وكالة سياحية معتمدة", "احضر ملابس دافئة للليل", "احضر كاميرا جيدة"]'::jsonb,
  true, true
),
(
  'ساحل تيبازة',
  'آثار رومانية على ساحل البحر الأبيض المتوسط الجميل',
  'تيبازة', 'تيبازة', 'historical',
  'الربيع والصيف', 'نصف يوم',
  '["https://example.com/tipaza1.jpg", "https://example.com/tipaza2.jpg"]'::jsonb,
  '["المسرح المطل على البحر", "الفيلات الرومانية", "المتحف الأثري", "الشاطئ الجميل"]'::jsonb,
  '["اجمع بين الزيارة الأثرية والاستجمام", "احضر ملابس السباحة", "تناول السمك الطازج"]'::jsonb,
  true, false
);

-- Create some sample accommodation types for reference
COMMENT ON TABLE public.accommodations IS 'أنواع الإقامة: فندق، منزل، شقة، فيلا، بيت ضيافة، نزل';
COMMENT ON COLUMN public.accommodations.type IS 'hotel=فندق, house=منزل, apartment=شقة, villa=فيلا, guesthouse=بيت ضيافة, hostel=نزل';

-- Create view for accommodation search with location
CREATE OR REPLACE VIEW public.accommodation_search AS
SELECT 
  a.*,
  p.full_name as owner_name,
  p.phone as owner_phone
FROM public.accommodations a
JOIN public.profiles p ON a.owner_id = p.id
WHERE a.is_available = true AND a.is_verified = true;

-- Create view for booking summary
CREATE OR REPLACE VIEW public.booking_summary AS
SELECT 
  b.*,
  a.title as accommodation_title,
  a.city as accommodation_city,
  a.type as accommodation_type,
  guest.full_name as guest_name,
  guest.phone as guest_phone,
  owner.full_name as owner_name,
  owner.phone as owner_phone
FROM public.bookings b
JOIN public.accommodations a ON b.accommodation_id = a.id
JOIN public.profiles guest ON b.guest_id = guest.id
JOIN public.profiles owner ON a.owner_id = owner.id;

COMMENT ON DATABASE postgres IS 'Rizervitoo - تطبيق الحجوزات السياحية الجزائري';