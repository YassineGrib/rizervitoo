class TravelAgency {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String wilaya; // الولاية
  final String phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final double rating;
  final int totalReviews;
  final bool isActive;
  final bool isVerified;
  final String? licenseNumber;
  final int? establishedYear;
  final List<String> specialties;
  final List<String> languages;
  final Map<String, dynamic>? workingHours;
  final Map<String, dynamic>? socialMedia;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TravelAgencyOffer>? offers;
  final List<TravelAgencyReview>? reviews;

  TravelAgency({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.wilaya,
    required this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    this.isVerified = false,
    this.licenseNumber,
    this.establishedYear,
    this.specialties = const [],
    this.languages = const ['العربية'],
    this.workingHours,
    this.socialMedia,
    this.createdAt,
    this.updatedAt,
    this.offers,
    this.reviews,
  });

  factory TravelAgency.fromJson(Map<String, dynamic> json) {
    return TravelAgency(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      wilaya: json['wilaya'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      licenseNumber: json['license_number'] as String?,
      establishedYear: json['established_year'] as int?,
      specialties: json['specialties'] != null 
          ? List<String>.from(json['specialties'] as List)
          : [],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages'] as List)
          : ['العربية'],
      workingHours: json['working_hours'] as Map<String, dynamic>?,
      socialMedia: json['social_media'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      offers: json['offers'] != null
          ? (json['offers'] as List)
              .map((offer) => TravelAgencyOffer.fromJson(offer))
              .toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((review) => TravelAgencyReview.fromJson(review))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'wilaya': wilaya,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_active': isActive,
      'is_verified': isVerified,
      'license_number': licenseNumber,
      'established_year': establishedYear,
      'specialties': specialties,
      'languages': languages,
      'working_hours': workingHours,
      'social_media': socialMedia,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TravelAgency copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? wilaya,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    double? rating,
    int? totalReviews,
    bool? isActive,
    bool? isVerified,
    String? licenseNumber,
    int? establishedYear,
    List<String>? specialties,
    List<String>? languages,
    Map<String, dynamic>? workingHours,
    Map<String, dynamic>? socialMedia,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TravelAgencyOffer>? offers,
    List<TravelAgencyReview>? reviews,
  }) {
    return TravelAgency(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      wilaya: wilaya ?? this.wilaya,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      establishedYear: establishedYear ?? this.establishedYear,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
      workingHours: workingHours ?? this.workingHours,
      socialMedia: socialMedia ?? this.socialMedia,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      offers: offers ?? this.offers,
      reviews: reviews ?? this.reviews,
    );
  }

  // Helper methods
  String get formattedRating => rating.toStringAsFixed(1);
  
  String get specialtiesText => specialties.join('، ');
  
  String get languagesText => languages.join('، ');
  
  bool get hasOffers => offers != null && offers!.isNotEmpty;
  
  bool get hasReviews => reviews != null && reviews!.isNotEmpty;
  
  List<TravelAgencyOffer> get activeOffers => 
      offers?.where((offer) => offer.isActive).toList() ?? [];
  
  List<TravelAgencyOffer> get featuredOffers => 
      offers?.where((offer) => offer.isActive && offer.isFeatured).toList() ?? [];
}

class TravelAgencyOffer {
  final String id;
  final String agencyId;
  final String title;
  final String? description;
  final String destination;
  final int durationDays;
  final double priceDzd;
  final double? originalPriceDzd;
  final List<String> includes;
  final List<String> excludes;
  final List<String> imageUrls;
  final int? maxParticipants;
  final int minParticipants;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final bool isActive;
  final bool isFeatured;
  final String? category;
  final String? difficultyLevel;
  final String? ageRestrictions;
  final String? requirements;
  final String? cancellationPolicy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TravelAgencyOffer({
    required this.id,
    required this.agencyId,
    required this.title,
    this.description,
    required this.destination,
    required this.durationDays,
    required this.priceDzd,
    this.originalPriceDzd,
    this.includes = const [],
    this.excludes = const [],
    this.imageUrls = const [],
    this.maxParticipants,
    this.minParticipants = 1,
    this.availableFrom,
    this.availableTo,
    this.isActive = true,
    this.isFeatured = false,
    this.category,
    this.difficultyLevel,
    this.ageRestrictions,
    this.requirements,
    this.cancellationPolicy,
    this.createdAt,
    this.updatedAt,
  });

  factory TravelAgencyOffer.fromJson(Map<String, dynamic> json) {
    return TravelAgencyOffer(
      id: json['id'] as String,
      agencyId: json['agency_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      durationDays: json['duration_days'] as int,
      priceDzd: (json['price_dzd'] as num).toDouble(),
      originalPriceDzd: (json['original_price_dzd'] as num?)?.toDouble(),
      includes: json['includes'] != null 
          ? List<String>.from(json['includes'] as List)
          : [],
      excludes: json['excludes'] != null 
          ? List<String>.from(json['excludes'] as List)
          : [],
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] as List)
          : [],
      maxParticipants: json['max_participants'] as int?,
      minParticipants: json['min_participants'] as int? ?? 1,
      availableFrom: json['available_from'] != null 
          ? DateTime.parse(json['available_from'] as String)
          : null,
      availableTo: json['available_to'] != null 
          ? DateTime.parse(json['available_to'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      category: json['category'] as String?,
      difficultyLevel: json['difficulty_level'] as String?,
      ageRestrictions: json['age_restrictions'] as String?,
      requirements: json['requirements'] as String?,
      cancellationPolicy: json['cancellation_policy'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agency_id': agencyId,
      'title': title,
      'description': description,
      'destination': destination,
      'duration_days': durationDays,
      'price_dzd': priceDzd,
      'original_price_dzd': originalPriceDzd,
      'includes': includes,
      'excludes': excludes,
      'image_urls': imageUrls,
      'max_participants': maxParticipants,
      'min_participants': minParticipants,
      'available_from': availableFrom?.toIso8601String(),
      'available_to': availableTo?.toIso8601String(),
      'is_active': isActive,
      'is_featured': isFeatured,
      'category': category,
      'difficulty_level': difficultyLevel,
      'age_restrictions': ageRestrictions,
      'requirements': requirements,
      'cancellation_policy': cancellationPolicy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedPrice => '${priceDzd.toStringAsFixed(0)} دج';
  
  String get formattedOriginalPrice => 
      originalPriceDzd != null ? '${originalPriceDzd!.toStringAsFixed(0)} دج' : '';
  
  bool get hasDiscount => originalPriceDzd != null && originalPriceDzd! > priceDzd;
  
  double get discountPercentage => hasDiscount 
      ? ((originalPriceDzd! - priceDzd) / originalPriceDzd! * 100)
      : 0.0;
  
  String get formattedDuration => durationDays == 1 
      ? 'يوم واحد'
      : durationDays == 2 
          ? 'يومان'
          : '$durationDays أيام';
  
  bool get isAvailable {
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) return false;
    if (availableTo != null && now.isAfter(availableTo!)) return false;
    return isActive;
  }
  
  String get includesText => includes.join('\n• ');
  String get excludesText => excludes.join('\n• ');
}

class TravelAgencyReview {
  final String id;
  final String agencyId;
  final String userId;
  final int rating;
  final String? title;
  final String? comment;
  final bool isVerified;
  final int helpfulCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName; // من جدول profiles
  final String? userAvatar; // من جدول profiles

  TravelAgencyReview({
    required this.id,
    required this.agencyId,
    required this.userId,
    required this.rating,
    this.title,
    this.comment,
    this.isVerified = false,
    this.helpfulCount = 0,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory TravelAgencyReview.fromJson(Map<String, dynamic> json) {
    return TravelAgencyReview(
      id: json['id'] as String,
      agencyId: json['agency_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agency_id': agencyId,
      'user_id': userId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'is_verified': isVerified,
      'helpful_count': helpfulCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedDate {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 30) {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else {
      return 'منذ قليل';
    }
  }
  
  String get displayName => userName ?? 'مستخدم مجهول';
}

// Enums for better type safety
enum AgencySpecialty {
  domestic('سياحة داخلية'),
  international('سياحة خارجية'),
  umrah('عمرة'),
  hajj('حج'),
  business('سياحة أعمال'),
  adventure('سياحة مغامرات'),
  cultural('سياحة ثقافية'),
  medical('سياحة علاجية'),
  educational('سياحة تعليمية');

  const AgencySpecialty(this.arabicName);
  final String arabicName;
}

enum OfferCategory {
  domestic('داخلية'),
  international('خارجية'),
  umrah('عمرة'),
  hajj('حج'),
  weekend('نهاية أسبوع'),
  holiday('عطلة'),
  adventure('مغامرة'),
  cultural('ثقافية'),
  beach('شاطئية'),
  mountain('جبلية'),
  desert('صحراوية');

  const OfferCategory(this.arabicName);
  final String arabicName;
}

enum DifficultyLevel {
  easy('سهل'),
  moderate('متوسط'),
  hard('صعب'),
  expert('خبير');

  const DifficultyLevel(this.arabicName);
  final String arabicName;
}

// Algerian Wilayas (States) for dropdown
class AlgerianWilayas {
  static const List<String> all = [
    'أدرار',
    'الشلف',
    'الأغواط',
    'أم البواقي',
    'باتنة',
    'بجاية',
    'بسكرة',
    'بشار',
    'البليدة',
    'البويرة',
    'تمنراست',
    'تبسة',
    'تلمسان',
    'تيارت',
    'تيزي وزو',
    'الجزائر',
    'الجلفة',
    'جيجل',
    'سطيف',
    'سعيدة',
    'سكيكدة',
    'سيدي بلعباس',
    'عنابة',
    'قالمة',
    'قسنطينة',
    'المدية',
    'مستغانم',
    'المسيلة',
    'معسكر',
    'ورقلة',
    'وهران',
    'البيض',
    'إليزي',
    'برج بوعريريج',
    'بومرداس',
    'الطارف',
    'تندوف',
    'تيسمسيلت',
    'الوادي',
    'خنشلة',
    'سوق أهراس',
    'تيبازة',
    'ميلة',
    'عين الدفلى',
    'النعامة',
    'عين تموشنت',
    'غرداية',
    'غليزان',
    'تيميمون',
    'برج باجي مختار',
    'أولاد جلال',
    'بني عباس',
    'عين صالح',
    'عين قزام',
    'تقرت',
    'جانت',
    'المغير',
    'المنيعة',
  ];
}