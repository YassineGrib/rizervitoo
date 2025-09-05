-- إصلاح نظيف للسياسات - يحذف جميع السياسات أولاً ثم ينشئها من جديد
-- يحل مشكلة "policy already exists"

-- =============================================================================
-- 1. حذف جميع السياسات الموجودة (بما في ذلك المتضاربة)
-- =============================================================================

-- حذف جميع سياسات الملفات الشخصية
DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can insert profiles" ON profiles;

-- حذف جميع سياسات الإقامات
DROP POLICY IF EXISTS "Admin can view all accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can update accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can delete accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can insert accommodations" ON accommodations;

-- حذف جميع سياسات الحجوزات
DROP POLICY IF EXISTS "Admin can view all bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can update bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can delete bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can insert bookings" ON bookings;

-- حذف جميع سياسات التقييمات
DROP POLICY IF EXISTS "Admin can view all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can update reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can delete reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can insert reviews" ON reviews;

-- حذف جميع سياسات الإشعارات
DROP POLICY IF EXISTS "Admin can view all notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can update notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can delete notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can insert notifications" ON notifications;

-- حذف جميع سياسات وكالات السفر
DROP POLICY IF EXISTS "Admin can view all travel_agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can update travel_agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can delete travel_agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can insert travel_agencies" ON travel_agencies;

-- حذف جميع سياسات عروض وكالات السفر
DROP POLICY IF EXISTS "Admin can view all travel_agency_offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can update travel_agency_offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can delete travel_agency_offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can insert travel_agency_offers" ON travel_agency_offers;

-- حذف جميع سياسات أدلة السفر
DROP POLICY IF EXISTS "Admin can view all travel_guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can update travel_guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can delete travel_guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can insert travel_guides" ON travel_guides;

-- =============================================================================
-- 2. إنشاء السياسات الجديدة باستخدام JWT role
-- =============================================================================

-- سياسات الملفات الشخصية للأدمن
CREATE POLICY "Admin can view all profiles" ON profiles
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update all profiles" ON profiles
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete profiles" ON profiles
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- سياسات الإقامات للأدمن
CREATE POLICY "Admin can view all accommodations" ON accommodations
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update accommodations" ON accommodations
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete accommodations" ON accommodations
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert accommodations" ON accommodations
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- سياسات الحجوزات للأدمن
CREATE POLICY "Admin can view all bookings" ON bookings
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update bookings" ON bookings
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete bookings" ON bookings
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert bookings" ON bookings
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- سياسات التقييمات للأدمن
CREATE POLICY "Admin can view all reviews" ON reviews
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update reviews" ON reviews
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete reviews" ON reviews
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert reviews" ON reviews
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- سياسات الإشعارات للأدمن
CREATE POLICY "Admin can view all notifications" ON notifications
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update notifications" ON notifications
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete notifications" ON notifications
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert notifications" ON notifications
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- =============================================================================
-- 3. تحديث الدوال لاستخدام JWT role
-- =============================================================================

-- تحديث دالة get_users_with_email
CREATE OR REPLACE FUNCTION public.get_users_with_email()
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  avatar_url TEXT,
  date_of_birth DATE,
  nationality TEXT,
  preferred_language TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
) 
SECURITY DEFINER
AS $$
BEGIN
  -- التحقق من صلاحيات الأدمن باستخدام JWT role
  IF (auth.jwt() ->> 'role') != 'admin' THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;
  
  RETURN QUERY
  SELECT 
    p.id,
    p.full_name,
    COALESCE(au.email, 'unknown@email.com') as email,
    p.phone,
    p.avatar_url,
    p.date_of_birth,
    p.nationality,
    p.preferred_language,
    p.is_active,
    p.created_at,
    p.updated_at
  FROM public.profiles p
  LEFT JOIN auth.users au ON p.id = au.id
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- دالة للإحصائيات الشاملة
CREATE OR REPLACE FUNCTION get_admin_dashboard_stats()
RETURNS TABLE (
    total_users BIGINT,
    active_users BIGINT,
    total_accommodations BIGINT,
    verified_accommodations BIGINT,
    total_bookings BIGINT,
    pending_bookings BIGINT,
    confirmed_bookings BIGINT,
    completed_bookings BIGINT,
    cancelled_bookings BIGINT,
    total_reviews BIGINT,
    verified_reviews BIGINT,
    total_revenue DECIMAL(15,2),
    monthly_revenue DECIMAL(15,2)
)
SECURITY DEFINER
AS $$
BEGIN
    -- التحقق من صلاحيات الأدمن
    IF (auth.jwt() ->> 'role') != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM profiles) as total_users,
        (SELECT COUNT(*) FROM profiles WHERE is_active = true) as active_users,
        (SELECT COUNT(*) FROM accommodations) as total_accommodations,
        (SELECT COUNT(*) FROM accommodations WHERE is_verified = true) as verified_accommodations,
        (SELECT COUNT(*) FROM bookings) as total_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'pending') as pending_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'confirmed') as confirmed_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'completed') as completed_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'cancelled') as cancelled_bookings,
        (SELECT COUNT(*) FROM reviews) as total_reviews,
        (SELECT COUNT(*) FROM reviews WHERE is_verified = true) as verified_reviews,
        (SELECT COALESCE(SUM(total_amount), 0) FROM bookings WHERE payment_status = 'paid') as total_revenue,
        (SELECT COALESCE(SUM(total_amount), 0) FROM bookings 
         WHERE payment_status = 'paid' 
         AND created_at >= date_trunc('month', CURRENT_DATE)) as monthly_revenue;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على تفاصيل الحجوزات
