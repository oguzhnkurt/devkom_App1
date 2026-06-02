/// Circuit Analysis Result using Claude's multimodal capabilities
class CircuitAnalysisResult {
  final String id;
  final String userId;
  final String imagePath; // Path to circuit diagram image
  final String analysisResult;
  final List<CircuitComponent> detectedComponents;
  final List<String> suggestions;
  final List<String> potentialIssues;
  final Map<String, dynamic> calculations; // voltage, current, resistance calculations
  final DateTime analyzedAt;
  final bool isPro; // Pro users get deeper analysis

  CircuitAnalysisResult({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.analysisResult,
    required this.detectedComponents,
    required this.suggestions,
    required this.potentialIssues,
    required this.calculations,
    required this.analyzedAt,
    required this.isPro,
  });

  // // REMOVED: Firebase-specific method
  // // factory CircuitAnalysisResult.fromFirestore(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imagePath': imagePath,
      'analysisResult': analysisResult,
      'detectedComponents': detectedComponents.map((e) => e.toMap()).toList(),
      'suggestions': suggestions,
      'potentialIssues': potentialIssues,
      'calculations': calculations,
      'analyzedAt': analyzedAt.toIso8601String(),
      'isPro': isPro,
    };
  }
}

/// Detected circuit component
class CircuitComponent {
  final String type; // resistor, capacitor, LED, etc.
  final String value;
  final String position;

  CircuitComponent({
    required this.type,
    required this.value,
    required this.position,
  });

  factory CircuitComponent.fromMap(Map<String, dynamic> map) {
    return CircuitComponent(
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      position: map['position'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'position': position,
    };
  }
}

/// Arduino/Raspberry Pi Code Helper
class HardwareCodeHelper {
  final String boardType; // 'arduino', 'raspberry_pi', 'esp32', etc.
  final String projectDescription;
  final List<String> requiredComponents;
  final String generatedCode;
  final List<String> setupInstructions;
  final Map<String, String> pinConnections; // component -> pin mapping
  final DateTime createdAt;

  HardwareCodeHelper({
    required this.boardType,
    required this.projectDescription,
    required this.requiredComponents,
    required this.generatedCode,
    required this.setupInstructions,
    required this.pinConnections,
    required this.createdAt,
  });

  factory HardwareCodeHelper.fromMap(Map<String, dynamic> map) {
    return HardwareCodeHelper(
      boardType: map['boardType'] ?? '',
      projectDescription: map['projectDescription'] ?? '',
      requiredComponents: List<String>.from(map['requiredComponents'] ?? []),
      generatedCode: map['generatedCode'] ?? '',
      setupInstructions: List<String>.from(map['setupInstructions'] ?? []),
      pinConnections: Map<String, String>.from(map['pinConnections'] ?? {}),
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'boardType': boardType,
      'projectDescription': projectDescription,
      'requiredComponents': requiredComponents,
      'generatedCode': generatedCode,
      'setupInstructions': setupInstructions,
      'pinConnections': pinConnections,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 3D Model Debugging Assistant (Pro Feature)
class Model3DDebugResult {
  final String userId;
  final String modelImagePath;
  final List<String> identifiedIssues;
  final List<String> recommendations;
  final Map<String, dynamic> printSettings; // recommended print settings
  final bool hasOverhangs;
  final bool needsSupports;
  final double estimatedPrintTime; // in minutes
  final DateTime analyzedAt;

  Model3DDebugResult({
    required this.userId,
    required this.modelImagePath,
    required this.identifiedIssues,
    required this.recommendations,
    required this.printSettings,
    required this.hasOverhangs,
    required this.needsSupports,
    required this.estimatedPrintTime,
    required this.analyzedAt,
  });

  factory Model3DDebugResult.fromMap(Map<String, dynamic> map) {
    return Model3DDebugResult(
      userId: map['userId'] ?? '',
      modelImagePath: map['modelImagePath'] ?? '',
      identifiedIssues: List<String>.from(map['identifiedIssues'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      printSettings: Map<String, dynamic>.from(map['printSettings'] ?? {}),
      hasOverhangs: map['hasOverhangs'] ?? false,
      needsSupports: map['needsSupports'] ?? false,
      estimatedPrintTime: (map['estimatedPrintTime'] ?? 0).toDouble(),
      analyzedAt: map['analyzedAt'] is String ? DateTime.parse(map['analyzedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'modelImagePath': modelImagePath,
      'identifiedIssues': identifiedIssues,
      'recommendations': recommendations,
      'printSettings': printSettings,
      'hasOverhangs': hasOverhangs,
      'needsSupports': needsSupports,
      'estimatedPrintTime': estimatedPrintTime,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}
