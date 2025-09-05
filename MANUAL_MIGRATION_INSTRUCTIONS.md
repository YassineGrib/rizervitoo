# تعليمات تطبيق قاعدة البيانات يدوياً

## نظرة عامة

بسبب مشاكل الاتصال مع Supabase CLI، يجب تطبيق migrations يدوياً عبر Supabase Dashboard.

## الخطوات المطلوبة

### 1. الوصول إلى Supabase Dashboard

1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. سجل دخولك إلى حسابك
3. اختر مشروع `pnueogeqpkokyeumylyg`

### 2. فتح SQL Editor

1. من القائمة الجانبية، اختر **SQL Editor**
2. انقر على **New Query**

### 3. تطبيق Migrations بالترتيب

يجب تطبيق الملفات بالترتيب التالي:

#### الخطوة 1: إنشاء جدول Profiles
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000001_create_profiles_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 2: إنشاء جدول Accommodations
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000002_create_accommodations_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 3: إنشاء جدول Bookings
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000003_create_bookings_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 4: إنشاء جدول Reviews
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000004_create_reviews_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 5: إنشاء جدول Messages
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000005_create_messages_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 6: إنشاء جدول Travel Guides
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000006_create_travel_guides_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 7: إنشاء جداول Travel Agencies
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000007_create_travel_agencies_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 8: إنشاء جدول Notifications
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000008_create_notifications_table.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### الخطوة 9: إنشاء Notification Triggers
```sql
-- انسخ محتوى ملف: supabase/migrations/20250106000009_create_notification_triggers.sql
-- والصقه في SQL Editor ثم اضغط Run
```

### 4. تطبيق الإصلاحات

بعد تطبيق جميع migrations الأساسية، طبق الإصلاحات التالية:

#### إصلاح شامل للمشاكل
```sql
-- انسخ محتوى ملف: database/fix_all_issues.sql
-- والصقه في SQL Editor ثم اضغط Run
```

#### إنشاء مستخدم المدير
```sql
-- انسخ محتوى ملف: database/create_admin_user.sql
-- والصقه في SQL Editor ثم اضغط Run
```

### 5. إضافة بيانات تجريبية (اختياري)

يمكنك إضافة بيانات تجريبية لاختبار التطبيق:

```sql
-- انسخ محتوى ملف: database/demo_data/accommodations_demo_data.sql
-- انسخ محتوى ملف: database/demo_data/travel_agencies_demo_data.sql
-- انسخ محتوى ملف: database/demo_data/notifications_demo_data.sql
```

### 6. التحقق من النجاح

بعد تطبيق جميع الخطوات، تحقق من:

1. **الجداول**: اذهب إلى **Table Editor** وتأكد من وجود جميع الجداول
2. **الصلاحيات**: اذهب إلى **Authentication** → **Policies** وتأكد من وجود السياسات
3. **الدوال**: اذهب إلى **Database** → **Functions** وتأكد من وجود الدوال

### 7. اختبار التطبيق

بعد تطبيق قاعدة البيانات:

```bash
flutter clean
flutter pub get
flutter run
```

## ملاحظات مهمة

- **الترتيب مهم**: يجب تطبيق الملفات بالترتيب المحدد
- **التحقق من الأخطاء**: إذا ظهرت أخطاء، تأكد من تطبيق الخطوات السابقة بشكل صحيح
- **النسخ الاحتياطي**: Supabase يحتفظ بنسخ احتياطية تلقائية
- **المساعدة**: إذا واجهت مشاكل، راجع [Supabase Documentation](https://supabase.com/docs)

## معلومات المشروع

- **Project URL**: https://pnueogeqpkokyeumylyg.supabase.co
- **Project ID**: pnueogeqpkokyeumylyg
- **Database Password**: Rizervitoo#2025

## الخطوات التالية

بعد تطبيق قاعدة البيانات بنجاح:

1. اختبار تسجيل المستخدمين
2. اختبار إنشاء الملفات الشخصية
3. اختبار عمليات الحجز
4. اختبار النظام الإداري
5. اختبار الإشعارات

---

**تم إنشاء هذا الملف تلقائياً بواسطة نظام الترحيل**