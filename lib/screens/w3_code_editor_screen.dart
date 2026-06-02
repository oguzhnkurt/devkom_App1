/// W3Schools-style Code Editor Screen
/// "Try it Yourself" interactive code editor
import 'package:flutter/material.dart';
import '../widgets/w3_widgets.dart';

class W3CodeEditorScreen extends StatefulWidget {
  final String code;
  final String language;
  final String? expectedOutput;

  const W3CodeEditorScreen({
    Key? key,
    required this.code,
    required this.language,
    this.expectedOutput,
  }) : super(key: key);

  @override
  State<W3CodeEditorScreen> createState() => _W3CodeEditorScreenState();
}

class _W3CodeEditorScreenState extends State<W3CodeEditorScreen> {
  late TextEditingController _codeController;
  String _output = '';
  bool _isRunning = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.code);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = '';
      _isCorrect = null;
    });

    // Simulate code execution
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple Python-like interpreter simulation
    String output = _simulateCodeExecution(_codeController.text);

    setState(() {
      _output = output;
      _isRunning = false;

      // Check if output matches expected
      if (widget.expectedOutput != null) {
        _isCorrect = _output.trim() == widget.expectedOutput!.trim();
      }
    });
  }

  String _simulateCodeExecution(String code) {
    // Very basic simulation - just for demo
    // In production, you'd use a real sandbox or interpreter

    try {
      List<String> outputs = [];
      List<String> lines = code.split('\n');

      for (String line in lines) {
        line = line.trim();

        // Handle print statements
        if (line.startsWith('print(') && line.endsWith(')')) {
          String content = line.substring(6, line.length - 1);

          // Remove quotes if it's a string
          if (content.startsWith('"') && content.endsWith('"')) {
            outputs.add(content.substring(1, content.length - 1));
          } else if (content.startsWith("'") && content.endsWith("'")) {
            outputs.add(content.substring(1, content.length - 1));
          } else {
            // Try to evaluate simple expressions
            try {
              outputs.add(_evaluateSimpleExpression(content));
            } catch (e) {
              outputs.add(content);
            }
          }
        }
      }

      return outputs.join('\n');
    } catch (e) {
      return 'Hata: Kod çalıştırılamadı';
    }
  }

  String _evaluateSimpleExpression(String expr) {
    // Very basic expression evaluator
    expr = expr.trim();

    // Handle simple arithmetic
    if (expr.contains('+')) {
      List<String> parts = expr.split('+');
      if (parts.length == 2) {
        try {
          int sum = int.parse(parts[0].trim()) + int.parse(parts[1].trim());
          return sum.toString();
        } catch (e) {
          // String concatenation
          String a = parts[0].trim().replaceAll('"', '').replaceAll("'", '');
          String b = parts[1].trim().replaceAll('"', '').replaceAll("'", '');
          return a + b;
        }
      }
    }

    if (expr.contains('-')) {
      List<String> parts = expr.split('-');
      if (parts.length == 2) {
        int diff = int.parse(parts[0].trim()) - int.parse(parts[1].trim());
        return diff.toString();
      }
    }

    if (expr.contains('*')) {
      List<String> parts = expr.split('*');
      if (parts.length == 2) {
        try {
          int product = int.parse(parts[0].trim()) * int.parse(parts[1].trim());
          return product.toString();
        } catch (e) {
          // String repetition
          String text = parts[0].trim().replaceAll('"', '').replaceAll("'", '');
          int count = int.parse(parts[1].trim());
          return text * count;
        }
      }
    }

    if (expr.contains('/')) {
      List<String> parts = expr.split('/');
      if (parts.length == 2) {
        double quotient = int.parse(parts[0].trim()) / int.parse(parts[1].trim());
        return quotient.toString();
      }
    }

    return expr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: W3Colors.darkCodeBackground,
      appBar: AppBar(
        backgroundColor: W3Colors.darkCodeBackground,
        elevation: 0,
        title: Text(
          '${widget.language.toUpperCase()} - Kendin Dene',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _codeController.text = widget.code;
                _output = '';
                _isCorrect = null;
              });
            },
            tooltip: 'Sıfırla',
          ),
        ],
      ),
      body: Column(
        children: [
          // Code editor area
          Expanded(
            flex: 3,
            child: Container(
              color: W3Colors.darkCodeBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Kodunu buraya yaz...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),
          ),

          // Run button
          Container(
            padding: const EdgeInsets.all(16),
            color: W3Colors.darkCodeBackground,
            child: ElevatedButton(
              onPressed: _isRunning ? null : _runCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: W3Colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'ÇALIŞTIR ▶',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Output area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ÇIKTI:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isCorrect != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isCorrect!
                                ? W3Colors.successGreen
                                : W3Colors.errorRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isCorrect! ? '✓ Doğru!' : '✗ Tekrar Dene',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _output.isEmpty ? 'Henüz çıktı yok...' : _output,
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 14,
                          color: _output.isEmpty ? Colors.white38 : Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (widget.expectedOutput != null) ...[
                    const Divider(color: Colors.white24, height: 24),
                    const Text(
                      'BEKLENİLEN ÇIKTI:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.expectedOutput!,
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 14,
                        color: Colors.greenAccent,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
