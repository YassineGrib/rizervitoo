-- Accommodations table for hotels, houses, apartments, etc.
CREATE TABLE IF NOT EXISTS public.accommodations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('hotel', 'house', 'apartment', 'villa', 'guesthouse', 'hostel')),
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL DEFAULT 'الجزائر',
  country TEXT NOT NULL DEFAULT 'الجزائر',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  price_per_night DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'DZD',
  max_guests INTEGER NOT NULL DEFAULT 1,
  bedrooms INTEGER DEFAULT 1,
  bathrooms INTEGER DEFAULT 1,
  amenities JSONB DEFAULT '[]'::jsonb,
  images JSONB DEFAULT '[]'::jsonb,
  is_available BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  rating DECIMAL(2, 1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.accommodations ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view available accommodations" ON public.accommodations
  FOR SELECT USING (is_available = true AND is_verified = true);

CREATE POLICY "Owners can view their accommodations" ON public.accommodations
  FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Owners can insert accommodations" ON public.accommodations
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their accommodations" ON public.accommodations
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their accommodations" ON public.accommodations
  FOR DELETE USING (auth.uid() = owner_id);

-- Create indexes for better performance
CREATE INDEX idx_accommodations_city ON public.accommodations(city);
CREATE INDEX idx_accommodations_type ON public.accommodations(type);
CREATE INDEX idx_accommodations_price ON public.accommodations(price_per_night);
CREATE INDEX idx_accommodations_available ON public.accommodations(is_available, is_verified);
CREATE INDEX idx_accommodations_location ON public.accommodations(latitude, longitude);

-- Create trigger for updated_at
CREATE TRIGGER accommodations_updated_at
  BEFORE UPDATE ON public.accommodations
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();