import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review.dart';

class ReviewService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get reviews for a specific accommodation
  static Future<List<Review>> getAccommodationReviews(
    String accommodationId, {
    int limit = 20,
    int offset = 0,
    bool verifiedOnly = true,
  }) async {
    try {
          .from('reviews')
          .select('''
            *,
            profiles!reviews_guest_id_fkey(
            profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
              full_name,
              avatar_url
            ),
            accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('accommodation_id', accommodationId);

      if (verifiedOnly) {
      final response = await query
      }

      final response = await query
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
      // Calculate statistics
      final reviews = response as List<Map<String, dynamic>>;
      final totalReviews = reviews.length;
      final averageRating = reviews
          .map((r) => r['rating'] as int)
          .reduce((a, b) => a + b) / totalReviews;

      // Rating distribution
      final ratingDistribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (final review in reviews) {
        final rating = review['rating'] as int;
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      // Detailed averages
      final detailedAverages = <String, double>{};
      final detailKeys = ['cleanliness_rating', 'location_rating', 'value_rating', 'communication_rating'];
      final detailNames = ['cleanliness', 'location', 'value', 'communication'];
      
      for (int i = 0; i < detailKeys.length; i++) {
        final key = detailKeys[i];
        final name = detailNames[i];
        final ratings = reviews
            .where((r) => r[key] != null)
            .map((r) => r[key] as int)
            .toList();
        
        if (ratings.isNotEmpty) {
          detailedAverages[name] = ratings.reduce((a, b) => a + b) / ratings.length;
        } else {
          detailedAverages[name] = 0.0;
        }
      }

      return {
        'total_reviews': totalReviews,
        'average_rating': averageRating,
        'rating_distribution': ratingDistribution,
        'detailed_averages': detailedAverages,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات التقييمات: ${e.toString()}');
    }
  }

  // Check if user can review an accommodation
  static Future<bool> canUserReview(String accommodationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Debug: canUserReview - No user logged in');
        return false;
      }

      print('Debug: canUserReview - Checking for user ${user.id} and accommodation $accommodationId');

      // Check if user has a booking for this accommodation that has passed checkout date
      final bookingResponse = await _supabase
          .from('bookings')
          .select('id, check_out_date, status')
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .neq('status', 'cancelled') // Exclude cancelled bookings
          .limit(1);

      print('Debug: canUserReview - Found ${bookingResponse.length} eligible bookings');
      if (bookingResponse.isEmpty) return false;

      // Check if checkout date has passed
      final booking = bookingResponse.first;
      final checkoutDate = DateTime.parse(booking['check_out_date']);
      final now = DateTime.now();
      final checkoutDatePassed = checkoutDate.isBefore(now) || 
                                checkoutDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
      
      print('Debug: canUserReview - Checkout date: $checkoutDate, passed: $checkoutDatePassed');
      if (!checkoutDatePassed) return false;

      // Check if user already reviewed this accommodation
      final reviewResponse = await _supabase
          .from('reviews')
          .select('id')
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .limit(1);

      final hasExistingReview = reviewResponse.isNotEmpty;
      print('Debug: canUserReview - Has existing review: $hasExistingReview');
      print('Debug: canUserReview - Final result: ${!hasExistingReview}');

      return reviewResponse.isEmpty;
    } catch (e) {
      print('Debug: canUserReview - Error: $e');
      return false;
    }
  }

  // Get user's review for an accommodation
  static Future<Review?> getUserReview(String accommodationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

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
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .limit(1);

      if (response.isEmpty) return null;

      final json = response.first;
      final profile = json['profiles'];
      final accommodation = json['accommodations'];
      
      return Review.fromJson({
        ...json,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (e) {
      return null;
      final response = await _supabase

  // Add a new review
  static Future<Review> addReview({
            profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
    String? bookingId,
    required String accommodationId,
    required int rating,
    String? title,
    String? comment,
    int? cleanlinessRating,
    int? locationRating,
    int? valueRating,
      if (response.isEmpty) return null;
    List<String>? images,
      final json = response.first;
      final profile = json['profiles'];
        'location_rating': locationRating,
        'value_rating': valueRating,
        'communication_rating': communicationRating,
        'images': images ?? [],
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
      if (bookingId != null) {
        reviewData['booking_id'] = bookingId;
      }
      print('Debug: addReview - Inserting review data: $reviewData');

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
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
          .single();

      print('Debug: addReview - Successfully inserted review with ID: ${response['id']}');

      final profile = response['profiles'];
      final accommodation = response['accommodations'];
      
      return Review.fromJson({
        ...response,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (e) {
      print('Debug: addReview - Error: $e');
      throw Exception('فشل في إضافة التقييم: ${e.toString()}');
    }
  }

  // Update a review
  static Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    int? cleanlinessRating,
    int? locationRating,
    int? valueRating,
    int? communicationRating,
    List<String>? images,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لتحديث التقييم');
      }

      final response = await _supabase
          .from('reviews')
          .update({
            'rating': rating,
            'title': title,
            'comment': comment,
            'cleanliness_rating': cleanlinessRating,
            'location_rating': locationRating,
            'value_rating': valueRating,
            'communication_rating': communicationRating,
            'images': images ?? [],
          })
          .eq('id', reviewId)
          .eq('guest_id', user.id)
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
          .single();

      final profile = response['profiles'];
      final accommodation = response['accommodations'];
      
      return Review.fromJson({
        ...response,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (e) {
      throw Exception('فشل في تحديث التقييم: ${e.toString()}');
    }
  }

  // Delete a review
  static Future<void> deleteReview(String reviewId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لحذف التقييم');
      }

      await _supabase
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('guest_id', user.id);
    } catch (e) {
      throw Exception('فشل في حذف التقييم: ${e.toString()}');
    }
  }

  // Add host reply to a review
  static Future<void> addHostReply({
    required String reviewId,
    required String accommodationId,
    required String reply,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لإضافة رد');
      }

      // Verify that user owns the accommodation
      final accommodationResponse = await _supabase
          .from('accommodations')
          .select('owner_id')
          .eq('id', accommodationId)
          .eq('owner_id', user.id)
          .single();

      if (accommodationResponse.isEmpty) {
        throw Exception('غير مسموح لك بالرد على هذا التقييم');
      }

      await _supabase
          .from('reviews')
          .update({
            'host_reply': reply,
            'host_reply_date': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId)
          .eq('accommodation_id', accommodationId);
    } catch (e) {
      throw Exception('فشل في إضافة الرد: ${e.toString()}');
    }
  }

  // Get reviews by user
  static Future<List<Review>> getUserReviews({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول');
      }

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
          .eq('guest_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

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
      throw Exception('فشل في جلب تقييماتك: ${e.toString()}');
    }
  }
}