import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  print('🔄 بدء اختبار الاتصال بـ Supabase...');
  
  try {
    // إنشاء Supabase client بالمعلومات المحدثة
    final supabase = SupabaseClient(
      'https://pnueogeqpkokyeumylyg.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudWVvZ2VxcGtva3lldW15bHlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNjIxOTMsImV4cCI6MjA3MjYzODE5M30.kiXBZkqnKgqRfPh3yf1GLra4KemipQNigYvgmsM1BqM',
    );
    
    print('✅ تم إنشاء Supabase client بنجاح');
    
    // اختبار الاتصال بقاعدة البيانات
    print('🔄 اختبار الاتصال بقاعدة البيانات...');
    
    // محاولة جلب بيانات من جدول profiles (حتى لو كان فارغاً)
    final response = await supabase
        .from('profiles')
        .select('count')
        .count(CountOption.exact);
    
    print('✅ تم الاتصال بقاعدة البيانات بنجاح');
    print('📊 عدد السجلات في جدول profiles: ${response.count}');
    
    // اختبار جلب بيانات من جدول accommodations
    print('🔄 اختبار جدول accommodations...');
    final accommodationsResponse = await supabase
        .from('accommodations')
        .select('count')
        .count(CountOption.exact);
    
    print('✅ جدول accommodations متاح');
    print('📊 عدد السجلات في جدول accommodations: ${accommodationsResponse.count}');
    
    // اختبار جلب بيانات من جدول bookings
    print('🔄 اختبار جدول bookings...');
    final bookingsResponse = await supabase
        .from('bookings')
        .select('count')
        .count(CountOption.exact);
    
    print('✅ جدول bookings متاح');
    print('📊 عدد السجلات في جدول bookings: ${bookingsResponse.count}');
    
    print('🎉 جميع الاختبارات نجحت! الاتصال بـ Supabase يعمل بشكل صحيح.');
    print('✅ جميع الجداول الأساسية متاحة ويمكن الوصول إليها.');
    
  } catch (e) {
    print('❌ خطأ في الاتصال بـ Supabase:');
    print('📝 تفاصيل الخطأ: $e');
    
    if (e.toString().contains('Failed host lookup')) {
      print('🌐 مشكلة في الاتصال بالإنترنت أو عنوان URL غير صحيح');
      print('🔍 تحقق من:');
      print('   - الاتصال بالإنترنت');
      print('   - صحة عنوان URL: https://pnueogeqpkokyeumylyg.supabase.co');
    } else if (e.toString().contains('Invalid JWT') || e.toString().contains('Invalid API key')) {
      print('🔑 مشكلة في مفتاح API (anon key)');
      print('🔍 تحقق من صحة anon key في إعدادات Supabase');
    } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
      print('🗃️ الجدول المطلوب غير موجود في قاعدة البيانات');
      print('🔍 تحقق من تطبيق migrations في Supabase Dashboard');
    } else if (e.toString().contains('permission denied')) {
      print('🚫 مشكلة في صلاحيات الوصول (RLS policies)');
      print('🔍 تحقق من إعدادات Row Level Security في Supabase');
    }
  }
  
  exit(0);
}