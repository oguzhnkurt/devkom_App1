#!/usr/bin/env python3
"""
Script to update all ScratchBlock instances in scratch_lessons_data.dart
to include the new 'shape' parameter and 'inputs' where appropriate.
"""

import re

def update_scratch_blocks(content):
    """Update all ScratchBlock instances with shape parameter"""

    # Pattern to match ScratchBlock definitions
    pattern = r'ScratchBlock\(\s*id:\s*\'([^\']+)\',\s*blockType:\s*ScratchBlockType\.(\w+),\s*label:\s*\'([^\']+)\',\s*color:\s*Color\(([^)]+)\),\s*\)'

    def replacement(match):
        block_id = match.group(1)
        block_type = match.group(2)
        label = match.group(3)
        color = match.group(4)

        # Determine shape based on block type
        if block_type == 'events':
            shape = 'ScratchBlockShape.cap'
        elif block_type == 'control' and ('tekrarla' in label or 'eger' in label):
            shape = 'ScratchBlockShape.cBlock'
        elif block_type == 'sensing' or ('mi?' in label or 'mi>' in label):
            shape = 'ScratchBlockShape.boolean'
        elif block_type == 'variables' or block_type == 'data':
            # Check if it's a getter (reporter) or setter (stack)
            if 'yap' in label or 'degistir' in label:
                shape = 'ScratchBlockShape.stack'
            else:
                shape = 'ScratchBlockShape.reporter'
        else:
            shape = 'ScratchBlockShape.stack'

        # Build the updated block
        result = f'''ScratchBlock(
              id: '{block_id}',
              blockType: ScratchBlockType.{block_type},
              shape: {shape},
              label: '{label}',
              color: Color({color}),
            )'''

        # Add inputs for specific blocks
        if 'adim' in label or 'kere' in label or 'saniye' in label:
            # Extract number from label
            numbers = re.findall(r'\d+', label)
            if numbers:
                num = numbers[0]
                input_name = 'steps' if 'adim' in label else ('times' if 'kere' in label else 'seconds')
                result = f'''ScratchBlock(
              id: '{block_id}',
              blockType: ScratchBlockType.{block_type},
              shape: {shape},
              label: '{label}',
              color: Color({color}),
              inputs: [
                BlockInput(
                  name: '{input_name}',
                  type: BlockInputType.number,
                  defaultValue: {num},
                ),
              ],
            )'''
        elif 'de' in label or 'soyle' in label:
            # Text input for "say" blocks
            result = f'''ScratchBlock(
              id: '{block_id}',
              blockType: ScratchBlockType.{block_type},
              shape: {shape},
              label: '{label}',
              color: Color({color}),
              inputs: [
                BlockInput(
                  name: 'message',
                  type: BlockInputType.text,
                  placeholder: 'Mesaj',
                ),
              ],
            )'''

        return result

    # Replace all matches
    updated = re.sub(pattern, replacement, content, flags=re.MULTILINE)

    return updated

# Read the file
with open(r'C:\Users\Oguzhan\devkom_app\lib\courses\data\scratch_lessons_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Update blocks
updated_content = update_scratch_blocks(content)

# Write back
with open(r'C:\Users\Oguzhan\devkom_app\lib\courses\data\scratch_lessons_data.dart', 'w', encoding='utf-8') as f:
    f.write(updated_content)

print("✅ Updated all ScratchBlock instances with shape parameter!")
