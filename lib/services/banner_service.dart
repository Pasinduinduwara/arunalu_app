import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';
import 'dart:developer' as developer;

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  // Get all banners
  Future<List<BannerModel>> getAllBanners({bool activeOnly = false}) async {
    try {
      developer.log('Fetching all banners, activeOnly: $activeOnly');
      
      Query query = _firestore.collection(_collection);
      
      // Only get active banners if requested
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      // Sort by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching banners', error: e);
      throw Exception('Failed to fetch banners: $e');
    }
  }

  // Get banner by ID
  Future<BannerModel?> getBanner(String bannerId) async {
    try {
      developer.log('Fetching banner with ID: $bannerId');
      
      final docSnapshot = await _firestore.collection(_collection).doc(bannerId).get();
      
      if (!docSnapshot.exists) {
        developer.log('Banner not found: $bannerId');
        return null;
      }
      
      return BannerModel.fromFirestore(docSnapshot);
    } catch (e) {
      developer.log('Error fetching banner', error: e);
      throw Exception('Failed to fetch banner: $e');
    }
  }

  // Add a new banner
  Future<String> addBanner(BannerModel banner) async {
    try {
      developer.log('Adding new banner');
      
      final data = banner.toFirestore();
      // Add created timestamp for new banners
      data['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(data);
      
      developer.log('Banner added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding banner', error: e);
      throw Exception('Failed to add banner: $e');
    }
  }

  // Update a banner
  Future<void> updateBanner(String bannerId, BannerModel banner) async {
    try {
      developer.log('Updating banner with ID: $bannerId');
      
      await _firestore.collection(_collection)
          .doc(bannerId)
          .update(banner.toFirestore());
      
      developer.log('Banner updated successfully');
    } catch (e) {
      developer.log('Error updating banner', error: e);
      throw Exception('Failed to update banner: $e');
    }
  }

  // Delete a banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      developer.log('Deleting banner with ID: $bannerId');
      
      await _firestore.collection(_collection).doc(bannerId).delete();
      
      developer.log('Banner deleted successfully');
    } catch (e) {
      developer.log('Error deleting banner', error: e);
      throw Exception('Failed to delete banner: $e');
    }
  }

  // Toggle banner active status
  Future<void> toggleBannerStatus(String bannerId, bool isActive) async {
    try {
      developer.log('Toggling banner status to: $isActive, ID: $bannerId');
      
      await _firestore.collection(_collection)
          .doc(bannerId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      developer.log('Banner status updated successfully');
    } catch (e) {
      developer.log('Error updating banner status', error: e);
      throw Exception('Failed to update banner status: $e');
    }
  }
} 