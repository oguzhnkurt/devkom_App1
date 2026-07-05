#!/usr/bin/env python3
"""
Script to fix all compile errors systematically
"""
import re
import os

def fix_file(filepath, fixes):
    """Apply fixes to a file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        for pattern, replacement in fixes:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Fixed: {filepath}")
            return True
        else:
            print(f"⏭️  No changes: {filepath}")
            return False
    except Exception as e:
        print(f"❌ Error fixing {filepath}: {e}")
        return False

# Define fixes for each file
fixes_map = {
    'lib/screens/games/game_result_screen.dart': [
        # Fix saveGameResult calls - add gameName parameter
        (r'await _leaderboardService\.addEntry\(\s*LeaderboardEntry\(',
         'await _leaderboardService.addEntry(\n        LeaderboardEntry('),
        # Fix getUserRank call
        (r'final rank = await _leaderboardService\.getUserRank\(\);',
         '''final rank = await _leaderboardService.getUserRank(
        userId: userId,
        gameType: widget.gameType.name,
        difficulty: widget.difficulty,
      );'''),
        # Fix GameType to string conversion
        (r'gameType: widget\.gameType,',
         'gameType: widget.gameType.name,'),
        # Fix entries type casting
        (r'final entries = response\[\'topEntries\'\] \?\? \[\];',
         'final entries = (response[\'topEntries\'] as List<dynamic>? ?? [])\n        .cast<LeaderboardEntry>();'),
    ],
    'lib/screens/games/leaderboard_screen.dart': [
        # Fix GameType to string conversion
        (r'_leaderboardService\.getTopEntries\(\s*gameType: _selectedGameType,',
         '_leaderboardService.getTopEntries(\n        gameType: _selectedGameType.name,'),
        # Fix entries type casting
        (r'List<LeaderboardEntry> entries = \[\];',
         'List<LeaderboardEntry> entries = [];'),
        (r'entries = await _leaderboardService\.getTopEntries\(\s*gameType: _selectedGameType,',
         'entries = (await _leaderboardService.getTopEntries(\n          gameType: _selectedGameType.name,'),
        # Fix score toInt()
        (r'entry\.score',
         'entry.score.toInt()'),
    ],
    'lib/screens/social/create_post_screen.dart': [
        # Add userName parameter
        (r'await _feedService\.createPost\(\s*userId: _currentUser\.id,',
         '''await _feedService.createPost(
        userId: _currentUser.id,
        userName: _currentUser.name ?? 'User','''),
    ],
    'lib/screens/social/comments_screen.dart': [
        # Fix addComment - add userName
        (r'await _feedService\.addComment\(\s*postId: widget\.postId,\s*userId: _currentUser\.id,',
         '''await _feedService.addComment(
          postId: widget.postId,
          userId: _currentUser.id,
          userName: _currentUser.name ?? 'User','''),
        # Fix deleteComment signature
        (r'await _feedService\.deleteComment\(\s*comment\.id,\s*widget\.postId\s*\);',
         'await _feedService.deleteComment(comment.id, widget.postId);'),
        # Fix getCommentsStream type casting
        (r'Stream<List<PostComment>>',
         'Stream<List<PostComment>>'),
    ],
    'lib/screens/social/post_detail_screen.dart': [
        # Fix addComment - add userName
        (r'await _feedService\.addComment\(\s*postId: widget\.post\.id,\s*userId: _currentUser\.id,',
         '''await _feedService.addComment(
        postId: widget.post.id,
        userId: _currentUser.id,
        userName: _currentUser.name ?? 'User','''),
    ],
}

def main():
    base_path = 'C:/Users/Oguzhan/devkom_app'
    fixed_count = 0

    for filepath, fixes in fixes_map.items():
        full_path = os.path.join(base_path, filepath.replace('/', os.sep))
        if os.path.exists(full_path):
            if fix_file(full_path, fixes):
                fixed_count += 1
        else:
            print(f"⚠️  File not found: {full_path}")

    print(f"\n🎉 Fixed {fixed_count} files!")

if __name__ == '__main__':
    main()
