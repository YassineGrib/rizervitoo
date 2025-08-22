import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all bookings for the current user (as guest)
  Future<List<Booking>> getUserBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images
            )
          ''')
          .eq('guest_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((booking) {
        final accommodationData = booking['accommodations'] as Map<String, dynamic>;
        return Booking.fromJson({
          ...booking,
          'accommodation_title': accommodationData['title'],
          'accommodation_city': accommodationData['city'],
          'accommodation_images': accommodationData['images'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الحجوزات: $e');
    }
  }

  // Get bookings for accommodations owned by current user (as host)
  Future<List<Booking>> getHostBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images,
              owner_id
            ),
            profiles!bookings_guest_id_fkey(
              full_name,
              phone
            )
          ''')
          .eq('accommodations.owner_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((booking) {
        final accommodationData = booking['accommodations'] as Map<String, dynamic>;
        final guestData = booking['profiles'] as Map<String, dynamic>?;
        return Booking.fromJson({
          ...booking,
          'accommodation_title': accommodationData['title'],
          'accommodation_city': accommodationData['city'],
          'accommodation_images': accommodationData['images'],
          'guest_name': guestData?['full_name'],
          'guest_phone': guestData?['phone'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب حجوزات الاستضافة: $e');
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images,
              address
            )
          ''')
          .eq('id', bookingId)
          .single();

      final accommodationData = response['accommodations'] as Map<String, dynamic>;
      return Booking.fromJson({
        ...response,
        'accommodation_title': accommodationData['title'],
        'accommodation_city': accommodationData['city'],
        'accommodation_images': accommodationData['images'],
        'accommodation_address': accommodationData['address'],
      });
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الحجز: $e');
    }
  }

  // Create a new booking
  Future<Booking> createBooking(BookingRequest request) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      // Check availability first
      final isAvailable = await checkAvailability(
        request.accommodationId,
        request.checkInDate,
        request.checkOutDate,
      );

      if (!isAvailable) {
        throw Exception('الإقامة غير متاحة في التواريخ المحددة');
      }

      final bookingData = {
        ...request.toJson(),
        'guest_id': user.id,
      };

      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images
            )
          ''')
          .single();

      final accommodationData = response['accommodations'] as Map<String, dynamic>;
      return Booking.fromJson({
        ...response,
        'accommodation_title': accommodationData['title'],
        'accommodation_city': accommodationData['city'],
        'accommodation_images': accommodationData['images'],
      });
    } catch (e) {
      throw Exception('فشل في إنشاء الحجز: $e');
    }
  }

  // Update booking
  Future<Booking> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      // If dates are being updated, check availability
      if (updates.containsKey('check_in_date') || updates.containsKey('check_out_date')) {
        final booking = await getBookingById(bookingId);
        if (booking == null) throw Exception('الحجز غير موجود');

        final checkInDate = updates['check_in_date'] != null
            ? DateTime.parse(updates['check_in_date'])
            : booking.checkInDate;
        final checkOutDate = updates['check_out_date'] != null
            ? DateTime.parse(updates['check_out_date'])
            : booking.checkOutDate;

        final isAvailable = await checkAvailability(
          booking.accommodationId,
          checkInDate,
          checkOutDate,
          excludeBookingId: bookingId,
        );

        if (!isAvailable) {
          throw Exception('الإقامة غير متاحة في التواريخ الجديدة');
        }

        // Recalculate total if dates changed
        if (updates.containsKey('check_in_date') || updates.containsKey('check_out_date')) {
          final totalNights = checkOutDate.difference(checkInDate).inDays;
          updates['total_amount'] = booking.pricePerNight * totalNights;
        }
      }

      final response = await _supabase
          .from('bookings')
          .update(updates)
          .eq('id', bookingId)
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images
            )
          ''')
          .single();

      final accommodationData = response['accommodations'] as Map<String, dynamic>;
      return Booking.fromJson({
        ...response,
        'accommodation_title': accommodationData['title'],
        'accommodation_city': accommodationData['city'],
        'accommodation_images': accommodationData['images'],
      });
    } catch (e) {
      throw Exception('فشل في تحديث الحجز: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancellation_reason': reason,
          })
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Confirm booking
  Future<void> confirmBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'confirmed',
            'confirmed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  // Check-in booking
  Future<void> checkInBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'confirmed',
            'checked_in_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to check-in booking: $e');
    }
  }

  // Complete booking
  Future<void> completeBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  // Check availability for specific dates
  Future<bool> checkAvailability(
    String accommodationId,
    DateTime checkInDate,
    DateTime checkOutDate, {
    String? excludeBookingId,
  }) async {
    try {
      var query = _supabase
          .from('bookings')
          .select('id, check_in_date, check_out_date')
          .eq('accommodation_id', accommodationId)
          .inFilter('status', ['confirmed', 'pending']);

      // Exclude specific booking if provided (for modification scenarios)
      if (excludeBookingId != null) {
        query = query.neq('id', excludeBookingId);
      }

      final response = await query;

      // Check for overlapping bookings
      for (final booking in response) {
        final existingCheckIn = DateTime.parse(booking['check_in_date']);
        final existingCheckOut = DateTime.parse(booking['check_out_date']);

        // Check if dates overlap
        if (checkInDate.isBefore(existingCheckOut) &&
            checkOutDate.isAfter(existingCheckIn)) {
          return false; // Dates overlap, not available
        }
      }

      return true; // No overlapping bookings found
    } catch (e) {
      throw Exception('Failed to check availability: $e');
    }
  }

  // Get booking statistics for user
  Future<Map<String, int>> getBookingStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final response = await _supabase
          .from('bookings')
          .select('status')
          .eq('guest_id', user.id);

      final stats = <String, int>{
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final booking in response) {
        final status = booking['status'] as String;
        stats['total'] = (stats['total'] ?? 0) + 1;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات الحجوزات: $e');
    }
  }

  // Get upcoming bookings
  Future<List<Booking>> getUpcomingBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            accommodations!inner(
              title,
              city,
              images
            )
          ''')
          .eq('guest_id', user.id)
          .gte('check_in_date', today)
          .inFilter('status', ['confirmed', 'pending'])
          .order('check_in_date', ascending: true)
          .limit(5);

      return (response as List).map((booking) {
        final accommodationData = booking['accommodations'] as Map<String, dynamic>;
        return Booking.fromJson({
          ...booking,
          'accommodation_title': accommodationData['title'],
          'accommodation_city': accommodationData['city'],
          'accommodation_images': accommodationData['images'],
        });
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب الحجوزات القادمة: $e');
    }
  }
}