import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel_agency.dart';

class TravelAgencyService {
  static final _supabase = Supabase.instance.client;

  // Get all active travel agencies
  static Future<List<TravelAgency>> getAllAgencies({
    String? wilaya,
    String? specialty,
    String? searchQuery,
    String sortBy = 'rating', // rating, name, created_at
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('travel_agencies')
          .select('*')
          .eq('is_active', true);

      // Apply filters
      if (wilaya != null && wilaya.isNotEmpty) {
        query = query.eq('wilaya', wilaya);
      }

      if (specialty != null && specialty.isNotEmpty) {
        query = query.contains('specialties', [specialty]);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,address.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => TravelAgency.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الوكالات السياحية: ${e.toString()}');
    }
  }

  // Get agency by ID with offers and reviews
  static Future<TravelAgency?> getAgencyById(String agencyId) async {
    try {
      // Get agency details
      final agencyResponse = await _supabase
          .from('travel_agencies')
          .select('*')
          .eq('id', agencyId)
          .eq('is_active', true)
          .single();

      // Get agency offers
      final offersResponse = await _supabase
          .from('travel_agency_offers')
          .select('*')
          .eq('agency_id', agencyId)
          .eq('is_active', true)
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false);

      // Get agency reviews with user info
      final reviewsResponse = await _supabase
          .from('travel_agency_reviews')
          .select('''
            *,
            profiles!travel_agency_reviews_user_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('agency_id', agencyId)
          .order('created_at', ascending: false)
          .limit(20);

      final agency = TravelAgency.fromJson(agencyResponse);
      
      final offers = (offersResponse as List)
          .map((json) => TravelAgencyOffer.fromJson(json))
          .toList();

      final reviews = (reviewsResponse as List).map((json) {
        final review = TravelAgencyReview.fromJson(json);
        final profile = json['profiles'];
        return TravelAgencyReview(
          id: review.id,
          agencyId: review.agencyId,
          userId: review.userId,
          rating: review.rating,
          title: review.title,
          comment: review.comment,
          isVerified: review.isVerified,
          helpfulCount: review.helpfulCount,
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
          userName: profile?['full_name'],
          userAvatar: profile?['avatar_url'],
        );
      }).toList();

      return agency.copyWith(
        offers: offers,
        reviews: reviews,
      );
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الوكالة: ${e.toString()}');
    }
  }

  // Get agencies by wilaya
  static Future<List<TravelAgency>> getAgenciesByWilaya(String wilaya) async {
    return getAllAgencies(wilaya: wilaya);
  }

  // Get featured agencies
  static Future<List<TravelAgency>> getFeaturedAgencies({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('travel_agencies')
          .select('*')
          .eq('is_active', true)
          .eq('is_verified', true)
          .gte('rating', 4.0)
          .order('rating', ascending: false)
          .order('total_reviews', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TravelAgency.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الوكالات المميزة: ${e.toString()}');
    }
  }

  // Get agency offers
  static Future<List<TravelAgencyOffer>> getAgencyOffers(
    String agencyId, {
    bool activeOnly = true,
    bool featuredOnly = false,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('travel_agency_offers')
          .select('*')
          .eq('agency_id', agencyId);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      // Apply filters and execute query
      final response = await (featuredOnly 
          ? query.eq('is_featured', true)
          : query)
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => TravelAgencyOffer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب عروض الوكالة: ${e.toString()}');
    }
  }

  // Get offer by ID
  static Future<TravelAgencyOffer?> getOfferById(String offerId) async {
    try {
      final response = await _supabase
          .from('travel_agency_offers')
          .select('*')
          .eq('id', offerId)
          .eq('is_active', true)
          .single();

      return TravelAgencyOffer.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل العرض: ${e.toString()}');
    }
  }

  // Search offers
  static Future<List<TravelAgencyOffer>> searchOffers({
    String? searchQuery,
    String? category,
    double? maxPrice,
    double? minPrice,
    String? destination,
    int? maxDuration,
    int? minDuration,
    String sortBy = 'created_at',
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('travel_agency_offers')
          .select('*')
          .eq('is_active', true);

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,destination.ilike.%$searchQuery%');
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (destination != null && destination.isNotEmpty) {
        query = query.ilike('destination', '%$destination%');
      }

      if (minPrice != null) {
        query = query.gte('price_dzd', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price_dzd', maxPrice);
      }

      if (minDuration != null) {
        query = query.gte('duration_days', minDuration);
      }

      if (maxDuration != null) {
        query = query.lte('duration_days', maxDuration);
      }

      // Apply sorting and pagination, then execute query
      final response = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => TravelAgencyOffer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في البحث عن العروض: ${e.toString()}');
    }
  }

  // Get agency reviews
  static Future<List<TravelAgencyReview>> getAgencyReviews(
    String agencyId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('travel_agency_reviews')
          .select('''
            *,
            profiles!travel_agency_reviews_user_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('agency_id', agencyId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        final review = TravelAgencyReview.fromJson(json);
        final profile = json['profiles'];
        return TravelAgencyReview(
          id: review.id,
          agencyId: review.agencyId,
          userId: review.userId,
          rating: review.rating,
          title: review.title,
          comment: review.comment,
          isVerified: review.isVerified,
          helpfulCount: review.helpfulCount,
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
          userName: profile?['full_name'],
          userAvatar: profile?['avatar_url'],
        );
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب تقييمات الوكالة: ${e.toString()}');
    }
  }

  // Add review
  static Future<TravelAgencyReview> addReview({
    required String agencyId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لإضافة تقييم');
      }

      final response = await _supabase
          .from('travel_agency_reviews')
          .insert({
            'agency_id': agencyId,
            'user_id': user.id,
            'rating': rating,
            'title': title,
            'comment': comment,
          })
          .select()
          .single();

      return TravelAgencyReview.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إضافة التقييم: ${e.toString()}');
    }
  }

  // Update review
  static Future<TravelAgencyReview> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لتحديث التقييم');
      }

