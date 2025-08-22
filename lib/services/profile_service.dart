import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user's profile
  Future<Profile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Create a new profile (usually called after user registration)
  Future<Profile?> createProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String nationality = 'الجزائر',
    String preferredLanguage = 'ar',
  }) async {
    try {
      final profileData = {
        'id': userId,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'nationality': nationality,
        'preferred_language': preferredLanguage,
      };

      final response = await _supabase
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error creating profile: $e');
      return null;
    }
  }

  // Update current user's profile
  Future<Profile?> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? nationality,
    String? preferredLanguage,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (dateOfBirth != null) {
        updateData['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (nationality != null) updateData['nationality'] = nationality;
      if (preferredLanguage != null) updateData['preferred_language'] = preferredLanguage;

      if (updateData.isEmpty) {
        // No updates to make
        return await getCurrentUserProfile();
      }

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Upload profile avatar
  Future<String?> uploadAvatar(File file, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final bytes = await file.readAsBytes();
      await _supabase.storage
          .from('avatars')
          .uploadBinary('${user.id}/$fileName', bytes);

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl('${user.id}/$fileName');

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // Delete profile avatar
  Future<bool> deleteAvatar() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // List all files in user's avatar folder
      final files = await _supabase.storage
          .from('avatars')
          .list(path: user.id);

      // Delete all files in the folder
      for (final file in files) {
        await _supabase.storage
            .from('avatars')
            .remove(['${user.id}/${file.name}']);
      }

      return true;
    } catch (e) {
      print('Error deleting avatar: $e');
      return false;
    }
  }

  // Check if profile exists for current user
  Future<bool> profileExists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  // Get profile by user ID (for viewing other users' profiles)
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching profile by ID: $e');
      return null;
    }
  }

  // Delete current user's profile
  Future<bool> deleteProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('profiles')
          .delete()
          .eq('id', user.id);

      return true;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }
}