import 'package:flutter/foundation.dart';

/// Parent Child Service Stub
class ParentChildService {
  Future<List<dynamic>> getChildren(String parentId) async {
    debugPrint('⚠️ ParentChildService: Supabase migration pending');
    return [];
  }

  Future<void> addChild(String parentId, String childId) async {
    debugPrint('⚠️ ParentChildService: Supabase migration pending');
  }
}

class ChildInfo {
  final String id;
  final String name;
  final String? photoUrl;

  ChildInfo({
    required this.id,
    required this.name,
    this.photoUrl,
  });
}
