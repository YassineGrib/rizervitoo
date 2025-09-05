# إصلاح صلاحيات المدير - تعليمات التطبيق
# Admin Permissions Fix - Application Instructions

## المشكلة الحالية
**Current Issue**

المدير يواجه مشاكل "permission denied" في:
- عرض المستخدمين (Users Management)
- عرض التقييمات (Reviews Management) 
- الوصول لبيانات الوكالات السياحية (Travel Agencies)

## الحل
**Solution**

تم إنشاء ملف `fix_admin_permissions_complete.sql` الذي يحتوي على إصلاحات شاملة لجميع صلاحيات المدير.

## خطوات التطبيق
**Application Steps**

### 1. تسجيل الدخول إلى Supabase Dashboard
**Login to Supabase Dashboard**

1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك `rizervitoo`
3. اذهب إلى **SQL Editor**

### 2. تطبيق ملف الإصلاحات
**Apply the Fix File**

1. في **SQL Editor**، انسخ والصق محتوى الملف:
   ```
   database/fix_admin_permissions_complete.sql
   ```

2. انقر على **Run** لتنفيذ السكريبت

3. تأكد من ظهور رسائل النجاح:
   ```
   تم تطبيق إصلاحات صلاحيات المدير بنجاح!
   Admin permissions fixes applied successfully!
   ```

### 3. التحقق من وجود مستخدم المدير
**Verify Admin User Exists**

إذا ظهرت رسالة "مستخدم المدير غير موجود":

1. اذهب إلى **Authentication** > **Users**
2. انقر **Invite User**
3. أدخل البيانات:
   - **Email**: `admin@rizervitoo.dz`
   - **Password**: `RizerAdmin2025!`
4. انقر **Send Invitation**

### 4. اختبار الصلاحيات
**Test Permissions**

في **SQL Editor**، جرب هذه الاستعلامات للتأكد من عمل الصلاحيات:

```sql
-- اختبار عرض المستخدمين
SELECT * FROM get_users_with_email() LIMIT 5;

-- اختبار عرض التقييمات
SELECT id, rating, title, is_verified, created_at 
FROM reviews 
ORDER BY created_at DESC 
LIMIT 5;

-- اختبار عرض الوكالات السياحية
SELECT id, name, description, is_active 
FROM travel_agencies 
ORDER BY created_at DESC 
LIMIT 5;
```

### 5. اختبار التطبيق
**Test the Application**

1. سجل الدخول في التطبيق بحساب المدير:
   - **Email**: `admin@rizervitoo.dz`
   - **Password**: `RizerAdmin2025!`

2. جرب الوصول إلى:
   - **إدارة المستخدمين** (Users Management)
   - **إدارة التقييمات** (Reviews Management)
   - **إدارة الوكالات السياحية** (Travel Agencies Management)

## ما يتم إصلاحه
**What Gets Fixed**

### 1. صلاحيات الوكالات السياحية
**Travel Agencies Permissions**
- عرض جميع الوكالات
- إضافة وكالة جديدة
- تعديل الوكالات الموجودة
- حذف الوكالات
- إدارة العروض

### 2. صلاحيات إدارة المستخدمين
**User Management Permissions**
- عرض جميع المستخدمين مع الإيميلات
- تعديل بيانات المستخدمين
- حذف المستخدمين
- إضافة مستخدمين جدد

### 3. صلاحيات إدارة التقييمات
**Reviews Management Permissions**
- عرض جميع التقييمات
- الموافقة على التقييمات
- رفض/حذف التقييمات
- تعديل التقييمات

### 4. صلاحيات الأدلة السياحية
**Travel Guides Permissions**
- عرض جميع الأدلة
- إضافة أدلة جديدة
- تعديل الأدلة الموجودة
- حذف الأدلة

## استكشاف الأخطاء
**Troubleshooting**

### إذا استمرت مشكلة "permission denied"
**If "permission denied" persists**

1. **تأكد من تسجيل الدخول بالحساب الصحيح**:
   - الإيميل يجب أن يكون: `admin@rizervitoo.dz`

2. **تحقق من وجود المستخدم في قاعدة البيانات**:
   ```sql
   SELECT id, email FROM auth.users WHERE email = 'admin@rizervitoo.dz';
   ```

3. **تحقق من تطبيق السياسات**:
   ```sql
   SELECT policyname, cmd, qual 
   FROM pg_policies 
   WHERE tablename IN ('profiles', 'reviews', 'travel_agencies')
   AND policyname LIKE '%Admin%';
   ```

### إذا لم تعمل دالة get_users_with_email
**If get_users_with_email function doesn't work**

```sql
-- تحقق من وجود الدالة
SELECT proname FROM pg_proc WHERE proname = 'get_users_with_email';

-- إعادة إنشاء الدالة إذا لزم الأمر
-- (انسخ قسم الدالة من ملف fix_admin_permissions_complete.sql)
```

## ملاحظات مهمة
**Important Notes**

1. **النسخ الاحتياطي**: يُنصح بعمل نسخة احتياطية من قاعدة البيانات قبل تطبيق الإصلاحات

2. **البيئة الإنتاجية**: تأكد من اختبار الإصلاحات في بيئة التطوير أولاً

3. **الأمان**: السياسات تعتمد على الإيميل `admin@rizervitoo.dz` فقط

4. **المراقبة**: راقب سجلات التطبيق بعد التطبيق للتأكد من عدم وجود أخطاء

## الملفات ذات الصلة
**Related Files**

- `database/fix_admin_permissions_complete.sql` - ملف الإصلاحات الرئيسي
- `database/fix_rls_policies.sql` - الملف السابق (سيتم استبداله)
- `database/fix_admin_review_access.sql` - إصلاحات التقييمات المحددة

## الدعم
**Support**

إذا واجهت أي مشاكل:
1. تحقق من رسائل الخطأ في SQL Editor
2. راجع سجلات التطبيق (Flutter Console)
3. تأكد من صحة بيانات تسجيل الدخول
4. تواصل مع المطور مع تفاصيل الخطأ المحددة