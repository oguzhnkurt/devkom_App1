import 'package:flutter/foundation.dart';

/// Storage Service Stub
class StorageService {
  Future<String?> uploadFile(String path, dynamic file) async {
    debugPrint('⚠️ StorageService: Supabase Storage migration pending');
    return null;
  }

  Future<void> deleteFile(String path) async {
    debugPrint('⚠️ StorageService: Supabase Storage migration pending');
  }

  Future<String> uploadImage({
    required String filePath,
    required String folder,
  }) async {
    debugPrint('⚠️ StorageService.uploadImage: Supabase Storage migration pending');
    return '';
  }

  Future<String> getFileSizeString(int bytes) async {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<String?> uploadVoice(String userId, dynamic file) async {
    debugPrint('⚠️ StorageService.uploadVoice: Supabase Storage migration pending');
    return null;
  }
}
