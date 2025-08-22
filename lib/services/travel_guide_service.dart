import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel_guide.dart';

class TravelGuideService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Mock data for testing
  static final List<TravelGuide> _mockGuides = [
    TravelGuide(
      id: '1',
      title: 'الجزائر العاصمة - قلب الجزائر النابض',
      description: 'اكتشف جمال العاصمة الجزائرية وتاريخها العريق',
      content: 'الجزائر العاصمة هي عاصمة الجزائر وأكبر مدنها. تقع على ساحل البحر الأبيض المتوسط في شمال البلاد. تُعرف المدينة بتاريخها العريق وهندستها المعمارية الفريدة التي تمزج بين الطراز العثماني والفرنسي والحديث.',
      imageUrl: null,
      category: 'cities',
      tags: ['عاصمة', 'تاريخ', 'ثقافة'],
      location: 'الجزائر العاصمة',
      latitude: 36.7538,
      longitude: 3.0588,
      isPublished: true,
      viewCount: 1250,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TravelGuide(
      id: '2',
      title: 'وهران - عروس البحر الأبيض المتوسط',
      description: 'مدينة الموسيقى والثقافة على ساحل البحر المتوسط',
      content: 'وهران هي ثاني أكبر مدينة في الجزائر وتُلقب بعروس البحر الأبيض المتوسط. تشتهر بموسيقى الراي وشواطئها الجميلة ومعمارها الاستعماري الفريد.',
      imageUrl: null,
      category: 'cities',
      tags: ['موسيقى', 'شواطئ', 'ثقافة'],
      location: 'وهران',
      latitude: 35.6911,
      longitude: -0.6417,
      isPublished: true,
      viewCount: 980,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TravelGuide(
      id: '3',
      title: 'قسنطينة - مدينة الجسور المعلقة',
      description: 'مدينة تاريخية مبنية على الصخور مع جسور رائعة',
      content: 'قسنطينة مدينة تاريخية تُعرف بجسورها المعلقة الرائعة وموقعها الفريد على الصخور. تُلقب بمدينة الجسور المعلقة وهي من أهم المدن التاريخية في الجزائر.',
      imageUrl: null,
      category: 'cities',
      tags: ['جسور', 'تاريخ', 'صخور'],
      location: 'قسنطينة',
      latitude: 36.3650,
      longitude: 6.6147,
      isPublished: true,
      viewCount: 750,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TravelGuide(
      id: '4',
      title: 'تيمقاد - مدينة رومانية أثرية',
      description: 'موقع أثري روماني مدرج في قائمة التراث العالمي',
      content: 'تيمقاد مدينة أثرية رومانية تقع في ولاية باتنة. تأسست عام 100 ميلادي وهي من أفضل المواقع الأثرية المحفوظة في شمال أفريقيا.',
      imageUrl: null,
      category: 'historical',
      tags: ['آثار', 'رومان', 'تراث'],
      location: 'باتنة',
      latitude: 35.4833,
      longitude: 6.4667,
      isPublished: true,
      viewCount: 650,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TravelGuide(
      id: '5',
      title: 'الصحراء الكبرى - أكبر صحراء في العالم',
      description: 'تجربة فريدة في قلب الصحراء الكبرى',
      content: 'الصحراء الكبرى في الجزائر تقدم تجربة لا تُنسى مع الكثبان الرملية الذهبية والواحات الخضراء والنجوم اللامعة في السماء الصافية.',
      imageUrl: null,
      category: 'nature',
      tags: ['صحراء', 'مغامرة', 'طبيعة'],
      location: 'تمنراست',
      latitude: 22.7833,
      longitude: 5.5167,
      isPublished: true,
      viewCount: 1100,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Get all travel guides
  Future<List<TravelGuide>> getAllTravelGuides({int limit = 20}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final guides = List<TravelGuide>.from(_mockGuides)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch travel guides: $e');
    }
  }

  // Get travel guide by ID
  Future<TravelGuide?> getTravelGuideById(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockGuides.firstWhere(
        (guide) => guide.id == id && guide.isPublished,
        orElse: () => throw Exception('Travel guide not found'),
      );
    } catch (e) {
      throw Exception('Failed to fetch travel guide: $e');
    }
  }

  // Get travel guides by category
  Future<List<TravelGuide>> getTravelGuidesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final guides = _mockGuides
          .where((guide) => guide.category == category && guide.isPublished)
          .toList()
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch travel guides by category: $e');
    }
  }

  // Get featured travel guides
  Future<List<TravelGuide>> getFeaturedTravelGuides({int limit = 10}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final guides = List<TravelGuide>.from(_mockGuides)
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured travel guides: $e');
    }
  }

  // Get recent travel guides
  Future<List<TravelGuide>> getRecentTravelGuides({int limit = 10}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final guides = List<TravelGuide>.from(_mockGuides)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent travel guides: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      final guideIndex = _mockGuides.indexWhere((guide) => guide.id == id);
      if (guideIndex != -1) {
        _mockGuides[guideIndex] = _mockGuides[guideIndex].copyWith(
          viewCount: _mockGuides[guideIndex].viewCount + 1,
        );
      }
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  // Get available categories
  Future<List<String>> getCategories() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final categories = _mockGuides
          .where((guide) => guide.isPublished)
          .map((guide) => guide.category)
          .toSet()
          .toList();
      
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Search travel guides
  Future<List<TravelGuide>> searchTravelGuides(
    String query, {
    int limit = 20,
    String? category,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final lowerQuery = query.toLowerCase();
      var guides = _mockGuides
          .where((guide) => 
              guide.isPublished &&
              (guide.title.toLowerCase().contains(lowerQuery) ||
               guide.description.toLowerCase().contains(lowerQuery) ||
               guide.location.toLowerCase().contains(lowerQuery) ||
               guide.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))))
          .toList();
      
      if (category != null && category.isNotEmpty) {
        guides = guides.where((guide) => guide.category == category).toList();
      }
      
      guides.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search travel guides: $e');
    }
  }

  // Get travel guides by location
  Future<List<TravelGuide>> getTravelGuidesByLocation(String location, {
    int limit = 10,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final guides = _mockGuides
          .where((guide) => guide.location.toLowerCase().contains(location.toLowerCase()) && guide.isPublished)
          .toList()
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      
      return guides.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch travel guides by location: $e');
    }
  }
}