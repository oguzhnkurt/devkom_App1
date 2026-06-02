/// Arduino Block Coding Model - mBlock Style
/// Defines block types and structures for visual programming

enum BlockType {
  // Control Blocks
  start,           // Program başlangıcı
  forever,         // Sürekli döngü
  repeat,          // N kez tekrar
  ifCondition,     // Eğer koşulu
  wait,            // Bekle

  // Pin Actions
  digitalWrite,    // Digital pin yaz
  analogWrite,     // Analog pin yaz (PWM)
  pinMode,         // Pin modu ayarla

  // Pin Reads
  digitalRead,     // Digital pin oku
  analogRead,      // Analog pin oku

  // LED Actions
  ledOn,           // LED aç
  ledOff,          // LED kapat
  ledBlink,        // LED yanıp sön

  // Servo Actions
  servoRotate,     // Servo açı ayarla

  // Buzzer Actions
  buzzerOn,        // Buzzer aç
  buzzerOff,       // Buzzer kapat
  buzzerTone,      // Buzzer ton çal

  // Sensor Reads
  readUltrasonic,  // Mesafe oku
  readTemperature, // Sıcaklık oku
  readLight,       // Işık seviyesi oku
  readPIR,         // Hareket algıla

  // Logic
  compare,         // Karşılaştırma (>, <, ==)
  and,             // Ve
  or,              // Veya
  not,             // Değil

  // Math
  add,             // Toplama
  subtract,        // Çıkarma
  multiply,        // Çarpma
  divide,          // Bölme

  // Variables
  setVariable,     // Değişken ata
  getVariable,     // Değişken oku

  // Display
  lcdPrint,        // LCD'ye yaz
  lcdClear,        // LCD temizle
}

enum BlockCategory {
  control,
  pins,
  leds,
  sensors,
  actuators,
  logic,
  math,
  variables,
  display,
}

class ArduinoBlock {
  final String id;
  final BlockType type;
  final BlockCategory category;
  final Map<String, dynamic> parameters;
  final List<ArduinoBlock> children;
  int order;

  ArduinoBlock({
    required this.id,
    required this.type,
    required this.category,
    this.parameters = const {},
    this.children = const [],
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'parameters': parameters,
      'children': children.map((c) => c.toMap()).toList(),
      'order': order,
    };
  }

  factory ArduinoBlock.fromMap(Map<String, dynamic> map) {
    return ArduinoBlock(
      id: map['id'] as String,
      type: BlockType.values.firstWhere((e) => e.name == map['type']),
      category: BlockCategory.values.firstWhere((e) => e.name == map['category']),
      parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
      children: (map['children'] as List?)
          ?.map((c) => ArduinoBlock.fromMap(c as Map<String, dynamic>))
          .toList() ?? [],
      order: map['order'] as int? ?? 0,
    );
  }

