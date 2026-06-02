/// W3Schools-style Widgets
/// Simple, clean, focused on learning
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// W3Schools color scheme
class W3Colors {
  static const Color primary = Color(0xFF04AA6D); // W3Schools green
  static const Color tipBackground = Color(0xFFFFFFE0); // Light yellow
  static const Color tipBorder = Color(0xFFFFEB3B);
  static const Color warningBackground = Color(0xFFFFEBEE); // Light red
  static const Color warningBorder = Color(0xFFF44336);
  static const Color codeBackground = Color(0xFFF1F1F1);
  static const Color darkCodeBackground = Color(0xFF282C34);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
}

/// Code block with syntax highlighting and "Try it Yourself" button
class W3CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final String? output;
  final bool showTryButton;
  final VoidCallback? onTryIt;

  const W3CodeBlock({
    Key? key,
    required this.code,
    required this.language,
    this.output,
    this.showTryButton = true,
    this.onTryIt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Code container
        Container(
          decoration: BoxDecoration(
            color: W3Colors.codeBackground,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Text(
                      language.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kod kopyalandı'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Code content
              Container(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (output != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÇIKTI:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  output!,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (showTryButton && onTryIt != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTryIt,
            style: ElevatedButton.styleFrom(
              backgroundColor: W3Colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Kendin Dene »',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Green tip box
class W3TipBox extends StatelessWidget {
  final String text;
  final String? title;

  const W3TipBox({
    Key? key,
    required this.text,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: W3Colors.tipBackground,
        border: Border(
          left: BorderSide(color: W3Colors.tipBorder, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (title != null) const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Red/Orange warning box
class W3WarningBox extends StatelessWidget {
  final String text;
  final String? title;

  const W3WarningBox({
    Key? key,
    required this.text,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: W3Colors.warningBackground,
        border: Border(
          left: BorderSide(color: W3Colors.warningBorder, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (title != null) const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple progress bar
class W3ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double height;
  final bool showPercentage;

  const W3ProgressBar({
    Key? key,
    required this.progress,
    this.color,
    this.height = 8,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? W3Colors.primary,
            ),
            minHeight: height,
          ),
        ),
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Achievement badge display
class W3BadgeWidget extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final bool isEarned;
  final VoidCallback? onTap;

  const W3BadgeWidget({
    Key? key,
    required this.emoji,
    required this.name,
    required this.description,
    this.isEarned = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEarned ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: isEarned ? W3Colors.primary : Colors.grey.shade300,
            width: isEarned ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 40,
                color: isEarned ? null : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.black : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isEarned ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Level badge with color
class W3LevelBadge extends StatelessWidget {
  final int level;
  final int xp;
  final int xpToNextLevel;

  const W3LevelBadge({
    Key? key,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
  }) : super(key: key);

  Color _getLevelColor() {
    if (level < 5) return Colors.grey;
    if (level < 10) return Colors.blue;
    if (level < 20) return Colors.purple;
    if (level < 30) return Colors.orange;
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (xp % xpToNextLevel) / xpToNextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getLevelColor(), _getLevelColor().withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seviye',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'XP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$xp',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sonraki seviyeye ${xpToNextLevel - (xp % xpToNextLevel)} XP',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Difficulty badge
class W3DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const W3DifficultyBadge({
    Key? key,
    required this.difficulty,
  }) : super(key: key);

  Color _getColor() {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
      case 'easy':
        return Colors.green;
      case 'orta':
      case 'medium':
        return Colors.orange;
      case 'zor':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        border: Border.all(color: _getColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getColor(),
        ),
      ),
    );
  }
}

/// Course progress card
class W3CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final double progress;
  final String ageRange;
  final bool isNew;
  final VoidCallback onTap;

  const W3CourseCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.ageRange,
    this.isNew = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: W3Colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'YENİ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ageRange,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              W3ProgressBar(
                progress: progress,
                showPercentage: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive code editor for challenges
class W3InteractiveCodeEditor extends StatefulWidget {
  final String language;
  final String starterCode;
  final List<Map<String, dynamic>> testCases;
  final Map<String, dynamic>? successCriteria;
  final String challengeId;
  final int xpReward;
  final Function(bool success, int xp)? onComplete;

  const W3InteractiveCodeEditor({
    Key? key,
    required this.language,
    required this.starterCode,
    required this.testCases,
    this.successCriteria,
    required this.challengeId,
    required this.xpReward,
    this.onComplete,
  }) : super(key: key);

  @override
  State<W3InteractiveCodeEditor> createState() => _W3InteractiveCodeEditorState();
}

class _W3InteractiveCodeEditorState extends State<W3InteractiveCodeEditor> {
  late TextEditingController _codeController;
  String? _output;
  bool? _testsPassed;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.starterCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = null;
      _testsPassed = null;
    });

    // Simulate code execution and testing
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple validation based on test cases
    final userCode = _codeController.text;
    bool allTestsPassed = true;
    final List<String> results = [];

    for (var testCase in widget.testCases) {
      final description = testCase['description'] as String? ?? 'Test';
      final expectedOutput = testCase['expected'] as String? ?? '';

      // Simple check: does code contain expected output or keywords
      bool passed = userCode.contains(expectedOutput) ||
                    _checkCodeLogic(userCode, testCase);

      allTestsPassed &= passed;
      results.add('${passed ? "✓" : "✗"} $description');
    }

    setState(() {
      _isRunning = false;
      _testsPassed = allTestsPassed;
      _output = results.join('\n');
    });

    if (allTestsPassed && widget.onComplete != null) {
      widget.onComplete!(true, widget.xpReward);
    }
  }

  bool _checkCodeLogic(String code, Map<String, dynamic> testCase) {
    // Simple heuristic checks for common patterns
    final checks = testCase['checks'] as List<dynamic>?;
    if (checks == null) return true;

    for (var check in checks) {
      if (!code.contains(check.toString())) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Code editor header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: W3Colors.darkCodeBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.language.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.xpReward} XP',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Code editor
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: W3Colors.codeBackground,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _codeController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'Courier New',
              fontSize: 13,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
        // Run button
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isRunning ? null : _runCode,
          icon: _isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_isRunning ? 'Çalıştırılıyor...' : 'Kodu Çalıştır'),
          style: ElevatedButton.styleFrom(
            backgroundColor: W3Colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        // Output/Results
        if (_output != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _testsPassed == true
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              border: Border(
                left: BorderSide(
                  color: _testsPassed == true
                      ? W3Colors.successGreen
                      : W3Colors.errorRed,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _testsPassed == true ? Icons.check_circle : Icons.error,
                      color: _testsPassed == true
                          ? W3Colors.successGreen
                          : W3Colors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _testsPassed == true
                          ? 'Başarılı! +${widget.xpReward} XP'
                          : 'Test Başarısız',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _testsPassed == true
                            ? W3Colors.successGreen
                            : W3Colors.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _output!,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Scratch-style drag-drop workspace
class W3ScratchWorkspace extends StatefulWidget {
  final List<Map<String, dynamic>> availableBlocks;
  final List<dynamic> expectedSequence;
  final Map<String, dynamic>? stage;
  final String challengeId;
  final int xpReward;
  final Function(bool success, int xp)? onComplete;

  const W3ScratchWorkspace({
    Key? key,
    required this.availableBlocks,
    required this.expectedSequence,
    this.stage,
    required this.challengeId,
    required this.xpReward,
    this.onComplete,
  }) : super(key: key);

  @override
  State<W3ScratchWorkspace> createState() => _W3ScratchWorkspaceState();
}

class _W3ScratchWorkspaceState extends State<W3ScratchWorkspace> {
  final List<Map<String, dynamic>> _workspace = [];
  bool? _testsPassed;
  bool _isRunning = false;

  void _addBlockToWorkspace(Map<String, dynamic> block) {
    setState(() {
      _workspace.add(Map.from(block));
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _workspace.removeAt(index);
    });
  }

  void _runWorkspace() async {
    setState(() {
      _isRunning = true;
      _testsPassed = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Check if workspace matches expected sequence
    bool passed = _checkSequence();

    setState(() {
      _isRunning = false;
      _testsPassed = passed;
    });

    if (passed && widget.onComplete != null) {
      widget.onComplete!(true, widget.xpReward);
    }
  }

  bool _checkSequence() {
    if (_workspace.length != widget.expectedSequence.length) {
      return false;
    }

    for (int i = 0; i < _workspace.length; i++) {
      final workspaceBlock = _workspace[i];
      final expectedBlock = widget.expectedSequence[i] as Map<String, dynamic>;

      if (workspaceBlock['type'] != expectedBlock['type']) {
        return false;
      }
    }

    return true;
  }

  Color _getBlockColor(String category) {
    switch (category) {
      case 'motion':
        return const Color(0xFF4C97FF);
      case 'looks':
        return const Color(0xFF9966FF);
      case 'events':
        return const Color(0xFFFFBF00);
      case 'control':
        return const Color(0xFFFFAB19);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '🐱 Scratch Workspace',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.xpReward} XP',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Block palette
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kullanılabilir Bloklar:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableBlocks.map((block) {
                  return InkWell(
                    onTap: () => _addBlockToWorkspace(block),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getBlockColor(block['category'] as String),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        block['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Workspace
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Çalışma Alanı:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_workspace.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Blokları buraya sürükle',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _workspace.asMap().entries.map((entry) {
                    final index = entry.key;
                    final block = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getBlockColor(block['category'] as String),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              block['label'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeBlock(index),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        // Run button
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isRunning || _workspace.isEmpty ? null : _runWorkspace,
          icon: _isRunning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_isRunning ? 'Çalıştırılıyor...' : 'Programı Çalıştır'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04AA6D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        // Results
        if (_testsPassed != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _testsPassed == true
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              border: Border(
                left: BorderSide(
                  color: _testsPassed == true
                      ? W3Colors.successGreen
                      : W3Colors.errorRed,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _testsPassed == true ? Icons.check_circle : Icons.error,
                  color: _testsPassed == true
                      ? W3Colors.successGreen
                      : W3Colors.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _testsPassed == true
                      ? 'Mükemmel! Blokları doğru sıraladın! +${widget.xpReward} XP'
                      : 'Blok sırası yanlış. Tekrar dene!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _testsPassed == true
                        ? W3Colors.successGreen
                        : W3Colors.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
