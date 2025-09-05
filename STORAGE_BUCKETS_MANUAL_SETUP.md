# إعداد Storage Buckets يدوياً - حل مشكلة صلاحيات storage.objects

## المشكلة
عند تشغيل سكريبت `fix_storage_policies.sql`، تظهر رسالة الخطأ:
```
ERROR: 42501: must be owner of table objects
```

هذا يحدث لأن المستخدم لا يملك صلاحيات المالك لجدول `storage.objects` في Supabase.

## الحل البديل

### الخطوة 1: إنشاء الـ Buckets باستخدام SQL

1. **افتح SQL Editor في Supabase Dashboard**:
   - اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
   - اختر مشروعك
   - اذهب إلى **SQL Editor**

2. **شغّل السكريبت المبسط**:
   ```sql
   -- نسخ محتوى ملف create_storage_buckets_only.sql وتشغيله
   ```
   أو استخدم الملف: `database/create_storage_buckets_only.sql`

### الخطوة 2: إنشاء السياسات يدوياً من Dashboard

#### 2.1 الذهاب إلى Storage
1. في Supabase Dashboard، اذهب إلى **Storage**
2. ستجد الـ buckets التي تم إنشاؤها:
   - `travel_guides`
   - `accommodation-images`
   - `avatars`
   - `reviews`

#### 2.2 إعداد سياسات bucket "travel_guides"

1. **اختر bucket "travel_guides"**
2. **اذهب إلى تبويب "Policies"**
3. **أنشئ السياسات التالية**:

**السياسة 1: القراءة العامة**
- **Name**: `Public read access to travel guides`
- **Allowed operation**: `SELECT`
- **Target roles**: `public`
- **Policy definition (USING)**: 
  ```sql
  true
  ```

**السياسة 2: رفع للمستخدمين المسجلين**
- **Name**: `Authenticated upload to travel guides`
- **Allowed operation**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition (WITH CHECK)**: 
  ```sql
  auth.role() = 'authenticated'
  ```

**السياسة 3: إدارة المدير**
- **Name**: `Admin manage travel guides`
- **Allowed operation**: `ALL`
- **Target roles**: `authenticated`
- **Policy definition (USING)**: 
  ```sql
  auth.uid()::text = owner OR 
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.users.id = auth.uid() 
    AND auth.users.email = 'admin@rizervitoo.dz'
  )
  ```

#### 2.3 إعداد سياسات bucket "accommodation-images"

**السياسة 1: القراءة العامة**
- **Name**: `Public read access to accommodation images`
- **Allowed operation**: `SELECT`
- **Target roles**: `public`
- **Policy definition (USING)**: 
  ```sql
  true
  ```

**السياسة 2: رفع للمستخدمين المسجلين**
- **Name**: `Authenticated upload accommodation images`
- **Allowed operation**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition (WITH CHECK)**: 
  ```sql
  auth.role() = 'authenticated'
  ```

**السياسة 3: إدارة الملفات الشخصية**
- **Name**: `Own accommodation images management`
- **Allowed operation**: `UPDATE, DELETE`
- **Target roles**: `authenticated`
- **Policy definition (USING)**: 
  ```sql
  auth.uid()::text = owner
  ```

#### 2.4 إعداد سياسات bucket "avatars"

**السياسة 1: القراءة العامة**
- **Name**: `Public read access to avatars`
- **Allowed operation**: `SELECT`
- **Target roles**: `public`
- **Policy definition (USING)**: 
  ```sql
  true
  ```

**السياسة 2: رفع الصور الشخصية**
- **Name**: `Upload own avatar`
- **Allowed operation**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition (WITH CHECK)**: 
  ```sql
  auth.role() = 'authenticated' AND auth.uid()::text = owner
  ```

**السياسة 3: إدارة الصور الشخصية**
- **Name**: `Manage own avatar`
- **Allowed operation**: `UPDATE, DELETE`
- **Target roles**: `authenticated`
- **Policy definition (USING)**: 
  ```sql
  auth.uid()::text = owner
  ```

#### 2.5 إعداد سياسات bucket "reviews"

**السياسة 1: القراءة العامة**
- **Name**: `Public read access to review images`
- **Allowed operation**: `SELECT`
- **Target roles**: `public`
- **Policy definition (USING)**: 
  ```sql
  true
  ```

**السياسة 2: رفع صور التقييمات**
- **Name**: `Upload review images`
- **Allowed operation**: `INSERT`
- **Target roles**: `authenticated`
- **Policy definition (WITH CHECK)**: 
  ```sql
  auth.role() = 'authenticated' AND auth.uid()::text = owner
  ```

**السياسة 3: إدارة صور التقييمات**
- **Name**: `Manage own review images`
- **Allowed operation**: `UPDATE, DELETE`
- **Target roles**: `authenticated`
- **Policy definition (USING)**: 
  ```sql
  auth.uid()::text = owner
  ```

### الخطوة 3: التحقق من الإعدادات

1. **تحقق من الـ Buckets**:
   ```sql
   SELECT id, name, public, file_size_limit 
   FROM storage.buckets 
   WHERE id IN ('travel_guides', 'accommodation-images', 'avatars', 'reviews');
   ```

2. **تحقق من السياسات**:
   ```sql
   SELECT schemaname, tablename, policyname, cmd
   FROM pg_policies 
   WHERE tablename = 'objects' AND schemaname = 'storage'
   ORDER BY policyname;
   ```

### الخطوة 4: اختبار رفع الصور

1. **شغّل ملف الاختبار**:
   ```bash
   dart run test_storage_upload.dart
   ```

2. **أو اختبر من التطبيق**:
   - سجل دخول كمدير: `admin@rizervitoo.dz`
   - اذهب إلى إدارة الأدلة السياحية
   - جرب رفع صورة

## ملاحظات مهمة

### حدود الملفات
- **travel_guides**: 50MB
- **accommodation-images**: 50MB
- **avatars**: 10MB
- **reviews**: 20MB

### أنواع الملفات المسموحة
- **الصور**: JPEG, PNG, WebP, GIF
- **الصور الشخصية**: JPEG, PNG, WebP فقط

### استكشاف الأخطاء

**إذا ظهر خطأ "Bucket not found"**:
- تأكد من تشغيل `create_storage_buckets_only.sql`
- تحقق من وجود الـ buckets في Storage Dashboard

**إذا ظهر خطأ "Permission denied"**:
- تأكد من إنشاء جميع السياسات المطلوبة
- تحقق من تسجيل دخول المستخدم الصحيح

**إذا ظهر خطأ "File too large"**:
- تحقق من حجم الملف مقارنة بالحدود المسموحة
- قلل حجم الصورة إذا لزم الأمر

## الخطوات التالية

بعد إكمال هذا الإعداد:
1. اختبر رفع الصور في جميع أقسام التطبيق
2. تأكد من عمل المدير والمستخدمين العاديين
3. راجع السياسات إذا واجهت أي مشاكل

---

**تم إنشاء هذا الدليل لحل مشكلة صلاحيات storage.objects في Supabase**