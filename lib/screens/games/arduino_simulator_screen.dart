import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class ArduinoSimulatorScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const ArduinoSimulatorScreen({super.key, required this.gameData});

  @override
  State<ArduinoSimulatorScreen> createState() => _ArduinoSimulatorScreenState();
}

class _ArduinoSimulatorScreenState extends State<ArduinoSimulatorScreen> {
  List<PlacedComponent> placedComponents = [];
  List<Wire> wires = [];
  PlacedComponent? selectedComponent;
  String? connectionStartPin;
  Offset? currentWireEndPoint;
  bool isSimulating = false;
  List<String> errors = [];
  List<String> activeLEDs = [];
  double arduinoScale = 1.0;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    // Arduino'yu otomatik ekle
    _addArduino();
  }

  void _addArduino() {
    final arduino = widget.gameData['availableComponents']
        .firstWhere((c) => c['id'] == 'arduino_uno');
    placedComponents.add(PlacedComponent(
      component: arduino,
      position: const Offset(200, 200),
      id: 'arduino_main',
    ));
  }

  void _addComponent(Map<String, dynamic> component) {
    setState(() {
      placedComponents.add(PlacedComponent(
        component: component,
        position: Offset(100 + placedComponents.length * 50.0, 400),
        id: '${component['id']}_${placedComponents.length}',
      ));
    });
  }

  void _startConnection(String componentId, String pin) {
    setState(() {
      connectionStartPin = '$componentId.$pin';
    });
  }

  void _completeConnection(String componentId, String pin) {
    if (connectionStartPin != null) {
      setState(() {
        wires.add(Wire(
          from: connectionStartPin!,
          to: '$componentId.$pin',
          color: Colors.red,
        ));
        connectionStartPin = null;
      });
    }
  }

  void _runSimulation() {
    setState(() {
      isSimulating = true;
      errors.clear();
      activeLEDs.clear();
    });

    // Basit simülasyon mantığı
    _validateCircuit();

    if (errors.isEmpty) {
      _simulateCircuit();
    }
  }

  void _validateCircuit() {
    // LED'lerin direnç ile bağlı olup olmadığını kontrol et
    for (var component in placedComponents) {
      if (component.component['type'] == 'led') {
        bool hasResistor = _hasResistorInSeries(component.id);
        if (!hasResistor) {
          errors.add(_isEn
              ? '${component.id}: LED connected without a resistor! The LED may burn out.'
              : '${component.id}: LED direnç olmadan bağlanmış! LED yanabilir.');
        }

        bool hasGround = _isConnectedToGround(component.id);
        if (!hasGround) {
          errors.add(_isEn
              ? '${component.id}: LED must be connected to GND.'
              : '${component.id}: LED GND\'ye bağlanmalı.');
        }

        bool hasPower = _isConnectedToPower(component.id);
        if (!hasPower) {
          errors.add(_isEn
              ? '${component.id}: LED must be connected to a power source.'
              : '${component.id}: LED güç kaynağına bağlanmalı.');
        }
      }
    }
  }

  bool _hasResistorInSeries(String ledId) {
    // LED ile bir direnç arasında bağlantı var mı kontrol et
    for (var wire in wires) {
      if (wire.from.startsWith(ledId) || wire.to.startsWith(ledId)) {
        String otherEnd = wire.from.startsWith(ledId) ? wire.to : wire.from;
        String otherComponentId = otherEnd.split('.')[0];
        var otherComponent = placedComponents.firstWhere(
          (c) => c.id == otherComponentId,
          orElse: () => PlacedComponent(
            component: {'type': 'unknown'},
            position: Offset.zero,
            id: '',
          ),
        );
        if (otherComponent.component['type'] == 'resistor') {
          return true;
        }
      }
    }
    return false;
  }

  bool _isConnectedToGround(String componentId) {
    for (var wire in wires) {
      if (wire.from.startsWith(componentId) && wire.to.contains('GND')) {
        return true;
      }
      if (wire.to.startsWith(componentId) && wire.from.contains('GND')) {
        return true;
      }
    }
    return false;
  }

  bool _isConnectedToPower(String componentId) {
    for (var wire in wires) {
      if (wire.from.startsWith(componentId) &&
          (wire.to.contains('D') || wire.to.contains('5V'))) {
        return true;
      }
      if (wire.to.startsWith(componentId) &&
          (wire.from.contains('D') || wire.from.contains('5V'))) {
        return true;
      }
    }
    return false;
  }

  void _simulateCircuit() {
    // Doğru bağlantıları tespit et ve LED'leri yak
    for (var component in placedComponents) {
      if (component.component['type'] == 'led') {
        bool hasResistor = _hasResistorInSeries(component.id);
        bool hasGround = _isConnectedToGround(component.id);
        bool hasPower = _isConnectedToPower(component.id);

        if (hasResistor && hasGround && hasPower) {
          activeLEDs.add(component.id);
        }
      }
    }
  }

  void _stopSimulation() {
    setState(() {
      isSimulating = false;
      activeLEDs.clear();
    });
  }

  void _clearAll() {
    setState(() {
      placedComponents.clear();
      wires.clear();
      errors.clear();
      activeLEDs.clear();
      isSimulating = false;
      _addArduino();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Arduino Simulator' : 'Arduino Simülatörü'),
        backgroundColor: const Color(0xFF00979D),
        foregroundColor: Colors.white,
        actions: [
          // Zoom Out
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                if (arduinoScale > 0.5) {
                  arduinoScale -= 0.1;
                }
              });
            },
            tooltip: _isEn ? 'Zoom Out' : 'Küçült',
          ),
          // Zoom Reset
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: () {
              setState(() {
                arduinoScale = 1.0;
              });
            },
            tooltip: _isEn ? 'Normal Size' : 'Normal Boyut',
          ),
          // Zoom In
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                if (arduinoScale < 2.0) {
                  arduinoScale += 0.1;
                }
              });
            },
            tooltip: _isEn ? 'Zoom In' : 'Büyüt',
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Colors.white30),
          IconButton(
            icon: Icon(isSimulating ? Icons.stop : Icons.play_arrow),
            onPressed: isSimulating ? _stopSimulation : _runSimulation,
            tooltip: isSimulating ? (_isEn ? 'Stop' : 'Durdur') : (_isEn ? 'Run' : 'Çalıştır'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAll,
            tooltip: _isEn ? 'Clear' : 'Temizle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Hata mesajları
          if (errors.isNotEmpty)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEn ? '⚠️ Faulty Connections:' : '⚠️ Hatalı Bağlantılar:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...errors.map((error) => Text(
                        '• $error',
                        style: const TextStyle(fontSize: 12),
                      )),
                ],
              ),
            ),

          // Çalışma alanı
          Expanded(
            flex: 3,
            child: MouseRegion(
              onHover: (event) {
                if (connectionStartPin != null) {
                  setState(() {
                    currentWireEndPoint = event.localPosition;
                  });
                }
              },
              child: GestureDetector(
                onTapUp: (details) {
                  // Boş alana tıklayınca kablo bağlantısını iptal et
                  if (connectionStartPin != null) {
                    setState(() {
                      connectionStartPin = null;
                      currentWireEndPoint = null;
                    });
                  }
                },
                child: Container(
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: [
                      // Grid arka plan
                      CustomPaint(
                        size: Size.infinite,
                        painter: GridPainter(),
                      ),

                      // Bileşenler
                      ...placedComponents.map((pc) => Positioned(
                            left: pc.position.dx,
                            top: pc.position.dy,
                            child: Draggable<PlacedComponent>(
                              data: pc,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildComponentWidget(pc, isDragging: true),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildComponentWidget(pc),
                              ),
                              onDragEnd: (details) {
                                setState(() {
                                  // Canvas'ın global pozisyonunu hesaba kat
                                  final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                                  if (renderBox != null) {
                                    final localPosition = renderBox.globalToLocal(details.offset);
                                    pc.position = localPosition;
                                  }
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedComponent = pc;
                                  });
                                },
                                child: _buildComponentWidget(pc),
                              ),
                            ),
                          )),

                      // Bağlantı kabloları (en üstte olmalı ki Arduino'nun üzerinde görünsün)
                      // IgnorePointer ile sarmalanmış ki dokunma olaylarını engellemeden sadece görsel olarak üstte kalsın
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: WirePainter(wires, placedComponents, connectionStartPin, currentWireEndPoint, arduinoScale),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bileşen paleti
          Container(
            height: 120,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _isEn ? 'Components (Tap to Add)' : 'Bileşenler (Tıklayarak Ekle)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: (widget.gameData['availableComponents'] as List)
                        .where((c) => c['id'] != 'arduino_uno')
                        .map((component) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => _addComponent(component),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        component['icon'],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        component['name'],
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentWidget(PlacedComponent pc, {bool isDragging = false}) {
    final type = pc.component['type'];
    final isActive = activeLEDs.contains(pc.id);
    final isSelected = selectedComponent?.id == pc.id;
    final scale = type == 'board' ? arduinoScale : 1.0;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == 'board') ...[
              _buildArduinoBoard(pc),
            ] else if (type == 'led') ...[
              _buildLED(pc, isActive),
            ] else if (type == 'resistor') ...[
              _buildResistor(pc),
            ] else if (type == 'button') ...[
              _buildButton(pc),
            ] else if (type == 'breadboard') ...[
              _buildBreadboard(pc),
            ],
            Text(
              pc.component['name'],
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArduinoBoard(PlacedComponent pc) {
    final pins = pc.component['pins'] as List;
    final digitalPins = ['D0', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D13'];
    final analogPins = ['A0', 'A1', 'A2', 'A3', 'A4', 'A5'];
    final powerPins = ['5V', '3.3V', 'GND', 'GND', 'VIN'];

    return Container(
      width: 320,
      height: 450,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arduino Uno gerçek görseli
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/arduino_uno.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Eğer görsel yüklenemezse placeholder göster
                  return Container(
                    color: const Color(0xFF00979D),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                          const SizedBox(height: 10),
                          Text(
                            _isEn
                                ? 'Save the Arduino Uno image as\nassets/images/arduino_uno.png'
                                : 'Arduino Uno görselini\nassets/images/arduino_uno.png\nolarak kaydedin',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // USB Port (sol tarafta, dışarı taşan)
          Positioned(
            left: -15,
            top: 120,
            child: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Stack(
                children: [
                  // Metal iç kısım
                  Positioned(
                    left: 5,
                    top: 5,
                    right: 10,
                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Power Jack (sol üst, dışarı taşan)
          Positioned(
            left: -10,
            top: 40,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade700, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Arduino Board ana gövde
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                // Arduino Logo with circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Infinity circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          '∞',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ARDUINO text
                const Text(
                  'ARDUINO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                // UNO badge
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    'UNO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ATmega328 Chip (büyük, DIP28)
                Container(
                  width: 100,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'ATmega\n328P',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // LED'ler - PWR, L, TX, RX
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PWR LED (Yeşil)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text('ON', style: TextStyle(color: Colors.white, fontSize: 5)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    // L LED (Sarı - D13)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text('L', style: TextStyle(color: Colors.white, fontSize: 5)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    // TX LED (Turuncu)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text('TX', style: TextStyle(color: Colors.white, fontSize: 5)),
                      ],
                    ),
                    const SizedBox(width: 3),
                    // RX LED (Turuncu)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text('RX', style: TextStyle(color: Colors.white, fontSize: 5)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Kristal Osilatör (16MHz)
                Container(
                  width: 28,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                  child: const Center(
                    child: Text('16MHz', style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Reset Butonu (sağ üst)
          Positioned(
            right: 80,
            top: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Center(
                child: Text('RST', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // USB to Serial Chip (ATmega16U2)
          Positioned(
            right: 100,
            top: 40,
            child: Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Center(
                child: Text(
                  'ATmega\n16U2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ICSP Header 1 (üst)
          Positioned(
            right: 20,
            top: 80,
            child: Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) => Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) => Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Voltage Regulator (5V)
          Positioned(
            left: 140,
            top: 70,
            child: Container(
              width: 25,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Center(
                child: Text(
                  '5V\nREG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                  ),
                ),
              ),
            ),
          ),

          // Kondansatörler (elektronik bileşenler)
          Positioned(
            left: 90,
            top: 110,
            child: Row(
              children: [
                // Kondansatör 1
                Container(
                  width: 10,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade400,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 5),
                // Kondansatör 2
                Container(
                  width: 10,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade400,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          // Sol taraf - Digital Pins (D0-D13)
          Positioned(
            left: 0,
            top: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: digitalPins.map((pin) {
                bool isActive = connectionStartPin == '${pc.id}.$pin';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      } else {
                        _completeConnection(pc.id, pin);
                      }
                    },
                    onPanStart: (details) {
                      // Sürükleme başladığında otomatik olarak kablo bağlantısını başlat
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      }
                    },
                    onPanUpdate: (details) {
                      // Sürükleme sırasında kablo ucunu güncelle
                      if (connectionStartPin != null) {
                        setState(() {
                          currentWireEndPoint = details.globalPosition;
                        });
                      }
                    },
                    onPanEnd: (details) {
                      // Sürükleme bittiğinde kabloyu iptal et (boş alana bırakıldı)
                      if (connectionStartPin != null) {
                        setState(() {
                          connectionStartPin = null;
                          currentWireEndPoint = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin header
                        Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.yellow : Colors.black,
                            border: Border.all(color: Colors.grey.shade700, width: 1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Pin label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            pin,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sağ taraf - Power Pins
          Positioned(
            right: 0,
            top: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: powerPins.map((pin) {
                bool isActive = connectionStartPin == '${pc.id}.$pin';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      } else {
                        _completeConnection(pc.id, pin);
                      }
                    },
                    onPanStart: (details) {
                      // Sürükleme başladığında otomatik olarak kablo bağlantısını başlat
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      }
                    },
                    onPanUpdate: (details) {
                      // Sürükleme sırasında kablo ucunu güncelle
                      if (connectionStartPin != null) {
                        setState(() {
                          currentWireEndPoint = details.globalPosition;
                        });
                      }
                    },
                    onPanEnd: (details) {
                      // Sürükleme bittiğinde kabloyu iptal et (boş alana bırakıldı)
                      if (connectionStartPin != null) {
                        setState(() {
                          connectionStartPin = null;
                          currentWireEndPoint = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            pin,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Pin header
                        Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.yellow : Colors.black,
                            border: Border.all(color: Colors.grey.shade700, width: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sağ alt - Analog Pins (A0-A5)
          Positioned(
            right: 0,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: analogPins.map((pin) {
                bool isActive = connectionStartPin == '${pc.id}.$pin';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      } else {
                        _completeConnection(pc.id, pin);
                      }
                    },
                    onPanStart: (details) {
                      // Sürükleme başladığında otomatik olarak kablo bağlantısını başlat
                      if (connectionStartPin == null) {
                        _startConnection(pc.id, pin);
                      }
                    },
                    onPanUpdate: (details) {
                      // Sürükleme sırasında kablo ucunu güncelle
                      if (connectionStartPin != null) {
                        setState(() {
                          currentWireEndPoint = details.globalPosition;
                        });
                      }
                    },
                    onPanEnd: (details) {
                      // Sürükleme bittiğinde kabloyu iptal et (boş alana bırakıldı)
                      if (connectionStartPin != null) {
                        setState(() {
                          connectionStartPin = null;
                          currentWireEndPoint = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            pin,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Pin header
                        Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.yellow : Colors.black,
                            border: Border.all(color: Colors.grey.shade700, width: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Power Jack (sol üst)
          Positioned(
            left: 8,
            top: 50,
            child: Container(
              width: 30,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey.shade600),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Center(
                child: Text('DC', style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLED(PlacedComponent pc, bool isActive) {
    final color = pc.component['color'];
    Color ledColor;
    Color offColor;

    switch (color) {
      case 'red':
        ledColor = const Color(0xFFFF0000);
        offColor = const Color(0xFFFF6B6B); // Kırmızı LED kapalıyken hafif kırmızımsı
        break;
      case 'green':
        ledColor = const Color(0xFF00FF00);
        offColor = const Color(0xFF90EE90);
        break;
      case 'blue':
        ledColor = const Color(0xFF0000FF);
        offColor = const Color(0xFF87CEEB);
        break;
      default:
        ledColor = Colors.grey;
        offColor = Colors.grey.shade300;
    }

    return Column(
      children: [
        // LED Gövdesi - Gerçekçi 5mm LED
        Container(
          width: 50,
          height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // LED başlığı (yarı küre)
              Positioned(
                top: 0,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 0.8,
                      colors: isActive
                          ? [
                              ledColor.withValues(alpha: 0.95),
                              ledColor,
                              ledColor.withValues(alpha: 0.7),
                            ]
                          : [
                              offColor.withValues(alpha: 0.5),
                              offColor.withValues(alpha: 0.3),
                              offColor.withValues(alpha: 0.2),
                            ],
                    ),
                    boxShadow: isActive
                        ? [
                            // Dış glow
                            BoxShadow(
                              color: ledColor.withValues(alpha: 0.8),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                            // İç glow
                            BoxShadow(
                              color: ledColor.withValues(alpha: 0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ]
                        : [
                            // Kapalı LED gölgesi
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                  ),
                  child: Stack(
                    children: [
                      // Highlight (üstte parlak nokta - gerçek LED efekti)
                      Positioned(
                        top: 8,
                        left: 12,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: isActive ? 0.9 : 0.3),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // LED merkez ışık kaynağı
                      if (isActive)
                        Center(
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: ledColor,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // LED bacakları
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pozitif bacak (uzun)
                    Container(
                      width: 2,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade500,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Negatif bacak (kısa)
                    Container(
                      width: 2,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade500,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'anode');
                } else {
                  _completeConnection(pc.id, 'anode');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'cathode');
                } else {
                  _completeConnection(pc.id, 'cathode');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '-',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResistor(PlacedComponent pc) {
    // Resistance değerine göre renk bantlarını belirle
    final resistance = pc.component['resistance'].toString();
    List<Color> colorBands = _getResistorColorBands(resistance);

    return Column(
      children: [
        // Gerçek direnç görseli
        SizedBox(
          width: 80,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Metal bacaklar (2 tarafta)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade300],
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                    ),
                  ),
                ],
              ),
              // Direnç gövdesi
              Center(
                child: Container(
                  width: 50,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF5DEB3), // Wheat/bej
                        const Color(0xFFDEB887), // BurlyWood
                        const Color(0xFFF5DEB3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Renk bantları (resistance değerine göre)
                      ...List.generate(
                        colorBands.length,
                        (index) => Positioned(
                          left: 10 + (index * 8.0),
                          top: 0,
                          bottom: 0,
                          width: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorBands[index],
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${pc.component['resistance']}Ω',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'pin1');
                } else {
                  _completeConnection(pc.id, 'pin1');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'pin2');
                } else {
                  _completeConnection(pc.id, 'pin2');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper function to get resistor color bands based on resistance value
  List<Color> _getResistorColorBands(String resistance) {
    // Remove any non-digit characters (like Ω)
    String cleanResistance = resistance.replaceAll(RegExp(r'[^\d]'), '');

    // Map of colors for resistor bands
    final colorMap = {
      0: Colors.black,
      1: const Color(0xFF8B4513), // Brown
      2: Colors.red,
      3: Colors.orange,
      4: Colors.yellow,
      5: Colors.green,
      6: Colors.blue,
      7: const Color(0xFF9370DB), // Violet
      8: Colors.grey,
      9: Colors.white,
    };

    try {
      int value = int.parse(cleanResistance);

      // Convert to string to get individual digits
      String valueStr = value.toString();

      // Get significant figures and multiplier
      List<Color> bands = [];

      if (valueStr.length == 1) {
        // Single digit: e.g., 1Ω = Brown, Black, Gold
        bands.add(colorMap[int.parse(valueStr[0])]!);
        bands.add(Colors.black);
        bands.add(const Color(0xFFFFD700)); // Gold (multiplier x0.1)
      } else if (valueStr.length == 2) {
        // Two digits: e.g., 47Ω = Yellow, Violet, Gold
        bands.add(colorMap[int.parse(valueStr[0])]!);
        bands.add(colorMap[int.parse(valueStr[1])]!);
        bands.add(const Color(0xFFFFD700)); // Gold (multiplier x1)
      } else {
        // Three or more digits
        bands.add(colorMap[int.parse(valueStr[0])]!);
        bands.add(colorMap[int.parse(valueStr[1])]!);

        // Multiplier band (number of zeros)
        int multiplier = valueStr.length - 2;
        if (multiplier < 10) {
          bands.add(colorMap[multiplier]!);
        } else {
          bands.add(colorMap[9]!); // White for very large values
        }
      }

      // Add tolerance band (gold for ±5%)
      bands.add(const Color(0xFFFFD700)); // Gold

      return bands;
    } catch (e) {
      // Default to brown-black-brown (100Ω) if parsing fails
      return [
        const Color(0xFF8B4513), // Brown
        Colors.black,
        const Color(0xFF8B4513), // Brown
        const Color(0xFFFFD700), // Gold
      ];
    }
  }

  Widget _buildButton(PlacedComponent pc) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              pc.component['icon'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'pin1');
                } else {
                  _completeConnection(pc.id, 'pin1');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (connectionStartPin == null) {
                  _startConnection(pc.id, 'pin2');
                } else {
                  _completeConnection(pc.id, 'pin2');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreadboard(PlacedComponent pc) {
    // Realistic breadboard design (mini breadboard 170 pin)
    return Container(
      width: 200,
      height: 140,
      decoration: BoxDecoration(
        // 3D gradient effect for plastic body
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFFAF0), // Light cream
            const Color(0xFFF5F5DC), // Beige
            const Color(0xFFEEE8CD), // Darker beige
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFD3D3D3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top power rails container
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  // + power rail (red)
                  _buildPowerRail(true, Colors.red, '+'),
                  const SizedBox(height: 2),
                  // - power rail (blue)
                  _buildPowerRail(false, Colors.blue, '-'),
                ],
              ),
            ),
          ),

          // Main terminal area with center channel
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                // Top terminal section (5 rows, A-E)
                ...List.generate(5, (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(17, (col) => _buildTerminalHole()),
                  ),
                )),

                // Center channel (IC groove)
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade300,
                        Colors.grey.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),

                // Bottom terminal section (5 rows, F-J)
                ...List.generate(5, (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(17, (col) => _buildTerminalHole()),
                  ),
                )),
              ],
            ),
          ),

          // Bottom power rails container
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  // + power rail (red)
                  _buildPowerRail(true, Colors.red, '+'),
                  const SizedBox(height: 2),
                  // - power rail (blue)
                  _buildPowerRail(false, Colors.blue, '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build power rail with realistic appearance
  Widget _buildPowerRail(bool isPositive, Color color, String symbol) {
    return Row(
      children: [
        Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.7),
                  color,
                  color.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Power rail holes
        ...List.generate(
          15,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade600,
                    Colors.grey.shade500,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 1,
                    offset: const Offset(0, 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build realistic terminal hole
  Widget _buildTerminalHole() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.grey.shade700,
            Colors.grey.shade600,
            Colors.grey.shade500,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 1.5,
            spreadRadius: 0.5,
          ),
        ],
      ),
      // Inner metallic contact
      child: Center(
        child: Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.grey.shade400,
                Colors.grey.shade600,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modeller
class PlacedComponent {
  final Map<String, dynamic> component;
  Offset position;
  final String id;

  PlacedComponent({
    required this.component,
    required this.position,
    required this.id,
  });
}

class Wire {
  final String from;
  final String to;
  final Color color;

  Wire({
    required this.from,
    required this.to,
    required this.color,
  });
}

// Çizim sınıfları
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WirePainter extends CustomPainter {
  final List<Wire> wires;
  final List<PlacedComponent> components;
  final String? connectionStartPin;
  final Offset? currentWireEndPoint;
  final double arduinoScale;

  WirePainter(this.wires, this.components, this.connectionStartPin, this.currentWireEndPoint, this.arduinoScale);

  @override
  void paint(Canvas canvas, Size size) {
    // Tamamlanmış kabloları çiz
    for (var wire in wires) {
      final fromPos = _getConnectionPoint(wire.from);
      final toPos = _getConnectionPoint(wire.to);

      if (fromPos != null && toPos != null) {
        _drawWire(canvas, fromPos, toPos, wire.color);
      }
    }

    // Aktif olarak çizilen kabloyu çiz (sürüklenen kablo)
    if (connectionStartPin != null && currentWireEndPoint != null) {
      final fromPos = _getConnectionPoint(connectionStartPin!);
      if (fromPos != null) {
        _drawWire(canvas, fromPos, currentWireEndPoint!, Colors.blue, isDashed: true);
      }
    }
  }

  void _drawWire(Canvas canvas, Offset from, Offset to, Color color, {bool isDashed = false}) {
    // Calculate control points for curved wire (more realistic)
    final midX = (from.dx + to.dx) / 2;
    final midY = (from.dy + to.dy) / 2;

    // Add slight curve for more realistic appearance
    final controlPoint1 = Offset(
      midX + (from.dy - to.dy) * 0.1,
      midY + (to.dx - from.dx) * 0.1,
    );

    final controlPoint2 = Offset(
      midX - (from.dy - to.dy) * 0.1,
      midY - (to.dx - from.dx) * 0.1,
    );

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        to.dx, to.dy,
      );

    // Draw wire shadow (for 3D effect)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, shadowPaint);

    // Draw darker underside of wire (3D effect)
    final undersidePaint = Paint()
      ..color = color.withValues(alpha: isDashed ? 0.5 : 0.7)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, undersidePaint);

    // Draw main wire body with gradient effect
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDashed
            ? [
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.7),
                color.withValues(alpha: 0.5),
              ]
            : [
                color.withValues(alpha: 0.9),
                color,
                color.withValues(alpha: 0.8),
              ],
      ).createShader(Rect.fromPoints(from, to))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, mainPaint);

    // Draw highlight on wire (plastic sheen)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDashed ? 0.2 : 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, highlightPaint);

    // Draw metallic connector pins at connection points
    if (!isDashed) {
      _drawMetallicPin(canvas, from, color);
      _drawMetallicPin(canvas, to, color);
    } else {
      _drawMetallicPin(canvas, from, color);
      // Draw temporary connection indicator
      final tempPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(to, 4, tempPaint);
      final tempBorderPaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(to, 4, tempBorderPaint);
    }
  }

  // Helper to draw realistic metallic pin connectors
  void _drawMetallicPin(Canvas canvas, Offset position, Color wireColor) {
    // Pin shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(position.translate(0.5, 0.5), 6, shadowPaint);

    // Pin base (darker metal)
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey.shade600,
          Colors.grey.shade700,
          Colors.grey.shade800,
        ],
      ).createShader(Rect.fromCircle(center: position, radius: 6))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 6, basePaint);

    // Pin highlight (metallic sheen)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          Colors.grey.shade300,
          Colors.grey.shade400,
          Colors.grey.shade600.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: position, radius: 6))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 5, highlightPaint);

    // Inner metallic ring
    final ringPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(position, 3.5, ringPaint);

    // Plastic insulator ring (colored part)
    final insulatorPaint = Paint()
      ..color = wireColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(position, 7, insulatorPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (to - from).distance;
    final direction = (to - from) / distance;

    var currentDistance = 0.0;
    while (currentDistance < distance) {
      final start = from + direction * currentDistance;
      currentDistance += dashWidth;
      final end = from + direction * math.min(currentDistance, distance);
      canvas.drawLine(start, end, paint);
      currentDistance += dashSpace;
    }
  }

  Offset? _getConnectionPoint(String connection) {
    final parts = connection.split('.');
    if (parts.length != 2) return null;

    final componentId = parts[0];
    final pin = parts[1];

    final component = components.firstWhere(
      (c) => c.id == componentId,
      orElse: () => PlacedComponent(
        component: {},
        position: Offset.zero,
        id: '',
      ),
    );

    if (component.id.isEmpty) return null;

    // Bileşen tipine göre bağlantı noktası hesaplama
    final type = component.component['type'];

    if (type == 'board') {
      // Arduino için pin pozisyonunu hesapla
      return _getArduinoPinPosition(component, pin);
    } else {
      // Diğer bileşenler için basit hesaplama
      return component.position + const Offset(75, 50);
    }
  }

  Offset _getArduinoPinPosition(PlacedComponent component, String pin) {
    final basePos = component.position;

    // Digital pinler (D0-D13) - sol taraf
    if (pin.startsWith('D')) {
      final pinNum = int.tryParse(pin.substring(1)) ?? 0;
      return basePos + Offset(10 * arduinoScale, (192 + (pinNum * 14)) * arduinoScale);
    }

    // Analog pinler (A0-A5) - sağ alt
    if (pin.startsWith('A')) {
      final pinNum = int.tryParse(pin.substring(1)) ?? 0;
      return basePos + Offset(270 * arduinoScale, (366 + (pinNum * 14)) * arduinoScale);
    }

    // Power pinler - sağ üst
    if (pin == '5V') return basePos + Offset(270 * arduinoScale, 132 * arduinoScale);
    if (pin == '3.3V') return basePos + Offset(270 * arduinoScale, 146 * arduinoScale);
    if (pin == 'GND') return basePos + Offset(270 * arduinoScale, 160 * arduinoScale);
    if (pin == 'VIN') return basePos + Offset(270 * arduinoScale, 188 * arduinoScale);

    // Varsayılan
    return basePos + Offset(140 * arduinoScale, 210 * arduinoScale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  