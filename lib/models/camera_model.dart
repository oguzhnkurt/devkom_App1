enum CameraQuality {
  low,
  medium,
  high,
}

enum CameraConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class CameraModel {
  final String id;
  final String name;
  final String rtspUrl;
  final String? httpUrl;
  final String? webRtcUrl;
  final String location;
  final bool isActive;
  final CameraQuality quality;
  final String? authToken;

  CameraModel({
    required this.id,
    required this.name,
    required this.rtspUrl,
    this.httpUrl,
    this.webRtcUrl,
    required this.location,
    this.isActive = true,
    this.quality = CameraQuality.medium,
    this.authToken,
  });

  // Get stream URL with token
  String getAuthenticatedUrl(String? userToken) {
    if (userToken == null) return rtspUrl;

    // Add token as URL parameter for authentication
    final uri = Uri.parse(rtspUrl);
    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'token': userToken,
      },
    );
    return newUri.toString();
  }

  // Get quality display name
  String get qualityDisplayName {
    switch (quality) {
      case CameraQuality.low:
        return 'Düşük (360p)';
      case CameraQuality.medium:
        return 'Orta (720p)';
      case CameraQuality.high:
        return 'Yüksek (1080p)';
    }
  }

  // Get resolution based on quality
  String get resolution {
    switch (quality) {
      case CameraQuality.low:
        return '640x360';
      case CameraQuality.medium:
        return '1280x720';
      case CameraQuality.high:
        return '1920x1080';
    }
  }

  // Copy with method
  CameraModel copyWith({
    String? id,
    String? name,
    String? rtspUrl,
    String? httpUrl,
    String? webRtcUrl,
    String? location,
    bool? isActive,
    CameraQuality? quality,
    String? authToken,
  }) {
    return CameraModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rtspUrl: rtspUrl ?? this.rtspUrl,
      httpUrl: httpUrl ?? this.httpUrl,
      webRtcUrl: webRtcUrl ?? this.webRtcUrl,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      quality: quality ?? this.quality,
      authToken: authToken ?? this.authToken,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rtspUrl': rtspUrl,
      'httpUrl': httpUrl,
      'webRtcUrl': webRtcUrl,
      'location': location,
      'isActive': isActive,
      'quality': quality.name,
      'authToken': authToken,
    };
  }

  // From JSON
  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rtspUrl: json['rtspUrl'] ?? '',
      httpUrl: json['httpUrl'],
      webRtcUrl: json['webRtcUrl'],
      location: json['location'] ?? '',
      isActive: json['isActive'] ?? true,
      quality: CameraQuality.values.firstWhere(
        (q) => q.name == json['quality'],
        orElse: () => CameraQuality.medium,
      ),
      authToken: json['authToken'],
    );
  }
}
