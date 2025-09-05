import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel_guide.dart';
import '../models/profile.dart';
import '../models/user.dart' as AppUser;
import '../models/review.dart';

class AdminService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Admin authentication - Using Supabase Auth
  static const String adminEmail = 'admin@rizervitoo.dz';
  
  // Check if current user is admin
  static bool isAdmin() {
    final user = _supabase.auth.currentUser;
    return user != null && user.email == adminEmail;
  }
  
  // Admin login - Supabase authentication
  static Future<bool> adminLogin(String email, String password) async {
    try {
      if (email.trim() != adminEmail) {
        throw Exception('غير مصرح لك بالوصول إلى لوحة الإدارة');
      }
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('فشل في تسجيل الدخول');
      }
      
      return true;
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: ${e.toString()}');
    }
  }
  
  // Admin logout
  static Future<void> adminLogout() async {
    await _supabase.auth.signOut();
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
      final accommodationsResponse = await _supabase.from('accommodations').select('id').count(CountOption.exact);
      
      // Get travel agencies statistics
      final totalAgenciesResponse = await _supabase.from('travel_agencies').select('id').count(CountOption.exact);
      final activeAgenciesResponse = await _supabase.from('travel_agencies').select('id').eq('is_active', true).count(CountOption.exact);
      final verifiedAgenciesResponse = await _supabase.from('travel_agencies').select('id').eq('is_active', true).eq('is_verified', true).count(CountOption.exact);
      final agencyOffersResponse = await _supabase.from('travel_agency_offers').select('id').eq('is_active', true).count(CountOption.exact);
      
      // Get review statistics
      final reviewStats = await getReviewStats();
      
      // Get actual counts
      final totalGuides = guidesResponse.count ?? 0;
      final publishedGuides = publishedGuidesResponse.count ?? 0;
      final totalUsers = usersResponse.count ?? 0;
      final totalAccommodations = accommodationsResponse.count ?? 0;
      final totalAgencies = totalAgenciesResponse.count ?? 0;
      final activeAgencies = activeAgenciesResponse.count ?? 0;
      final verifiedAgencies = verifiedAgenciesResponse.count ?? 0;
      final totalOffers = agencyOffersResponse.count ?? 0;
      
      return {
        'total_guides': totalGuides,
        'published_guides': publishedGuides,
        'draft_guides': totalGuides - publishedGuides,
        'total_users': totalUsers,
        'total_accommodations': totalAccommodations,
        'total_agencies': totalAgencies,
        'active_agencies': activeAgencies,
        'inactive_agencies': totalAgencies - activeAgencies,
        'verified_agencies': verifiedAgencies,
        'unverified_agencies': activeAgencies - verifiedAgencies,
        'total_offers': totalOffers,
        'active_users': (totalUsers * 0.8).round(), // 80% active
        'new_users_this_month': (totalUsers * 0.2).round(), // 20% new
        'total_bookings': totalUsers * 2, // Mock: 2 bookings per user
        'revenue': totalUsers * 150.0, // Mock: $150 per user
        // Review statistics
        'total_reviews': reviewStats['total_reviews'],
        'pending_reviews': reviewStats['pending_reviews'],
        'verified_reviews': reviewStats['verified_reviews'],
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Return empty stats on error
      return {
        'total_guides': 0,
        'published_guides': 0,
        'draft_guides': 0,
        'total_users': 0,
        'total_accommodations': 0,
        'total_agencies': 0,
        'active_agencies': 0,
        'inactive_agencies': 0,
        'verified_agencies': 0,
        'unverified_agencies': 0,
        'total_offers': 0,
        'active_users': 0,
        'new_users_this_month': 0,
        'total_bookings': 0,
        'revenue': 0.0,
        'total_reviews': 0,
        'pending_reviews': 0,
        'verified_reviews': 0,
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
      // Add the current user as creator
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        guideData['created_by'] = currentUser.id;
      }
      
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
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }
      
      if (currentUser.email != adminEmail) {
        throw Exception('غير مصرح لك بالوصول إلى بيانات المستخدمين - يجب أن تكون مدير');
      }
      
      // Use direct query instead of RPC to avoid permission issues
      final profilesResponse = await _supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);
      
      List<AppUser.User> users = [];
      for (var profile in profilesResponse) {
        try {
          // Try to get user email from auth
          final authUser = await _supabase.auth.admin.getUserById(profile['id']);
          final email = authUser.user?.email ?? 'unknown@email.com';
          
          users.add(AppUser.User.fromProfile(profile, email));
        } catch (e) {
          // If can't get email, still add user with unknown email
          users.add(AppUser.User.fromProfile(profile, 'unknown@email.com'));
        }
      }
      
      return users;
    } catch (e) {
      if (e.toString().contains('JWT')) {
        throw Exception('انتهت صلاحية جلسة المدير - يرجى تسجيل الدخول مرة أخرى');
      }
      throw Exception('فشل في جلب المستخدمين: ${e.toString()}');
    }
  }
  
  // Update user profile
  static Future<AppUser.User> updateUserProfile(String id, Map<String, dynamic> profileData) async {
    try {
      if (!isAdmin()) {
        throw Exception('غير مصرح لك بتحديث بيانات المستخدمين');
      }
      
      final response = await _supabase
          .from('profiles')
          .update(profileData)
          .eq('id', id)
          .select()
          .single();
      
      // Get updated user data using RPC
      final users = await _supabase.rpc('get_users_with_email');
      final userData = users.firstWhere((user) => user['id'] == id);
      
      return AppUser.User.fromJson(userData);
    } catch (e) {
      throw Exception('فشل في تحديث ملف المستخدم: ${e.toString()}');
    }
  }
  
  // Deactivate user
  static Future<void> deactivateUser(String id) async {
    try {
      if (!isAdmin()) {
        throw Exception('غير مصرح لك بإلغاء تفعيل المستخدمين');
      }
      
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
      if (!isAdmin()) {
        throw Exception('غير مصرح لك بتفعيل المستخدمين');
      }
      
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

  // Review Management Operations
  
  // Get pending reviews (not verified)
  static Future<List<Review>> getPendingReviews() async {
    try {
      print('Debug: AdminService.getPendingReviews() called');
      
      // Check if user is admin
      final currentUser = _supabase.auth.currentUser;
      print('Debug: Current user: ${currentUser?.email}');
      print('Debug: Is admin: ${isAdmin()}');
      
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      print('Debug: Raw response from Supabase: $response');
      print('Debug: Response length: ${response.length}');

      final reviews = (response as List).map((json) {
        final profile = json['profiles'];
        final accommodation = json['accommodations'];
        
        print('Debug: Processing review: ${json['id']}, is_verified: ${json['is_verified']}');
        
        return Review.fromJson({
          ...json,
          'guest_name': profile?['full_name'],
          'guest_avatar': profile?['avatar_url'],
          'accommodation_title': accommodation?['title'],
        });
      }).toList();
      
      print('Debug: Returning ${reviews.length} pending reviews');
      return reviews;
    } catch (e) {
      print('Debug: Error in getPendingReviews: $e');
      throw Exception('فشل في جلب التقييمات قيد المراجعة: ${e.toString()}');
    }
  }

  // Get verified reviews
  static Future<List<Review>> getVerifiedReviews() async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('''
            *,
            profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('is_verified', true)
          .order('created_at', ascending: false)
          .limit(50); // Limit to recent 50 verified reviews

      return (response as List).map((json) {
        final profile = json['profiles'];
        final accommodation = json['accommodations'];
        
        return Review.fromJson({
          ...json,
          'guest_name': profile?['full_name'],
          'guest_avatar': profile?['avatar_url'],
          'accommodation_title': accommodation?['title'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب التقييمات المقبولة: ${e.toString()}');
    }
  }

  // Approve a review (set is_verified to true)
  static Future<void> approveReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({'is_verified': true})
          .eq('id', reviewId);
    } catch (e) {
      throw Exception('فشل في قبول التقييم: ${e.toString()}');
    }
  }

  // Reject a review (delete it)
  static Future<void> rejectReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .delete()
          .eq('id', reviewId);
    } catch (e) {
      throw Exception('فشل في رفض التقييم: ${e.toString()}');
    }
  }

  // Get review statistics for admin dashboard
  static Future<Map<String, dynamic>> getReviewStats() async {
    try {
      final totalReviewsResponse = await _supabase
          .from('reviews')
          .select('id')
          .count(CountOption.exact);
          
      final pendingReviewsResponse = await _supabase
          .from('reviews')
          .select('id')
          .eq('is_verified', false)
          .count(CountOption.exact);
          
      final verifiedReviewsResponse = await _supabase
          .from('reviews')
          .select('id')
          .eq('is_verified', true)
          .count(CountOption.exact);

      final totalReviews = totalReviewsResponse.count ?? 0;
      final pendingReviews = pendingReviewsResponse.count ?? 0;
      final verifiedReviews = verifiedReviewsResponse.count ?? 0;

      return {
        'total_reviews': totalReviews,
        'pending_reviews': pendingReviews,
        'verified_reviews': verifiedReviews,
      };
    } catch (e) {
      return {
        'total_reviews': 0,
        'pending_reviews': 0,
        'verified_reviews': 0,
      };
    }
  }

  // Accommodation Management Operations
  
  // Get pending accommodations (not verified)
  static Future<List<Map<String, dynamic>>> getPendingAccommodations() async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select('''
            *,
            profiles!accommodations_owner_id_fkey(
              full_name,
              phone
            )
          ''')
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      return (response as List).map<Map<String, dynamic>>((json) {
        final profile = json['profiles'];
        
        return {
          ...json,
          'owner_name': profile?['full_name'],
          'owner_phone': profile?['phone'],
          'owner_email': 'غير متاح', // Email not available from profiles table
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الاستضافات قيد المراجعة: ${e.toString()}');
    }
  }

  // Get all accommodations (verified and unverified)
  static Future<List<Map<String, dynamic>>> getAllAccommodations() async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select('''
            *,
            profiles!accommodations_owner_id_fkey(
              full_name,
              phone
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List).map<Map<String, dynamic>>((json) {
        final profile = json['profiles'];
        
        return {
          ...json,
          'owner_name': profile?['full_name'],
          'owner_phone': profile?['phone'],
          'owner_email': 'غير متاح', // Email not available from profiles table
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب جميع الاستضافات: ${e.toString()}');
    }
  }

  // Approve an accommodation (set is_verified to true)
  static Future<void> approveAccommodation(String accommodationId) async {
    try {
      await _supabase
          .from('accommodations')
          .update({'is_verified': true})
          .eq('id', accommodationId);
    } catch (e) {
      throw Exception('فشل في قبول الاستضافة: ${e.toString()}');
    }
  }

  // Reject an accommodation (delete it or mark as rejected)
  static Future<void> rejectAccommodation(String accommodationId) async {
    try {
      // For now, we'll delete rejected accommodations
      // In the future, you might want to add a 'status' field instead
      await _supabase
          .from('accommodations')
          .delete()
          .eq('id', accommodationId);
    } catch (e) {
      throw Exception('فشل في رفض الاستضافة: ${e.toString()}');
    }
  }

  // Toggle accommodation availability
  static Future<void> toggleAccommodationAvailability(String accommodationId, bool isAvailable) async {
    try {
      await _supabase
          .from('accommodations')
          .update({'is_available': isAvailable})
          .eq('id', accommodationId);
    } catch (e) {
      throw Exception('فشل في تغيير حالة الاستضافة: ${e.toString()}');
    }
  }
}