import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int discountPercentage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.discountPercentage,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Debug output for banner data
    developer.log('Banner data for ${doc.id}: ${data.toString()}');
    
    // Extract discount percentage, ensuring it's an integer
    int discountPct = 0;
    if (data['discountPercentage'] != null) {
      if (data['discountPercentage'] is int) {
        discountPct = data['discountPercentage'];
      } else if (data['discountPercentage'] is double) {
        discountPct = data['discountPercentage'].toInt();
      } else {
        try {
          discountPct = int.parse(data['discountPercentage'].toString());
        } catch (e) {
          developer.log('Error parsing discountPercentage: ${data['discountPercentage']}', error: e);
        }
      }
    }
    
    // Check if isActive is present and a boolean
    bool isActive = true;
    if (data.containsKey('isActive')) {
      if (data['isActive'] is bool) {
        isActive = data['isActive'];
      } else {
        // Try to parse as string "true" or "false"
        try {
          final activeStr = data['isActive'].toString().toLowerCase();
          isActive = activeStr == 'true' || activeStr == '1';
        } catch (e) {
          developer.log('Error parsing isActive field: ${data['isActive']}', error: e);
        }
      }
    }
    
    return BannerModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      subtitle: data['subtitle']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      discountPercentage: discountPct,
      isActive: isActive,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    int? discountPercentage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 