  /// Convert blocks to Arduino code
  String toArduinoCode({int indent = 0}) {
    final String spacing = '  ' * indent;
    String code = '';

    switch (type) {
      case BlockType.start:
        code += '${spacing}void setup() {\n';
        for (var child in children) {
          code += child.toArduinoCode(indent: indent + 1);
        }
        code += '${spacing}}\n\n${spacing}void loop() {\n';
        code += '${spacing}}\n';
        break;

      case BlockType.forever:
        code += '${spacing}void loop() {\n';
        for (var child in children) {
          code += child.toArduinoCode(indent: indent + 1);
        }
        code += '${spacing}}\n';
        break;

      case BlockType.repeat:
        final times = parameters['times'] ?? 10;
        code += '${spacing}for(int i = 0; i < $times; i++) {\n';
        for (var child in children) {
          code += child.toArduinoCode(indent: indent + 1);
        }
        code += '${spacing}}\n';
        break;

      case BlockType.ifCondition:
        final condition = parameters['condition'] ?? 'true';
        code += '${spacing}if($condition) {\n';
        for (var child in children) {
          code += child.toArduinoCode(indent: indent + 1);
        }
        code += '${spacing}}\n';
        break;

      case BlockType.wait:
        final ms = parameters['milliseconds'] ?? 1000;
        code += '${spacing}delay($ms);\n';
        break;

      case BlockType.digitalWrite:
        final pin = parameters['pin'] ?? 13;
        final value = parameters['value'] ?? 'HIGH';
        code += '${spacing}digitalWrite($pin, $value);\n';
        break;

      case BlockType.analogWrite:
        final pin = parameters['pin'] ?? 9;
        final value = parameters['value'] ?? 128;
        code += '${spacing}analogWrite($pin, $value);\n';
        break;

      case BlockType.pinMode:
        final pin = parameters['pin'] ?? 13;
        final mode = parameters['mode'] ?? 'OUTPUT';
        code += '${spacing}pinMode($pin, $mode);\n';
        break;

      case BlockType.digitalRead:
        final pin = parameters['pin'] ?? 2;
        code += '${spacing}digitalRead($pin)';
        break;

      case BlockType.analogRead:
        final pin = parameters['pin'] ?? 'A0';
        code += '${spacing}analogRead($pin)';
        break;

      case BlockType.ledOn:
        final pin = parameters['pin'] ?? 13;
        code += '${spacing}digitalWrite($pin, HIGH);\n';
        break;

      case BlockType.ledOff:
        final pin = parameters['pin'] ?? 13;
        code += '${spacing}digitalWrite($pin, LOW);\n';
        break;

      case BlockType.ledBlink:
        final pin = parameters['pin'] ?? 13;
        final delay = parameters['delay'] ?? 500;
        code += '${spacing}digitalWrite($pin, HIGH);\n';
        code += '${spacing}delay($delay);\n';
        code += '${spacing}digitalWrite($pin, LOW);\n';
        code += '${spacing}delay($delay);\n';
        break;

      case BlockType.servoRotate:
        final pin = parameters['pin'] ?? 9;
        final angle = parameters['angle'] ?? 90;
        code += '${spacing}myServo.write($angle);\n';
        break;

      case BlockType.buzzerOn:
        final pin = parameters['pin'] ?? 8;
        code += '${spacing}digitalWrite($pin, HIGH);\n';
        break;

      case BlockType.buzzerOff:
        final pin = parameters['pin'] ?? 8;
        code += '${spacing}digitalWrite($pin, LOW);\n';
        break;

      case BlockType.buzzerTone:
        final pin = parameters['pin'] ?? 8;
        final frequency = parameters['frequency'] ?? 1000;
        final duration = parameters['duration'] ?? 500;
        code += '${spacing}tone($pin, $frequency, $duration);\n';
        break;

      case BlockType.readUltrasonic:
        final trigPin = parameters['trigPin'] ?? 9;
        final echoPin = parameters['echoPin'] ?? 10;
        code += '${spacing}getDistance($trigPin, $echoPin)';
        break;

      case BlockType.readTemperature:
        final pin = parameters['pin'] ?? 2;
        code += '${spacing}dht.readTemperature()';
        break;

      case BlockType.readLight:
        final pin = parameters['pin'] ?? 'A0';
        code += '${spacing}analogRead($pin)';
        break;

      case BlockType.readPIR:
        final pin = parameters['pin'] ?? 2;
        code += '${spacing}digitalRead($pin)';
        break;

      case BlockType.lcdPrint:
        final text = parameters['text'] ?? 'Hello';
        code += '${spacing}lcd.print("$text");\n';
        break;

      case BlockType.lcdClear:
        code += '${spacing}lcd.clear();\n';
        break;

      default:
        code += '${spacing}// ${type.name}\n';
    }

    return code;
  }

  ArduinoBlock copyWith({
    String? id,
    BlockType? type,
    BlockCategory? category,
    Map<String, dynamic>? parameters,
    List<ArduinoBlock>? children,
    int? order,
  }) {
    return ArduinoBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      parameters: parameters ?? this.parameters,
      children: children ?? this.children,
      order: order ?? this.order,
    );
  }
}

/// Block metadata for display
class BlockMetadata {
  final BlockType type;
  final String label;
  final String icon;
  final BlockCategory category;
  final List<BlockParameter> parameters;
  final bool hasChildren;

  const BlockMetadata({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
    this.parameters = const [],
    this.hasChildren = false,
  });
}

