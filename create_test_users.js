/**
 * Test Users Creator
 * Creates test users in Firestore with different subscription states
 *
 * Usage:
 * node create_test_users.js
 *
 * Prerequisites:
 * - serviceAccountKey.json in the root directory
 * - Firebase Admin SDK initialized
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
});

const db = admin.firestore();
const auth = admin.auth();

// Test users data
const testUsers = [
  {
    email: 'free.student@devkom.test',
    password: 'Test123456',
    displayName: 'Ücretsiz Öğrenci',
    role: 'student',
    ageGroup: 'age7to9',
    isPro: false,
    description: 'Test için ücretsiz öğrenci hesabı'
  },
  {
    email: 'pro.student@devkom.test',
    password: 'Test123456',
    displayName: 'Pro Öğrenci',
    role: 'student',
    ageGroup: 'age10to12',
    isPro: true,
    proExpiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 gün sonra
    lastPurchaseProductId: 'devkom_pro_monthly',
    lastPurchaseDate: new Date(),
    description: 'Test için Pro öğrenci hesabı (30 gün)'
  },
  {
    email: 'pro.yearly@devkom.test',
    password: 'Test123456',
    displayName: 'Pro Yıllık Öğrenci',
    role: 'student',
    ageGroup: 'age13plus',
    isPro: true,
    proExpiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 yıl sonra
    lastPurchaseProductId: 'devkom_pro_yearly',
    lastPurchaseDate: new Date(),
    description: 'Test için Pro öğrenci hesabı (yıllık)'
  },
  {
    email: 'expired.pro@devkom.test',
    password: 'Test123456',
    displayName: 'Süresi Dolmuş Pro',
    role: 'student',
    ageGroup: 'age7to9',
    isPro: true,
    proExpiryDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 gün önce
    lastPurchaseProductId: 'devkom_pro_monthly',
    lastPurchaseDate: new Date(Date.now() - 37 * 24 * 60 * 60 * 1000),
    description: 'Test için süresi dolmuş Pro hesabı'
  },
  {
    email: 'free.parent@devkom.test',
    password: 'Test123456',
    displayName: 'Ücretsiz Veli',
    role: 'parent',
    isPro: false,
    studentIds: [], // Will be populated after creating students
    description: 'Test için ücretsiz veli hesabı'
  },
  {
    email: 'pro.parent@devkom.test',
    password: 'Test123456',
    displayName: 'Pro Veli',
    role: 'parent',
    isPro: true,
    proExpiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    lastPurchaseProductId: 'devkom_pro_monthly',
    lastPurchaseDate: new Date(),
    studentIds: [],
    description: 'Test için Pro veli hesabı'
  },
  {
    email: 'teacher@devkom.test',
    password: 'Test123456',
    displayName: 'Test Öğretmen',
    role: 'teacher',
    isPro: false, // Teachers might not need Pro
    description: 'Test için öğretmen hesabı'
  },
  {
    email: 'admin@devkom.test',
    password: 'Test123456',
    displayName: 'Test Admin',
    role: 'admin',
    isPro: true, // Admins usually have Pro
    proExpiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
    description: 'Test için admin hesabı'
  }
];

async function createTestUsers() {
  console.log('🚀 Starting test user creation...\n');

  let successCount = 0;
  let errorCount = 0;

  for (const userData of testUsers) {
    try {
      console.log(`📝 Creating user: ${userData.email}`);

      // Check if user already exists
      try {
        const existingUser = await auth.getUserByEmail(userData.email);
        console.log(`⚠️  User ${userData.email} already exists, deleting...`);
        await auth.deleteUser(existingUser.uid);
        await db.collection('users').doc(existingUser.uid).delete();
        console.log(`✅ Deleted existing user: ${userData.email}`);
      } catch (error) {
        if (error.code !== 'auth/user-not-found') {
          throw error;
        }
      }

      // Create user in Firebase Auth
      const userRecord = await auth.createUser({
        email: userData.email,
        password: userData.password,
        displayName: userData.displayName,
        emailVerified: true
      });

      console.log(`✅ Auth user created: ${userRecord.uid}`);

      // Create user document in Firestore
      const firestoreData = {
        uid: userRecord.uid,
        email: userData.email,
        displayName: userData.displayName,
        role: userData.role,
        createdAt: admin.firestore.Timestamp.now(),
        lastLoginAt: admin.firestore.Timestamp.now(),
        isPro: userData.isPro || false,
        hasUsedTrial: false,
        dailyPostCount: 0,
        dailyAiMessageCount: 0,
        dailyQuestionCount: 0,
        hasSelectedPurpose: true
      };

      // Add optional fields
      if (userData.ageGroup) firestoreData.ageGroup = userData.ageGroup;
      if (userData.proExpiryDate) {
        firestoreData.proExpiryDate = admin.firestore.Timestamp.fromDate(userData.proExpiryDate);
      }
      if (userData.lastPurchaseDate) {
        firestoreData.lastPurchaseDate = admin.firestore.Timestamp.fromDate(userData.lastPurchaseDate);
      }
      if (userData.lastPurchaseProductId) {
        firestoreData.lastPurchaseProductId = userData.lastPurchaseProductId;
      }
      if (userData.studentIds) firestoreData.studentIds = userData.studentIds;
      if (userData.description) firestoreData.description = userData.description;

      await db.collection('users').doc(userRecord.uid).set(firestoreData);

      console.log(`✅ Firestore document created`);
      console.log(`   - UID: ${userRecord.uid}`);
      console.log(`   - Role: ${userData.role}`);
      console.log(`   - Pro: ${userData.isPro ? '✅' : '❌'}`);
      if (userData.proExpiryDate) {
        const daysLeft = Math.ceil((userData.proExpiryDate - new Date()) / (1000 * 60 * 60 * 24));
        console.log(`   - Pro Expiry: ${daysLeft} days`);
      }
      console.log('');

      successCount++;
    } catch (error) {
      console.error(`❌ Error creating user ${userData.email}:`, error.message);
      errorCount++;
    }
  }

  console.log('\n📊 Summary:');
  console.log(`✅ Successfully created: ${successCount} users`);
  console.log(`❌ Errors: ${errorCount} users`);
  console.log('\n🔐 Login Credentials:');
  console.log('Password for all users: Test123456\n');
  console.log('Test Users:');
  testUsers.forEach(user => {
    const proStatus = user.isPro ? '(PRO ✨)' : '(FREE)';
    console.log(`  - ${user.email} ${proStatus}`);
  });

  console.log('\n💡 Usage Tips:');
  console.log('1. Use these accounts to test Pro vs Free features');
  console.log('2. Test subscription expiry with "expired.pro@devkom.test"');
  console.log('3. Test parent-student linking with parent accounts');
  console.log('4. Admin account for testing admin features\n');
}

// Create a test purchase record
async function createTestPurchaseRecord(userId, productId) {
  const purchase = {
    userId: userId,
    productId: productId,
    purchaseId: `test_${Date.now()}`,
    transactionDate: admin.firestore.Timestamp.now(),
    expiryDate: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + (productId.includes('yearly') ? 365 : 30) * 24 * 60 * 60 * 1000)
    ),
    platform: 'test',
    verificationData: 'test_verification_data'
  };

  await db.collection('purchases').add(purchase);
  console.log(`✅ Test purchase record created for ${userId}`);
}

// Run the script
createTestUsers()
  .then(() => {
    console.log('✅ All done!');
    process.exit(0);
  })
  .catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  });
