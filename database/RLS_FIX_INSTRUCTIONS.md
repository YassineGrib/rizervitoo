# إصلاح مشكلة Row-Level Security للوكالات السياحية
# RLS Fix Instructions for Travel Agencies

## المشكلة / Problem
عند محاولة إنشاء وكالة سياحية جديدة، يظهر الخطأ التالي:
```
PostgrestException: new row violates row-level security policy for table 'travel_agencies'
code: 42501
details: Unauthorized
```

## الحل / Solution

### 1. إنشاء مستخدم المدير في Supabase
**Create Admin User in Supabase**

1. افتح لوحة تحكم Supabase: https://supabase.com/dashboard
2. اذهب إلى مشروعك Rizervitoo
3. من القائمة الجانبية، اختر **Authentication** > **Users**
4. انقر على **Add User**
5. أدخل البيانات التالية:
   - **Email**: `admin@rizervitoo.dz`
   - **Password**: `RizerAdmin2025!`
   - **Email Confirm**: ✅ (مفعل)
6. انقر على **Create User**

### 2. تطبيق سياسات RLS الجديدة
**Apply New RLS Policies**

1. في لوحة تحكم Supabase، اذهب إلى **SQL Editor**
2. انسخ والصق محتوى الملف `fix_rls_policies.sql`:

```sql
-- تحديث سياسات Row-Level Security للوكالات السياحية
-- Update RLS policies for travel agencies

-- حذف السياسات القديمة إذا كانت موجودة
DROP POLICY IF EXISTS "travel_agencies_admin_all" ON travel_agencies;
DROP POLICY IF EXISTS "travel_agency_offers_admin_all" ON travel_agency_offers;

-- إنشاء سياسة للمدير للوكالات السياحية
CREATE POLICY "travel_agencies_admin_all" ON travel_agencies
    FOR ALL
    TO authenticated
    USING (auth.email() = 'admin@rizervitoo.dz')
    WITH CHECK (auth.email() = 'admin@rizervitoo.dz');

-- إنشاء سياسة للمدير لعروض الوكالات السياحية
CREATE POLICY "travel_agency_offers_admin_all" ON travel_agency_offers
    FOR ALL
    TO authenticated
    USING (auth.email() = 'admin@rizervitoo.dz')
    WITH CHECK (auth.email() = 'admin@rizervitoo.dz');

-- رسالة تأكيد
DO $$
BEGIN
    RAISE NOTICE 'تم تطبيق سياسات RLS بنجاح للوكالات السياحية!';
    RAISE NOTICE 'RLS policies applied successfully for travel agencies!';
END $$;
```

3. انقر على **Run** لتنفيذ الاستعلام

### 3. إضافة البيانات التجريبية (اختياري)
**Add Demo Data (Optional)**

1. في **SQL Editor**، انسخ والصق محتوى الملف `travel_agencies_demo_data.sql`
2. انقر على **Run** لإضافة الوكالات السياحية التجريبية

### 4. اختبار النظام
**Test the System**

1. شغّل تطبيق Flutter:
   ```bash
   flutter run
   ```

2. في التطبيق:
   - اذهب إلى شاشة تسجيل دخول المدير
   - استخدم البيانات:
     - **البريد الإلكتروني**: `admin@rizervitoo.dz`
     - **كلمة المرور**: `RizerAdmin2025!`

3. بعد تسجيل الدخول بنجاح:
   - اذهب إلى إدارة الوكالات السياحية
   - جرب إنشاء وكالة سياحية جديدة
   - يجب أن تعمل العملية بدون أخطاء

## التحديثات المطبقة / Applied Updates

### 1. تحديث نظام المصادقة
- تم تحديث `AdminService` لاستخدام Supabase Auth بدلاً من المصادقة المحلية
- تم تحديث دالة `adminLogin()` لتستخدم `signInWithPassword()`
- تم تحديث دالة `adminLogout()` لتصبح async وتستخدم `signOut()`
- تم تحديث `admin_dashboard_screen.dart` لاستخدام الدالة الجديدة

### 2. سياسات RLS الجديدة
- تم إنشاء سياسات RLS تسمح للمدير بإدارة الوكالات السياحية
- السياسات تعتمد على البريد الإلكتروني `admin@rizervitoo.dz`
- تشمل عمليات INSERT, UPDATE, DELETE, SELECT

### 3. البيانات التجريبية
- تم إنشاء 5 وكالات سياحية جزائرية
- كل وكالة تحتوي على عرض سياحي واحد
- تم إضافة مراجعات العملاء لكل وكالة

## استكشاف الأخطاء / Troubleshooting

### إذا استمر ظهور خطأ RLS:
1. تأكد من إنشاء المستخدم المدير بالبريد الإلكتروني الصحيح
2. تأكد من تطبيق سياسات RLS الجديدة
3. تأكد من تسجيل الدخول بالبيانات الصحيحة في التطبيق

### إذا فشل تسجيل الدخول:
1. تأكد من أن المستخدم المدير مُفعّل في Supabase
2. تأكد من صحة كلمة المرور
3. تحقق من اتصال الإنترنت

### للتحقق من حالة المستخدم:
```sql
SELECT email, email_confirmed_at, created_at 
FROM auth.users 
WHERE email = 'admin@rizervitoo.dz';
```

---

**ملاحظة**: تأكد من تطبيق جميع الخطوات بالترتيب المذكور للحصول على أفضل النتائج.

**Note**: Make sure to follow all steps in the mentioned order for best results.