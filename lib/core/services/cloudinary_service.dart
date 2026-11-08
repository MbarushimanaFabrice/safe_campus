import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'campusfix_preset';
    
    _cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );
  }
  
  /// Upload an image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage({
    required File image,
    required String folder,
    String? publicId,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: folder,
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
  
  /// Upload an image with transformation (resize, optimize)
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImageWithTransformation({
    required File image,
    required String folder,
    String? publicId,
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: folder,
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      // Build transformation URL
      String url = response.secureUrl;
      
      if (maxWidth != null || maxHeight != null) {
        // Extract public ID from URL
        final parts = url.split('/upload/');
        if (parts.length == 2) {
          final transformations = <String>[];
          
          if (maxWidth != null && maxHeight != null) {
            transformations.add('c_limit,w_$maxWidth,h_$maxHeight');
          } else if (maxWidth != null) {
            transformations.add('w_$maxWidth');
          } else if (maxHeight != null) {
            transformations.add('h_$maxHeight');
          }
          
          transformations.add('q_$quality');
          transformations.add('f_auto');
          
          url = '${parts[0]}/upload/${transformations.join(',')}/${parts[1]}';
        }
      }
      
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
  
  /// Delete an image from Cloudinary
  /// Note: cloudinary_public package doesn't support delete.
  /// For production, implement via backend API or accept that images remain in Cloudinary
  /// (Firestore cascade delete will remove references)
  Future<void> deleteImage(String imageUrl) async {
    // Note: The cloudinary_public package doesn't support delete operations
    // Options:
    // 1. Implement via backend API with API secret
    // 2. Accept that images remain in storage (disk space is cheap)
    // 3. Set up lifecycle rules in Cloudinary to auto-delete old images
    // 
    // For this project, we'll log and continue
    // The Firestore reference is deleted, so the image becomes inaccessible
    try {
      // TODO: Implement delete via backend API if needed
      // For now, just remove the Firestore reference
      debugPrint('Image delete not implemented: $imageUrl');
      debugPrint('Consider implementing via backend API or Cloudinary lifecycle rules');
    } catch (e) {
      debugPrint('Image cleanup note: ${e.toString()}');
    }
  }
  
  /// Get optimized image URL with transformations
  String getOptimizedUrl({
    required String originalUrl,
    int? width,
    int? height,
    int quality = 85,
    String format = 'auto',
  }) {
    try {
      final parts = originalUrl.split('/upload/');
      if (parts.length != 2) return originalUrl;
      
      final transformations = <String>[];
      
      if (width != null && height != null) {
        transformations.add('c_limit,w_$width,h_$height');
      } else if (width != null) {
        transformations.add('w_$width');
      } else if (height != null) {
        transformations.add('h_$height');
      }
      
      transformations.add('q_$quality');
      transformations.add('f_$format');
      
      return '${parts[0]}/upload/${transformations.join(',')}/${parts[1]}';
    } catch (e) {
      return originalUrl;
    }
  }
}
