-- إصلاح شامل لصلاحيات المدير لجميع الجداول
-- Complete fix for admin permissions for all tables

-- ============================================================================
-- 1. حذف السياسات الموجودة للمدير
-- Drop existing admin policies
-- ============================================================================

-- Travel agencies policies
DROP POLICY IF EXISTS "Admin can insert travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can update travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can delete travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can view all travel agencies" ON travel_agencies;

-- Travel agency offers policies
DROP POLICY IF EXISTS "Admin can insert offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can update offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can delete offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can view all offers" ON travel_agency_offers;

-- Profiles policies
DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can insert profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can delete profiles" ON profiles;

-- Reviews policies
DROP POLICY IF EXISTS "Admin can view all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can update all reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can insert reviews" ON reviews;
DROP POLICY IF EXISTS "Admin can delete all reviews" ON reviews;

-- Travel guides policies
DROP POLICY IF EXISTS "Admin can view all travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can update travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can insert travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can delete travel guides" ON travel_guides;

-- ============================================================================
-- 2. حذف الدالة الموجودة أولاً
-- Drop existing function first
-- ============================================================================

DROP FUNCTION IF EXISTS get_users_with_email();

-- ============================================================================
-- 3. إنشاء سياسات جديدة للمدير باستخدام البريد الإلكتروني
-- Create new admin policies using email authentication
-- ============================================================================

-- Travel agencies policies
CREATE POLICY "Admin can insert travel agencies" ON travel_agencies
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can update travel agencies" ON travel_agencies
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can delete travel agencies" ON travel_agencies
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can view all travel agencies" ON travel_agencies
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Travel agency offers policies
CREATE POLICY "Admin can insert offers" ON travel_agency_offers
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can update offers" ON travel_agency_offers
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can delete offers" ON travel_agency_offers
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can view all offers" ON travel_agency_offers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Profiles policies (for user management)
CREATE POLICY "Admin can view all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can update profiles" ON profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can insert profiles" ON profiles
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can delete profiles" ON profiles
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Reviews policies (for review management)
CREATE POLICY "Admin can view all reviews" ON reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can update all reviews" ON reviews
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can insert reviews" ON reviews
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can delete all reviews" ON reviews
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Travel guides policies
CREATE POLICY "Admin can view all travel guides" ON travel_guides
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can insert travel guides" ON travel_guides
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can update travel guides" ON travel_guides
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin can delete travel guides" ON travel_guides
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- ============================================================================
-- 4. إنشاء دالة get_users_with_email للمدير
-- Create get_users_with_email function for admin
-- ============================================================================

CREATE OR REPLACE FUNCTION get_users_with_email()
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    date_of_birth DATE,
    nationality TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
SECURITY DEFINER
AS $$
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.users.id = auth.uid() 
        AND auth.users.email = 'admin@rizervitoo.dz'
    ) THEN
        RAISE EXCEPTION 'Access denied. Admin privileges required.';
    END IF;
    
    -- Return profiles with emails from auth.users
    RETURN QUERY
    SELECT 
        p.id,
        p.full_name,
        COALESCE(au.email, 'unknown@email.com') as email,
        p.phone,
        p.date_of_birth,
        p.nationality,
        COALESCE(p.is_active, true) as is_active,
        p.created_at,
        p.updated_at
    FROM profiles p
    LEFT JOIN auth.users au ON p.id = au.id
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 5. التحقق من وجود مستخدم المدير
-- Check if admin user exists
-- ============================================================================

DO $$
DECLARE
    admin_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM auth.users 
        WHERE email = 'admin@rizervitoo.dz'
    ) INTO admin_exists;
    
    IF admin_exists THEN
        RAISE NOTICE 'مستخدم المدير موجود - Admin user exists: admin@rizervitoo.dz';
    ELSE
        RAISE NOTICE 'تحذير: مستخدم المدير غير موجود! - WARNING: Admin user does not exist!';
        RAISE NOTICE 'يجب إنشاء مستخدم بالإيميل: admin@rizervitoo.dz';
        RAISE NOTICE 'You need to create a user with email: admin@rizervitoo.dz';
    END IF;
END $$;

-- ============================================================================
-- 6. رسالة تأكيد
-- Confirmation message
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'تم تطبيق إصلاحات صلاحيات المدير بنجاح!';
    RAISE NOTICE 'Admin permissions fixes applied successfully!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE '1. تم إصلاح صلاحيات الوكالات السياحية';
    RAISE NOTICE '2. تم إصلاح صلاحيات إدارة المستخدمين';
    RAISE NOTICE '3. تم إصلاح صلاحيات إدارة التقييمات';
    RAISE NOTICE '4. تم إصلاح صلاحيات الأدلة السياحية';
    RAISE NOTICE '5. تم تحديث دالة get_users_with_email';
    RAISE NOTICE '=============================================';
END $$;