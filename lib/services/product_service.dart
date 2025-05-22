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
      developer.log('Fetching all products');
      final querySnapshot = await _firestore.collection(_collection).get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      developer.log('Error fetching products', error: e);
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get product by ID
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      developer.log('Fetching product with ID: $productId');
      final docSnapshot = await _firestore.collection(_collection).doc(productId).get();
      
      if (!docSnapshot.exists) {
        developer.log('Product not found: $productId');
        return null;
      }
      
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return data;
    } catch (e) {
      developer.log('Error fetching product', error: e);
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Add a new product
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      developer.log('Adding new product');
      
      // Validate base64 image if present
      if (productData.containsKey('imageBase64')) {
        final imageBase64 = productData['imageBase64'] as String?;
        if (imageBase64 != null && imageBase64.isNotEmpty) {
          try {
            // Attempt to decode to validate the base64 string
            base64Decode(imageBase64);
          } catch (e) {
            developer.log('Invalid base64 image data', error: e);
            throw Exception('Failed to process image: Invalid base64 data');
          }
        }
      }
      
      // Add timestamp
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      
      // Add the product to Firestore
      final docRef = await _firestore.collection(_collection).add(productData);
      
      developer.log('Product added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding product', error: e);
      throw Exception('Failed to add product: $e');
    }
  }

  // Update a product
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      developer.log('Updating product with ID: $productId');
      
      // Validate base64 image if present
      if (productData.containsKey('imageBase64')) {
        final imageBase64 = productData['imageBase64'] as String?;
        if (imageBase64 != null && imageBase64.isNotEmpty) {
          try {
            // Attempt to decode to validate the base64 string
            base64Decode(imageBase64);
          } catch (e) {
            developer.log('Invalid base64 image data', error: e);
            throw Exception('Failed to process image: Invalid base64 data');
          }
        }
      }
      
      // Update timestamp
      productData['updatedAt'] = FieldValue.serverTimestamp();
      
      // Update the product in Firestore
      await _firestore.collection(_collection).doc(productId).update(productData);
      
      developer.log('Product updated successfully');
    } catch (e) {
      developer.log('Error updating product', error: e);
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      developer.log('Deleting product with ID: $productId');
      
      // Delete the product from Firestore
      await _firestore.collection(_collection).doc(productId).delete();
      
      developer.log('Product deleted successfully');
    } catch (e) {
      developer.log('Error deleting product', error: e);
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      developer.log('Fetching products for category: $category');
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      developer.log('Error fetching products by category', error: e);
      throw Exception('Failed to fetch products by category: $e');
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
  Widget safeBase64ToImage(String? base64String, {
    double? width, 
    double? height, 
    BoxFit fit = BoxFit.cover
  }) {
    if (base64String == null || base64String.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 50);
    }
    
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          developer.log('Error rendering image', error: error);
          return const Icon(Icons.broken_image, color: Colors.red);
        },
      );
    } catch (e) {
      developer.log('Error decoding base64', error: e);
      return const Icon(Icons.error_outline, color: Colors.red);
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
} 