      final response = await _supabase
          .from('travel_agency_reviews')
          .update({
            'rating': rating,
            'title': title,
            'comment': comment,
          })
          .eq('id', reviewId)
          .eq('user_id', user.id)
          .select()
          .single();

      return TravelAgencyReview.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث التقييم: ${e.toString()}');
    }
  }

  // Delete review
  static Future<void> deleteReview(String reviewId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لحذف التقييم');
      }

      await _supabase
          .from('travel_agency_reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('فشل في حذف التقييم: ${e.toString()}');
    }
  }

  // Get user's review for agency
  static Future<TravelAgencyReview?> getUserReviewForAgency(String agencyId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('travel_agency_reviews')
          .select('*')
          .eq('agency_id', agencyId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null ? TravelAgencyReview.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final agenciesCount = await _supabase
          .from('travel_agencies')
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact);

      final verifiedAgenciesCount = await _supabase
          .from('travel_agencies')
          .select('id')
          .eq('is_active', true)
          .eq('is_verified', true)
          .count(CountOption.exact);

      final offersCount = await _supabase
          .from('travel_agency_offers')
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact);

      final reviewsCount = await _supabase
          .from('travel_agency_reviews')
          .select('id')
          .count(CountOption.exact);

      // Get agencies by wilaya
      final agenciesByWilaya = await _supabase
          .from('travel_agencies')
          .select('wilaya')
          .eq('is_active', true);

      final wilayaStats = <String, int>{};
      for (final agency in agenciesByWilaya) {
        final wilaya = agency['wilaya'] as String;
        wilayaStats[wilaya] = (wilayaStats[wilaya] ?? 0) + 1;
      }

      return {
        'total_agencies': agenciesCount.count,
        'verified_agencies': verifiedAgenciesCount.count,
        'total_offers': offersCount.count,
        'total_reviews': reviewsCount.count,
        'agencies_by_wilaya': wilayaStats,
      };
    } catch (e) {
      throw Exception('فشل في جلب الإحصائيات: ${e.toString()}');
    }
  }

  // Admin functions
  
  // Create agency (Admin only)
  static Future<TravelAgency> createAgency(Map<String, dynamic> agencyData) async {
    try {
      final response = await _supabase
          .from('travel_agencies')
          .insert(agencyData)
          .select()
          .single();

      return TravelAgency.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الوكالة: ${e.toString()}');
    }
  }

  // Update agency (Admin only)
  static Future<TravelAgency> updateAgency(String agencyId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('travel_agencies')
          .update(updates)
          .eq('id', agencyId)
          .select()
          .single();

      return TravelAgency.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الوكالة: ${e.toString()}');
    }
  }

  // Delete agency (Admin only)
  static Future<void> deleteAgency(String agencyId) async {
    try {
      await _supabase
          .from('travel_agencies')
          .delete()
          .eq('id', agencyId);
    } catch (e) {
      throw Exception('فشل في حذف الوكالة: ${e.toString()}');
    }
  }

  // Toggle agency active status (Admin only)
  static Future<TravelAgency> toggleAgencyStatus(String agencyId, bool isActive) async {
    try {
      final response = await _supabase
          .from('travel_agencies')
          .update({'is_active': isActive})
          .eq('id', agencyId)
          .select()
          .single();

      return TravelAgency.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تغيير حالة الوكالة: ${e.toString()}');
    }
  }

  // Verify agency (Admin only)
  static Future<TravelAgency> verifyAgency(String agencyId, bool isVerified) async {
    try {
      final response = await _supabase
          .from('travel_agencies')
          .update({'is_verified': isVerified})
          .eq('id', agencyId)
          .select()
          .single();

      return TravelAgency.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث حالة التحقق: ${e.toString()}');
    }
  }

  // Create offer (Admin only)
  static Future<TravelAgencyOffer> createOffer(Map<String, dynamic> offerData) async {
    try {
      final response = await _supabase
          .from('travel_agency_offers')
          .insert(offerData)
          .select()
          .single();

      return TravelAgencyOffer.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء العرض: ${e.toString()}');
    }
  }

  // Update offer (Admin only)
  static Future<TravelAgencyOffer> updateOffer(String offerId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('travel_agency_offers')
          .update(updates)
          .eq('id', offerId)
          .select()
          .single();

      return TravelAgencyOffer.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث العرض: ${e.toString()}');
    }
  }

  // Delete offer (Admin only)
  static Future<void> deleteOffer(String offerId) async {
    try {
      await _supabase
          .from('travel_agency_offers')
          .delete()
          .eq('id', offerId);
    } catch (e) {
      throw Exception('فشل في حذف العرض: ${e.toString()}');
    }
  }

  // Get all agencies for admin (including inactive)
  static Future<List<TravelAgency>> getAllAgenciesForAdmin({
    String? searchQuery,
    String? wilaya,
    bool? isActive,
    bool? isVerified,
    String sortBy = 'created_at',
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Check if user is admin
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }
      
      if (currentUser.email != 'admin@rizervitoo.dz') {
        throw Exception('غير مصرح لك بالوصول إلى بيانات الوكالات - يجب أن تكون مدير');
      }

      var query = _supabase
          .from('travel_agencies')
          .select('*');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,address.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      if (wilaya != null && wilaya.isNotEmpty) {
        query = query.eq('wilaya', wilaya);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (isVerified != null) {
        query = query.eq('is_verified', isVerified);
      }

      // Apply sorting and pagination, then execute query
      final response = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => TravelAgency.fromJson(json))
          .toList();
    } catch (e) {
      if (e.toString().contains('JWT')) {
        throw Exception('انتهت صلاحية جلسة المدير - يرجى تسجيل الدخول مرة أخرى');
      }
      if (e.toString().contains('permission denied') || e.toString().contains('42501')) {
        throw Exception('ليس لديك صلاحية للوصول إلى بيانات الوكالات - تأكد من تسجيل الدخول كمدير');
      }
      throw Exception('فشل في جلب الوكالات للمدير: ${e.toString()}');
    }
  }

  // Get all offers for admin (including inactive)
  static Future<List<TravelAgencyOffer>> getAllOffersForAdmin({
    String? searchQuery,
    String? agencyId,
    String? category,
    bool? isActive,
    bool? isFeatured,
    String sortBy = 'created_at',
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('travel_agency_offers')
          .select('*');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,destination.ilike.%$searchQuery%');
      }

      if (agencyId != null && agencyId.isNotEmpty) {
        query = query.eq('agency_id', agencyId);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      // Apply sorting and pagination
      final response = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => TravelAgencyOffer.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب العروض للمدير: ${e.toString()}');
    }
  }

  // Toggle offer status (active/inactive)
  static Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      await _supabase
          .from('travel_agency_offers')
          .update({'is_active': isActive, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', offerId);
    } catch (e) {
      throw Exception('فشل في تغيير حالة العرض: ${e.toString()}');
    }
  }
}