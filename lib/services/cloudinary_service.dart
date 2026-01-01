import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // REPLACE THESE WITH YOUR CLOUDINARY CREDENTIALS
  final String _cloudName = 'dsoz2xlwg'; // Dummy cloud name
  final String _uploadPreset = 'ragfree_images'; // Dummy upload preset

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
      print('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
