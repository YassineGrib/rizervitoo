-- Create admin user in Supabase
-- This script creates the admin user that can manage travel agencies

-- First, we need to insert the admin user into auth.users table
-- Note: This should be done through Supabase Dashboard or Auth API
-- The password should be hashed properly by Supabase

-- For now, we'll create a temporary solution using a function
-- that can be called to create the admin user

CREATE OR REPLACE FUNCTION create_admin_user()
RETURNS TEXT AS $$
DECLARE
    admin_exists BOOLEAN;
BEGIN
    -- Check if admin user already exists
    SELECT EXISTS(
        SELECT 1 FROM auth.users 
        WHERE email = 'admin@rizervitoo.dz'
    ) INTO admin_exists;
    
    IF admin_exists THEN
        RETURN 'Admin user already exists';
    ELSE
        -- Note: In production, you should create the admin user through:
        -- 1. Supabase Dashboard -> Authentication -> Users -> Invite User
        -- 2. Or use Supabase Auth API with proper password hashing
        -- 3. Or use supabase CLI: supabase auth users create admin@rizervitoo.dz --password=RizerAdmin2025!
        
        RETURN 'Please create admin user through Supabase Dashboard or CLI';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Instructions for creating admin user:
-- 1. Go to Supabase Dashboard
-- 2. Navigate to Authentication -> Users
-- 3. Click "Invite User"
-- 4. Email: admin@rizervitoo.dz
-- 5. Password: RizerAdmin2025!
-- 6. Or use CLI: supabase auth users create admin@rizervitoo.dz --password=RizerAdmin2025!

-- After creating the admin user, run the RLS policies from fix_rls_policies.sql