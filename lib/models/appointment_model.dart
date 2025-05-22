import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentTypeModel {
  final String id;
  final String name;
  final String description;
  final Color color;
  final bool isEmergency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.isEmergency = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentTypeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      color: Color(data['colorValue'] ?? 0xFF000000),
      isEmergency: data['isEmergency'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'colorValue': color.value,
      'isEmergency': isEmergency,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppointmentTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    bool? isEmergency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      isEmergency: isEmergency ?? this.isEmergency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 