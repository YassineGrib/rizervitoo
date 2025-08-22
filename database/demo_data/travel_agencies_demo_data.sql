-- بيانات تجريبية للوكالات السياحية الجزائرية
-- Demo data for Algerian travel agencies

-- إدراج الوكالات السياحية
INSERT INTO travel_agencies (
    id,
    name,
    description,
    address,
    wilaya,
    phone,
    email,
    website,R
    logo_url,
    rating,
    total_reviews,
    is_active,
    created_at,
    updated_at
) VALUES 
(
    gen_random_uuid(),
    'وكالة الأندلس للسياحة والسفر',
    'وكالة سياحية رائدة في الجزائر تقدم خدمات السفر والسياحة الداخلية والخارجية. نحن متخصصون في تنظيم الرحلات السياحية إلى أجمل الوجهات في الجزائر والعالم.',
    'شارع ديدوش مراد، الجزائر العاصمة',
    'الجزائر',
    '+213 21 123 456',
    'info@andalus-travel.dz',
    'https://www.andalus-travel.dz',
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=500',
    4.5,
    127,
    true,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'وكالة الصحراء الذهبية',
    'متخصصون في رحلات الصحراء والمغامرات. اكتشف جمال الصحراء الجزائرية مع خبرائنا في السياحة الصحراوية.',
    'حي بن عكنون، الجزائر العاصمة',
    'الجزائر',
    '+213 21 987 654',
    'contact@golden-sahara.dz',
    'https://www.golden-sahara.dz',
    'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=500',
    4.7,
    89,
    true,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'وكالة البحر الأبيض المتوسط',
    'وكالة سياحية متخصصة في الرحلات البحرية والسياحة الساحلية. استمتع بأجمل الشواطئ والمنتجعات على الساحل الجزائري.',
    'شارع الأمير عبد القادر، وهران',
    'وهران',
    '+213 41 555 777',
    'info@mediterranean-travel.dz',
    'https://www.mediterranean-travel.dz',
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500',
    4.3,
    156,
    true,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'وكالة الأطلس للسياحة الجبلية',
    'اكتشف جبال الأطلس والطبيعة الخلابة في الجزائر. نقدم رحلات المشي لمسافات طويلة والتخييم في أجمل المناطق الجبلية.',
    'شارع العربي بن مهيدي، قسنطينة',
    'قسنطينة',
    '+213 31 444 888',
    'atlas@mountain-tours.dz',
    'https://www.mountain-tours.dz',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
    4.6,
    73,
    true,
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'وكالة التراث الجزائري',
    'متخصصون في السياحة الثقافية والتراثية. اكتشف تاريخ وثقافة الجزائر من خلال جولاتنا المنظمة للمواقع الأثرية والتاريخية.',
    'شارع الاستقلال، تلمسان',
    'تلمسان',
    '+213 43 333 999',
    'heritage@algeria-tours.dz',
    'https://www.algeria-heritage.dz',
    'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=500',
    4.4,
    94,
    true,
    NOW(),
    NOW()
);

