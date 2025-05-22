import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import 'dart:developer' as developer;

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Get all services
  Future<List<ServiceModel>> getAllServices({bool activeOnly = false}) async {
    try {
      developer.log('ServiceService: Fetching all services, activeOnly: $activeOnly');
      
      Query query = _firestore.collection(_collection);
      
      // Only get active services if requested
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      // Sort by sort order
      query = query.orderBy('sortOrder');
      
      final querySnapshot = await query.get();
      
      final services = querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
          
      developer.log('ServiceService: Successfully fetched ${services.length} services');
      return services;
    } catch (e, stackTrace) {
      developer.log('ServiceService: Error fetching services', error: e);
      developer.log('ServiceService: Stack trace: $stackTrace');
      
      // Return empty list instead of throwing to avoid crashing the app
      return [];
    }
  }

  // Get service by ID
  Future<ServiceModel?> getService(String serviceId) async {
    try {
      developer.log('Fetching service with ID: $serviceId');
      
      final docSnapshot = await _firestore.collection(_collection).doc(serviceId).get();
      
      if (!docSnapshot.exists) {
        developer.log('Service not found: $serviceId');
        return null;
      }
      
      return ServiceModel.fromFirestore(docSnapshot);
    } catch (e) {
      developer.log('Error fetching service', error: e);
      throw Exception('Failed to fetch service: $e');
    }
  }

  // Add a new service
  Future<String> addService(ServiceModel service) async {
    try {
      developer.log('Adding new service');
      
      final data = service.toFirestore();
      // Add created timestamp for new services
      data['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(data);
      
      developer.log('Service added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding service', error: e);
      throw Exception('Failed to add service: $e');
    }
  }

  // Update a service
  Future<void> updateService(String serviceId, ServiceModel service) async {
    try {
      developer.log('Updating service with ID: $serviceId');
      
      await _firestore.collection(_collection)
          .doc(serviceId)
          .update(service.toFirestore());
      
      developer.log('Service updated successfully');
    } catch (e) {
      developer.log('Error updating service', error: e);
      throw Exception('Failed to update service: $e');
    }
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      developer.log('Deleting service with ID: $serviceId');
      
      await _firestore.collection(_collection).doc(serviceId).delete();
      
      developer.log('Service deleted successfully');
    } catch (e) {
      developer.log('Error deleting service', error: e);
      throw Exception('Failed to delete service: $e');
    }
  }

  // Toggle service active status
  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      developer.log('Toggling service status to: $isActive, ID: $serviceId');
      
      await _firestore.collection(_collection)
          .doc(serviceId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      developer.log('Service status updated successfully');
    } catch (e) {
      developer.log('Error updating service status', error: e);
      throw Exception('Failed to update service status: $e');
    }
  }

  // Reorder services
  Future<void> reorderServices(List<String> serviceIds) async {
    try {
      developer.log('Reordering services');
      
      final batch = _firestore.batch();
      
      for (int i = 0; i < serviceIds.length; i++) {
        final serviceRef = _firestore.collection(_collection).doc(serviceIds[i]);
        batch.update(serviceRef, {
          'sortOrder': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      
      developer.log('Services reordered successfully');
    } catch (e) {
      developer.log('Error reordering services', error: e);
      throw Exception('Failed to reorder services: $e');
    }
  }

  // Get icon data from string name
  IconData getIconDataFromName(String iconName) {
    // This is a helper method to convert icon name strings to IconData objects
    // Map of available icon names to IconData objects
    final Map<String, IconData> iconMap = {
      'build': Icons.build,
      'electrical_services': Icons.electrical_services,
      'miscellaneous_services': Icons.miscellaneous_services,
      'home_repair_service': Icons.home_repair_service,
      'construction': Icons.construction,
      'plumbing': Icons.plumbing,
      'settings': Icons.settings,
      'work': Icons.work,
      'engineering': Icons.engineering,
      'handyman': Icons.handyman,
    };
    
    return iconMap[iconName] ?? Icons.miscellaneous_services; // Default icon if not found
  }
} 