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
      // Build filter first to keep filter builder type (so eq is available), then apply order/range
      var filter = _supabase
          .from('reviews')
          .select('''
            *,
            profiles:profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations:accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('accommodation_id', accommodationId);

      if (verifiedOnly) {
        filter = filter.eq('is_verified', true);
      }

      final response = await filter
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map<Review>((e) {
        final json = e as Map<String, dynamic>;
        final profile = json['profiles'] as Map<String, dynamic>?;
        final accommodation = json['accommodations'] as Map<String, dynamic>?;
        return Review.fromJson({
          ...json,
          'guest_name': profile?['full_name'],
          'guest_avatar': profile?['avatar_url'],
          'accommodation_title': accommodation?['title'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب التقييمات: $e');
    }
  }

  // Check if user can review an accommodation
  static Future<bool> canUserReview(String accommodationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final bookings = await _supabase
          .from('bookings')
          .select('id, check_out_date, status')
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .neq('status', 'cancelled')
          .limit(1);

      if ((bookings as List).isEmpty) return false;

      final booking = (bookings.first) as Map<String, dynamic>;
      final checkoutDate = DateTime.parse(booking['check_out_date'] as String);
      final now = DateTime.now();
      final passed = checkoutDate.isBefore(now) ||
          checkoutDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
      if (!passed) return false;

      final existing = await _supabase
          .from('reviews')
          .select('id')
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .limit(1);

      return (existing as List).isEmpty;
    } catch (_) {
      return false;
    }
  }

  // Get user's review for an accommodation
  static Future<Review?> getUserReview(String accommodationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final res = await _supabase
          .from('reviews')
          .select('''
            *,
            profiles:profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations:accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('guest_id', user.id)
          .eq('accommodation_id', accommodationId)
          .limit(1);

      if ((res as List).isEmpty) return null;
      final json = res.first as Map<String, dynamic>;
      final profile = json['profiles'] as Map<String, dynamic>?;
      final accommodation = json['accommodations'] as Map<String, dynamic>?;

      return Review.fromJson({
        ...json,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (_) {
      return null;
    }
  }

  // Add a new review
  static Future<Review> addReview({
    String? bookingId,
    required String accommodationId,
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
        throw Exception('يجب تسجيل الدخول لإضافة تقييم');
      }

      final Map<String, dynamic> reviewData = {
        'guest_id': user.id,
        'accommodation_id': accommodationId,
        'rating': rating,
        'title': title,
        'comment': comment,
        'cleanliness_rating': cleanlinessRating,
        'location_rating': locationRating,
        'value_rating': valueRating,
        'communication_rating': communicationRating,
        'images': images ?? <String>[],
      };
      if (bookingId != null) {
        reviewData['booking_id'] = bookingId;
      }

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
          .select('''
            *,
            profiles:profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations:accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .single();

      final profile = response['profiles'] as Map<String, dynamic>?;
      final accommodation = response['accommodations'] as Map<String, dynamic>?;

      return Review.fromJson({
        ...response,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (e) {
      throw Exception('فشل في إضافة التقييم: $e');
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
            'images': images ?? <String>[],
          })
          .eq('id', reviewId)
          .eq('guest_id', user.id)
          .select('''
            *,
            profiles:profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations:accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .single();

      final profile = response['profiles'] as Map<String, dynamic>?;
      final accommodation = response['accommodations'] as Map<String, dynamic>?;

      return Review.fromJson({
        ...response,
        'guest_name': profile?['full_name'],
        'guest_avatar': profile?['avatar_url'],
        'accommodation_title': accommodation?['title'],
      });
    } catch (e) {
      throw Exception('فشل في تحديث التقييم: $e');
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
      throw Exception('فشل في حذف التقييم: $e');
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
          .limit(1);

      if ((accommodationResponse as List).isEmpty) {
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
      throw Exception('فشل في إضافة الرد: $e');
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
            profiles:profiles!reviews_guest_id_fkey(
              full_name,
              avatar_url
            ),
            accommodations:accommodations!reviews_accommodation_id_fkey(
              title
            )
          ''')
          .eq('guest_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map<Review>((e) {
        final json = e as Map<String, dynamic>;
        final profile = json['profiles'] as Map<String, dynamic>?;
        final accommodation = json['accommodations'] as Map<String, dynamic>?;
        return Review.fromJson({
          ...json,
          'guest_name': profile?['full_name'],
          'guest_avatar': profile?['avatar_url'],
          'accommodation_title': accommodation?['title'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب تقييماتك: $e');
    }
  }

  // احصائيات التقييمات لإقامة معيّنة
  static Future<Map<String, dynamic>> getAccommodationReviewStats(
    String accommodationId, {
    bool verifiedOnly = true,
  }) async {
    try {
      var query = _supabase
          .from('reviews')
          .select('rating, cleanliness_rating, location_rating, value_rating, communication_rating, is_verified')
          .eq('accommodation_id', accommodationId);

      if (verifiedOnly) {
        query = query.eq('is_verified', true);
      }

      final rows = await query;
      final list = (rows as List).cast<Map<String, dynamic>>();
      final total = list.length;
      if (total == 0) {
        return {
          'total_reviews': 0,
          'average_rating': 0.0,
          'rating_distribution': {for (var i = 1; i <= 5; i++) i: 0},
          'detailed_averages': {
            'cleanliness': 0.0,
            'location': 0.0,
            'value': 0.0,
            'communication': 0.0,
          },
        };
      }

      int ratingSum = 0;
      final Map<int, int> distribution = {for (var i = 1; i <= 5; i++) i: 0};

      int cleanlinessSum = 0, cleanlinessCount = 0;
      int locationSum = 0, locationCount = 0;
      int valueSum = 0, valueCount = 0;
      int communicationSum = 0, communicationCount = 0;

      for (final row in list) {
        final rating = (row['rating'] as num).toInt();
        ratingSum += rating;
        if (distribution.containsKey(rating)) {
          distribution[rating] = (distribution[rating] ?? 0) + 1;
        }

        final cr = row['cleanliness_rating'];
        if (cr != null) {
          cleanlinessSum += (cr as num).toInt();
          cleanlinessCount++;
        }
        final lr = row['location_rating'];
        if (lr != null) {
          locationSum += (lr as num).toInt();
          locationCount++;
        }
        final vr = row['value_rating'];
        if (vr != null) {
          valueSum += (vr as num).toInt();
          valueCount++;
        }
        final comm = row['communication_rating'];
        if (comm != null) {
          communicationSum += (comm as num).toInt();
          communicationCount++;
        }
      }

      final average = ratingSum / total;

      final Map<String, double> detailedAverages = {
        'cleanliness': cleanlinessCount > 0 ? cleanlinessSum / cleanlinessCount : 0.0,
        'location': locationCount > 0 ? locationSum / locationCount : 0.0,
        'value': valueCount > 0 ? valueSum / valueCount : 0.0,
        'communication': communicationCount > 0 ? communicationSum / communicationCount : 0.0,
      };

      return {
        'total_reviews': total,
        'average_rating': average.toDouble(),
        'rating_distribution': distribution,
        'detailed_averages': detailedAverages,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات التقييمات: $e');
    }
  }
}