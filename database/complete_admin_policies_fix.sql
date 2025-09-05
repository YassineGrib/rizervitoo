-- إصلاح شامل لسياسات الأدمن - حل مشاكل لوحة التحكم
-- يحل مشاكل: الإحصائيات = 0، Permission Denied في إدارة المستخدمين والتقييمات والإقامات
-- يستخدم JWT role بدلاً من البريد الإلكتروني للتوافق مع النظام الأصلي

-- =============================================================================
-- إزالة السياسات المتضاربة التي تم إنشاؤها بواسطة ملفات الإصلاح السابقة
-- =============================================================================

-- حذف السياسات المبنية على البريد الإلكتروني التي قد تسبب تضارب
DROP POLICY IF EXISTS "Admin can view all bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can update bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can delete bookings" ON bookings;
DROP POLICY IF EXISTS "Admin can insert bookings" ON bookings;

DROP POLICY IF EXISTS "Admin can view all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can update reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can delete reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can insert reviews" ON reviews;

DROP POLICY IF EXISTS "Admin can view all accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can update accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can delete accommodations" ON accommodations;
DROP POLICY IF EXISTS "Admin can insert accommodations" ON accommodations;

DROP POLICY IF EXISTS "Admin can view all notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can update notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can delete notifications" ON notifications;
DROP POLICY IF EXISTS "Admin can insert notifications" ON notifications;

-- =============================================================================
-- إنشاء سياسات الأدمن الجديدة باستخدام JWT role
-- =============================================================================

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

-- سياسات الإقامات للأدمن
CREATE POLICY "Admin can view all accommodations" ON accommodations
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update accommodations" ON accommodations
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete accommodations" ON accommodations
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert accommodations" ON accommodations
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
-- إنشاء دوال مساعدة للإحصائيات (لحل مشكلة الإحصائيات = 0)
-- =============================================================================

-- دالة للحصول على إحصائيات شاملة للأدمن
CREATE OR REPLACE FUNCTION get_admin_statistics()
RETURNS TABLE (
    total_users BIGINT,
    total_accommodations BIGINT,
    total_bookings BIGINT,
    total_reviews BIGINT,
    pending_bookings BIGINT,
    confirmed_bookings BIGINT,
    completed_bookings BIGINT,
    cancelled_bookings BIGINT,
    verified_accommodations BIGINT,
    unverified_accommodations BIGINT,
    total_revenue DECIMAL(15,2)
)
SECURITY DEFINER
AS $$
BEGIN
    -- التحقق من صلاحيات الأدمن
    IF (auth.jwt() ->> 'role') != 'admin' THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- إرجاع الإحصائيات
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM profiles) as total_users,
        (SELECT COUNT(*) FROM accommodations) as total_accommodations,
        (SELECT COUNT(*) FROM bookings) as total_bookings,
        (SELECT COUNT(*) FROM reviews) as total_reviews,
        (SELECT COUNT(*) FROM bookings WHERE status = 'pending') as pending_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'confirmed') as confirmed_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'completed') as completed_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'cancelled') as cancelled_bookings,
        (SELECT COUNT(*) FROM accommodations WHERE is_verified = true) as verified_accommodations,
        (SELECT COUNT(*) FROM accommodations WHERE is_verified = false) as unverified_accommodations,
        (SELECT COALESCE(SUM(total_amount), 0) FROM bookings WHERE payment_status = 'paid') as total_revenue;
END;
$$ LANGUAGE plpgsql;

-- منح صلاحية التنفيذ
GRANT EXECUTE ON FUNCTION get_admin_statistics() TO authenticated;

-- دالة للحصول على الحجوزات مع تفاصيل إضافية
CREATE OR REPLACE FUNCTION get_bookings_with_details()
RETURNS TABLE (
    booking_id UUID,
    guest_name TEXT,
    guest_email TEXT,
    accommodation_title TEXT,
    check_in_date DATE,
    check_out_date DATE,
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
    
    -- إرجاع الحجوزات مع التفاصيل
    RETURN QUERY
    SELECT 
        b.id as booking_id,
        p.full_name as guest_name,
        COALESCE(au.email, 'unknown@email.com') as guest_email,
        a.title as accommodation_title,
        b.check_in_date,
        b.check_out_date,
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

-- منح صلاحية التنفيذ
GRANT EXECUTE ON FUNCTION get_bookings_with_details() TO authenticated;

-- دالة للحصول على التقييمات مع تفاصيل إضافية
CREATE OR REPLACE FUNCTION get_reviews_with_details()
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
    
    -- إرجاع التقييمات مع التفاصيل
    RETURN QUERY
    SELECT 
        r.id as review_id,
        p.full_name as guest_name,
        COALESCE(au.email, 'unknown@email.com') as guest_email,
        a.title as accommodation_title,
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

-- منح صلاحية التنفيذ
GRANT EXECUTE ON FUNCTION get_reviews_with_details() TO authenticated;

-- =============================================================================
-- رسالة الإكمال
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'تم إصلاح سياسات الأدمن بنجاح!';
    RAISE NOTICE 'تم إضافة سياسات للحجوزات والتقييمات والإقامات والإشعارات';
    RAISE NOTICE 'تم إنشاء دوال مساعدة للإحصائيات';
    RAISE NOTICE 'يجب أن تعمل لوحة التحكم الآن بشكل صحيح';
    RAISE NOTICE 'تأكد من أن المستخدم الأدمن لديه role = admin في JWT token';
    RAISE NOTICE '=============================================';
END $$;