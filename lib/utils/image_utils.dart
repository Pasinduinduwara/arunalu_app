import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera and convert to base64
  static Future<String?> pickImageToBase64({
    required BuildContext context,
    required ImageSource source,
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 85,
  }) async {
    try {
      // Pick an image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
      
      if (image == null) {
        developer.log('No image selected');
        return null;
      }
      
      // Read image as bytes
      final bytes = await image.readAsBytes();
      
      // Convert to base64
      return base64Encode(bytes);
    } catch (e) {
      developer.log('Error picking image', error: e);
      // Show error dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process image: $e')),
        );
      }
      return null;
    }
  }
  
  /// Convert a base64 string back to an image widget
  static Widget base64ToImage(String? base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    if (base64String == null || base64String.isEmpty) {
      return placeholder ?? const Icon(Icons.image_not_supported, size: 50);
    }
    
    try {
      // Decode base64 to bytes
      final Uint8List bytes = base64Decode(base64String);
      
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          developer.log('Error displaying image', error: error);
          return placeholder ?? const Icon(Icons.broken_image, size: 50);
        },
      );
    } catch (e) {
      developer.log('Error converting base64 to image', error: e);
      return placeholder ?? const Icon(Icons.error_outline, size: 50);
    }
  }
  
  /// Show image picker dialog
  static Future<String?> showImagePickerDialog(BuildContext context) async {
    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await pickImageToBase64(
                      context: context,
                      source: ImageSource.gallery,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await pickImageToBase64(
                      context: context,
                      source: ImageSource.camera,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
} 