-- إدراج عروض الوكالات السياحية
-- سيتم إدراج العروض بعد إنشاء الوكالات
WITH agency_ids AS (
    SELECT id, name FROM travel_agencies WHERE name IN (
        'وكالة الأندلس للسياحة والسفر',
        'وكالة الصحراء الذهبية',
        'وكالة البحر الأبيض المتوسط',
        'وكالة الأطلس للسياحة الجبلية',
        'وكالة التراث الجزائري'
    )
)
INSERT INTO travel_agency_offers (
    id,
    agency_id,
    title,
    description,
    destination,
    duration_days,
    price_dzd,
    max_participants,
    includes,
    excludes,
    image_urls,
    is_active,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    a.id,
    offer.title,
    offer.description,
    offer.destination,
    offer.duration_days,
    offer.price_dzd,
    offer.max_participants,
    offer.includes,
    offer.excludes,
    offer.image_urls,
    true,
    NOW(),
    NOW()
FROM agency_ids a
CROSS JOIN (
    VALUES 
    ('رحلة إلى الجزائر العاصمة', 'جولة شاملة في العاصمة تشمل زيارة القصبة والمتاحف والأسواق التقليدية', 'الجزائر العاصمة', 3, 15000.00, 25, ARRAY['الإقامة', 'وجبات الطعام', 'النقل', 'دليل سياحي'], ARRAY['تذاكر الطيران', 'المشتريات الشخصية'], ARRAY['https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=500']),
    ('مغامرة في الصحراء الكبرى', 'رحلة استكشافية لمدة 5 أيام في الصحراء مع التخييم تحت النجوم', 'تمنراست', 5, 35000.00, 15, ARRAY['الإقامة في الخيام', 'جميع الوجبات', 'النقل بسيارات الدفع الرباعي', 'دليل محلي'], ARRAY['المعدات الشخصية', 'التأمين'], ARRAY['https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=500']),
    ('عطلة على الساحل الجزائري', 'استمتع بأسبوع رائع على شواطئ الجزائر الخلابة', 'وهران', 7, 25000.00, 30, ARRAY['الإقامة في فندق 4 نجوم', 'الإفطار والعشاء', 'الأنشطة المائية'], ARRAY['الغداء', 'المشروبات الكحولية'], ARRAY['https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500']),
    ('تسلق جبال الأطلس', 'مغامرة تسلق الجبال للمحترفين والمبتدئين', 'تيزي وزو', 4, 20000.00, 12, ARRAY['المعدات اللازمة', 'دليل متخصص', 'وجبات الطعام', 'الإسعافات الأولية'], ARRAY['الملابس الشخصية', 'التأمين الصحي'], ARRAY['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500']),
    ('جولة التراث والثقافة', 'اكتشف المواقع الأثرية والتراثية في الجزائر', 'تلمسان', 6, 18000.00, 20, ARRAY['الإقامة', 'النقل المكيف', 'دليل ثقافي متخصص', 'رسوم دخول المواقع'], ARRAY['الوجبات', 'الهدايا التذكارية'], ARRAY['https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=500'])
) AS offer(title, description, destination, duration_days, price_dzd, max_participants, includes, excludes, image_urls)
WHERE 
    (a.name = 'وكالة الأندلس للسياحة والسفر' AND offer.title = 'رحلة إلى الجزائر العاصمة') OR
    (a.name = 'وكالة الصحراء الذهبية' AND offer.title = 'مغامرة في الصحراء الكبرى') OR
    (a.name = 'وكالة البحر الأبيض المتوسط' AND offer.title = 'عطلة على الساحل الجزائري') OR
    (a.name = 'وكالة الأطلس للسياحة الجبلية' AND offer.title = 'تسلق جبال الأطلس') OR
    (a.name = 'وكالة التراث الجزائري' AND offer.title = 'جولة التراث والثقافة');

-- إدراج مراجعات العملاء
-- سيتم إدراج المراجعات بعد إنشاء الوكالات
WITH agency_ids AS (
    SELECT id, name FROM travel_agencies WHERE name IN (
        'وكالة الأندلس للسياحة والسفر',
        'وكالة الصحراء الذهبية',
        'وكالة البحر الأبيض المتوسط',
        'وكالة الأطلس للسياحة الجبلية',
        'وكالة التراث الجزائري'
    )
)
INSERT INTO travel_agency_reviews (
    id,
    agency_id,
    user_id,
    rating,
    comment,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    a.id,
    (SELECT id FROM profiles LIMIT 1), -- استخدام أول مستخدم متاح
    review.rating,
    review.comment,
    NOW() - (random() * interval '30 days'), -- مراجعات عشوائية خلال الشهر الماضي
    NOW() - (random() * interval '30 days')
FROM agency_ids a
CROSS JOIN (
    VALUES 
    (5, 'خدمة ممتازة ورحلة رائعة! أنصح بشدة بهذه الوكالة.'),
    (4, 'تجربة جيدة جداً، الفريق محترف والتنظيم ممتاز.'),
    (5, 'أفضل وكالة سياحية جربتها في الجزائر، خدمة عالية الجودة.'),
    (4, 'رحلة لا تُنسى مع تنظيم رائع وأسعار معقولة.'),
    (3, 'خدمة جيدة لكن يمكن تحسين بعض الجوانب.')
) AS review(rating, comment)
LIMIT 25; -- إضافة 5 مراجعات لكل وكالة

-- تحديث عدد المراجعات والتقييمات للوكالات
UPDATE travel_agencies 
SET 
    total_reviews = (
        SELECT COUNT(*) 
        FROM travel_agency_reviews 
        WHERE agency_id = travel_agencies.id
    ),
    rating = (
        SELECT ROUND(AVG(rating)::numeric, 1) 
        FROM travel_agency_reviews 
        WHERE agency_id = travel_agencies.id
    ),
    updated_at = NOW()
WHERE id IN (
    SELECT id FROM travel_agencies 
    WHERE name IN (
        'وكالة الأندلس للسياحة والسفر',
        'وكالة الصحراء الذهبية',
        'وكالة البحر الأبيض المتوسط',
        'وكالة الأطلس للسياحة الجبلية',
        'وكالة التراث الجزائري'
    )
);

-- رسالة تأكيد
DO $$
BEGIN
    RAISE NOTICE 'تم إدراج البيانات التجريبية للوكالات السياحية بنجاح!';
    RAISE NOTICE 'Demo data for travel agencies inserted successfully!';
END $$;