-- Demo data for notifications table
-- This file contains sample notifications for testing the notification system

-- Insert demo notifications for different users and types
INSERT INTO public.notifications (user_id, title, message, type, priority, is_read, data, action_url, expires_at) VALUES
-- Welcome notifications
('00000000-0000-0000-0000-000000000001', 'مرحباً بك في ريزرفيتو!', 'نحن سعداء لانضمامك إلينا. استكشف أفضل أماكن الإقامة في الجزائر.', 'welcome', 'normal', false, '{"welcome_bonus": true}', '/home', NULL),

-- Booking notifications
('00000000-0000-0000-0000-000000000001', 'تم تأكيد حجزك', 'تم تأكيد حجزك في فندق الأوراسي. رقم الحجز: #12345', 'booking', 'high', false, '{"booking_id": "12345", "hotel_name": "فندق الأوراسي"}', '/bookings/12345', NULL),

('00000000-0000-0000-0000-000000000001', 'تذكير بموعد الوصول', 'تذكير: موعد وصولك إلى فندق الأوراسي غداً في الساعة 2:00 مساءً', 'reminder', 'normal', true, '{"booking_id": "12345", "check_in_time": "14:00"}', '/bookings/12345', NOW() + INTERVAL '1 day'),

-- Payment notifications
('00000000-0000-0000-0000-000000000001', 'تم استلام الدفع', 'تم استلام دفعتك بنجاح. المبلغ: 15,000 دج', 'payment', 'normal', false, '{"amount": 15000, "currency": "DZD", "payment_id": "pay_123"}', '/payments/pay_123', NULL),

('00000000-0000-0000-0000-000000000001', 'فشل في الدفع', 'فشل في معالجة دفعتك. يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى.', 'payment', 'urgent', false, '{"error_code": "insufficient_funds", "booking_id": "12346"}', '/payments/retry', NULL),

-- System notifications
('00000000-0000-0000-0000-000000000001', 'تحديث النظام', 'تم تحديث التطبيق بميزات جديدة. استكشف الآن!', 'system', 'low', true, '{"version": "2.1.0", "features": ["notifications", "improved_search"]}', '/updates', NULL),

('00000000-0000-0000-0000-000000000001', 'صيانة مجدولة', 'سيكون النظام متوقفاً للصيانة يوم الجمعة من 2:00 إلى 4:00 صباحاً', 'system', 'high', false, '{"maintenance_start": "2024-01-26T02:00:00Z", "maintenance_end": "2024-01-26T04:00:00Z"}', NULL, NULL),

-- Promotion notifications
('00000000-0000-0000-0000-000000000001', 'عرض خاص: خصم 25%', 'احصل على خصم 25% على جميع الحجوزات في وهران. العرض ساري حتى نهاية الشهر!', 'promotion', 'high', false, '{"discount_percent": 25, "city": "وهران", "promo_code": "ORAN25"}', '/search?city=oran', NOW() + INTERVAL '30 days'),

('00000000-0000-0000-0000-000000000001', 'عرض محدود الوقت', 'عرض البرق! خصم 40% على الفنادق الفاخرة في الجزائر العاصمة لمدة 24 ساعة فقط', 'promotion', 'urgent', false, '{"discount_percent": 40, "city": "الجزائر العاصمة", "expires_in_hours": 24}', '/search?city=algiers&category=luxury', NOW() + INTERVAL '24 hours'),

-- More booking notifications
('00000000-0000-0000-0000-000000000001', 'تم إلغاء الحجز', 'تم إلغاء حجزك في فندق الشيراتون. سيتم رد المبلغ خلال 3-5 أيام عمل.', 'booking', 'normal', false, '{"booking_id": "12347", "refund_days": "3-5", "hotel_name": "فندق الشيراتون"}', '/bookings/12347', NULL),

('00000000-0000-0000-0000-000000000001', 'اكتمل إقامتك', 'نأمل أن تكون قد استمتعت بإقامتك في فندق الأوراسي. شاركنا تقييمك!', 'booking', 'low', true, '{"booking_id": "12345", "hotel_name": "فندق الأوراسي", "can_review": true}', '/bookings/12345/review', NULL),

-- Additional system notifications
('00000000-0000-0000-0000-000000000001', 'تحديث الملف الشخصي', 'يرجى تحديث معلومات ملفك الشخصي لضمان أفضل تجربة حجز', 'system', 'normal', false, '{"missing_fields": ["phone", "address"]}', '/profile/edit', NULL),

-- Reminder notifications
('00000000-0000-0000-0000-000000000001', 'تذكير بتقييم الإقامة', 'لا تنس تقييم إقامتك الأخيرة في فندق الأوراسي. رأيك مهم لنا!', 'reminder', 'low', false, '{"booking_id": "12345", "hotel_name": "فندق الأوراسي"}', '/bookings/12345/review', NOW() + INTERVAL '7 days'),

-- Expired promotion (for testing expired notifications)
('00000000-0000-0000-0000-000000000001', 'عرض منتهي الصلاحية', 'هذا العرض انتهت صلاحيته ولن يظهر في القائمة', 'promotion', 'normal', false, '{"discount_percent": 15}', NULL, NOW() - INTERVAL '1 day');

-- Add notifications for a second demo user
INSERT INTO public.notifications (user_id, title, message, type, priority, is_read, data, action_url) VALUES
('00000000-0000-0000-0000-000000000002', 'مرحباً بك في ريزرفيتو!', 'أهلاً وسهلاً! ابدأ رحلتك في اكتشاف أجمل الأماكن في الجزائر.', 'welcome', 'normal', true, '{"welcome_bonus": true}', '/home'),

('00000000-0000-0000-0000-000000000002', 'عرض خاص لك', 'كعضو جديد، احصل على خصم 15% على أول حجز لك!', 'promotion', 'high', false, '{"discount_percent": 15, "first_booking": true, "promo_code": "WELCOME15"}', '/search'),

('00000000-0000-0000-0000-000000000002', 'تأكيد الحجز مطلوب', 'يرجى تأكيد حجزك في شقة البحر الأبيض خلال 24 ساعة', 'booking', 'urgent', false, '{"booking_id": "12348", "property_name": "شقة البحر الأبيض", "expires_in_hours": 24}', '/bookings/12348/confirm');

-- Update timestamps to create realistic time distribution
UPDATE public.notifications SET 
  created_at = NOW() - (RANDOM() * INTERVAL '30 days'),
  updated_at = created_at
WHERE user_id IN ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002');

-- Update some notifications to be more recent (last 24 hours)
UPDATE public.notifications SET 
  created_at = NOW() - (RANDOM() * INTERVAL '24 hours'),
  updated_at = created_at
WHERE type IN ('booking', 'payment') AND user_id = '00000000-0000-0000-0000-000000000001'
LIMIT 3;