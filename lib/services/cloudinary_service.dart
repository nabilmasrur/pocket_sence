import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });
}

class CloudinaryService {
  static const String _cloudName = 'drzgoh1li';
  static const String _uploadPreset = 'pocket_sense_unsigned';

  bool get isConfigured => _cloudName.isNotEmpty && _uploadPreset.isNotEmpty;

  Future<CloudinaryUploadResult?> uploadImage(
    XFile file, {
    required String folder,
  }) async {
    if (!isConfigured) {
      debugPrint('Cloudinary is missing CLOUDINARY_CLOUD_NAME or preset.');
      return null;
    }

    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Cloudinary upload failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CloudinaryUploadResult(
        secureUrl: data['secure_url']?.toString() ?? '',
        publicId: data['public_id']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
