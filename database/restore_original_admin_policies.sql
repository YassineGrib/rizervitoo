-- Restore original admin policies that use JWT role instead of email check
-- This fixes admin access issues that occurred after running migration files

-- =============================================================================
-- Remove conflicting policies created by fix files
-- =============================================================================

-- Drop email-based policies that may be conflicting
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

DROP POLICY IF EXISTS "Admin can view all travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can insert travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can update travel guides" ON travel_guides;
DROP POLICY IF EXISTS "Admin can delete travel guides" ON travel_guides;

-- =============================================================================
-- Restore original JWT-based admin policies
-- =============================================================================

-- Travel agencies policies
CREATE POLICY "Admin can insert travel agencies" ON travel_agencies
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update travel agencies" ON travel_agencies
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete travel agencies" ON travel_agencies
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can view all travel agencies" ON travel_agencies
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- Travel agency offers policies
CREATE POLICY "Admin can insert offers" ON travel_agency_offers
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update offers" ON travel_agency_offers
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete offers" ON travel_agency_offers
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can view all offers" ON travel_agency_offers
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- Profiles policies for admin
CREATE POLICY "Admin can view all profiles" ON profiles
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update profiles" ON profiles
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

-- Travel guides policies for admin
CREATE POLICY "Admin can view all travel guides" ON travel_guides
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can insert travel guides" ON travel_guides
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update travel guides" ON travel_guides
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete travel guides" ON travel_guides
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- =============================================================================
-- Keep the fixed get_users_with_email function (without gender column)
-- =============================================================================

-- The function fix is still valid, just recreate it to ensure it's correct
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
    -- Check if user has admin role in JWT
    IF (auth.jwt() ->> 'role') != 'admin' THEN
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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_users_with_email() TO authenticated;

-- =============================================================================
-- Add difficulty column if it doesn't exist (keep this fix)
-- =============================================================================

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
-- Completion message
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';  
    RAISE NOTICE 'Original admin policies restored successfully!';
    RAISE NOTICE 'Admin access should now work with JWT role = admin';
    RAISE NOTICE 'Make sure your admin user has role = admin in JWT token';
    RAISE NOTICE '=============================================';
END $$;