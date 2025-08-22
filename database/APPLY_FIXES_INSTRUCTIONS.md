# تعليمات تطبيق إصلاحات قاعدة البيانات

## المشاكل التي تم حلها

تم إنشاء ملف `fix_all_issues.sql` لحل المشاكل التالية:

1. **مشكلة صلاحيات المدير**: `not_admin` و `permission denied`
2. **عمود gender مفقود**: في دالة `get_users_with_email`
3. **عمود difficulty مفقود**: في جدول `travel_agency_offers`

## خطوات التطبيق

### الطريقة الأولى: استخدام Supabase Dashboard

1. **افتح Supabase Dashboard**
   - اذهب إلى [https://app.supabase.com](https://app.supabase.com)
   - سجل دخولك إلى مشروعك

2. **افتح SQL Editor**
   - من القائمة الجانبية، اختر "SQL Editor"
   - انقر على "New Query"

3. **انسخ والصق محتوى الملف**
   - افتح ملف `database/fix_all_issues.sql`
   - انسخ كامل محتوى الملف
   - الصقه في SQL Editor

4. **شغل الاستعلام**
   - انقر على "Run" أو اضغط Ctrl+Enter
   - انتظر حتى يكتمل التنفيذ

5. **تحقق من النتائج**
   - يجب أن ترى رسائل نجاح تؤكد تطبيق الإصلاحات

### الطريقة الثانية: استخدام Supabase CLI

```bash
# إذا كان لديك Supabase CLI مثبت ومربوط بالمشروع
supabase db reset
# ثم
psql -h your-project-url -U postgres -d postgres -f database/fix_all_issues.sql
```

## التحقق من نجاح الإصلاحات

بعد تطبيق الإصلاحات، تحقق من:

1. **جدول travel_agency_offers**
   ```sql
   SELECT column_name FROM information_schema.columns 
   WHERE table_name = 'travel_agency_offers' AND column_name = 'difficulty';
   ```
   - يجب أن يظهر عمود `difficulty`

2. **دالة get_users_with_email**
   ```sql
   SELECT get_users_with_email();
   ```
   - يجب أن تعمل بدون أخطاء

3. **صلاحيات المدير**
   - جرب الوصول إلى إدارة المستخدمين في التطبيق
   - جرب إنشاء عرض جديد في الوكالات السياحية

## ملاحظات مهمة

- **تأكد من وجود مستخدم المدير**: يجب أن يكون هناك مستخدم بالإيميل `admin@rizervitoo.dz`
- **إذا لم يكن موجوداً**: استخدم Supabase Dashboard لإنشاء المستخدم:
  - اذهب إلى Authentication > Users
  - انقر "Invite User"
  - الإيميل: `admin@rizervitoo.dz`
  - كلمة المرور: `RizerAdmin2025!`

## في حالة وجود مشاكل

إذا واجهت أي مشاكل:

1. **تحقق من رسائل الخطأ** في SQL Editor
2. **تأكد من صلاحيات المستخدم** الذي تستخدمه
3. **راجع ملف README.md** في مجلد database
4. **تواصل مع المطور** مع تفاصيل الخطأ

## ملفات ذات صلة

- `database/fix_all_issues.sql` - ملف الإصلاحات الرئيسي
- `database/fix_rls_policies.sql` - إصلاحات الصلاحيات
- `database/fix_gender_column_issue.sql` - إصلاح عمود gender
- `database/create_admin_user.sql` - تعليمات إنشاء المدير