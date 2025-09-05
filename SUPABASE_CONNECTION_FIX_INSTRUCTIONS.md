# تعليمات إصلاح الاتصال بـ Supabase

## المشكلة الحالية
التطبيق لا يستطيع الاتصال بقاعدة البيانات بسبب مشاكل في صلاحيات Row Level Security (RLS).

## معلومات المشروع
- **Project ID**: `pnueogeqpkokyeumylyg`
- **URL**: `https://pnueogeqpkokyeumylyg.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudWVvZ2VxcGtva3lldW15bHlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNjIxOTMsImV4cCI6MjA3MjYzODE5M30.kiXBZkqnKgqRfPh3yf1GLra4KemipQNigYvgmsM1BqM`

## خطوات الإصلاح

### 1. الوصول إلى Supabase Dashboard
1. اذهب إلى [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. سجل دخول إلى حسابك
3. اختر المشروع `pnueogeqpkokyeumylyg`

### 2. إنشاء المستخدم الإداري
1. اذهب إلى **Authentication** → **Users**
2. انقر على **Invite User**
3. أدخل البيانات التالية:
   - **Email**: `admin@rizervitoo.dz`
   - **Password**: `RizerAdmin2025!`
4. انقر على **Send Invitation**

### 3. تطبيق الإصلاحات في SQL Editor

#### الخطوة 3.1: فتح SQL Editor
1. اذهب إلى **SQL Editor**
2. انقر على **New Query**

#### الخطوة 3.2: تطبيق الإصلاحات الأساسية
انسخ والصق الكود التالي وشغله:

```sql
-- إصلاح صلاحيات RLS للجداول الأساسية

-- تعطيل RLS مؤقتاً للجداول الأساسية للسماح بالوصول العام للقراءة
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE accommodations DISABLE ROW LEVEL SECURITY;
ALTER TABLE bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE reviews DISABLE ROW LEVEL SECURITY;
ALTER TABLE travel_guides DISABLE ROW LEVEL SECURITY;
ALTER TABLE travel_agencies DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- إنشاء صلاحيات أساسية للقراءة العامة
CREATE POLICY "Enable read access for all users" ON profiles FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON accommodations FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON bookings FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON reviews FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON travel_guides FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON travel_agencies FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON notifications FOR SELECT USING (true);

-- إعادة تفعيل RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE accommodations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE travel_guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE travel_agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

#### الخطوة 3.3: إضافة صلاحيات المستخدمين المسجلين
انسخ والصق الكود التالي وشغله:

```sql
-- صلاحيات للمستخدمين المسجلين

-- المستخدمون يمكنهم إنشاء وتعديل ملفاتهم الشخصية
CREATE POLICY "Users can insert their own profile" ON profiles 
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles 
    FOR UPDATE USING (auth.uid() = id);

-- المستخدمون يمكنهم إنشاء وإدارة إقاماتهم
CREATE POLICY "Users can insert their own accommodations" ON accommodations 
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own accommodations" ON accommodations 
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own accommodations" ON accommodations 
    FOR DELETE USING (auth.uid() = owner_id);

-- المستخدمون يمكنهم إنشاء حجوزات
CREATE POLICY "Users can insert their own bookings" ON bookings 
    FOR INSERT WITH CHECK (auth.uid() = guest_id);

CREATE POLICY "Users can view their own bookings" ON bookings 
    FOR SELECT USING (auth.uid() = guest_id OR auth.uid() = (SELECT owner_id FROM accommodations WHERE id = accommodation_id));

CREATE POLICY "Users can update their own bookings" ON bookings 
    FOR UPDATE USING (auth.uid() = guest_id OR auth.uid() = (SELECT owner_id FROM accommodations WHERE id = accommodation_id));

-- المستخدمون يمكنهم إضافة تقييمات
CREATE POLICY "Users can insert their own reviews" ON reviews 
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

CREATE POLICY "Users can update their own reviews" ON reviews 
    FOR UPDATE USING (auth.uid() = reviewer_id);

CREATE POLICY "Users can delete their own reviews" ON reviews 
    FOR DELETE USING (auth.uid() = reviewer_id);
```

#### الخطوة 3.4: إضافة صلاحيات المدير
انسخ والصق الكود التالي وشغله:

```sql
-- صلاحيات المدير

-- المدير يمكنه الوصول لجميع الجداول
CREATE POLICY "Admin full access to profiles" ON profiles 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to accommodations" ON accommodations 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to bookings" ON bookings 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to reviews" ON reviews 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to travel_guides" ON travel_guides 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to travel_agencies" ON travel_agencies 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );

CREATE POLICY "Admin full access to notifications" ON notifications 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.email = 'admin@rizervitoo.dz'
        )
    );
```

### 4. التحقق من الإصلاحات

#### اختبار الاتصال
1. ارجع إلى مجلد المشروع في Terminal
2. شغل الأمر: `dart run test_supabase_connection.dart`
3. يجب أن ترى رسائل نجاح الاتصال

#### اختبار التطبيق
1. تأكد من وجود جهاز Android متصل أو محاكي يعمل
2. شغل الأمر: `flutter run`
3. اختبر تسجيل الدخول والوظائف الأساسية

### 5. إضافة بيانات تجريبية (اختياري)

إذا كنت تريد إضافة بيانات تجريبية للاختبار:

1. في SQL Editor، شغل محتويات الملفات التالية بالترتيب:
   - `database/demo_data/accommodations_demo_data.sql`
   - `database/demo_data/travel_agencies_demo_data.sql`
   - `database/demo_data/notifications_demo_data.sql`

### 6. ملاحظات مهمة

- **كلمة مرور قاعدة البيانات**: `Rizervitoo#2025`
- **بيانات المدير**: 
  - Email: `admin@rizervitoo.dz`
  - Password: `RizerAdmin2025!`
- تأكد من تطبيق جميع الخطوات بالترتيب المذكور
- إذا واجهت أي أخطاء، تحقق من رسائل الخطأ في SQL Editor

### 7. استكشاف الأخطاء

إذا استمرت المشاكل:

1. **تحقق من الجداول**: اذهب إلى **Table Editor** وتأكد من وجود جميع الجداول
2. **تحقق من RLS**: في **Table Editor**، انقر على أي جدول ثم **RLS** للتحقق من الصلاحيات
3. **تحقق من المستخدم الإداري**: في **Authentication** → **Users** تأكد من وجود `admin@rizervitoo.dz`

---

**بعد تطبيق هذه الخطوات، يجب أن يعمل التطبيق بشكل طبيعي مع قاعدة البيانات.**