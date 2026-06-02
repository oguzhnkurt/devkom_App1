import 'package:flutter/foundation.dart';

/// File Upload Service Stub
class FileUploadService {
  Future<String?> uploadFile(dynamic file, String path) async {
    debugPrint('⚠️ FileUploadService: Supabase Storage migration pending');
    return null;
  }

  Future<void> deleteFile(String url) async {
    debugPrint('⚠️ FileUploadService: Supabase Storage migration pending');
  }

  Future<List<dynamic>?> pickFiles() async {
    debugPrint('⚠️  pickFiles - stub');
    return null;
  }

  Future<List<String>> uploadHomeworkFiles(List<dynamic> files, String homeworkId, String studentId) async {
    debugPrint('⚠️  uploadHomeworkFiles - stub');
    return [];
  }
}
