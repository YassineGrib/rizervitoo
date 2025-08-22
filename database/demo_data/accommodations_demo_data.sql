INSERT INTO accommodations (
    owner_id,
    title,
    description,
    type,
    address,
    city,
    state,
    country,
    latitude,
    longitude,
    price_per_night,
    currency,
    max_guests,
    bedrooms,
    bathrooms,
    amenities,
    images,
    is_available,
    is_verified,
    rating,
    total_reviews
) VALUES
-- Luxury Hotel in Algiers
(
    '4fa1fe91-183f-4c9d-ad64-512e65971ec0',
    'فندق الأوراسي الفاخر - الجزائر العاصمة',
    'فندق فاخر في قلب العاصمة الجزائرية مع إطلالة رائعة على البحر الأبيض المتوسط والقصبة التاريخية. يوفر خدمات من الدرجة الأولى ومرافق عالمية المستوى مع لمسة جزائرية أصيلة.',
    'hotel',
    'شارع فرانتز فانون، وسط الجزائر العاصمة',
    'الجزائر العاصمة',
    'الجزائر',
    'الجزائر',
    36.753768,
    3.058756,
    15000.00,
    'DZD',
    4,
    2,
    2,
    to_jsonb(ARRAY['واي فاي مجاني', 'مسبح', 'سبا', 'مطعم', 'خدمة الغرف', 'موقف سيارات', 'صالة رياضية', 'إطلالة على البحر', 'مكيف هواء']),
    to_jsonb(ARRAY['https://images.unsplash.com/photo-1566073771259-6a8506099945', 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d']),
    true,
    true,
    4.7,
    142
),

-- Traditional Guesthouse in Constantine
(
    '4fa1fe91-183f-4c9d-ad64-512e65971ec0',
    'دار ضيافة تقليدية - قسنطينة مدينة الجسور',
    'بيت ضيافة أصيل في مدينة قسنطينة العريقة، يعكس التراث الجزائري الأصيل مع وسائل الراحة العصرية. موقع مثالي لاستكشاف جسور المدينة المعلقة والمعالم التاريخية.',
    'guesthouse',
    'حي سوق العصر، قسنطينة القديمة',
    'قسنطينة',
    'قسنطينة',
    'الجزائر',
    36.365000,
    6.614722,
    8500.00,
    'DZD',
    6,
    3,
    2,
    to_jsonb(ARRAY['واي فاي مجاني', 'إفطار تقليدي', 'مكيف هواء', 'جلسة عربية تقليدية', 'موقف سيارات', 'حديقة داخلية', 'ديكور تراثي', 'شاي بالنعناع']),
    to_jsonb(ARRAY['https://images.unsplash.com/photo-1571896349842-33c89424de2d', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c']),
    true,
    true,
    4.5,
    89
);

-- تحديث الـ timestamps لتكون حديثة
UPDATE accommodations 
SET 
    created_at = NOW() - INTERVAL '15 days' * RANDOM(),
    updated_at = NOW() - INTERVAL '3 days' * RANDOM()
WHERE owner_id = '4fa1fe91-183f-4c9d-ad64-512e65971ec0';
