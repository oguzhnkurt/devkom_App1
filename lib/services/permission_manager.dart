import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

enum AppPermission {
  notification,
  camera,
  photos,
  storage,
}

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  // Permission state tracking
  final Map<AppPermission, PermissionStatus> _permissionStates = {};

  /// Check if a permission is granted
  Future<bool> isPermissionGranted(AppPermission permission) async {
    PermissionStatus status;

    switch (permission) {
      case AppPermission.notification:
        status = await Permission.notification.status;
        break;
      case AppPermission.camera:
        status = await Permission.camera.status;
        break;
      case AppPermission.photos:
        status = await Permission.photos.status;
        break;
      case AppPermission.storage:
        status = await Permission.storage.status;
        break;
    }

    _permissionStates[permission] = status;
    return status.isGranted;
  }

  /// Request a single permission
  Future<bool> requestPermission(AppPermission permission) async {
    PermissionStatus status;

    switch (permission) {
      case AppPermission.notification:
        status = await Permission.notification.request();
        break;
      case AppPermission.camera:
        status = await Permission.camera.request();
        break;
      case AppPermission.photos:
        status = await Permission.photos.request();
        break;
      case AppPermission.storage:
        status = await Permission.storage.request();
        break;
    }

    _permissionStates[permission] = status;
    return status.isGranted;
  }

  /// Request multiple permissions
  Future<Map<AppPermission, bool>> requestMultiplePermissions(
    List<AppPermission> permissions,
  ) async {
    Map<AppPermission, bool> results = {};

    for (var permission in permissions) {
      results[permission] = await requestPermission(permission);
    }

    return results;
  }

  /// Check if permission was previously denied
  Future<bool> isPermanentlyDenied(AppPermission permission) async {
    PermissionStatus status;

    switch (permission) {
      case AppPermission.notification:
        status = await Permission.notification.status;
        break;
      case AppPermission.camera:
        status = await Permission.camera.status;
        break;
      case AppPermission.photos:
        status = await Permission.photos.status;
        break;
      case AppPermission.storage:
        status = await Permission.storage.status;
        break;
    }

    return status.isPermanentlyDenied;
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get permission name for display
  String getPermissionName(AppPermission permission) {
    switch (permission) {
      case AppPermission.notification:
        return 'Bildirimler';
      case AppPermission.camera:
        return 'Kamera';
      case AppPermission.photos:
        return 'Fotoğraflar';
      case AppPermission.storage:
        return 'Depolama';
    }
  }

  /// Get permission description
  String getPermissionDescription(AppPermission permission) {
    switch (permission) {
      case AppPermission.notification:
        return 'Ödevler, duyurular ve önemli güncellemeler için bildirim göndermemize izin verin.';
      case AppPermission.camera:
        return 'Canlı kamera yayınlarını izleyebilmek için kamera erişimi gereklidir.';
      case AppPermission.photos:
        return 'Ödev ve proje gönderimleri için fotoğraf yüklemenize olanak tanır.';
      case AppPermission.storage:
        return 'Dosya indirme ve yükleme işlemleri için depolama erişimi gereklidir.';
    }
  }

  /// Get permission icon
  IconData getPermissionIcon(AppPermission permission) {
    switch (permission) {
      case AppPermission.notification:
        return Icons.notifications_active;
      case AppPermission.camera:
        return Icons.camera_alt;
      case AppPermission.photos:
        return Icons.photo_library;
      case AppPermission.storage:
        return Icons.storage;
    }
  }

  /// Get current status of a permission
  PermissionStatus? getPermissionStatus(AppPermission permission) {
    return _permissionStates[permission];
  }

  /// Clear all cached permission states
  void clearCache() {
    _permissionStates.clear();
  }
}
