import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel_guide.dart';
import '../models/profile.dart';
import '../models/user.dart' as AppUser;

class AdminService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Admin authentication - Local credentials
  static const String adminEmail = 'admin@rizervitoo.dz';
  static const String adminPassword = 'RizerAdmin2025!';
  
  // Track admin login status locally
  static bool _isAdminLoggedIn = false;
  
  // Check if current user is admin
  static bool isAdmin() {
    return _isAdminLoggedIn;
  }
  
  // Admin login - Local authentication
  static Future<bool> adminLogin(String email, String password) async {
    try {
      // Simulate network delay for realistic UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (email.trim() != adminEmail) {
        throw Exception('غير مصرح لك بالوصول إلى لوحة الإدارة');
      }
      
      if (password != adminPassword) {
        throw Exception('كلمة المرور غير صحيحة');
      }
      
      _isAdminLoggedIn = true;
      return true;
    } catch (e) {
      _isAdminLoggedIn = false;
      throw Exception('فشل في تسجيل الدخول: ${e.toString()}');
    }
  }
  
  // Admin logout
  static void adminLogout() {
    _isAdminLoggedIn = false;
  }
  
  // Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get real data from Supabase
      final guidesResponse = await _supabase.from('travel_guides').select('id, is_published').count(CountOption.exact);
      final publishedGuidesResponse = await _supabase.from('travel_guides').select('id').eq('is_published', true).count(CountOption.exact);
      final usersResponse = await _supabase.from('profiles').select('id').count(CountOption.exact);
      
      // Get actual counts
      final totalGuides = guidesResponse.count ?? 0;
      final publishedGuides = publishedGuidesResponse.count ?? 0;
      final totalUsers = usersResponse.count ?? 0;
      
      return {
        'total_guides': totalGuides,
        'published_guides': publishedGuides,
        'draft_guides': totalGuides - publishedGuides,
        'total_users': totalUsers,
        'active_users': (totalUsers * 0.8).round(), // 80% active
        'new_users_this_month': (totalUsers * 0.2).round(), // 20% new
        'total_bookings': totalUsers * 2, // Mock: 2 bookings per user
        'revenue': totalUsers * 150.0, // Mock: $150 per user
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Return empty stats on error
      return {
        'total_guides': 0,
        'published_guides': 0,
        'draft_guides': 0,
        'total_users': 0,
        'active_users': 0,
        'new_users_this_month': 0,
        'total_bookings': 0,
        'revenue': 0.0,
      };
    }
  }
  
  // Travel Guides CRUD Operations
  
  // Get all travel guides
  static Future<List<TravelGuide>> getAllTravelGuides() async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .order('created_at', ascending: false);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الأدلة السياحية: ${e.toString()}');
    }
  }
  
  // Create travel guide
  static Future<TravelGuide> createTravelGuide(Map<String, dynamic> guideData) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .insert(guideData)
          .select()
          .single();
      
      return TravelGuide.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الدليل السياحي: ${e.toString()}');
    }
  }
  
  // Update travel guide
  static Future<TravelGuide> updateTravelGuide(String id, Map<String, dynamic> guideData) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .update(guideData)
          .eq('id', id)
          .select()
          .single();
      
      return TravelGuide.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الدليل السياحي: ${e.toString()}');
    }
  }
  
  // Delete travel guide
  static Future<void> deleteTravelGuide(String id) async {
    try {
      await _supabase
          .from('travel_guides')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف الدليل السياحي: ${e.toString()}');
    }
  }
  
  // Toggle guide publication status
  static Future<void> toggleGuidePublication(String id, bool isPublished) async {
    try {
      await _supabase
          .from('travel_guides')
          .update({'is_published': isPublished})
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في تغيير حالة النشر: ${e.toString()}');
    }
  }
  
  // User Management Operations
  
  // Get all users
  static Future<List<AppUser.User>> getAllUsers() async {
    try {
      // Get profiles with user email from auth.users
      final response = await _supabase
          .rpc('get_users_with_email')
          .order('created_at', ascending: false);
      
      return response.map((userData) => AppUser.User.fromJson(userData)).toList();
    } catch (e) {
      // Fallback: get profiles and fetch emails separately
      try {
        final profiles = await _supabase
            .from('profiles')
            .select('*')
            .order('created_at', ascending: false);
        
        List<AppUser.User> users = [];
        for (var profile in profiles) {
          // Try to get user email from auth metadata
          final user = await _supabase.auth.admin.getUserById(profile['id']);
          final email = user.user?.email ?? 'unknown@email.com';
          
          users.add(AppUser.User.fromProfile(profile, email));
        }
        
        return users;
      } catch (fallbackError) {
        throw Exception('فشل في جلب المستخدمين: ${fallbackError.toString()}');
      }
    }
  }
  
  // Update user profile
  static Future<AppUser.User> updateUserProfile(String id, Map<String, dynamic> profileData) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update(profileData)
          .eq('id', id)
          .select()
          .single();
      
      // Get user email
      final user = await _supabase.auth.admin.getUserById(id);
      final email = user.user?.email ?? 'unknown@email.com';
      
      return AppUser.User.fromProfile(response, email);
    } catch (e) {
      throw Exception('فشل في تحديث ملف المستخدم: ${e.toString()}');
    }
  }
  
  // Deactivate user
  static Future<void> deactivateUser(String id) async {
    try {
      // Add is_active column to profiles table if it doesn't exist
      await _supabase
          .from('profiles')
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في إلغاء تفعيل المستخدم: ${e.toString()}');
    }
  }
  
  // Activate user
  static Future<void> activateUser(String id) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': true})
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في تفعيل المستخدم: ${e.toString()}');
    }
  }
  
  // Search travel guides
  static Future<List<TravelGuide>> searchTravelGuides(String query) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .or('title.ilike.%$query%,description.ilike.%$query%,city.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      throw Exception('فشل في البحث عن الأدلة السياحية: ${e.toString()}');
    }
  }
  
  // Search users
  static Future<List<AppUser.User>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .or('full_name.ilike.%$query%')
          .order('created_at', ascending: false);
      
      List<AppUser.User> users = [];
      for (var profile in response) {
        // Try to get user email from auth metadata
        try {
          final user = await _supabase.auth.admin.getUserById(profile['id']);
          final email = user.user?.email ?? 'unknown@email.com';
          
          // Check if email matches query too
          if (email.toLowerCase().contains(query.toLowerCase()) ||
              (profile['full_name'] as String? ?? '').toLowerCase().contains(query.toLowerCase())) {
            users.add(AppUser.User.fromProfile(profile, email));
          }
        } catch (e) {
          // If can't get email, still add if name matches
          if ((profile['full_name'] as String? ?? '').toLowerCase().contains(query.toLowerCase())) {
            users.add(AppUser.User.fromProfile(profile, 'unknown@email.com'));
          }
        }
      }
      
      return users;
    } catch (e) {
      throw Exception('فشل في البحث عن المستخدمين: ${e.toString()}');
    }
  }
}