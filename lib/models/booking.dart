import 'booking_status.dart';
import 'payment_status.dart';

class Booking {
  final String id;
  final String guestId;
  final String accommodationId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestsCount;
  final int totalNights;
  final double pricePerNight;
  final double totalAmount;
  final String currency;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final String? guestNotes;
  final String? hostNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? checkedInAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Optional accommodation details for display
  final String? accommodationTitle;
  final String? accommodationCity;
  final List<String>? accommodationImages;

  // New property to check if a booking can be reviewed
  final bool canReview;

  const Booking({
    required this.id,
    required this.guestId,
    required this.accommodationId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestsCount,
    required this.totalNights,
    required this.pricePerNight,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.specialRequests,
    this.guestNotes,
    this.hostNotes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.checkedInAt,
    this.completedAt,
    this.cancelledAt,
    this.accommodationTitle,
    this.accommodationCity,
    this.accommodationImages,
    this.canReview = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      accommodationId: json['accommodation_id'] as String,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      guestsCount: json['guests_count'] as int,
      totalNights: json['total_nights'] as int,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'DZD',
      status: BookingStatusExtension.fromString(json['status'] as String),
      paymentStatus: PaymentStatusExtension.fromString(json['payment_status'] as String),
      paymentMethod: json['payment_method'] as String?,
      specialRequests: json['special_requests'] as String?,
      guestNotes: json['guest_notes'] as String?,
      hostNotes: json['host_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at'] as String) : null,
      checkedInAt: json['checked_in_at'] != null ? DateTime.parse(json['checked_in_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at'] as String) : null,
      // Add canReview property from JSON
      canReview: json['can_review'] as bool? ?? false,
      accommodationTitle: json['accommodation_title'] as String?,
      accommodationCity: json['accommodation_city'] as String?,
      accommodationImages: json['accommodation_images'] != null
          ? List<String>.from(json['accommodation_images'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_id': guestId,
      'accommodation_id': accommodationId,
      'check_in_date': checkInDate.toIso8601String().split('T')[0],
      'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      'guests_count': guestsCount,
      'price_per_night': pricePerNight,
      'total_amount': totalAmount,
      'currency': currency,
      'status': status.value,
      'payment_status': paymentStatus.value,
      'payment_method': paymentMethod,
      'special_requests': specialRequests,
      'guest_notes': guestNotes,
      'host_notes': hostNotes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'checked_in_at': checkedInAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      // Add canReview to JSON
      'can_review': canReview,
    };
  }

  Booking copyWith({
    String? id,
    String? guestId,
    String? accommodationId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guestsCount,
    int? totalNights,
    double? pricePerNight,
    double? totalAmount,
    String? currency,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? specialRequests,
    String? guestNotes,
    String? hostNotes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? accommodationTitle,
    String? accommodationCity,
    List<String>? accommodationImages,
    bool? canReview,
  }) {
    return Booking(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      accommodationId: accommodationId ?? this.accommodationId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guestsCount: guestsCount ?? this.guestsCount,
      totalNights: totalNights ?? this.totalNights,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      specialRequests: specialRequests ?? this.specialRequests,
      guestNotes: guestNotes ?? this.guestNotes,
      hostNotes: hostNotes ?? this.hostNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      accommodationTitle: accommodationTitle ?? this.accommodationTitle,
      accommodationCity: accommodationCity ?? this.accommodationCity,
      accommodationImages: accommodationImages ?? this.accommodationImages,
      // Update canReview value
      canReview: canReview ?? this.canReview,
    );
  }

  bool get canBeCancelled => status == BookingStatus.pending || status == BookingStatus.confirmed;
  bool get canBeModified => status == BookingStatus.pending;

  @override
  String toString() {
    return 'Booking(id: $id, guestId: $guestId, accommodationId: $accommodationId, checkInDate: $checkInDate, checkOutDate: $checkOutDate, guestsCount: $guestsCount, totalNights: $totalNights, pricePerNight: $pricePerNight, totalAmount: $totalAmount, currency: $currency, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, specialRequests: $specialRequests, guestNotes: $guestNotes, hostNotes: $hostNotes, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, checkedInAt: $checkedInAt, completedAt: $completedAt, cancelledAt: $cancelledAt, accommodationTitle: $accommodationTitle, accommodationCity: $accommodationCity, accommodationImages: $accommodationImages, canReview: $canReview)';
  }
}
