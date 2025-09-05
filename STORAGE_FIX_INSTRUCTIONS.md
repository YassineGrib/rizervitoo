# إصلاح مشكلة رفع الصور في Supabase Storage
# Fix Image Upload Issues in Supabase Storage

## المشكلة / Problem
عند محاولة رفع صورة في إدارة الأدلة السياحية، يظهر الخطأ التالي:
```
StorageException: violates row-level security policy
statusCode: 403
error: Unauthorized
```

## السبب / Root Cause
المشكلة تحدث بسبب:
1. عدم وجود buckets مطلوبة في Supabase Storage
2. عدم وجود صلاحيات Storage (RLS policies) للـ buckets
3. عدم إعداد صلاحيات الوصول للملفات

## الحل / Solution

### الخطوة 1: إنشاء Buckets في Supabase Dashboard

1. **افتح لوحة تحكم Supabase**:
   - اذهب إلى: https://supabase.com/dashboard
   - اختر مشروع Rizervitoo

2. **اذهب إلى Storage**:
   - من القائمة الجانبية، انقر على **Storage**

3. **أنشئ البuckets التالية**:
   
   **أ) Bucket للأدلة السياحية:**
   - انقر على **New Bucket**
   - **Name**: `travel_guides`
   - **Public**: ✅ Yes
   - **File size limit**: `5 MB`
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp,image/jpg`
   - انقر على **Create Bucket**
   
   **ب) Bucket للإقامات:**
   - انقر على **New Bucket**
   - **Name**: `accommodation-images`
   - **Public**: ✅ Yes
   - **File size limit**: `5 MB`
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp,image/jpg`
   - انقر على **Create Bucket**
   
   **ج) Bucket للصور الشخصية:**
   - انقر على **New Bucket**
   - **Name**: `avatars`
   - **Public**: ✅ Yes
   - **File size limit**: `2 MB`
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp,image/jpg`
   - انقر على **Create Bucket**
   
   **د) Bucket للتقييمات:**
   - انقر على **New Bucket**
   - **Name**: `reviews`
   - **Public**: ✅ Yes
   - **File size limit**: `5 MB`
   - **Allowed MIME types**: `image/jpeg,image/png,image/webp,image/jpg`
   - انقر على **Create Bucket**

### الخطوة 2: تطبيق صلاحيات Storage

⚠️ **تحديث مهم**: إذا واجهت خطأ `ERROR: 42501: must be owner of table objects` عند تشغيل السكريبت، فهذا يعني أنك لا تملك صلاحيات المالك لجدول storage.objects. في هذه الحالة، ستحتاج لإنشاء السياسات يدوياً من خلال Supabase Dashboard.

1. **اذهب إلى SQL Editor**:
   - من القائمة الجانبية، انقر على **SQL Editor**

2. **انسخ والصق محتوى ملف `fix_storage_policies.sql`**:
   ```sql
   -- إصلاح مشكلة رفع الصور في Supabase Storage
   -- Fix for image upload issues in Supabase Storage
   
   -- Enable RLS on storage.objects table
   ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
   
   -- صلاحيات bucket travel_guides
   DROP POLICY IF EXISTS "Allow authenticated users to upload travel guide images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow public read access to travel guide images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow admin to manage travel guide images" ON storage.objects;
   
   CREATE POLICY "Allow authenticated users to upload travel guide images" ON storage.objects
     FOR INSERT WITH CHECK (
       bucket_id = 'travel_guides' AND
       auth.role() = 'authenticated'
     );
   
   CREATE POLICY "Allow public read access to travel guide images" ON storage.objects
     FOR SELECT USING (
       bucket_id = 'travel_guides'
     );
   
   CREATE POLICY "Allow admin to manage travel guide images" ON storage.objects
     FOR ALL USING (
       bucket_id = 'travel_guides' AND
       (
         auth.uid()::text = owner OR
         EXISTS (
           SELECT 1 FROM auth.users 
           WHERE auth.users.id = auth.uid() 
           AND auth.users.email = 'admin@rizervitoo.dz'
         )
       )
     );
   
   -- صلاحيات bucket accommodation-images
   DROP POLICY IF EXISTS "Allow authenticated users to upload accommodation images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow public read access to accommodation images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow owners to manage accommodation images" ON storage.objects;
   
   CREATE POLICY "Allow authenticated users to upload accommodation images" ON storage.objects
     FOR INSERT WITH CHECK (
       bucket_id = 'accommodation-images' AND
       auth.role() = 'authenticated'
     );
   
   CREATE POLICY "Allow public read access to accommodation images" ON storage.objects
     FOR SELECT USING (
       bucket_id = 'accommodation-images'
     );
   
   CREATE POLICY "Allow owners to manage accommodation images" ON storage.objects
     FOR ALL USING (
       bucket_id = 'accommodation-images' AND
       auth.uid()::text = owner
     );
   
   -- صلاحيات bucket avatars
   DROP POLICY IF EXISTS "Allow users to upload their avatars" ON storage.objects;
   DROP POLICY IF EXISTS "Allow public read access to avatars" ON storage.objects;
   DROP POLICY IF EXISTS "Allow users to manage their avatars" ON storage.objects;
   
   CREATE POLICY "Allow users to upload their avatars" ON storage.objects
     FOR INSERT WITH CHECK (
       bucket_id = 'avatars' AND
       auth.role() = 'authenticated' AND
       auth.uid()::text = owner
     );
   
   CREATE POLICY "Allow public read access to avatars" ON storage.objects
     FOR SELECT USING (
       bucket_id = 'avatars'
     );
   
   CREATE POLICY "Allow users to manage their avatars" ON storage.objects
     FOR ALL USING (
       bucket_id = 'avatars' AND
       auth.uid()::text = owner
     );
   
   -- صلاحيات bucket reviews
   DROP POLICY IF EXISTS "Allow users to upload review images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow public read access to review images" ON storage.objects;
   DROP POLICY IF EXISTS "Allow users to manage their review images" ON storage.objects;
   
   CREATE POLICY "Allow users to upload review images" ON storage.objects
     FOR INSERT WITH CHECK (
       bucket_id = 'reviews' AND
       auth.role() = 'authenticated' AND
       auth.uid()::text = owner
     );
   
   CREATE POLICY "Allow public read access to review images" ON storage.objects
     FOR SELECT USING (
       bucket_id = 'reviews'
     );
   
   CREATE POLICY "Allow users to manage their review images" ON storage.objects
     FOR ALL USING (
       bucket_id = 'reviews' AND
       auth.uid()::text = owner
     );
   ```

3. **شغل الكود**:
   - انقر على **Run** أو اضغط `Ctrl + Enter`

### الخطوة 3: التحقق من الإعدادات

1. **تحقق من البuckets**:
   - ارجع إلى **Storage**
   - تأكد من وجود جميع البuckets الأربعة

2. **تحقق من الصلاحيات**:
   - في **SQL Editor**، شغل الاستعلام التالي:
   ```sql
   SELECT 
       schemaname,
       tablename,
       policyname,
       cmd
   FROM pg_policies 
   WHERE tablename = 'objects' 
     AND schemaname = 'storage'
   ORDER BY policyname;
   ```

### الخطوة 4: اختبار رفع الصور

1. **تأكد من تسجيل الدخول**:
   - تأكد من أن المستخدم الإداري (`admin@rizervitoo.dz`) مسجل دخول في التطبيق

2. **اختبر رفع صورة**:
   - اذهب إلى إدارة الأدلة السياحية
   - حاول إضافة دليل جديد مع صورة
   - يجب أن يعمل رفع الصورة بنجاح الآن

## استكشاف الأخطاء / Troubleshooting

### إذا استمرت المشكلة:

1. **تحقق من تسجيل الدخول**:
   ```dart
   final user = Supabase.instance.client.auth.currentUser;
   print('Current user: ${user?.email}');
   ```

2. **تحقق من اسم البucket**:
   - تأكد من أن اسم البucket في الكود يطابق الاسم في Supabase
   - في الكود: `'travel_guides'`

3. **تحقق من حجم الصورة**:
   - تأكد من أن حجم الصورة لا يتجاوز 5MB

4. **تحقق من نوع الملف**:
   - تأكد من أن الصورة من النوع المسموح (JPEG, PNG, WebP)

### رسائل الخطأ الشائعة:

- **"Bucket not found"**: البucket غير موجود - أنشئه في Storage
- **"Unauthorized"**: مشكلة في الصلاحيات - طبق ملف `fix_storage_policies.sql`
- **"File too large"**: حجم الملف كبير - قلل حجم الصورة
- **"Invalid file type"**: نوع الملف غير مسموح - استخدم JPEG أو PNG

## ملاحظات مهمة / Important Notes

1. **الأمان**: جميع البuckets مُعدة كـ Public للقراءة فقط
2. **الرفع**: يتطلب تسجيل دخول للرفع
3. **الحجم**: الحد الأقصى 5MB للصور العادية، 2MB للصور الشخصية
4. **الأنواع**: JPEG, PNG, WebP, JPG مسموحة فقط

## اختبار سريع / Quick Test

لاختبار الإعداد بسرعة:

1. سجل دخول كمدير في التطبيق
2. اذهب إلى إدارة الأدلة السياحية
3. انقر على "اختبار التخزين" (إذا كان متوفراً)
4. حاول رفع صورة صغيرة (أقل من 1MB)

إذا نجح الاختبار، فالمشكلة محلولة! 🎉

---

**آخر تحديث**: يناير 2025  
**الإصدار**: 1.0