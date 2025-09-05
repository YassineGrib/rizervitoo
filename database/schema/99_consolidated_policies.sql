-- 99_consolidated_policies.sql
-- هدف الملف: تنظيف كل سياسات RLS الحالية وإنشاء مجموعة سياسات موحّدة ومتسقة
-- كما يضيف عمود email في profiles ويزامنه مع auth.users، ويوحّد فحص الأدمن عبر دالة is_admin()

BEGIN;

-- 1) دالة موحدة لفحص صلاحيات الأدمن
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin boolean;
BEGIN
  v_is_admin := EXISTS (
    SELECT 1
    FROM auth.users u
    WHERE u.id = auth.uid()
      AND (
        u.email = 'admin@rizervitoo.dz'
        OR COALESCE(u.raw_app_meta_data->>'role','') = 'admin'
        OR COALESCE((auth.jwt())->>'role','') = 'admin'
      )
  );
  RETURN COALESCE(v_is_admin, false);
END;
$$;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- 2) إضافة عمود البريد الإلكتروني إلى profiles + مزامنة مع auth.users
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- تحديث دالة إنشاء بروفايل المستخدم الجديد لتعبئة البريد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- دالة ومُشغّل لمزامنة البريد عند تغييره في auth.users
CREATE OR REPLACE FUNCTION public.sync_profile_email()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles p
  SET email = NEW.email,
      updated_at = NOW()
  WHERE p.id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_email_updated ON auth.users;
CREATE TRIGGER on_auth_user_email_updated
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.sync_profile_email();

-- 3) تحديث دالة get_users_with_email للاعتماد على is_admin() واسترجاع البريد من profiles أو auth.users
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
) AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Access denied. Admin privileges required.';
  END IF;
  
  RETURN QUERY
  SELECT 
    p.id,
    p.full_name,
    COALESCE(p.email, au.email) AS email,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_users_with_email() TO authenticated;

-- 4) إسقاط كل السياسات الحالية ديناميكيًا للجداول المستهدفة
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN (
        'profiles','accommodations','bookings','reviews','messages',
        'travel_agencies','travel_agency_offers','travel_agency_reviews'
      )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- 5) تفعيل RLS للجداول
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_agency_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.travel_agency_reviews ENABLE ROW LEVEL SECURITY;

-- 6) سياسات موحّدة ومتسقة

-- profiles
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Admin can view all profiles" ON public.profiles
  FOR SELECT USING (public.is_admin());
CREATE POLICY "Admin can update all profiles" ON public.profiles
  FOR UPDATE USING (public.is_admin());

-- accommodations
CREATE POLICY "Public can view verified available accommodations" ON public.accommodations
  FOR SELECT USING (is_available = true AND is_verified = true);
CREATE POLICY "Owners can view their accommodations" ON public.accommodations
  FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "Owners can insert accommodations" ON public.accommodations
  FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update their accommodations" ON public.accommodations
  FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Owners can delete their accommodations" ON public.accommodations
  FOR DELETE USING (auth.uid() = owner_id);
CREATE POLICY "Admin can manage all accommodations" ON public.accommodations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- bookings
CREATE POLICY "Guests can view their bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = guest_id);
CREATE POLICY "Hosts can view bookings for their accommodations" ON public.bookings
  FOR SELECT USING (
    auth.uid() IN (
      SELECT owner_id FROM public.accommodations 
      WHERE id = accommodation_id
    )
  );
CREATE POLICY "Guests can insert bookings" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = guest_id);
CREATE POLICY "Guests can update their bookings" ON public.bookings
  FOR UPDATE USING (auth.uid() = guest_id);
CREATE POLICY "Hosts can update bookings for their accommodations" ON public.bookings
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT owner_id FROM public.accommodations 
      WHERE id = accommodation_id
    )
  );
CREATE POLICY "Admin can manage all bookings" ON public.bookings
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- reviews
CREATE POLICY "Anyone can view verified reviews" ON public.reviews
  FOR SELECT USING (is_verified = true);
CREATE POLICY "Guests can view their reviews" ON public.reviews
  FOR SELECT USING (auth.uid() = guest_id);
CREATE POLICY "Hosts can view reviews for their accommodations" ON public.reviews
  FOR SELECT USING (
    auth.uid() IN (
      SELECT owner_id FROM public.accommodations 
      WHERE id = accommodation_id
    )
  );
CREATE POLICY "Guests can insert reviews for their completed bookings" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.uid() = guest_id AND
    EXISTS (
      SELECT 1 FROM public.bookings 
      WHERE id = booking_id 
        AND guest_id = auth.uid() 
        AND status = 'completed'
    )
  );
CREATE POLICY "Guests can update their reviews" ON public.reviews
  FOR UPDATE USING (auth.uid() = guest_id);
CREATE POLICY "Hosts can update host_reply for their accommodations" ON public.reviews
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT owner_id FROM public.accommodations 
      WHERE id = accommodation_id
    )
  );
CREATE POLICY "Admin can manage all reviews" ON public.reviews
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- messages
CREATE POLICY "Users can view their conversations" ON public.messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON public.messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND (
      -- المرسل ضيف الحجز، والمستلم هو صاحب الاستضافة
      (
        EXISTS (
          SELECT 1 FROM public.bookings b 
          JOIN public.accommodations a ON a.id = b.accommodation_id
          WHERE b.id = booking_id 
            AND b.guest_id = auth.uid() 
            AND a.owner_id = receiver_id
        )
      ) OR (
      -- المرسل صاحب الاستضافة، والمستلم هو ضيف الحجز
        EXISTS (
          SELECT 1 FROM public.bookings b 
          JOIN public.accommodations a ON a.id = b.accommodation_id
          WHERE b.id = booking_id 
            AND a.owner_id = auth.uid() 
            AND b.guest_id = receiver_id
        )
      )
    )
  );
CREATE POLICY "Users can update their messages" ON public.messages
  FOR UPDATE USING (auth.uid() = sender_id);
CREATE POLICY "Users can mark messages as read" ON public.messages
  FOR UPDATE USING (auth.uid() = receiver_id);
CREATE POLICY "Admin can manage all messages" ON public.messages
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- travel_agencies
CREATE POLICY "Public can view active travel agencies" ON public.travel_agencies
  FOR SELECT USING (is_active = true);
CREATE POLICY "Admin can view all travel agencies" ON public.travel_agencies
  FOR SELECT USING (public.is_admin());
CREATE POLICY "Admin can insert travel agencies" ON public.travel_agencies
  FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "Admin can update travel agencies" ON public.travel_agencies
  FOR UPDATE USING (public.is_admin());
CREATE POLICY "Admin can delete travel agencies" ON public.travel_agencies
  FOR DELETE USING (public.is_admin());

-- travel_agency_offers
CREATE POLICY "Public can view active offers" ON public.travel_agency_offers
  FOR SELECT USING (is_active = true);
CREATE POLICY "Admin can view all offers" ON public.travel_agency_offers
  FOR SELECT USING (public.is_admin());
CREATE POLICY "Admin can insert offers" ON public.travel_agency_offers
  FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "Admin can update offers" ON public.travel_agency_offers
  FOR UPDATE USING (public.is_admin());
CREATE POLICY "Admin can delete offers" ON public.travel_agency_offers
  FOR DELETE USING (public.is_admin());

-- travel_agency_reviews
CREATE POLICY "Public can view reviews" ON public.travel_agency_reviews
  FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON public.travel_agency_reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reviews" ON public.travel_agency_reviews
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reviews" ON public.travel_agency_reviews
  FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Admin can manage travel agency reviews" ON public.travel_agency_reviews
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

COMMIT;