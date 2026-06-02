import re

with open('student_home_screen.dart', 'r') as f:
    content = f.read()

# Find and fix the indentation issue
old_pattern = r'''                  Expanded\(
                    child: Column\(
                    crossAxisAlignment: CrossAxisAlignment\.start,
                    children: \[
                      Text\(
                        formattedDate,
                        style: TextStyle\(
                          fontSize: 14,
                          color: Colors\.grey\[600\],
                          fontWeight: FontWeight\.w500,
                        \),
                      \),
                      const SizedBox\(height: 4\),
                      Text\(
                        '\$\{loc\.welcome\}, \$\{user\?\.displayName \?\? loc\.student\}',
                        style: const TextStyle\(
                          fontSize: 28,
                          fontWeight: FontWeight\.bold,
                        \),
                          overflow: TextOverflow\.ellipsis,
                          maxLines: 1,
                      \),
                      \],
                    \),
                  \),'''

new_pattern = '''                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.welcome}, ${user?.displayName ?? loc.student}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),'''

# More direct approach - find the section and replace
lines = content.split('\n')
new_lines = []
i = 0
while i < len(lines):
    if i < len(lines) - 1 and 'Expanded(' in lines[i] and 'child: Column(' in lines[i+1]:
        # Found the Expanded block, now fix it
        new_lines.append('                  Expanded(')
        new_lines.append('                    child: Column(')
        new_lines.append('                      crossAxisAlignment: CrossAxisAlignment.start,')
        new_lines.append('                      children: [')
        i += 4  # Skip the malformed lines
        # Now add the Text widgets with correct formatting
        while i < len(lines):
            line = lines[i]
            if 'Text(' in line and 'formattedDate' in lines[i+1]:
                # Format the date text
                new_lines.append('                        Text(')
                i += 1
                new_lines.append('                          formattedDate,')
                i += 1
                new_lines.append('                          style: TextStyle(')
                i += 1
                new_lines.append('                            fontSize: 14,')
                i += 1
                new_lines.append('                            color: Colors.grey[600],')
                i += 1
                new_lines.append('                            fontWeight: FontWeight.w500,')
                i += 1
                new_lines.append('                          ),')
                i += 1
                new_lines.append('                        ),')
                i += 1
                new_lines.append('                        const SizedBox(height: 4),')
                i += 1
            elif 'Text(' in line and 'loc.welcome' in lines[i+1]:
                # Format the welcome text
                new_lines.append('                        Text(')
                i += 1
                new_lines.append('                          \'${loc.welcome}, ${user?.displayName ?? loc.student}\',')
                i += 1
                new_lines.append('                          style: const TextStyle(')
                i += 1
                new_lines.append('                            fontSize: 28,')
                i += 1
                new_lines.append('                            fontWeight: FontWeight.bold,')
                i += 1
                new_lines.append('                          ),')
                i += 1
                new_lines.append('                          overflow: TextOverflow.ellipsis,')
                i += 1
                new_lines.append('                          maxLines: 1,')
                i += 1
                new_lines.append('                        ),')
                i += 1
            elif '],                    ),' in line or (i > 0 and '                      ],' in lines[i] and '                    ),' in lines[i+1]):
                new_lines.append('                      ],')
                new_lines.append('                    ),')
                new_lines.append('                  ),')
                i += 3
                break
            else:
                i += 1
    else:
        new_lines.append(lines[i])
        i += 1

with open('student_home_screen.dart', 'w') as f:
    f.write('\n'.join(new_lines))

print("Fixed!")
