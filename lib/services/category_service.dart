import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'dart:developer' as developer;

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Get all categories
  Future<List<CategoryModel>> getAllCategories({bool activeOnly = false}) async {
    try {
      developer.log('Fetching all categories, activeOnly: $activeOnly');
      
      Query query = _firestore.collection(_collection);
      
      // Only get active categories if requested
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      // Sort by sort order
      query = query.orderBy('sortOrder');
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching categories', error: e);
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategory(String categoryId) async {
    try {
      developer.log('Fetching category with ID: $categoryId');
      
      final docSnapshot = await _firestore.collection(_collection).doc(categoryId).get();
      
      if (!docSnapshot.exists) {
        developer.log('Category not found: $categoryId');
        return null;
      }
      
      return CategoryModel.fromFirestore(docSnapshot);
    } catch (e) {
      developer.log('Error fetching category', error: e);
      throw Exception('Failed to fetch category: $e');
    }
  }

  // Add a new category
  Future<String> addCategory(CategoryModel category) async {
    try {
      developer.log('Adding new category');
      
      final data = category.toFirestore();
      // Add created timestamp for new categories
      data['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(data);
      
      developer.log('Category added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding category', error: e);
      throw Exception('Failed to add category: $e');
    }
  }

  // Update a category
  Future<void> updateCategory(String categoryId, CategoryModel category) async {
    try {
      developer.log('Updating category with ID: $categoryId');
      
      await _firestore.collection(_collection)
          .doc(categoryId)
          .update(category.toFirestore());
      
      developer.log('Category updated successfully');
    } catch (e) {
      developer.log('Error updating category', error: e);
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      developer.log('Deleting category with ID: $categoryId');
      
      await _firestore.collection(_collection).doc(categoryId).delete();
      
      developer.log('Category deleted successfully');
    } catch (e) {
      developer.log('Error deleting category', error: e);
      throw Exception('Failed to delete category: $e');
    }
  }

  // Toggle category active status
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      developer.log('Toggling category status to: $isActive, ID: $categoryId');
      
      await _firestore.collection(_collection)
          .doc(categoryId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      developer.log('Category status updated successfully');
    } catch (e) {
      developer.log('Error updating category status', error: e);
      throw Exception('Failed to update category status: $e');
    }
  }

  // Reorder categories
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      developer.log('Reordering categories');
      
      final batch = _firestore.batch();
      
      for (int i = 0; i < categoryIds.length; i++) {
        final categoryRef = _firestore.collection(_collection).doc(categoryIds[i]);
        batch.update(categoryRef, {
          'sortOrder': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      
      developer.log('Categories reordered successfully');
    } catch (e) {
      developer.log('Error reordering categories', error: e);
      throw Exception('Failed to reorder categories: $e');
    }
  }
} 