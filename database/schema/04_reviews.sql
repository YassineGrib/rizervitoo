-- Reviews table for guest feedback
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  guest_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  accommodation_id UUID REFERENCES public.accommodations(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title TEXT,
  comment TEXT,
  cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
  location_rating INTEGER CHECK (location_rating >= 1 AND location_rating <= 5),
  value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  images JSONB DEFAULT '[]'::jsonb,
  is_verified BOOLEAN DEFAULT false,
  host_reply TEXT,
  host_reply_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one review per booking
  UNIQUE(booking_id)
);

-- Enable RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Create indexes
CREATE INDEX idx_reviews_accommodation ON public.reviews(accommodation_id);
CREATE INDEX idx_reviews_guest ON public.reviews(guest_id);
CREATE INDEX idx_reviews_rating ON public.reviews(rating);
CREATE INDEX idx_reviews_verified ON public.reviews(is_verified);

-- Create trigger for updated_at
CREATE TRIGGER reviews_updated_at
  BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to update accommodation rating when review is added/updated
CREATE OR REPLACE FUNCTION update_accommodation_rating()
RETURNS TRIGGER AS $$
DECLARE
  avg_rating DECIMAL(2,1);
  review_count INTEGER;
BEGIN
  -- Calculate new average rating and count
  SELECT 
    ROUND(AVG(rating), 1),
    COUNT(*)
  INTO avg_rating, review_count
  FROM public.reviews 
  WHERE accommodation_id = COALESCE(NEW.accommodation_id, OLD.accommodation_id)
    AND is_verified = true;
  
  -- Update accommodation
  UPDATE public.accommodations 
  SET 
    rating = COALESCE(avg_rating, 0.0),
    total_reviews = COALESCE(review_count, 0)
  WHERE id = COALESCE(NEW.accommodation_id, OLD.accommodation_id);
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for rating updates
CREATE TRIGGER update_accommodation_rating_on_insert
  AFTER INSERT ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_accommodation_rating();

CREATE TRIGGER update_accommodation_rating_on_update
  AFTER UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_accommodation_rating();

CREATE TRIGGER update_accommodation_rating_on_delete
  AFTER DELETE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_accommodation_rating();