-- Travel Agencies Table
-- This table stores information about travel agencies in Algeria

CREATE TABLE travel_agencies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    wilaya VARCHAR(100) NOT NULL, -- الولاية
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    website VARCHAR(255),
    logo_url TEXT,
    rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    license_number VARCHAR(100), -- رقم الترخيص
    established_year INTEGER,
    specialties TEXT[], -- التخصصات (سياحة داخلية، خارجية، عمرة، حج، إلخ)
    languages TEXT[] DEFAULT ARRAY['العربية'], -- اللغات المدعومة
    working_hours JSONB, -- ساعات العمل
    social_media JSONB, -- روابط وسائل التواصل الاجتماعي
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Travel Agency Offers Table
-- This table stores the offers/packages provided by travel agencies
CREATE TABLE travel_agency_offers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agency_id UUID NOT NULL REFERENCES travel_agencies(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    destination VARCHAR(255) NOT NULL,
    duration_days INTEGER NOT NULL,
    price_dzd DECIMAL(10,2) NOT NULL, -- السعر بالدينار الجزائري
    original_price_dzd DECIMAL(10,2), -- السعر الأصلي قبل الخصم
    includes TEXT[], -- ما يشمله العرض
    excludes TEXT[], -- ما لا يشمله العرض
    image_urls TEXT[],
    max_participants INTEGER,
    min_participants INTEGER DEFAULT 1,
    available_from DATE,
    available_to DATE,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    category VARCHAR(100), -- نوع الرحلة (داخلية، خارجية، عمرة، حج، إلخ)
    difficulty_level VARCHAR(50), -- مستوى الصعوبة
    age_restrictions VARCHAR(100), -- قيود العمر
    requirements TEXT, -- المتطلبات
    cancellation_policy TEXT, -- سياسة الإلغاء
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Travel Agency Reviews Table
-- This table stores reviews for travel agencies
CREATE TABLE travel_agency_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agency_id UUID NOT NULL REFERENCES travel_agencies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(agency_id, user_id) -- منع المستخدم من تقييم نفس الوكالة أكثر من مرة
);

-- Indexes for better performance
CREATE INDEX idx_travel_agencies_wilaya ON travel_agencies(wilaya);
CREATE INDEX idx_travel_agencies_active ON travel_agencies(is_active);
CREATE INDEX idx_travel_agencies_verified ON travel_agencies(is_verified);
CREATE INDEX idx_travel_agencies_rating ON travel_agencies(rating DESC);
CREATE INDEX idx_travel_agencies_created_at ON travel_agencies(created_at DESC);

CREATE INDEX idx_travel_agency_offers_agency_id ON travel_agency_offers(agency_id);
CREATE INDEX idx_travel_agency_offers_active ON travel_agency_offers(is_active);
CREATE INDEX idx_travel_agency_offers_featured ON travel_agency_offers(is_featured);
CREATE INDEX idx_travel_agency_offers_price ON travel_agency_offers(price_dzd);
CREATE INDEX idx_travel_agency_offers_category ON travel_agency_offers(category);
CREATE INDEX idx_travel_agency_offers_available ON travel_agency_offers(available_from, available_to);

CREATE INDEX idx_travel_agency_reviews_agency_id ON travel_agency_reviews(agency_id);
CREATE INDEX idx_travel_agency_reviews_user_id ON travel_agency_reviews(user_id);
CREATE INDEX idx_travel_agency_reviews_rating ON travel_agency_reviews(rating DESC);
CREATE INDEX idx_travel_agency_reviews_created_at ON travel_agency_reviews(created_at DESC);

-- RLS (Row Level Security) Policies
ALTER TABLE travel_agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE travel_agency_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE travel_agency_reviews ENABLE ROW LEVEL SECURITY;

-- Public read access for active agencies
CREATE POLICY "Public can view active travel agencies" ON travel_agencies
    FOR SELECT USING (is_active = true);

-- Admin can manage travel agencies
CREATE POLICY "Admin can insert travel agencies" ON travel_agencies
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update travel agencies" ON travel_agencies
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete travel agencies" ON travel_agencies
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- Admin can view all agencies
CREATE POLICY "Admin can view all travel agencies" ON travel_agencies
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- Public read access for active offers
CREATE POLICY "Public can view active offers" ON travel_agency_offers
    FOR SELECT USING (is_active = true);

-- Admin can manage offers
CREATE POLICY "Admin can insert offers" ON travel_agency_offers
    FOR INSERT WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can update offers" ON travel_agency_offers
    FOR UPDATE USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Admin can delete offers" ON travel_agency_offers
    FOR DELETE USING (auth.jwt() ->> 'role' = 'admin');

-- Admin can view all offers
CREATE POLICY "Admin can view all offers" ON travel_agency_offers
    FOR SELECT USING (auth.jwt() ->> 'role' = 'admin');

-- Public read access for reviews
CREATE POLICY "Public can view reviews" ON travel_agency_reviews
    FOR SELECT USING (true);

-- Users can create reviews
CREATE POLICY "Users can create reviews" ON travel_agency_reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews" ON travel_agency_reviews
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete own reviews" ON travel_agency_reviews
    FOR DELETE USING (auth.uid() = user_id);

-- Function to update agency rating when reviews change
CREATE OR REPLACE FUNCTION update_agency_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE travel_agencies 
    SET 
        rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM travel_agency_reviews 
            WHERE agency_id = COALESCE(NEW.agency_id, OLD.agency_id)
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM travel_agency_reviews 
            WHERE agency_id = COALESCE(NEW.agency_id, OLD.agency_id)
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.agency_id, OLD.agency_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers to update agency rating
CREATE TRIGGER update_agency_rating_on_review_insert
    AFTER INSERT ON travel_agency_reviews
    FOR EACH ROW EXECUTE FUNCTION update_agency_rating();

CREATE TRIGGER update_agency_rating_on_review_update
    AFTER UPDATE ON travel_agency_reviews
    FOR EACH ROW EXECUTE FUNCTION update_agency_rating();

CREATE TRIGGER update_agency_rating_on_review_delete
    AFTER DELETE ON travel_agency_reviews
    FOR EACH ROW EXECUTE FUNCTION update_agency_rating();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to update updated_at
CREATE TRIGGER update_travel_agencies_updated_at
    BEFORE UPDATE ON travel_agencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_travel_agency_offers_updated_at
    BEFORE UPDATE ON travel_agency_offers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_travel_agency_reviews_updated_at
    BEFORE UPDATE ON travel_agency_reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();