import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/accommodation.dart';
import 'dart:io';

class AccommodationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all available accommodations
  Future<List<Accommodation>> getAccommodations({
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minGuests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build the base query
      var queryBuilder = _supabase
          .from('accommodations')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true);

      // Apply filters
      if (city != null && city.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('city', '%$city%');
      }
      
      if (type != null && type.isNotEmpty) {
        queryBuilder = queryBuilder.eq('type', type);
      }
      
      // Apply price and guest filters
      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price_per_night', minPrice);
      }
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price_per_night', maxPrice);
      }
      if (minGuests != null) {
        queryBuilder = queryBuilder.lte('max_guests', minGuests);
      }

      // Apply ordering and pagination
      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch accommodations: $e');
    }
  }

  // Get accommodation by ID
  Future<Accommodation?> getAccommodationById(String id) async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select()
          .eq('id', id)
          .eq('is_available', true)
          .eq('is_verified', true)
          .single();
      
      return Accommodation.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Search accommodations by text
  Future<List<Accommodation>> searchAccommodations(String searchText) async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true)
          .or('title.ilike.%$searchText%,description.ilike.%$searchText%,city.ilike.%$searchText%,address.ilike.%$searchText%')
          .order('rating', ascending: false)
          .limit(20);
      
      return (response as List)
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search accommodations: $e');
    }
  }

  // Get accommodations by city
  Future<List<Accommodation>> getAccommodationsByCity(String city) async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true)
          .ilike('city', '%$city%')
          .order('rating', ascending: false)
          .limit(20);
      
      return (response as List)
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch accommodations by city: $e');
    }
  }

  // Get popular accommodations (highest rated)
  Future<List<Accommodation>> getPopularAccommodations({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select()
          .eq('is_available', true)
          .eq('is_verified', true)
          .gte('rating', 4.0)
          .order('rating', ascending: false)
          .order('total_reviews', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular accommodations: $e');
    }
  }

  // Get unique cities for filter dropdown
  Future<List<String>> getCities() async {
    try {
      final response = await _supabase
          .from('accommodations')
          .select('city')
          .eq('is_available', true)
          .eq('is_verified', true);
      
      final cities = (response as List)
          .map((item) => item['city'] as String)
          .toSet()
          .toList();
      
      cities.sort();
      return cities;
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  // Get accommodation types for filter
  List<String> getAccommodationTypes() {
    return ['hotel', 'house', 'apartment', 'villa', 'guesthouse', 'hostel'];
  }

  // Get accommodation type display names
  Map<String, String> getAccommodationTypeNames() {
    return {
      'hotel': 'فندق',
      'house': 'منزل',
      'apartment': 'شقة',
      'villa': 'فيلا',
      'guesthouse': 'بيت ضيافة',
      'hostel': 'نزل',
    };
  }

  // Get current user's accommodations (for hosts)
  Future<List<Accommodation>> getHostAccommodations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('accommodations')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Accommodation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch host accommodations: $e');
    }
  }

  // Create new accommodation
  Future<Accommodation> createAccommodation(Accommodation accommodation) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final accommodationData = {
        'title': accommodation.title,
        'description': accommodation.description,
        'type': accommodation.type,
        'address': accommodation.address,
        'city': accommodation.city,
        'country': accommodation.country,
        'price_per_night': accommodation.pricePerNight,
        'max_guests': accommodation.maxGuests,
        'bedrooms': accommodation.bedrooms,
        'bathrooms': accommodation.bathrooms,
        'amenities': accommodation.amenities,
        'images': accommodation.images,
        'is_available': accommodation.isAvailable,
        'owner_id': user.id,
        'is_verified': false, // New accommodations need verification
        'rating': 0.0,
        'total_reviews': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('accommodations')
          .insert(accommodationData)
          .select()
          .single();
      
      return Accommodation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create accommodation: $e');
    }
  }

  // Update existing accommodation
  Future<Accommodation> updateAccommodation(Accommodation accommodation) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final accommodationData = {
        'title': accommodation.title,
        'description': accommodation.description,
        'type': accommodation.type,
        'address': accommodation.address,
        'city': accommodation.city,
        'country': accommodation.country,
        'price_per_night': accommodation.pricePerNight,
        'max_guests': accommodation.maxGuests,
        'bedrooms': accommodation.bedrooms,
        'bathrooms': accommodation.bathrooms,
        'amenities': accommodation.amenities,
        'images': accommodation.images,
        'is_available': accommodation.isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('accommodations')
          .update(accommodationData)
          .eq('id', accommodation.id)
          .eq('owner_id', user.id) // Ensure user can only update their own accommodations
          .select()
          .single();
      
      return Accommodation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update accommodation: $e');
    }
  }

  // Delete accommodation
  Future<void> deleteAccommodation(String accommodationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('accommodations')
          .delete()
          .eq('id', accommodationId)
          .eq('owner_id', user.id); // Ensure user can only delete their own accommodations
      
    } catch (e) {
      throw Exception('Failed to delete accommodation: $e');
    }
  }

  // Upload images to Supabase Storage
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      List<String> uploadedUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = 'accommodations/$fileName';
        
        await _supabase.storage
            .from('accommodation-images')
            .upload(filePath, file);
        
        final publicUrl = _supabase.storage
            .from('accommodation-images')
            .getPublicUrl(filePath);
        
        uploadedUrls.add(publicUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }
}