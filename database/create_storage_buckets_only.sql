-- ============================================================================
-- إنشاء Storage Buckets المطلوبة فقط
-- Create Required Storage Buckets Only
-- ============================================================================
-- هذا السكريبت ينشئ الـ buckets المطلوبة فقط دون التعامل مع سياسات storage.objects
-- This script creates only the required buckets without dealing with storage.objects policies

-- ============================================================================
-- 1. إنشاء bucket للأدلة السياحية / Create travel guides bucket
-- ============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'travel_guides',
  'travel_guides', 
  true,
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- 2. إنشاء bucket لصور الإقامات / Create accommodation images bucket
-- ============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'accommodation-images',
  'accommodation-images',
  true,
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- 3. إنشاء bucket للصور الشخصية / Create avatars bucket
-- ============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- 4. إنشاء bucket لصور التقييمات / Create reviews bucket
-- ============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'reviews',
  'reviews',
  true,
  20971520, -- 20MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- 5. التحقق من إنشاء الـ buckets / Verify bucket creation
-- ============================================================================
SELECT 
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types,
    created_at
FROM storage.buckets 
WHERE id IN ('travel_guides', 'accommodation-images', 'avatars', 'reviews')
ORDER BY id;

-- ============================================================================
-- ملاحظات مهمة / Important Notes
-- ============================================================================
/*
1. هذا السكريبت ينشئ الـ buckets فقط
   This script creates buckets only

2. السياسات (RLS Policies) يجب إنشاؤها من Supabase Dashboard
   Policies (RLS Policies) must be created from Supabase Dashboard

3. خطوات إنشاء السياسات يدوياً:
   Steps to create policies manually:
   
   أ) اذهب إلى Supabase Dashboard > Storage
   a) Go to Supabase Dashboard > Storage
   
   ب) اختر bucket > Policies
   b) Select bucket > Policies
   
   ج) أنشئ السياسات التالية لكل bucket:
   c) Create the following policies for each bucket:
   
   - Policy للقراءة العامة (SELECT):
   - Policy for public read (SELECT):
     Name: "Public read access"
     Operation: SELECT
     Target roles: public
     USING expression: true
   
   - Policy للرفع للمستخدمين المسجلين (INSERT):
   - Policy for authenticated upload (INSERT):
     Name: "Authenticated upload"
     Operation: INSERT
     Target roles: authenticated
     WITH CHECK expression: auth.role() = 'authenticated'
   
   - Policy لإدارة الملفات الشخصية (UPDATE/DELETE):
   - Policy for personal file management (UPDATE/DELETE):
     Name: "Own files management"
     Operation: UPDATE, DELETE
     Target roles: authenticated
     USING expression: auth.uid()::text = owner

4. للمدير (admin@rizervitoo.dz)، أضف سياسة إضافية:
   For admin (admin@rizervitoo.dz), add additional policy:
   Name: "Admin full access"
   Operation: ALL
   Target roles: authenticated
   USING expression: 
   EXISTS (
     SELECT 1 FROM auth.users 
     WHERE auth.users.id = auth.uid() 
     AND auth.users.email = 'admin@rizervitoo.dz'
   )
*/