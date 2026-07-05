const admin = require('firebase-admin');

// Firebase Admin SDK'yı başlat
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'devkom-dfdca',
  });
}

const db = admin.firestore();

async function addTestStudent() {
  try {
    // Önce mevcut parent ID'yi bulalım
    const parentsSnapshot = await db.collection('users')
      .where('role', '==', 'parent')
      .limit(1)
      .get();

    if (parentsSnapshot.empty) {
      console.log('❌ Parent bulunamadı!');
      return;
    }

    const parentDoc = parentsSnapshot.docs[0];
    const parentId = parentDoc.id;
    const parentData = parentDoc.data();

    console.log('✅ Parent bulundu:', parentData.name, '(ID:', parentId + ')');

    // Test öğrencisi oluştur
    const studentData = {
      name: 'Ahmet Yılmaz',
      email: 'ahmet.yilmaz@test.com',
      role: 'student',
      parentId: parentId,
      classId: 'test_class_001',
      className: '3-A',
      profilePictureUrl: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const studentRef = await db.collection('users').add(studentData);
    console.log('✅ Test öğrencisi oluşturuldu! ID:', studentRef.id);
    console.log('📋 Öğrenci bilgileri:', studentData.name, '-', studentData.className);

    // Öğrenci için bazı test verileri ekleyelim

    // 1. Ödev ekle
    const homework = {
      title: 'Matematik Ödevi',
      description: 'Sayfa 45-46 problemleri',
      dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 gün sonra
      classId: 'test_class_001',
      teacherId: 'test_teacher',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const homeworkRef = await db.collection('homework').add(homework);
    console.log('✅ Test ödevi eklendi');

    // 2. Quiz ekle
    const quiz = {
      title: 'Türkçe Quiz',
      questions: [
        { question: 'Başkent nedir?', options: ['Ankara', 'İstanbul', 'İzmir', 'Bursa'], correctAnswer: 0 },
        { question: '2+2=?', options: ['3', '4', '5', '6'], correctAnswer: 1 },
      ],
      classId: 'test_class_001',
      teacherId: 'test_teacher',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const quizRef = await db.collection('quizzes').add(quiz);
    console.log('✅ Test quiz eklendi');

    // 3. Not ekle
    const grade = {
      studentId: studentRef.id,
      subject: 'Matematik',
      score: 85,
      maxScore: 100,
      date: admin.firestore.FieldValue.serverTimestamp(),
      teacherId: 'test_teacher',
    };
    await db.collection('grades').add(grade);
    console.log('✅ Test notu eklendi');

    console.log('\n🎉 Tüm test verileri başarıyla eklendi!');
    console.log('🔍 Artık uygulamada öğrenci seçerek raporları görebilirsiniz.');

    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error);
    process.exit(1);
  }
}

addTestStudent();
