-- Bookings table for managing reservations
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  guest_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  accommodation_id UUID REFERENCES public.accommodations(id) ON DELETE CASCADE,
  check_in_date DATE NOT NULL,
  check_out_date DATE NOT NULL,
  guests_count INTEGER NOT NULL DEFAULT 1,
  total_nights INTEGER GENERATED ALWAYS AS (check_out_date - check_in_date) STORED,
  price_per_night DECIMAL(10, 2) NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'DZD',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
  payment_method TEXT,
  special_requests TEXT,
  guest_notes TEXT,
  host_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT check_dates CHECK (check_out_date > check_in_date),
  CONSTRAINT check_guests CHECK (guests_count > 0),
  CONSTRAINT check_amount CHECK (total_amount > 0)
);

-- Enable RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Create indexes
CREATE INDEX idx_bookings_guest ON public.bookings(guest_id);
CREATE INDEX idx_bookings_accommodation ON public.bookings(accommodation_id);
CREATE INDEX idx_bookings_dates ON public.bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_payment_status ON public.bookings(payment_status);

-- Create trigger for updated_at
CREATE TRIGGER bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to check availability before booking
CREATE OR REPLACE FUNCTION check_accommodation_availability(
  accommodation_uuid UUID,
  check_in DATE,
  check_out DATE
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM public.bookings
    WHERE accommodation_id = accommodation_uuid
      AND status IN ('confirmed', 'pending')
      AND (
        (check_in_date <= check_in AND check_out_date > check_in) OR
        (check_in_date < check_out AND check_out_date >= check_out) OR
        (check_in_date >= check_in AND check_out_date <= check_out)
      )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;