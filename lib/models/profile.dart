class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String nationality;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.nationality = 'الجزائر',
    this.preferredLanguage = 'ar',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      nationality: json['nationality'] as String? ?? 'الجزائر',
      preferredLanguage: json['preferred_language'] as String? ?? 'ar',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'nationality': nationality,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    // Only include fields that can be updated (exclude id, created_at, updated_at)
    return {
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'nationality': nationality,
      'preferred_language': preferredLanguage,
    };
  }

  Profile copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? nationality,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, fullName: $fullName, phone: $phone, nationality: $nationality)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.id == id &&
        other.fullName == fullName &&
        other.phone == phone &&
        other.avatarUrl == avatarUrl &&
        other.dateOfBirth == dateOfBirth &&
        other.nationality == nationality &&
        other.preferredLanguage == preferredLanguage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      phone,
      avatarUrl,
      dateOfBirth,
      nationality,
      preferredLanguage,
    );
  }
}