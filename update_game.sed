# Add selection clearing in status listener (after "setState(() {" on line ~102)
/setState(() {$/{
  n
  /^            _blocks\.remove(block);$/a\            // Clear selection if the missed block was selected\            if (_selectedBlock == block) {\              _selectedBlock = null;\            }
}

# Replace _catchBlock method with new methods (lines ~116-132)
/^  void _catchBlock\(_FallingBlock block, String category\) {$/,/^  }$/{
  c\  void _selectBlock(_FallingBlock block) {\    setState(() {\      _selectedBlock = block;\    });\    HapticFeedback.selectionClick();\  }\  void _categorizeSelectedBlock(String category) {\    if (_selectedBlock == null) {\      return; // No block selected, do nothing\    }\    final block = _selectedBlock!;\    final isCorrect = (block.type == 'motion' && category == 'motion') ||\                     (block.type == 'looks' && category == 'looks');\    setState(() {\      if (isCorrect) {\        _score += 10;\        HapticFeedback.mediumImpact();\      } else {\        _score = (_score - 5).clamp(0, 999999);\        HapticFeedback.lightImpact();\      }\      _blocks.remove(block);\      block.controller.dispose();\      _selectedBlock = null; // Clear selection after categorizing\    });\  }
}
