import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user notifications with pagination and filtering
  Future<List<AppNotification>> getUserNotifications({
    int offset = 0,
    int limit = 20,
    bool? isRead,
    NotificationType? type,
    bool excludeExpired = true,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      var query = _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId);

      // Apply filters
      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }
      
      if (type != null) {
        query = query.eq('type', type.name);
      }

      // Filter out expired notifications
      if (excludeExpired) {
        query = query.or('expires_at.is.null,expires_at.gt.${DateTime.now().toIso8601String()}');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الإشعارات: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .eq('is_read', false)
          .or('expires_at.is.null,expires_at.gt.${DateTime.now().toIso8601String()}');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الإشعار: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('فشل في تحديث الإشعارات: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('فشل في حذف الإشعار: $e');
    }
  }

  // Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);
    } catch (e) {
      throw Exception('فشل في حذف الإشعارات: $e');
    }
  }

  // Create notification (for admin/system use)
  Future<AppNotification> createNotification(CreateNotificationRequest request) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert(request.toJson())
          .select()
          .single();

      return AppNotification.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إنشاء الإشعار: $e');
    }
  }

  // Create booking notification
  Future<void> createBookingNotification({
    required String userId,
    required String bookingId,
    required String accommodationTitle,
    required String status,
  }) async {
    String title;
    String message;
    NotificationPriority priority = NotificationPriority.normal;

    switch (status) {
      case 'confirmed':
        title = 'تم تأكيد حجزك';
        message = 'تم تأكيد حجزك في $accommodationTitle بنجاح';
        priority = NotificationPriority.high;
        break;
      case 'cancelled':
        title = 'تم إلغاء حجزك';
        message = 'تم إلغاء حجزك في $accommodationTitle';
        priority = NotificationPriority.high;
        break;
      case 'completed':
        title = 'تم إكمال إقامتك';
        message = 'نأمل أن تكون قد استمتعت بإقامتك في $accommodationTitle';
        break;
      default:
        title = 'تحديث على حجزك';
        message = 'تم تحديث حالة حجزك في $accommodationTitle';
    }

    await createNotification(CreateNotificationRequest(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.booking,
      priority: priority,
      data: {
        'booking_id': bookingId,
        'accommodation_title': accommodationTitle,
        'status': status,
      },
      actionUrl: '/bookings',
    ));
  }

  // Create payment notification
  Future<void> createPaymentNotification({
    required String userId,
    required String bookingId,
    required double amount,
    required String status,
  }) async {
    String title;
    String message;
    NotificationPriority priority = NotificationPriority.high;

    switch (status) {
      case 'completed':
        title = 'تم الدفع بنجاح';
        message = 'تم استلام دفعتك بقيمة ${amount.toStringAsFixed(0)} دج';
        break;
      case 'failed':
        title = 'فشل في الدفع';
        message = 'فشل في معالجة دفعتك بقيمة ${amount.toStringAsFixed(0)} دج';
        break;
      case 'refunded':
        title = 'تم استرداد المبلغ';
        message = 'تم استرداد مبلغ ${amount.toStringAsFixed(0)} دج إلى حسابك';
        break;
      default:
        title = 'تحديث على الدفع';
        message = 'تم تحديث حالة دفعتك';
    }

    await createNotification(CreateNotificationRequest(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.payment,
      priority: priority,
      data: {
        'booking_id': bookingId,
        'amount': amount,
        'status': status,
      },
      actionUrl: '/bookings',
    ));
  }

  // Create welcome notification for new users
  Future<void> createWelcomeNotification(String userId, String userName) async {
    await createNotification(CreateNotificationRequest(
      userId: userId,
      title: 'مرحباً بك في ريزرفيتو!',
      message: 'أهلاً وسهلاً $userName! نحن سعداء لانضمامك إلينا. اكتشف أجمل الأماكن في الجزائر واحجز إقامتك المثالية.',
      type: NotificationType.welcome,
      priority: NotificationPriority.normal,
      data: {
        'user_name': userName,
        'welcome_date': DateTime.now().toIso8601String(),
      },
      actionUrl: '/accommodations',
    ));
  }

  // Create promotion notification
  Future<void> createPromotionNotification({
    required String userId,
    required String title,
    required String message,
    String? actionUrl,
    DateTime? expiresAt,
  }) async {
    await createNotification(CreateNotificationRequest(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.promotion,
      priority: NotificationPriority.normal,
      actionUrl: actionUrl,
      expiresAt: expiresAt,
    ));
  }

  // Listen to real-time notifications
  Stream<List<AppNotification>> watchUserNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => AppNotification.fromJson(json))
            .where((notification) => !notification.isExpired)
            .toList());
  }

  // Get notifications by type
  Future<List<AppNotification>> getNotificationsByType(NotificationType type) async {
    return getUserNotifications(type: type);
  }

  // Get recent notifications (last 24 hours)
  Future<List<AppNotification>> getRecentNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .gte('created_at', yesterday.toIso8601String())
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}