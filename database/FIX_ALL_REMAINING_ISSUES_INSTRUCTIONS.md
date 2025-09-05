# إصلاح المشاكل المتبقية - تعليمات التطبيق (محدث)
# Fix All Remaining Issues - Application Instructions (Updated)

## ⚠️ تحديث مهم / Important Update
**تم إصلاح خطأ UUID**: كان هناك خطأ في مقارنة أنواع البيانات (`text = uuid`) في النسخة السابقة. النسخة المحدثة تستخدم معرف المدير الصحيح: `78abcc88-0d36-4b5a-bb8f-809db1dfe10c`

**UUID Error Fixed**: There was an error in data type comparison (`text = uuid`) in the previous version. The updated version uses the correct admin ID: `78abcc88-0d36-4b5a-bb8f-809db1dfe10c`

## المشاكل المُعالجة / Issues Addressed

### 1. 🖼️ فشل رفع الصور / Image Upload Failure
**الخطأ:** `Storage violates row-level security policy, statusCode:403, error: Unauthorized`

**السبب:** سياسات RLS للتخزين غير مكتملة أو متضاربة
**Root Cause:** Incomplete or conflicting Storage RLS policies

### 2. 🏢 فشل إنشاء الوكالات السياحية / Travel Agency Creation Failure
**الخطأ:** `new row violates row-level security policy for table "travel_agencies"`

**السبب:** سياسات RLS للوكالات السياحية غير صحيحة
**Root Cause:** Incorrect RLS policies for travel agencies

### 3. 📊 فشل جلب التقييمات قيد المراجعة / Failed to Fetch Pending Reviews
**الخطأ:** `permission denied for table users, code: 42501, details: Forbidden`

**السبب:** صلاحيات جدول المستخدمين غير صحيحة
**Root Cause:** Incorrect users table permissions

---

## خطوات التطبيق / Application Steps

### الخطوة 1: الوصول إلى Supabase Dashboard
**Step 1: Access Supabase Dashboard**

1. افتح المتصفح واذهب إلى: https://supabase.com/dashboard
2. سجل الدخول إلى حسابك
3. اختر مشروع **RizerVitoo**
4. من القائمة الجانبية، اختر **SQL Editor**

### الخطوة 2: تطبيق الإصلاحات الشاملة
**Step 2: Apply Comprehensive Fixes**

1. في **SQL Editor**، انسخ والصق محتوى الملف:
   ```
   fix_all_remaining_issues.sql
   ```

2. انقر على **Run** لتنفيذ جميع الإصلاحات

3. انتظر حتى ظهور رسالة النجاح:
   ```
   ✅ All fixes applied successfully!
   ✅ Storage RLS policies fixed
   ✅ Travel agencies RLS policies fixed  
   ✅ Users table permissions fixed
   ✅ Reviews policies added
   ```

### الخطوة 3: التحقق من النتائج
**Step 3: Verify Results**

ستظهر لك جداول التحقق التالية:

#### أ) سياسات التخزين / Storage Policies
```sql
Storage Policies | storage | objects | Allow authenticated users to upload... | INSERT
Storage Policies | storage | objects | Allow public read access to...        | SELECT
Storage Policies | storage | objects | Allow admin to manage...              | ALL
```

#### ب) سياسات الوكالات السياحية / Travel Agencies Policies
```sql
Travel Agencies Policies | public | travel_agencies | Admin can insert travel agencies | INSERT
Travel Agencies Policies | public | travel_agencies | Admin can update travel agencies | UPDATE
Travel Agencies Policies | public | travel_agencies | Admin can delete travel agencies | DELETE
Travel Agencies Policies | public | travel_agencies | Admin can view all travel agencies | SELECT
```

#### ج) سياسات التقييمات / Reviews Policies
```sql
Reviews Policies | public | reviews | Admin can view all reviews   | SELECT
Reviews Policies | public | reviews | Admin can update all reviews | UPDATE
Reviews Policies | public | reviews | Admin can delete reviews     | DELETE
```

#### د) اختبار الدالة / Function Test
```sql
Function Test | get_users_with_email function exists
```

---

