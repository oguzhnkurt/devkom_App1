#!/usr/bin/env node

/**
 * Fix JSONB Type Errors in Migration Files
 *
 * This script converts ARRAY['...', '...'] format to '["...", "..."]'::jsonb
 * for hints and other JSONB columns
 */

const fs = require('fs');
const path = require('path');

const MIGRATION_DIR = path.join(__dirname, 'supabase', 'migrations');
const FILES_TO_FIX = [
  '11_expand_python_challenges.sql',
  '12_expand_scratch_challenges.sql',
  '13_expand_html_challenges.sql',
  '14_expand_css_challenges.sql',
  '15_create_java_challenges.sql',
  '16_create_csharp_challenges.sql'
];

function convertArrayToJsonb(content) {
  // Pattern: ARRAY['item1', 'item2', ...]
  // Replace with: '["item1", "item2", ...]'::jsonb

  const arrayPattern = /ARRAY\[((?:'[^']*'(?:\s*,\s*)?)+)\]/g;

  return content.replace(arrayPattern, (match, items) => {
    // Split items by comma (but not commas inside strings)
    const itemList = [];
    let currentItem = '';
    let inString = false;

    for (let i = 0; i < items.length; i++) {
      const char = items[i];

      if (char === "'" && (i === 0 || items[i-1] !== '\\')) {
        inString = !inString;
        currentItem += char;
      } else if (char === ',' && !inString) {
        if (currentItem.trim()) {
          itemList.push(currentItem.trim());
        }
        currentItem = '';
      } else {
        currentItem += char;
      }
    }

    if (currentItem.trim()) {
      itemList.push(currentItem.trim());
    }

    // Convert to JSON array
    const jsonArray = '[' + itemList.map(item => {
      // Remove surrounding quotes and escape internal quotes
      const cleaned = item.trim().replace(/^'|'$/g, '');
      const escaped = cleaned.replace(/"/g, '\\"');
      return `"${escaped}"`;
    }).join(', ') + ']';

    return `'${jsonArray}'::jsonb`;
  });
}

console.log('🔧 Fixing JSONB type errors in migration files...\n');

let filesFixed = 0;
let totalReplacements = 0;

FILES_TO_FIX.forEach(filename => {
  const filePath = path.join(MIGRATION_DIR, filename);

  if (!fs.existsSync(filePath)) {
    console.log(`⚠️  Skipping ${filename} (not found)`);
    return;
  }

  console.log(`📝 Processing: ${filename}`);

  let content = fs.readFileSync(filePath, 'utf8');
  const originalContent = content;

  // Count ARRAY occurrences before conversion
  const arrayMatches = content.match(/ARRAY\[/g);
  const beforeCount = arrayMatches ? arrayMatches.length : 0;

  // Convert ARRAY to JSONB
  content = convertArrayToJsonb(content);

  // Count ARRAY occurrences after conversion
  const afterMatches = content.match(/ARRAY\[/g);
  const afterCount = afterMatches ? afterMatches.length : 0;

  const replacements = beforeCount - afterCount;

  if (content !== originalContent) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log(`   ✅ Fixed ${replacements} ARRAY → JSONB conversions`);
    filesFixed++;
    totalReplacements += replacements;
  } else {
    console.log(`   ℹ️  No changes needed`);
  }
});

console.log(`\n✅ Fixed ${filesFixed} files with ${totalReplacements} total replacements\n`);

// Also fix the combined deployment file
const deployFilePath = path.join(MIGRATION_DIR, 'deploy_all_challenges.sql');
if (fs.existsSync(deployFilePath)) {
  console.log('📝 Regenerating combined deployment file...');

  // Read header
  let combinedContent = `-- ========================================
-- COMBINED MIGRATION FILE FOR CHALLENGE EXPANSION
-- Deploy Date: 2025-11-28
-- ========================================
--
-- This file combines the following migrations:
-- 11_expand_python_challenges.sql      (+15 challenges)
-- 12_expand_scratch_challenges.sql     (+12 challenges)
-- 13_expand_html_challenges.sql        (+10 challenges)
-- 14_expand_css_challenges.sql         (+10 challenges)
-- 15_create_java_challenges.sql        (+20 challenges)
-- 16_create_csharp_challenges.sql      (+20 challenges)
--
-- Total: +87 new interactive challenges
-- Total XP: +3,075 XP
--
-- INSTRUCTIONS:
-- 1. Open Supabase Dashboard → SQL Editor
-- 2. Copy and paste this entire file
-- 3. Click "Run" to execute
-- 4. Verify with: SELECT course_id, COUNT(*) FROM interactive_lessons GROUP BY course_id;
--
-- ========================================

`;

  // Append all fixed migration files
  FILES_TO_FIX.forEach(filename => {
    const filePath = path.join(MIGRATION_DIR, filename);
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf8');
      combinedContent += `\n-- ========================================\n`;
      combinedContent += `-- ${filename}\n`;
      combinedContent += `-- ========================================\n\n`;
      combinedContent += content + '\n\n';
    }
  });

  fs.writeFileSync(deployFilePath, combinedContent, 'utf8');
  console.log('   ✅ Combined deployment file updated\n');
}

console.log('🎉 All files fixed and ready for deployment!');
