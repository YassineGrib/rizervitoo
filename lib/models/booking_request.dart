class BookingRequest {
  final String accommodationId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestsCount;
  final double pricePerNight;
  final double totalAmount;
  final String currency;
  final String? specialRequests;
  final String? guestNotes;

  const BookingRequest({
    required this.accommodationId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestsCount,
    required this.pricePerNight,
    required this.totalAmount,
    this.currency = 'DZD',
    this.specialRequests,
    this.guestNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'accommodation_id': accommodationId,
      'check_in_date': checkInDate.toIso8601String().split('T')[0],
      'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      'guests_count': guestsCount,
      // Remove total_nights as it's a generated column
      'price_per_night': pricePerNight,
      'total_amount': totalAmount,
      'currency': currency,
      'special_requests': specialRequests,
      'guest_notes': guestNotes,
      'status': 'pending',
      'payment_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BookingRequest(accommodationId: $accommodationId, checkInDate: $checkInDate, checkOutDate: $checkOutDate, guestsCount: $guestsCount, pricePerNight: $pricePerNight, totalAmount: $totalAmount, currency: $currency, specialRequests: $specialRequests, guestNotes: $guestNotes)';
  }
}