## اختبار الإصلاحات / Testing the Fixes

### 1. اختبار رفع الصور / Test Image Upload

1. افتح التطبيق وسجل الدخول كمدير
2. اذهب إلى قسم **الأدلة السياحية** أو **الإقامات**
3. حاول رفع صورة جديدة
4. **النتيجة المتوقعة:** يجب أن يتم رفع الصورة بنجاح

### 2. اختبار إنشاء الوكالات السياحية / Test Travel Agency Creation

1. في لوحة تحكم المدير، اذهب إلى **الوكالات السياحية**
2. انقر على **إضافة وكالة جديدة**
3. املأ البيانات المطلوبة واحفظ
4. **النتيجة المتوقعة:** يجب أن يتم إنشاء الوكالة بنجاح

### 3. اختبار جلب التقييمات قيد المراجعة / Test Pending Reviews Fetch

1. في لوحة تحكم المدير، اذهب إلى **التقييمات**
2. حاول عرض التقييمات قيد المراجعة
3. **النتيجة المتوقعة:** يجب أن تظهر قائمة التقييمات بدون أخطاء

---

## استكشاف الأخطاء / Troubleshooting

### إذا استمرت مشكلة رفع الصور / If Image Upload Still Fails

1. تحقق من وجود buckets في Storage:
   - `travel_guides`
   - `accommodation-images`
   - `avatars`
   - `reviews`

2. إذا لم تكن موجودة، قم بتشغيل:
   ```sql
   -- في SQL Editor
   INSERT INTO storage.buckets (id, name, public) VALUES 
   ('travel_guides', 'travel_guides', true),
   ('accommodation-images', 'accommodation-images', true),
   ('avatars', 'avatars', true),
   ('reviews', 'reviews', true)
   ON CONFLICT (id) DO NOTHING;
   ```

### إذا استمرت مشكلة الوكالات السياحية / If Travel Agency Issue Persists

1. تحقق من أن المدير مسجل دخول بشكل صحيح
2. تحقق من أن JWT يحتوي على `role: 'admin'`
3. في حالة الشك، قم بإعادة تسجيل الدخول كمدير

### إذا استمرت مشكلة التقييمات / If Reviews Issue Persists

1. تحقق من وجود الدالة:
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'get_users_with_email';
   ```

2. إذا لم تكن موجودة، قم بتشغيل الجزء الخاص بالدالة من السكريبت مرة أخرى

---

## ملاحظات مهمة / Important Notes

### 🔒 الأمان / Security
- جميع السياسات تستخدم `auth.jwt() ->> 'role' = 'admin'` للتحقق من صلاحيات المدير
- سياسات التخزين تسمح للمستخدمين المسجلين برفع الصور وللجمهور بعرضها
- المدير لديه صلاحيات كاملة لإدارة جميع الملفات

### 📱 التطبيق / Application
- تأكد من أن التطبيق يرسل JWT صحيح مع `role: 'admin'` للمدير
- تأكد من أن المستخدمين العاديين لديهم `role: 'authenticated'`

### 🗄️ قاعدة البيانات / Database
- جميع الجداول لديها RLS مفعل
- السياسات تعتمد على JWT roles وليس email checking
- الدالة `get_users_with_email()` محمية بـ SECURITY DEFINER

---

## الخطوات التالية / Next Steps

1. ✅ تطبيق السكريبت في Supabase
2. ✅ التحقق من رسائل النجاح
3. ✅ اختبار رفع الصور
4. ✅ اختبار إنشاء الوكالات
5. ✅ اختبار جلب التقييمات
6. ✅ اختبار جميع وظائف المدير

---

## الدعم / Support

إذا واجهت أي مشاكل:
1. تحقق من console logs في المتصفح
2. تحقق من Flutter debug logs
3. تحقق من Supabase logs في Dashboard
4. تأكد من أن جميع buckets موجودة في Storage
5. تأكد من أن المدير مسجل دخول بشكل صحيح

**تذكر:** هذا السكريبت يحل جميع المشاكل الثلاث دفعة واحدة، لذا لا تحتاج لتشغيل ملفات إصلاح أخرى بعده.