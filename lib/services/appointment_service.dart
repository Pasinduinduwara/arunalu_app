import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import 'dart:developer' as developer;

class AppointmentTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointmentTypes';

  // Get all appointment types
  Future<List<AppointmentTypeModel>> getAllAppointmentTypes({bool activeOnly = false}) async {
    try {
      developer.log('Fetching all appointment types, activeOnly: $activeOnly');
      
      Query query = _firestore.collection(_collection);
      
      // Only get active appointment types if requested
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      // Sort by name
      query = query.orderBy('name');
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => AppointmentTypeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching appointment types', error: e);
      throw Exception('Failed to fetch appointment types: $e');
    }
  }

  // Get appointment type by ID
  Future<AppointmentTypeModel?> getAppointmentType(String appointmentTypeId) async {
    try {
      developer.log('Fetching appointment type with ID: $appointmentTypeId');
      
      final docSnapshot = await _firestore.collection(_collection).doc(appointmentTypeId).get();
      
      if (!docSnapshot.exists) {
        developer.log('Appointment type not found: $appointmentTypeId');
        return null;
      }
      
      return AppointmentTypeModel.fromFirestore(docSnapshot);
    } catch (e) {
      developer.log('Error fetching appointment type', error: e);
      throw Exception('Failed to fetch appointment type: $e');
    }
  }

  // Add a new appointment type
  Future<String> addAppointmentType(AppointmentTypeModel appointmentType) async {
    try {
      developer.log('Adding new appointment type');
      
      final data = appointmentType.toFirestore();
      // Add created timestamp for new appointment types
      data['createdAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(data);
      
      developer.log('Appointment type added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding appointment type', error: e);
      throw Exception('Failed to add appointment type: $e');
    }
  }

  // Update an appointment type
  Future<void> updateAppointmentType(String appointmentTypeId, AppointmentTypeModel appointmentType) async {
    try {
      developer.log('Updating appointment type with ID: $appointmentTypeId');
      
      await _firestore.collection(_collection)
          .doc(appointmentTypeId)
          .update(appointmentType.toFirestore());
      
      developer.log('Appointment type updated successfully');
    } catch (e) {
      developer.log('Error updating appointment type', error: e);
      throw Exception('Failed to update appointment type: $e');
    }
  }

  // Delete an appointment type
  Future<void> deleteAppointmentType(String appointmentTypeId) async {
    try {
      developer.log('Deleting appointment type with ID: $appointmentTypeId');
      
      await _firestore.collection(_collection).doc(appointmentTypeId).delete();
      
      developer.log('Appointment type deleted successfully');
    } catch (e) {
      developer.log('Error deleting appointment type', error: e);
      throw Exception('Failed to delete appointment type: $e');
    }
  }

  // Toggle appointment type active status
  Future<void> toggleAppointmentTypeStatus(String appointmentTypeId, bool isActive) async {
    try {
      developer.log('Toggling appointment type status to: $isActive, ID: $appointmentTypeId');
      
      await _firestore.collection(_collection)
          .doc(appointmentTypeId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      developer.log('Appointment type status updated successfully');
    } catch (e) {
      developer.log('Error updating appointment type status', error: e);
      throw Exception('Failed to update appointment type status: $e');
    }
  }

  // Get emergency appointment types
  Future<List<AppointmentTypeModel>> getEmergencyAppointmentTypes() async {
    try {
      developer.log('Fetching emergency appointment types');
      
      final querySnapshot = await _firestore.collection(_collection)
          .where('isEmergency', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AppointmentTypeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching emergency appointment types', error: e);
      throw Exception('Failed to fetch emergency appointment types: $e');
    }
  }

  // Get regular appointment types
  Future<List<AppointmentTypeModel>> getRegularAppointmentTypes() async {
    try {
      developer.log('Fetching regular appointment types');
      
      final querySnapshot = await _firestore.collection(_collection)
          .where('isEmergency', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => AppointmentTypeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching regular appointment types', error: e);
      throw Exception('Failed to fetch regular appointment types: $e');
    }
  }
} 