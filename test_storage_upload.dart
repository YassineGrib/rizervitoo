import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// اختبار بسيط لرفع الصور إلى Supabase Storage
/// Simple test for uploading images to Supabase Storage
void main() async {
  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://your-project-url.supabase.co',
    anonKey: 'your-anon-key',
  );

  final supabase = Supabase.instance.client;

  print('🔍 اختبار اتصال Supabase Storage...');
  print('Testing Supabase Storage connection...');

  try {
    // اختبار 1: التحقق من المصادقة
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('❌ خطأ: المستخدم غير مسجل دخول');
      print('Error: User not authenticated');
      
      // محاولة تسجيل دخول المدير
      print('🔐 محاولة تسجيل دخول المدير...');
      try {
        await supabase.auth.signInWithPassword(
          email: 'admin@rizervitoo.dz',
          password: 'RizerAdmin2025!',
        );
        print('✅ تم تسجيل دخول المدير بنجاح');
      } catch (e) {
        print('❌ فشل تسجيل دخول المدير: $e');
        return;
      }
    } else {
      print('✅ المستخدم مسجل دخول: ${user.email}');
    }

    // اختبار 2: قائمة البuckets
    print('\n📂 فحص البuckets المتوفرة...');
    try {
      final buckets = await supabase.storage.listBuckets();
      print('البuckets الموجودة:');
      for (final bucket in buckets) {
        print('  - ${bucket.id} (Public: ${bucket.public})');
      }
      
      // التحقق من وجود bucket travel_guides
      final travelGuidesBucket = buckets.where((b) => b.id == 'travel_guides').firstOrNull;
      if (travelGuidesBucket == null) {
        print('❌ خطأ: bucket "travel_guides" غير موجود');
        print('يرجى إنشاؤه في Supabase Dashboard > Storage');
        return;
      } else {
        print('✅ bucket "travel_guides" موجود');
      }
    } catch (e) {
      print('❌ خطأ في قائمة البuckets: $e');
      return;
    }

    // اختبار 3: محاولة قائمة الملفات في bucket travel_guides
    print('\n📋 فحص ملفات bucket travel_guides...');
    try {
      final files = await supabase.storage.from('travel_guides').list();
      print('عدد الملفات الموجودة: ${files.length}');
      if (files.isNotEmpty) {
        print('أول 3 ملفات:');
        for (int i = 0; i < files.length && i < 3; i++) {
          print('  - ${files[i].name}');
        }
      }
    } catch (e) {
      print('⚠️  تحذير: لا يمكن قراءة ملفات البucket: $e');
      print('هذا قد يكون طبيعياً بسبب صلاحيات RLS');
    }

    // اختبار 4: رفع ملف تجريبي
    print('\n📤 اختبار رفع ملف تجريبي...');
    try {
      // إنشاء صورة تجريبية بسيطة (1x1 pixel PNG)
      final testImageBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
        0x54, 0x08, 0xD7, 0x63, 0xF8, 0x00, 0x00, 0x00,
        0x00, 0x01, 0x00, 0x01, 0x5C, 0xC2, 0xD5, 0x7E,
        0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
        0xAE, 0x42, 0x60, 0x82
      ]);
      
      final fileName = 'test_upload_${DateTime.now().millisecondsSinceEpoch}.png';
      
      // رفع الملف
      await supabase.storage
          .from('travel_guides')
          .uploadBinary(fileName, testImageBytes);
      
      print('✅ تم رفع الملف بنجاح: $fileName');
      
      // الحصول على الرابط العام
      final publicUrl = supabase.storage
          .from('travel_guides')
          .getPublicUrl(fileName);
      
      print('🔗 الرابط العام: $publicUrl');
      
      // اختبار 5: حذف الملف التجريبي
      print('\n🗑️  حذف الملف التجريبي...');
      try {
        await supabase.storage
            .from('travel_guides')
            .remove([fileName]);
        print('✅ تم حذف الملف التجريبي بنجاح');
      } catch (e) {
        print('⚠️  تحذير: لا يمكن حذف الملف التجريبي: $e');
        print('الملف موجود في: $fileName');
      }
      
    } catch (e) {
      print('❌ فشل رفع الملف: $e');
      
      // تحليل نوع الخطأ
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('permission')) {
        print('\n💡 الحل المقترح:');
        print('1. تأكد من تطبيق ملف fix_storage_policies.sql');
        print('2. تأكد من إنشاء bucket "travel_guides" في Supabase Dashboard');
        print('3. تأكد من تسجيل دخول المستخدم الصحيح');
      } else if (errorStr.contains('bucket')) {
        print('\n💡 الحل المقترح:');
        print('1. أنشئ bucket "travel_guides" في Supabase Dashboard > Storage');
        print('2. تأكد من تفعيل خيار Public للبucket');
      }
      return;
    }

    print('\n🎉 جميع اختبارات Storage نجحت!');
    print('All Storage tests passed!');
    
  } catch (e) {
    print('❌ خطأ عام في الاختبار: $e');
  }
}

/// دالة مساعدة للتحقق من حالة المصادقة
void checkAuthStatus() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    print('المستخدم الحالي: ${user.email}');
    print('معرف المستخدم: ${user.id}');
    print('الدور: ${user.role}');
  } else {
    print('لا يوجد مستخدم مسجل دخول');
  }
}

/// دالة مساعدة لاختبار bucket محدد
Future<void> testSpecificBucket(String bucketName) async {
  final supabase = Supabase.instance.client;
  
  print('اختبار bucket: $bucketName');
  
  try {
    // محاولة قائمة الملفات
    final files = await supabase.storage.from(bucketName).list();
    print('✅ يمكن الوصول للبucket، عدد الملفات: ${files.length}');
  } catch (e) {
    print('❌ لا يمكن الوصول للبucket: $e');
  }
}