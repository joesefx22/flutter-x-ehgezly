import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StorageService {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();
  
  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final urls = <String>[];
      
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final bytes = await image.readAsBytes();
        
        final formData = FormData();
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(
            bytes,
            filename: '${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          ),
        ));
        formData.fields.add(MapEntry('folder', folder));
        
        final response = await _apiClient.postMultipart(
          '/storage/upload',
          data: formData,
        );
        
        if (response.success) {
          urls.add(response.data['url']);
        }
        
        onProgress?.call(i + 1, images.length);
      }
      
      return urls;
    } catch (e) {
      debugPrint('StorageService.uploadImages error: $e');
      rethrow;
    }
  }
  
  Future<String> uploadSingleImage({
    required XFile image,
    required String folder,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      
      final formData = FormData();
      formData.files.add(MapEntry(
        'image',
        MultipartFile.fromBytes(
          bytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));
      formData.fields.add(MapEntry('folder', folder));
      
      final response = await _apiClient.postMultipart(
        '/storage/upload',
        data: formData,
      );
      
      if (response.success) {
        return response.data['url'];
      }
      
      throw Exception('Failed to upload image');
    } catch (e) {
      debugPrint('StorageService.uploadSingleImage error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteImage(String url) async {
    try {
      await _apiClient.delete(
        '/storage/delete',
        data: {'url': url},
      );
    } catch (e) {
      debugPrint('StorageService.deleteImage error: $e');
      rethrow;
    }
  }
  
  Future<XFile?> pickImage({
    required ImageSource source,
    double maxWidth = 1200,
    double maxHeight = 1200,
    int quality = 80,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      return image;
    } catch (e) {
      debugPrint('StorageService.pickImage error: $e');
      return null;
    }
  }
  
  Future<List<XFile>> pickMultipleImages({
    double maxWidth = 1200,
    double maxHeight = 1200,
    int quality = 80,
  }) async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      return images;
    } catch (e) {
      debugPrint('StorageService.pickMultipleImages error: $e');
      return [];
    }
  }
  
  Future<File?> compressImage(File imageFile) async {
    // Note: You might want to use flutter_image_compress package
    // For now, return the original file
    return imageFile;
  }
  
  String getImageUrl(String path, {int? width, int? height}) {
    // This is a helper method to generate CDN URLs with optional resizing
    String url = 'https://your-cdn.com/$path';
    
    if (width != null || height != null) {
      url += '?';
      if (width != null) url += 'width=$width&';
      if (height != null) url += 'height=$height&';
      url = url.substring(0, url.length - 1); // Remove trailing &
    }
    
    return url;
  }
}
