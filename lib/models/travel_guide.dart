class TravelGuide {
  final String id;
  final String title;
  final String description;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final String category;
  final String difficultyLevel;
  final String? bestSeason;
  final String? estimatedDuration;
  final double entryFee;
  final String currency;
  final List<String> images;
  final List<String> highlights;
  final List<String> tips;
  final List<String> nearbyAccommodations;
  final String? transportationInfo;
  final Map<String, dynamic> contactInfo;
  final Map<String, dynamic> openingHours;
  final bool isPublished;
  final bool isFeatured;
  final int viewsCount;
  final double rating;
  final int totalReviews;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    required this.category,
    required this.difficultyLevel,
    this.bestSeason,
    this.estimatedDuration,
    required this.entryFee,
    required this.currency,
    required this.images,
    required this.highlights,
    required this.tips,
    required this.nearbyAccommodations,
    this.transportationInfo,
    required this.contactInfo,
    required this.openingHours,
    required this.isPublished,
    required this.isFeatured,
    required this.viewsCount,
    required this.rating,
    required this.totalReviews,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelGuide.fromJson(Map<String, dynamic> json) {
    return TravelGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'الجزائر',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      category: json['category'] as String,
      difficultyLevel: json['difficulty_level'] as String? ?? 'easy',
      bestSeason: json['best_season'] as String?,
      estimatedDuration: json['estimated_duration'] as String?,
      entryFee: (json['entry_fee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'DZD',
      images: List<String>.from(json['images'] ?? []),
      highlights: List<String>.from(json['highlights'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      nearbyAccommodations: List<String>.from(json['nearby_accommodations'] ?? []),
      transportationInfo: json['transportation_info'] as String?,
      contactInfo: Map<String, dynamic>.from(json['contact_info'] ?? {}),
      openingHours: Map<String, dynamic>.from(json['opening_hours'] ?? {}),
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'difficulty_level': difficultyLevel,
      'best_season': bestSeason,
      'estimated_duration': estimatedDuration,
      'entry_fee': entryFee,
      'currency': currency,
      'images': images,
      'highlights': highlights,
      'tips': tips,
      'nearby_accommodations': nearbyAccommodations,
      'transportation_info': transportationInfo,
      'contact_info': contactInfo,
      'opening_hours': openingHours,
      'is_published': isPublished,
      'is_featured': isFeatured,
      'views_count': viewsCount,
      'rating': rating,
      'total_reviews': totalReviews,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TravelGuide copyWith({
    String? id,
    String? title,
    String? description,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    String? category,
    String? difficultyLevel,
    String? bestSeason,
    String? estimatedDuration,
    double? entryFee,
    String? currency,
    List<String>? images,
    List<String>? highlights,
    List<String>? tips,
    List<String>? nearbyAccommodations,
    String? transportationInfo,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? openingHours,
    bool? isPublished,
    bool? isFeatured,
    int? viewsCount,
    double? rating,
    int? totalReviews,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      bestSeason: bestSeason ?? this.bestSeason,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      entryFee: entryFee ?? this.entryFee,
      currency: currency ?? this.currency,
      images: images ?? this.images,
      highlights: highlights ?? this.highlights,
      tips: tips ?? this.tips,
      nearbyAccommodations: nearbyAccommodations ?? this.nearbyAccommodations,
      transportationInfo: transportationInfo ?? this.transportationInfo,
      contactInfo: contactInfo ?? this.contactInfo,
      openingHours: openingHours ?? this.openingHours,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TravelGuide(id: $id, title: $title, category: $category, city: $city, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelGuide && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods for UI
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  String get location {
    return '$city, $state';
  }

  String get primaryImageUrl {
    return images.isNotEmpty ? images.first : '';
  }

  String get difficultyDisplayName {
    switch (difficultyLevel.toLowerCase()) {
      case 'easy':
        return 'سهل';
      case 'moderate':
        return 'متوسط';
      case 'difficult':
        return 'صعب';
      default:
        return difficultyLevel;
    }
  }

  String get formattedViewCount {
    if (viewsCount < 1000) return viewsCount.toString();
    if (viewsCount < 1000000) return '${(viewsCount / 1000).toStringAsFixed(1)}ك';
    return '${(viewsCount / 1000000).toStringAsFixed(1)}م';
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'historical':
        return 'تاريخي';
      case 'cultural':
        return 'ثقافي';
      case 'natural':
        return 'طبيعي';
      case 'adventure':
        return 'مغامرة';
      case 'religious':
        return 'ديني';
      case 'food':
        return 'طعام';
      case 'shopping':
        return 'تسوق';
      case 'entertainment':
        return 'ترفيه';
      default:
        return category;
    }
  }
}