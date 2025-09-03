class Review {
  final String id;
  final String? bookingId;
  final String guestId;
  final String accommodationId;
  final int rating;
  final String? title;
  final String? comment;
  final int? cleanlinessRating;
  final int? locationRating;
  final int? valueRating;
  final int? communicationRating;
  final List<String> images;
  final bool isVerified;
  final String? hostReply;
  final DateTime? hostReplyDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for display
  final String? guestName;
  final String? guestAvatar;
  final String? accommodationTitle;

  const Review({
    required this.id,
    this.bookingId,
    required this.guestId,
    required this.accommodationId,
    required this.rating,
    this.title,
    this.comment,
    this.cleanlinessRating,
    this.locationRating,
    this.valueRating,
    this.communicationRating,
    required this.images,
    required this.isVerified,
    this.hostReply,
    this.hostReplyDate,
    required this.createdAt,
    required this.updatedAt,
    this.guestName,
    this.guestAvatar,
    this.accommodationTitle,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String?,
      guestId: json['guest_id'] as String,
      accommodationId: json['accommodation_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      cleanlinessRating: json['cleanliness_rating'] as int?,
      locationRating: json['location_rating'] as int?,
      valueRating: json['value_rating'] as int?,
      communicationRating: json['communication_rating'] as int?,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List)
          : [],
      isVerified: json['is_verified'] as bool? ?? false,
      hostReply: json['host_reply'] as String?,
      hostReplyDate: json['host_reply_date'] != null 
          ? DateTime.parse(json['host_reply_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      guestName: json['guest_name'] as String?,
      guestAvatar: json['guest_avatar'] as String?,
      accommodationTitle: json['accommodation_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'guest_id': guestId,
      'accommodation_id': accommodationId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'cleanliness_rating': cleanlinessRating,
      'location_rating': locationRating,
      'value_rating': valueRating,
      'communication_rating': communicationRating,
      'images': images,
      'is_verified': isVerified,
      'host_reply': hostReply,
      'host_reply_date': hostReplyDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? bookingId,
    String? guestId,
    String? accommodationId,
    int? rating,
    String? title,
    String? comment,
    int? cleanlinessRating,
    int? locationRating,
    int? valueRating,
    int? communicationRating,
    List<String>? images,
    bool? isVerified,
    String? hostReply,
    DateTime? hostReplyDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? guestName,
    String? guestAvatar,
    String? accommodationTitle,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      guestId: guestId ?? this.guestId,
      accommodationId: accommodationId ?? this.accommodationId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      cleanlinessRating: cleanlinessRating ?? this.cleanlinessRating,
      locationRating: locationRating ?? this.locationRating,
      valueRating: valueRating ?? this.valueRating,
      communicationRating: communicationRating ?? this.communicationRating,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      hostReply: hostReply ?? this.hostReply,
      hostReplyDate: hostReplyDate ?? this.hostReplyDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      guestName: guestName ?? this.guestName,
      guestAvatar: guestAvatar ?? this.guestAvatar,
      accommodationTitle: accommodationTitle ?? this.accommodationTitle,
    );
  }

  // Helper methods
  double get averageDetailRating {
    final ratings = [
      cleanlinessRating,
      locationRating,
      valueRating,
      communicationRating,
    ].where((rating) => rating != null).map((rating) => rating!);
    
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else {
      return 'منذ قليل';
    }
  }

  String get displayName => guestName ?? 'ضيف';

  bool get hasDetailedRatings => 
      cleanlinessRating != null || 
      locationRating != null || 
      valueRating != null || 
      communicationRating != null;

  bool get hasImages => images.isNotEmpty;
  bool get hasHostReply => hostReply != null && hostReply!.isNotEmpty;
}