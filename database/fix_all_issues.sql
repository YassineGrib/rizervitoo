-- Fix all database issues reported by the user
-- This script addresses:
-- 1. Missing 'difficulty' column in travel_agency_offers table
-- 2. Admin permissions issues (RLS policies)
-- 3. Gender column issue in get_users_with_email function

-- =============================================================================
-- 1. Add missing 'difficulty' column to travel_agency_offers table
-- =============================================================================

-- Check if difficulty column exists, if not add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'travel_agency_offers' 
        AND column_name = 'difficulty'
    ) THEN
        ALTER TABLE travel_agency_offers 
        ADD COLUMN difficulty VARCHAR(50) DEFAULT 'متوسط';
        
        -- Update existing records to use difficulty_level value if it exists
        UPDATE travel_agency_offers 
        SET difficulty = COALESCE(difficulty_level, 'متوسط')
        WHERE difficulty IS NULL;
        
        RAISE NOTICE 'Added difficulty column to travel_agency_offers table';
    ELSE
        RAISE NOTICE 'Difficulty column already exists in travel_agency_offers table';
    END IF;
END $$;

-- =============================================================================
-- 2. Fix RLS policies for admin access
-- =============================================================================

-- Drop existing conflicting policies if they exist
DROP POLICY IF EXISTS "Admin can insert travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can update travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can delete travel agencies" ON travel_agencies;
DROP POLICY IF EXISTS "Admin can view all travel agencies" ON travel_agencies;

DROP POLICY IF EXISTS "Admin can insert offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can update offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can delete offers" ON travel_agency_offers;
DROP POLICY IF EXISTS "Admin can view all offers" ON travel_agency_offers;

DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update profiles" ON profiles;

-- Create new admin policies using email-based authentication
-- Admin can manage travel agencies
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

-- Admin can view all agencies
CREATE POLICY "Admin can view all travel agencies" ON travel_agencies
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Admin can manage offers
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

-- Admin can view all offers
CREATE POLICY "Admin can view all offers" ON travel_agency_offers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- RLS policies for profiles table (users management)
-- Admin can view all profiles
CREATE POLICY "Admin can view all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Admin can update profiles
CREATE POLICY "Admin can update profiles" ON profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- =============================================================================
-- 3. Fix get_users_with_email function (remove gender column reference)
-- =============================================================================

-- Drop and recreate the RPC function without gender column
DROP FUNCTION IF EXISTS get_users_with_email();

CREATE OR REPLACE FUNCTION get_users_with_email()
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
    
    -- Return profiles with emails from auth.users (without gender column)
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
        COALESCE(p.is_active, true) as is_active,
        p.created_at,
        p.updated_at
    FROM profiles p
    LEFT JOIN auth.users au ON p.id = au.id
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 4. Grant necessary permissions
-- =============================================================================

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION get_users_with_email() TO authenticated;

-- =============================================================================
-- Completion message
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Database fixes completed successfully!';
    RAISE NOTICE '1. Added difficulty column to travel_agency_offers';
    RAISE NOTICE '2. Fixed RLS policies for admin access';
    RAISE NOTICE '3. Fixed get_users_with_email function';
    RAISE NOTICE '=============================================';
END $$;