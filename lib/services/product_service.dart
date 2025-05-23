import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get all products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      developer.log('Error getting all products', error: e);
      return [];
    }
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      developer.log('ProductService: Fetching product with ID: $productId');
      final docSnapshot = await _firestore.collection(_collection).doc(productId).get();
      
      if (!docSnapshot.exists) {
        developer.log('ProductService: Product not found: $productId');
        return null;
      }
      
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      
      developer.log('ProductService: Successfully fetched product: $productId');
      return data;
    } catch (e) {
      developer.log('ProductService: Error fetching product', error: e);
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Add a new product
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection(_collection).add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error adding product', error: e);
      throw Exception('Failed to add product');
    }
  }

  // Update a product
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error updating product', error: e);
      throw Exception('Failed to update product');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      developer.log('Error deleting product', error: e);
      throw Exception('Failed to delete product');
    }
  }

  // Get active products for home screen
  Future<List<Map<String, dynamic>>> getActiveProducts() async {
    try {
      developer.log('ProductService: Fetching active products for home screen');
      
      // First attempt to query only active products
      try {
        final querySnapshot = await _firestore.collection(_collection)
            .where('isActive', isEqualTo: true)
            .get();
        
        final products = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Include document ID
          return data;
        }).toList();
        
        developer.log('ProductService: Found ${products.length} active products with isActive filter');
        
        if (products.isNotEmpty) {
          return products;
        }
      } catch (e) {
        developer.log('ProductService: Error with isActive filter', error: e);
        // Continue to fallback approach
      }
      
      // Fallback: Get all products and manually filter if the isActive query fails
      developer.log('ProductService: Using fallback to get all products');
      final querySnapshot = await _firestore.collection(_collection).get();
      
      final allProducts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      developer.log('ProductService: Got ${allProducts.length} total products');
      
      // First try to filter for active products
      var activeProducts = allProducts.where((p) => p['isActive'] == true).toList();
      
      // If no active products found, just return all products
      if (activeProducts.isEmpty) {
        developer.log('ProductService: No active products found, returning all ${allProducts.length} products');
        return allProducts;
      }
      
      developer.log('ProductService: Returning ${activeProducts.length} active products after manual filtering');
      return activeProducts;
    } catch (e) {
      developer.log('ProductService: Critical error fetching active products', error: e);
      
      // As a last resort, return empty list to avoid app crashes
      return [];
    }
  }

  // Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      developer.log('Error getting products by category', error: e);
      return [];
    }
  }

  // Get featured products 
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      developer.log('ProductService: Fetching featured products');
      
      final querySnapshot = await _firestore.collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(5)
          .get();
      
      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      developer.log('ProductService: Successfully fetched ${products.length} featured products');
      return products;
    } catch (e) {
      developer.log('ProductService: Error fetching featured products', error: e);
      return [];
    }
  }

  // Safe convert image to base64
  String? safeImageToBase64(Uint8List? imageBytes) {
    if (imageBytes == null) return null;
    
    try {
      final result = base64Encode(imageBytes);
      // Validate the resulting base64 string
      base64Decode(result); // This will throw if invalid
      return result;
    } catch (e) {
      developer.log('Error converting image to base64', error: e);
      return null;
    }
  }

  // Safe convert base64 to image widget
  Widget safeBase64ToImage(String base64String, {
    BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } catch (e) {
      developer.log('Error converting base64 to image', error: e);
      return errorBuilder?.call(
        null as BuildContext,
        e,
        null,
      ) ?? Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }
  }

  // Get products by search term
  Future<List<Map<String, dynamic>>> searchProducts(String searchTerm) async {
    try {
      developer.log('Searching for products with term: $searchTerm');
      final querySnapshot = await _firestore.collection(_collection).get();
      
      final lowercaseSearchTerm = searchTerm.toLowerCase();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((product) {
            final title = (product['title'] as String?)?.toLowerCase() ?? '';
            final description = (product['description'] as String?)?.toLowerCase() ?? '';
            final category = (product['category'] as String?)?.toLowerCase() ?? '';
            
            return title.contains(lowercaseSearchTerm) ||
                description.contains(lowercaseSearchTerm) ||
                category.contains(lowercaseSearchTerm);
          })
          .toList();
    } catch (e) {
      developer.log('Error searching products', error: e);
      throw Exception('Failed to search products: $e');
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      final Set<String> categories = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('category') && data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }
      
      return categories.toList()..sort();
    } catch (e) {
      developer.log('Error getting categories', error: e);
      return [];
    }
  }
} 