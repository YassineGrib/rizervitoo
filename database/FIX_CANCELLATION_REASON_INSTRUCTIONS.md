# إصلاح مشكلة عمود cancellation_reason

## المشكلة
عند محاولة تعديل الحجز وحفظ التغييرات، يظهر خطأ:
```
فشل في حفظ التغييرات
could not find the "cancellation_reason" of booking
schema cache code pgrts204 details bad request hint null
```

## السبب
المشكلة تحدث لأن عمود `cancellation_reason` مفقود من جدول `bookings` في قاعدة البيانات، بينما الكود يحاول الوصول إليه.

## الحل

### 1. تطبيق Migration الجديد
قم بتشغيل الأمر التالي لتطبيق migration الجديد:

```bash
cd database
psql -h your-supabase-host -U postgres -d your-database-name -f migrations/003_add_cancellation_reason.sql
```

أو يمكنك تشغيل الأمر التالي إذا كان لديك ملف migrate.ps1:

```powershell
.\migrate.ps1
```

### 2. التحقق من التطبيق
بعد تطبيق Migration، تأكد من وجود العمود:

```sql
\d public.bookings
```

يجب أن ترى عمود `cancellation_reason` في قائمة الأعمدة.

### 3. اختبار التطبيق
بعد تطبيق التحديث:
1. افتح التطبيق
2. اذهب إلى صفحة الحجوزات
3. اختر حجز للتعديل
4. قم بتعديل أي معلومة
5. اضغط على "حفظ التعديل"
6. يجب أن يعمل التعديل بنجاح الآن

## ملاحظات
- تم إضافة العمود كـ TEXT nullable
- تم تحديث أي حجوزات ملغاة موجودة لتحتوي على سبب افتراضي
- العمود متاح الآن لجميع عمليات تحديث الحجوزات