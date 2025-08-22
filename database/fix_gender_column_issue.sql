-- Fix gender column issue in get_users_with_email RPC function
-- This script removes the non-existent gender column reference

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

-- Grant execute permission to authenticated users (admin only)
GRANT EXECUTE ON FUNCTION get_users_with_email() TO authenticated;