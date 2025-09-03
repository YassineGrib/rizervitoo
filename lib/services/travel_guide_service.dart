import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/travel_guide.dart';

class TravelGuideService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Mock data for testing
  static final List<TravelGuide> _mockGuides = [
    // TravelGuide(
    //   id: '1',
    //   title: 'الجزائر العاصمة - قلب الجزائر النابض',
    //   description: 'اكتشف جمال العاصمة الجزائرية وتاريخها العريق',
    //   content: 'الجزائر العاصمة هي عاصمة الجزائر وأكبر مدنها. تقع على ساحل البحر الأبيض المتوسط في شمال البلاد. تُعرف المدينة بتاريخها العريق وهندستها المعمارية الفريدة التي تمزج بين الطراز العثماني والفرنسي والحديث.',
    //   imageUrl: null,
    //   category: 'cities',
    //   tags: ['عاصمة', 'تاريخ', 'ثقافة'],
    //   location: 'الجزائر العاصمة',
    //   latitude: 36.7538,
    //   longitude: 3.0588,
    //   isPublished: true,
    //   viewCount: 1250,
    //   createdAt: DateTime.now().subtract(const Duration(days: 30)),
    //   updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    // ),
    // TravelGuide(
    //   id: '2',
    //   title: 'وهران - عروس البحر الأبيض المتوسط',
    //   description: 'مدينة الموسيقى والثقافة على ساحل البحر المتوسط',
    //   content: 'وهران هي ثاني أكبر مدينة في الجزائر وتُلقب بعروس البحر الأبيض المتوسط. تشتهر بموسيقى الراي وشواطئها الجميلة ومعمارها الاستعماري الفريد.',
    //   imageUrl: null,
    //   category: 'cities',
    //   tags: ['موسيقى', 'شواطئ', 'ثقافة'],
    //   location: 'وهران',
    //   latitude: 35.6911,
    //   longitude: -0.6417,
    //   isPublished: true,
    //   viewCount: 980,
    //   createdAt: DateTime.now().subtract(const Duration(days: 25)),
    //   updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    // ),
    // TravelGuide(
    //   id: '3',
    //   title: 'قسنطينة - مدينة الجسور المعلقة',
    //   description: 'مدينة تاريخية مبنية على الصخور مع جسور رائعة',
    //   content: 'قسنطينة مدينة تاريخية تُعرف بجسورها المعلقة الرائعة وموقعها الفريد على الصخور. تُلقب بمدينة الجسور المعلقة وهي من أهم المدن التاريخية في الجزائر.',
    //   imageUrl: null,
    //   category: 'cities',
    //   tags: ['جسور', 'تاريخ', 'صخور'],
    //   location: 'قسنطينة',
    //   latitude: 36.3650,
    //   longitude: 6.6147,
    //   isPublished: true,
    //   viewCount: 750,
    //   createdAt: DateTime.now().subtract(const Duration(days: 20)),
    //   updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    // ),
    // TravelGuide(
    //   id: '4',
    //   title: 'تيمقاد - مدينة رومانية أثرية',
    //   description: 'موقع أثري روماني مدرج في قائمة التراث العالمي',
    //   content: 'تيمقاد مدينة أثرية رومانية تقع في ولاية باتنة. تأسست عام 100 ميلادي وهي من أفضل المواقع الأثرية المحفوظة في شمال أفريقيا.',
    //   imageUrl: null,
    //   category: 'historical',
    //   tags: ['آثار', 'رومان', 'تراث'],
    //   location: 'باتنة',
    //   latitude: 35.4833,
    //   longitude: 6.4667,
    //   isPublished: true,
    //   viewCount: 650,
    //   createdAt: DateTime.now().subtract(const Duration(days: 15)),
    //   updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    // ),
    // TravelGuide(
    //   id: '5',
    //   title: 'الصحراء الكبرى - أكبر صحراء في العالم',
    //   description: 'تجربة فريدة في قلب الصحراء الكبرى',
    //   content: 'الصحراء الكبرى في الجزائر تقدم تجربة لا تُنسى مع الكثبان الرملية الذهبية والواحات الخضراء والنجوم اللامعة في السماء الصافية.',
    //   imageUrl: null,
    //   category: 'nature',
    //   tags: ['صحراء', 'مغامرة', 'طبيعة'],
    //   location: 'تمنراست',
    //   latitude: 22.7833,
    //   longitude: 5.5167,
    //   isPublished: true,
    //   viewCount: 1100,
    //   createdAt: DateTime.now().subtract(const Duration(days: 10)),
    //   updatedAt: DateTime.now(),
    // ),
  ];

  // Get all travel guides
  Future<List<TravelGuide>> getAllTravelGuides({int limit = 20}) async {
    try {
      print('Fetching travel guides from database...');
      
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);
      
      print('Database response: ${response.length} travel guides found');
      
      if (response.isEmpty) {
        // Also try to get unpublished guides for debugging
        final allResponse = await _supabase
            .from('travel_guides')
            .select('id, title, is_published')
            .order('created_at', ascending: false);
        
        print('Total guides in database (including unpublished): ${allResponse.length}');
        for (var guide in allResponse) {
          print('Guide: ${guide['title']} - Published: ${guide['is_published']}');
        }
      }
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error fetching travel guides: $e');
      throw Exception('Failed to fetch travel guides: $e');
    }
  }

  // Get travel guide by ID
  Future<TravelGuide?> getTravelGuideById(String id) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('id', id)
          .eq('is_published', true)
          .single();
      
      return TravelGuide.fromJson(response);
    } catch (e) {
      print('Error fetching travel guide by ID: $e');
      throw Exception('Failed to fetch travel guide: $e');
    }
  }

  // Get travel guides by category
  Future<List<TravelGuide>> getTravelGuidesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('category', category)
          .eq('is_published', true)
          .order('views_count', ascending: false)
          .limit(limit);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error fetching travel guides by category: $e');
      throw Exception('Failed to fetch travel guides by category: $e');
    }
  }

  // Get featured travel guides
  Future<List<TravelGuide>> getFeaturedTravelGuides({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('is_published', true)
          .eq('is_featured', true)
          .order('views_count', ascending: false)
          .limit(limit);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error fetching featured travel guides: $e');
      throw Exception('Failed to fetch featured travel guides: $e');
    }
  }

  // Get recent travel guides
  Future<List<TravelGuide>> getRecentTravelGuides({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error fetching recent travel guides: $e');
      throw Exception('Failed to fetch recent travel guides: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      // Get current views count
      final response = await _supabase
          .from('travel_guides')
          .select('views_count')
          .eq('id', id)
          .single();
      
      final currentViews = response['views_count'] as int? ?? 0;
      
      // Update with incremented count
      await _supabase
          .from('travel_guides')
          .update({'views_count': currentViews + 1})
          .eq('id', id);
    } catch (e) {
      print('Error incrementing view count: $e');
      throw Exception('Failed to increment view count: $e');
    }
  }

  // Get available categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('category')
          .eq('is_published', true);
      
      final categories = response
          .map((guide) => guide['category'] as String)
          .toSet()
          .toList();
      
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
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
      var queryBuilder = _supabase
          .from('travel_guides')
          .select('*')
          .eq('is_published', true);
      
      // Add text search
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,description.ilike.%$query%,city.ilike.%$query%,state.ilike.%$query%'
        );
      }
      
      // Add category filter
      if (category != null && category.isNotEmpty) {
        queryBuilder = queryBuilder.eq('category', category);
      }
      
      final response = await queryBuilder
          .order('views_count', ascending: false)
          .limit(limit);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error searching travel guides: $e');
      throw Exception('Failed to search travel guides: $e');
    }
  }

  // Get travel guides by location
  Future<List<TravelGuide>> getTravelGuidesByLocation(String location, {
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('travel_guides')
          .select('*')
          .eq('is_published', true)
          .or('city.ilike.%$location%,state.ilike.%$location%')
          .order('views_count', ascending: false)
          .limit(limit);
      
      return response.map((guide) => TravelGuide.fromJson(guide)).toList();
    } catch (e) {
      print('Error fetching travel guides by location: $e');
      throw Exception('Failed to fetch travel guides by location: $e');
    }
  }
}