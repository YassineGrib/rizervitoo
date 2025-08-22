# إصلاح مشكلة صلاحيات المدير
# Admin Access Fix Instructions

## المشكلة / Problem
بعد تشغيل ملفات migration، أصبح هناك مشاكل في صلاحيات الوصول للمدير إلى قاعدة البيانات.
After running migration files, there are admin access permission issues to the database.

## السبب / Root Cause
تم تغيير سياسات RLS من استخدام `auth.jwt() ->> 'role' = 'admin'` إلى فحص البريد الإلكتروني، مما تسبب في تعارض وفقدان الصلاحيات.
RLS policies were changed from using `auth.jwt() ->> 'role' = 'admin'` to email checking, causing conflicts and permission loss.

## الحل / Solution

### الخطوة 1: تطبيق الإصلاح
**Step 1: Apply the Fix**

1. افتح لوحة تحكم Supabase: https://supabase.com/dashboard
2. اذهب إلى مشروعك RizerVitoo
3. من القائمة الجانبية، اختر **SQL Editor**
4. انسخ والصق محتوى الملف `restore_original_admin_policies.sql`
5. انقر على **Run** لتنفيذ الاستعلام

### الخطوة 2: التأكد من إعداد المدير
**Step 2: Verify Admin Setup**

#### أ) التحقق من وجود المستخدم المدير
**A) Check if Admin User Exists**

```sql
SELECT id, email, created_at, email_confirmed_at
FROM auth.users 
WHERE email = 'admin@rizervitoo.dz';
```

#### ب) إنشاء المستخدم المدير إذا لم يكن موجوداً
**B) Create Admin User if Not Exists**

1. في لوحة تحكم Supabase، اذهب إلى **Authentication** > **Users**
2. انقر على **Add User**
3. أدخل البيانات التالية:
   - **Email**: `admin@rizervitoo.dz`
   - **Password**: `RizerAdmin2025!`
   - **Email Confirm**: ✅ (مفعل)
4. انقر على **Create User**

#### ج) إضافة دور المدير في JWT
**C) Add Admin Role in JWT**

في **SQL Editor**، نفذ الاستعلام التالي لإضافة دور المدير:

```sql
-- إضافة دور المدير للمستخدم
UPDATE auth.users 
SET raw_app_meta_data = 
  COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "admin"}'::jsonb
WHERE email = 'admin@rizervitoo.dz';

-- التحقق من إضافة الدور
SELECT email, raw_app_meta_data
FROM auth.users 
WHERE email = 'admin@rizervitoo.dz';
```

### الخطوة 3: اختبار الوصول
**Step 3: Test Access**

#### أ) اختبار تسجيل الدخول
**A) Test Login**

1. افتح التطبيق
2. اذهب إلى شاشة تسجيل دخول المدير
3. أدخل البيانات:
   - **البريد الإلكتروني**: `admin@rizervitoo.dz`
   - **كلمة المرور**: `RizerAdmin2025!`
4. اضغط على تسجيل الدخول

#### ب) اختبار الصلاحيات
**B) Test Permissions**

بعد تسجيل الدخول، جرب:
- عرض قائمة المستخدمين
- إنشاء وكالة سياحية جديدة
- إضافة مرشد سياحي
- تعديل البيانات

### الخطوة 4: التحقق من JWT Token
**Step 4: Verify JWT Token**

للتأكد من أن JWT token يحتوي على الدور الصحيح، يمكنك استخدام:

```sql
-- فحص محتوى JWT للمستخدم الحالي
SELECT auth.jwt();

-- فحص الدور في JWT
SELECT auth.jwt() ->> 'role' as user_role;
```

## استكشاف الأخطاء / Troubleshooting

### إذا استمرت مشكلة الصلاحيات:
**If Permission Issues Persist:**

1. **تحقق من JWT Token**:
   ```sql
   SELECT auth.jwt() ->> 'role' as current_role;
   ```
   يجب أن يعرض `admin`

2. **تحقق من السياسات**:
   ```sql
   SELECT schemaname, tablename, policyname, cmd, qual
   FROM pg_policies 
   WHERE tablename IN ('travel_agencies', 'travel_agency_offers', 'profiles');
   ```

3. **إعادة تشغيل التطبيق** بعد تطبيق الإصلاحات

### إذا فشل تسجيل الدخول:
**If Login Fails:**

1. تأكد من تأكيد البريد الإلكتروني في Supabase
2. تحقق من كلمة المرور
3. تأكد من اتصال الإنترنت
4. تحقق من إعدادات Supabase في التطبيق

### رسائل الخطأ الشائعة:
**Common Error Messages:**

- `permission denied for table users` → تحقق من دور المدير في JWT
- `not_admin` → تأكد من وجود `role: admin` في JWT token
- `new row violates row-level security policy` → تأكد من تطبيق السياسات الجديدة

## ملاحظات مهمة / Important Notes

1. **لا تستخدم ملف `fix_all_issues.sql` مرة أخرى** - استخدم `restore_original_admin_policies.sql` بدلاً منه
2. **تأكد من وجود دور المدير في JWT** قبل اختبار الصلاحيات
3. **أعد تشغيل التطبيق** بعد تطبيق الإصلاحات
4. **احتفظ بنسخة احتياطية** من قاعدة البيانات قبل تطبيق أي تغييرات

---

**للدعم الفني**: إذا استمرت المشاكل، تحقق من سجلات Supabase في لوحة التحكم تحت **Logs** > **Database**.

**Technical Support**: If issues persist, check Supabase logs in the dashboard under **Logs** > **Database**.