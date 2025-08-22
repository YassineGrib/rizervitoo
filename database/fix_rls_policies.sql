-- Fix RLS policies for travel agencies
-- Add missing INSERT, UPDATE, DELETE policies for admin users
-- Using email-based admin authentication since the app uses local admin auth

-- Admin can manage travel agencies (using admin email)
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

-- RLS policies for travel_guides table
-- Admin can view all travel guides
CREATE POLICY "Admin can view all travel guides" ON travel_guides
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Admin can insert travel guides
CREATE POLICY "Admin can insert travel guides" ON travel_guides
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Admin can update travel guides
CREATE POLICY "Admin can update travel guides" ON travel_guides
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Admin can delete travel guides
CREATE POLICY "Admin can delete travel guides" ON travel_guides
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

-- Create RPC function to get users with email for admin
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