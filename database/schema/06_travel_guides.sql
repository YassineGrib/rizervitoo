-- Travel guides table for Algerian destinations
CREATE TABLE IF NOT EXISTS public.travel_guides (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'الجزائر',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  category TEXT NOT NULL CHECK (category IN ('historical', 'natural', 'cultural', 'adventure', 'religious', 'beach', 'mountain')),
  difficulty_level TEXT DEFAULT 'easy' CHECK (difficulty_level IN ('easy', 'moderate', 'difficult')),
  best_season TEXT,
  estimated_duration TEXT, -- e.g., '2-3 hours', '1 day', '2-3 days'
  entry_fee DECIMAL(10, 2) DEFAULT 0,
  currency TEXT DEFAULT 'DZD',
  images JSONB DEFAULT '[]'::jsonb,
  highlights JSONB DEFAULT '[]'::jsonb, -- Array of key highlights
  tips JSONB DEFAULT '[]'::jsonb, -- Array of travel tips
  nearby_accommodations JSONB DEFAULT '[]'::jsonb, -- Array of accommodation IDs
  transportation_info TEXT,
  contact_info JSONB DEFAULT '{}'::jsonb,
  opening_hours JSONB DEFAULT '{}'::jsonb,
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  views_count INTEGER DEFAULT 0,
  rating DECIMAL(2, 1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.travel_guides ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view published travel guides" ON public.travel_guides
  FOR SELECT USING (is_published = true);

CREATE POLICY "Creators can view their travel guides" ON public.travel_guides
  FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Authenticated users can create travel guides" ON public.travel_guides
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Creators can update their travel guides" ON public.travel_guides
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Creators can delete their travel guides" ON public.travel_guides
  FOR DELETE USING (auth.uid() = created_by);

-- Create indexes
CREATE INDEX idx_travel_guides_city ON public.travel_guides(city);
CREATE INDEX idx_travel_guides_state ON public.travel_guides(state);
CREATE INDEX idx_travel_guides_category ON public.travel_guides(category);
CREATE INDEX idx_travel_guides_published ON public.travel_guides(is_published);
CREATE INDEX idx_travel_guides_featured ON public.travel_guides(is_featured);
CREATE INDEX idx_travel_guides_location ON public.travel_guides(latitude, longitude);
CREATE INDEX idx_travel_guides_rating ON public.travel_guides(rating DESC);
CREATE INDEX idx_travel_guides_views ON public.travel_guides(views_count DESC);

-- Create trigger for updated_at
CREATE TRIGGER travel_guides_updated_at
  BEFORE UPDATE ON public.travel_guides
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to increment views count
CREATE OR REPLACE FUNCTION increment_guide_views(guide_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.travel_guides 
  SET views_count = views_count + 1 
  WHERE id = guide_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;