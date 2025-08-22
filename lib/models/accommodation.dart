class Accommodation {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String type;
  final String address;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final double pricePerNight;
  final String currency;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final bool isVerified;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Accommodation({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    required this.pricePerNight,
    required this.currency,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.images,
    required this.isAvailable,
    required this.isVerified,
    required this.rating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String? ?? 'الجزائر',
      country: json['country'] as String? ?? 'الجزائر',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'DZD',
      maxGuests: json['max_guests'] as int? ?? 1,
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities'] as List)
          : [],
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List)
          : [],
      isAvailable: json['is_available'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'price_per_night': pricePerNight,
      'currency': currency,
      'max_guests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'images': images,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'rating': rating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'hotel':
        return 'فندق';
      case 'house':
        return 'منزل';
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'guesthouse':
        return 'بيت ضيافة';
      case 'hostel':
        return 'نزل';
      default:
        return type;
    }
  }

  String get formattedPrice {
    return '${pricePerNight.toStringAsFixed(0)} $currency';
  }

  String get guestInfo {
    return '$maxGuests ضيوف • $bedrooms غرف نوم • $bathrooms حمامات';
  }
}