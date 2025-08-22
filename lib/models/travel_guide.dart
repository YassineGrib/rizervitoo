class TravelGuide {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final String location;
  final double? latitude;
  final double? longitude;
  final bool isPublished;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.category,
    required this.tags,
    required this.location,
    this.latitude,
    this.longitude,
    required this.isPublished,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelGuide.fromJson(Map<String, dynamic> json) {
    return TravelGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] as String,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isPublished: json['is_published'] as bool,
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'image_url': imageUrl,
      'category': category,
      'tags': tags,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_published': isPublished,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TravelGuide copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? category,
    List<String>? tags,
    String? location,
    double? latitude,
    double? longitude,
    bool? isPublished,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TravelGuide(id: $id, title: $title, category: $category, location: $location)';
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

  String get formattedViewCount {
    if (viewCount < 1000) return viewCount.toString();
    if (viewCount < 1000000) return '${(viewCount / 1000).toStringAsFixed(1)}ك';
    return '${(viewCount / 1000000).toStringAsFixed(1)}م';
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