CREATE OR REPLACE FUNCTION get_admin_bookings_details()
RETURNS TABLE (
    booking_id UUID,
    guest_name TEXT,
    guest_email TEXT,
    accommodation_title TEXT,
    accommodation_city TEXT,
    check_in_date DATE,
    check_out_date DATE,
    total_nights INTEGER,
    total_amount DECIMAL(10,2),
    status TEXT,
    payment_status TEXT,
    created_at TIMESTAMPTZ
)
SECURITY DEFINER
AS $$
BEGIN
    -- التحقق من صلاحيات الأدمن
    IF (auth.jwt() ->> 'role') != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        b.id as booking_id,
        COALESCE(p.full_name, 'غير محدد') as guest_name,
        COALESCE(au.email, 'unknown@email.com') as guest_email,
        COALESCE(a.title, 'غير محدد') as accommodation_title,
        COALESCE(a.city, 'غير محدد') as accommodation_city,
        b.check_in_date,
        b.check_out_date,
        b.total_nights,
        b.total_amount,
        b.status,
        b.payment_status,
        b.created_at
    FROM bookings b
    LEFT JOIN profiles p ON b.guest_id = p.id
    LEFT JOIN auth.users au ON p.id = au.id
    LEFT JOIN accommodations a ON b.accommodation_id = a.id
    ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على تفاصيل التقييمات
CREATE OR REPLACE FUNCTION get_admin_reviews_details()
RETURNS TABLE (
    review_id UUID,
    guest_name TEXT,
    guest_email TEXT,
    accommodation_title TEXT,
    rating INTEGER,
    title TEXT,
    comment TEXT,
    is_verified BOOLEAN,
    created_at TIMESTAMPTZ
)
SECURITY DEFINER
AS $$
BEGIN
    -- التحقق من صلاحيات الأدمن
    IF (auth.jwt() ->> 'role') != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    RETURN QUERY
    SELECT 
        r.id as review_id,
        COALESCE(p.full_name, 'غير محدد') as guest_name,
        COALESCE(au.email, 'unknown@email.com') as guest_email,
        COALESCE(a.title, 'غير محدد') as accommodation_title,
        r.rating,
        r.title,
        r.comment,
        r.is_verified,
        r.created_at
    FROM reviews r
    LEFT JOIN profiles p ON r.guest_id = p.id
    LEFT JOIN auth.users au ON p.id = au.id
    LEFT JOIN accommodations a ON r.accommodation_id = a.id
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 4. منح الصلاحيات للدوال
-- =============================================================================

GRANT EXECUTE ON FUNCTION get_users_with_email() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_dashboard_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_bookings_details() TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_reviews_details() TO authenticated;

-- =============================================================================
-- 5. رسالة الإكمال
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'تم تطبيق الإصلاح النظيف بنجاح!';
    RAISE NOTICE 'تم حذف جميع السياسات القديمة وإنشاء سياسات جديدة';
    RAISE NOTICE 'تم حل مشكلة "policy already exists"';
    RAISE NOTICE 'الآن يجب أن تعمل لوحة التحكم بشكل صحيح';
    RAISE NOTICE 'تأكد من أن المستخدم الأدمن لديه role = admin في JWT';
    RAISE NOTICE '=============================================';
END $$;