class BlockParameter {
  final String name;
  final String label;
  final ParameterType type;
  final dynamic defaultValue;
  final List<dynamic>? options;

  const BlockParameter({
    required this.name,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
  });
}

enum ParameterType {
  number,
  text,
  dropdown,
  pin,
  boolean,
}

/// Predefined block templates
class BlockTemplates {
  static const List<BlockMetadata> allBlocks = [
    // Control
    BlockMetadata(
      type: BlockType.start,
      label: 'Başla',
      icon: '▶️',
      category: BlockCategory.control,
      hasChildren: true,
    ),
    BlockMetadata(
      type: BlockType.forever,
      label: 'Sürekli Tekrarla',
      icon: '🔄',
      category: BlockCategory.control,
      hasChildren: true,
    ),
    BlockMetadata(
      type: BlockType.repeat,
      label: 'Tekrarla',
      icon: '🔁',
      category: BlockCategory.control,
      parameters: [
        BlockParameter(
          name: 'times',
          label: 'Kaç Kez',
          type: ParameterType.number,
          defaultValue: 10,
        ),
      ],
      hasChildren: true,
    ),
    BlockMetadata(
      type: BlockType.wait,
      label: 'Bekle',
      icon: '⏱️',
      category: BlockCategory.control,
      parameters: [
        BlockParameter(
          name: 'milliseconds',
          label: 'ms',
          type: ParameterType.number,
          defaultValue: 1000,
        ),
      ],
    ),

    // LED
    BlockMetadata(
      type: BlockType.ledOn,
      label: 'LED Aç',
      icon: '💡',
      category: BlockCategory.leds,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 13,
        ),
      ],
    ),
    BlockMetadata(
      type: BlockType.ledOff,
      label: 'LED Kapat',
      icon: '⚫',
      category: BlockCategory.leds,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 13,
        ),
      ],
    ),
    BlockMetadata(
      type: BlockType.ledBlink,
      label: 'LED Yanıp Sön',
      icon: '✨',
      category: BlockCategory.leds,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 13,
        ),
        BlockParameter(
          name: 'delay',
          label: 'Gecikme (ms)',
          type: ParameterType.number,
          defaultValue: 500,
        ),
      ],
    ),

    // Buzzer
    BlockMetadata(
      type: BlockType.buzzerTone,
      label: 'Buzzer Ton Çal',
      icon: '🔊',
      category: BlockCategory.actuators,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 8,
        ),
        BlockParameter(
          name: 'frequency',
          label: 'Frekans (Hz)',
          type: ParameterType.number,
          defaultValue: 1000,
        ),
        BlockParameter(
          name: 'duration',
          label: 'Süre (ms)',
          type: ParameterType.number,
          defaultValue: 500,
        ),
      ],
    ),

    // Servo
    BlockMetadata(
      type: BlockType.servoRotate,
      label: 'Servo Döndür',
      icon: '⚙️',
      category: BlockCategory.actuators,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 9,
        ),
        BlockParameter(
          name: 'angle',
          label: 'Açı (0-180)',
          type: ParameterType.number,
          defaultValue: 90,
        ),
      ],
    ),

    // Sensors
    BlockMetadata(
      type: BlockType.readUltrasonic,
      label: 'Mesafe Oku',
      icon: '📡',
      category: BlockCategory.sensors,
      parameters: [
        BlockParameter(
          name: 'trigPin',
          label: 'Trig Pin',
          type: ParameterType.pin,
          defaultValue: 9,
        ),
        BlockParameter(
          name: 'echoPin',
          label: 'Echo Pin',
          type: ParameterType.pin,
          defaultValue: 10,
        ),
      ],
    ),
    BlockMetadata(
      type: BlockType.readTemperature,
      label: 'Sıcaklık Oku',
      icon: '🌡️',
      category: BlockCategory.sensors,
      parameters: [
        BlockParameter(
          name: 'pin',
          label: 'Pin',
          type: ParameterType.pin,
          defaultValue: 2,
        ),
      ],
    ),
  ];

  static List<BlockMetadata> getBlocksByCategory(BlockCategory category) {
    return allBlocks.where((b) => b.category == category).toList();
  }
}
