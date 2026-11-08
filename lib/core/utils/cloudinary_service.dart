import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
    
    if (cloudName == null || uploadPreset == null) {
      throw Exception('Cloudinary credentials not found in .env');
    }
    
    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large (max 1920px on longest side)
    img.Image resized = image;
    if (image.width > 1920 || image.height > 1920) {
      if (image.width > image.height) {
        resized = img.copyResize(image, width: 1920);
      } else {
        resized = img.copyResize(image, height: 1920);
      }
    }

    // Compress to JPEG with 85% quality
    final compressed = img.encodeJpg(resized, quality: 85);
    
    return Uint8List.fromList(compressed);
  }

  Future<CloudinaryUploadResult> uploadImage({
    required Uint8List imageBytes,
    required String folder,
    bool compress = true,
  }) async {
    try {
      final bytesToUpload = compress
          ? await compressImage(imageBytes)
          : imageBytes;
      final uploadId = const Uuid().v4();

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytesToUpload,
          identifier: '$uploadId.jpg',
          publicId: 'campusfix_$uploadId',
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return CloudinaryUploadResult(
        url: response.secureUrl,
        publicId: response.publicId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CloudinaryUploadResult>> uploadMultipleImages({
    required List<Uint8List> images,
    required String folder,
    bool compress = true,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <CloudinaryUploadResult>[];
    
    for (int i = 0; i < images.length; i++) {
      onProgress?.call(i + 1, images.length);
      
      final result = await uploadImage(
        imageBytes: images[i],
        folder: folder,
        compress: compress,
      );
      
      results.add(result);
    }
    
    return results;
  }

  String getThumbnailUrl(String originalUrl) {
    return _withTransformation(
      originalUrl,
      AppConstants.cloudinaryThumbnailTransform,
    );
  }

  String getDisplayUrl(String originalUrl, {int? width}) {
    final transformations = [
      if (width != null) 'w_$width,c_limit',
      'q_auto',
      'f_jpg',
    ].join(',');
    return _withTransformation(originalUrl, transformations);
  }

  String _withTransformation(String originalUrl, String transformation) {
    if (!originalUrl.contains('/upload/')) return originalUrl;
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/$transformation/',
    );
  }

  // Note: Deletion requires a signed request, which cannot be done from the client
  // This would need a backend function
  // For this app, we'll just remove the reference from Firestore
}

class CloudinaryUploadResult {
  final String url;
  final String publicId;

  CloudinaryUploadResult({
    required this.url,
    required this.publicId,
  });
}
