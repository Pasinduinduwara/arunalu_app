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

  // Convert image to base64
  String imageToBase64(Uint8List imageBytes) {
    try {
      return base64Encode(imageBytes);
    } catch (e) {
      developer.log('Error converting image to base64', error: e);
      throw Exception('Failed to convert image: $e');
    }
  }

  // Convert base64 to image
  Image base64ToImage(String base64String) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      );
    } catch (e) {
      developer.log('Error converting base64 to image', error: e);
      return const Image(
        image: AssetImage('assets/images/placeholder.png'),
        fit: BoxFit.cover,
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
            final name = (product['name'] as String?)?.toLowerCase() ?? '';
            final description = (product['description'] as String?)?.toLowerCase() ?? '';
            final category = (product['category'] as String?)?.toLowerCase() ?? '';
            
            return name.contains(lowercaseSearchTerm) ||
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