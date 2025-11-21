import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dsoz2xlwg';
  static const String uploadPreset = 'ragfree_images';
  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/upload';

  // Upload image to Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        throw Exception('Upload failed: ${jsonData['error']?['message']}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Upload video to Cloudinary
  Future<String?> uploadVideo(File videoFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['resource_type'] = 'video';
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        throw Exception('Upload failed: ${jsonData['error']?['message']}');
      }
    } catch (e) {
      throw Exception('Failed to upload video: ${e.toString()}');
    }
  }

  // Upload audio to Cloudinary
  Future<String?> uploadAudio(File audioFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['resource_type'] = 'raw';
      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        throw Exception('Upload failed: ${jsonData['error']?['message']}');
      }
    } catch (e) {
      throw Exception('Failed to upload audio: ${e.toString()}');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final List<String> urls = [];
    for (var file in imageFiles) {
      final url = await uploadImage(file);
      if (url != null) urls.add(url);
    }
    return urls;
  }

  // Upload media file (auto-detect type)
  Future<String?> uploadMedia(File file, {String? resourceType}) async {
    final extension = file.path.split('.').last.toLowerCase();
    
    if (resourceType != null) {
      switch (resourceType) {
        case 'video':
          return await uploadVideo(file);
        case 'audio':
          return await uploadAudio(file);
        default:
          return await uploadImage(file);
      }
    }

    // Auto-detect based on extension
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return await uploadVideo(file);
    } else if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
      return await uploadAudio(file);
    } else {
      return await uploadImage(file);
    }
  }
}

