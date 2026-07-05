const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin (uses application default credentials)
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'devkom-dfdca',
  });
}

const db = admin.firestore();

const curricula = JSON.parse(fs.readFileSync('curriculum_firestore_import.json', 'utf8'));

async function importCurricula() {
  console.log('📚 Müfredat verileri ekleniyor...\n');

  let successCount = 0;
  let errorCount = 0;

  for (const curriculum of curricula) {
    try {
      const docRef = await db.collection('curriculum').add({
        ...curriculum,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: 'admin'
      });

      console.log(`✅ ${curriculum.title}`);
      console.log(`   ID: ${docRef.id}`);
      console.log(`   Konu: ${curriculum.subject} | Seviye: ${curriculum.level}`);
      console.log('');

      successCount++;
    } catch (error) {
      console.error(`❌ ${curriculum.title} - Hata:`, error.message);
      errorCount++;
    }
  }

  console.log('\n═══════════════════════════════════════');
  console.log(`✨ İşlem Tamamlandı!`);
  console.log(`✅ Başarılı: ${successCount} müfredat`);
  if (errorCount > 0) {
    console.log(`❌ Hatalı: ${errorCount} müfredat`);
  }
  console.log('═══════════════════════════════════════\n');

  process.exit(errorCount > 0 ? 1 : 0);
}

importCurricula().catch(error => {
  console.error('\n❌ Kritik Hata:', error);
  process.exit(1);
});
