class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;
  final String? nationality;
  final String? preferredLanguage;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.nationality,
    this.preferredLanguage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      nationality: json['nationality'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
    );
  }

  factory User.fromProfile(Map<String, dynamic> profileData, String email) {
    return User(
      id: profileData['id'] as String,
      fullName: profileData['full_name'] as String? ?? '',
      email: email,
      phoneNumber: profileData['phone'] as String?,
      dateOfBirth: profileData['date_of_birth'] as String?,
      isActive: true, // Default to active
      createdAt: profileData['created_at'] != null 
          ? DateTime.parse(profileData['created_at'] as String)
          : null,
      updatedAt: profileData['updated_at'] != null 
          ? DateTime.parse(profileData['updated_at'] as String)
          : null,
      avatarUrl: profileData['avatar_url'] as String?,
      nationality: profileData['nationality'] as String?,
      preferredLanguage: profileData['preferred_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'avatar_url': avatarUrl,
      'nationality': nationality,
      'preferred_language': preferredLanguage,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    String? nationality,
    String? preferredLanguage,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, fullName, email, isActive);
  }
}