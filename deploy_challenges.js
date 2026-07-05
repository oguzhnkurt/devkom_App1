#!/usr/bin/env node

/**
 * Supabase Challenge Deployment Script
 *
 * This script deploys all new interactive challenges to Supabase
 *
 * Usage:
 *   node deploy_challenges.js
 *
 * Requirements:
 *   - DATABASE_URL environment variable with PostgreSQL connection string
 *   OR
 *   - Supabase Database Password (will be prompted)
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Supabase config from lib/config/supabase_config.dart
const SUPABASE_URL = 'https://zvbigvcdddkwixljjypa.supabase.co';
const PROJECT_REF = 'zvbigvcdddkwixljjypa';

// SQL file to deploy
const SQL_FILE = path.join(__dirname, 'supabase', 'migrations', 'deploy_all_challenges.sql');

// Color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = '') {
  console.log(`${color}${message}${colors.reset}`);
}

async function promptPassword() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    rl.question('Enter your Supabase Database Password (from Settings > Database): ', (password) => {
      rl.close();
      resolve(password.trim());
    });
  });
}

async function main() {
  log('\n🚀 Supabase Challenge Deployment Script', colors.bright + colors.cyan);
  log('==========================================\n', colors.cyan);

  // Check if SQL file exists
  if (!fs.existsSync(SQL_FILE)) {
    log(`❌ Error: SQL file not found at ${SQL_FILE}`, colors.red);
    process.exit(1);
  }

  log('📄 Reading SQL file...', colors.blue);
  const sql = fs.readFileSync(SQL_FILE, 'utf8');
  const statementCount = sql.split(';').filter(s => s.trim().length > 0).length;
  log(`   Found ${statementCount} SQL statements\n`, colors.green);

  // Get DATABASE_URL or prompt for password
  let connectionString = process.env.DATABASE_URL;

  if (!connectionString) {
    log('💡 DATABASE_URL not found in environment variables', colors.yellow);
    log('   You can get your database password from:', colors.yellow);
    log('   Supabase Dashboard → Settings → Database → Connection String\n', colors.yellow);

    const password = await promptPassword();

    if (!password) {
      log('\n❌ No password provided. Exiting.', colors.red);
      process.exit(1);
    }

    connectionString = `postgresql://postgres.${PROJECT_REF}:${password}@aws-0-eu-central-1.pooler.supabase.com:6543/postgres`;
  }

  log('\n🔌 Connecting to Supabase PostgreSQL...', colors.blue);

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    log('   ✅ Connected successfully!\n', colors.green);

    log('📊 Checking current challenge counts...', colors.blue);
    const beforeResult = await client.query(`
      SELECT course_id, COUNT(*) as total_challenges, SUM(xp_reward) as total_xp
      FROM interactive_lessons
      WHERE is_active = true
      GROUP BY course_id
      ORDER BY course_id;
    `);

    log('\n   Current counts:', colors.cyan);
    beforeResult.rows.forEach(row => {
      log(`   - ${row.course_id}: ${row.total_challenges} challenges (${row.total_xp} XP)`, colors.cyan);
    });

    log('\n🚀 Deploying new challenges...', colors.blue);
    log('   This may take a moment...\n', colors.yellow);

    await client.query(sql);

    log('   ✅ SQL executed successfully!\n', colors.green);

    log('📊 Verifying new challenge counts...', colors.blue);
    const afterResult = await client.query(`
      SELECT course_id, COUNT(*) as total_challenges, SUM(xp_reward) as total_xp
      FROM interactive_lessons
      WHERE is_active = true
      GROUP BY course_id
      ORDER BY course_id;
    `);

    log('\n   New counts:', colors.green);
    afterResult.rows.forEach(row => {
      log(`   ✅ ${row.course_id}: ${row.total_challenges} challenges (${row.total_xp} XP)`, colors.green);
    });

    // Calculate differences
    log('\n📈 Changes:', colors.bright + colors.green);
    afterResult.rows.forEach(afterRow => {
      const beforeRow = beforeResult.rows.find(r => r.course_id === afterRow.course_id);
      if (beforeRow) {
        const challengeDiff = afterRow.total_challenges - beforeRow.total_challenges;
        const xpDiff = afterRow.total_xp - beforeRow.total_xp;
        if (challengeDiff > 0 || xpDiff > 0) {
          log(`   + ${afterRow.course_id}: +${challengeDiff} challenges (+${xpDiff} XP)`, colors.green);
        }
      } else {
        log(`   + ${afterRow.course_id}: ${afterRow.total_challenges} challenges (NEW!)`, colors.green);
      }
    });

    log('\n🎉 Deployment completed successfully!', colors.bright + colors.green);
    log('==========================================\n', colors.green);

  } catch (error) {
    log('\n❌ Deployment failed!', colors.bright + colors.red);
    log(`   Error: ${error.message}`, colors.red);

    if (error.message.includes('authentication failed')) {
      log('\n💡 Tip: Check your database password', colors.yellow);
      log('   Get it from: Supabase Dashboard → Settings → Database', colors.yellow);
    }

    process.exit(1);
  } finally {
    await client.end();
  }
}

// Run the script
main().catch(error => {
  log(`\n❌ Unexpected error: ${error.message}`, colors.red);
  process.exit(1);
});
