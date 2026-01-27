import 'package:flutter/foundation.dart';

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final String _cloudName = 'dsoz2xlwg'; 
  final String _uploadPreset = 'ragfree_images'; 

  late final CloudinaryPublic _cloudinary;

  void init() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  Future<String?> uploadFile({
    required File file,
    required String folder,
    String? resourceType, // 'image', 'video', 'raw'
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: resourceType != null 
              ? CloudinaryResourceType.values.firstWhere(
                  (e) => e.toString().split('.').last == resourceType,
                  orElse: () => CloudinaryResourceType.Auto,
                )
              : CloudinaryResourceType.Auto,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File file) async {
    return uploadFile(
      file: file,
      folder: 'images',
      resourceType: 'image',
    );
  }

  Future<String?> uploadVideo(File file) async {
    return uploadFile(
      file: file,
      folder: 'videos',
      resourceType: 'video',
    );
  }

  Future<String?> uploadAudio(File file) async {
    return uploadFile(
      file: file,
      folder: 'audio',
      resourceType: 'raw',
    );
  }
}
