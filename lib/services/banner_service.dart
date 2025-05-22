import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';
import 'dart:developer' as developer;
import 'dart:math';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  // Get all banners
  Future<List<BannerModel>> getAllBanners({bool activeOnly = false}) async {
    try {
      developer.log('BannerService: Fetching all banners, activeOnly: $activeOnly');
      
      Query query = _firestore.collection(_collection);
      
      // Only get active banners if requested
      if (activeOnly) {
        developer.log('BannerService: Filtering for isActive=true banners only');
        query = query.where('isActive', isEqualTo: true);
      }
      
      // Sort by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);
      
      // Debug: List all documents in the banners collection
      try {
        final allBanners = await _firestore.collection(_collection).get();
        developer.log('BannerService: Debug - Found ${allBanners.docs.length} total documents in banners collection');
        
        if (allBanners.docs.isEmpty) {
          developer.log('BannerService: WARNING - No banner documents found in Firestore!');
        } else {
          developer.log('BannerService: Banner documents found:');
          for (final doc in allBanners.docs) {
            final data = doc.data();
            developer.log(
              'BannerService: Banner ID: ${doc.id}\n'
              '  - title: ${data['title']}\n'
              '  - subtitle: ${data['subtitle']}\n'
              '  - discountPercentage: ${data['discountPercentage']}\n'
              '  - imageUrl: ${data['imageUrl']?.toString().substring(0, min(40, (data['imageUrl'] ?? '').toString().length))}...\n'
              '  - isActive: ${data['isActive']}\n'
              '  - createdAt: ${data['createdAt']}\n'
            );
          }
        }
      } catch (e) {
        developer.log('BannerService: Error during debug query', error: e);
      }
      
      // Perform the actual query to get banners based on the filter
      final querySnapshot = await query.get();
      developer.log('BannerService: Query returned ${querySnapshot.docs.length} documents');
      
      // Map the documents to BannerModel objects
      final banners = querySnapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
          
      developer.log('BannerService: Successfully converted ${banners.length} documents to BannerModel objects');
      
      if (banners.isNotEmpty) {
        // Log the banners that will be shown
        developer.log('BannerService: Banners to display:');
        for (final banner in banners) {
          developer.log(
            'BannerService: Banner: ${banner.id}\n'
            '  - title: ${banner.title}\n'
            '  - subtitle: ${banner.subtitle}\n'
            '  - discountPercentage: ${banner.discountPercentage}\n'
            '  - isActive: ${banner.isActive}\n'
            '  - imageUrl: ${banner.imageUrl.substring(0, min(40, banner.imageUrl.length))}...\n'
          );
        }
        return banners;
      }
      
      // Special handling for no active banners but when not filtering
      if (!activeOnly) {
        developer.log('BannerService: No banners found in database');
      } else {
        developer.log('BannerService: No ACTIVE banners found in database');
        
        // Try to get any banners, even inactive ones for debugging purposes
        final allQuerySnapshot = await _firestore.collection(_collection).get();
        if (allQuerySnapshot.docs.isNotEmpty) {
          developer.log('BannerService: However, found ${allQuerySnapshot.docs.length} total banners (including inactive)');
        }
      }
      
      // If no banners found, create a default one
      developer.log('BannerService: Returning default banner');
      return [
        BannerModel(
          id: 'default',
          title: 'Special Promotion',
          subtitle: 'Limited time offer on services',
          imageUrl: 'https://placehold.co/800x400/orange/white?text=Special+Offer',
          discountPercentage: 20,
          isActive: true,
        ),
      ];
    } catch (e, stackTrace) {
      developer.log('BannerService: Error fetching banners', error: e);
      developer.log('BannerService: Stack trace: $stackTrace');
      
      // Return default banner instead of empty list
      return [
        BannerModel(
          id: 'default-error',
          title: 'Special Offer',
          subtitle: 'Limited time discount on all services',
          imageUrl: 'https://placehold.co/800x400/orange/white?text=Special+Offer',
          discountPercentage: 15,
          isActive: true,
        ),
      ];
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