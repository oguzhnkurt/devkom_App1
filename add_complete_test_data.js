const admin = require('firebase-admin');

// Firebase'i başlat
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'devkom-dfdca',
  });
}

const db = admin.firestore();

async function addCompleteTestData() {
  try {
    console.log('🔍 Parent kullanıcı aranıyor (a@devkom.com)...');

    // a@devkom.com parent kullanıcısını bul
    const parentSnapshot = await db.collection('users')
      .where('email', '==', 'a@devkom.com')
      .limit(1)
      .get();

    if (parentSnapshot.empty) {
      console.log('❌ a@devkom.com parent bulunamadı!');
      console.log('💡 Lütfen önce a@devkom.com ile parent hesabı oluşturun.');
      process.exit(1);
    }

    const parentDoc = parentSnapshot.docs[0];
    const parentId = parentDoc.id;
    const parentData = parentDoc.data();

    console.log('✅ Parent bulundu:', parentData.name || parentData.displayName || parentData.email);
    console.log('');

    // Test öğrencisi ekle
    console.log('📝 Öğrenci ekleniyor...');

    const studentData = {
      name: 'Ahmet Yılmaz',
      displayName: 'Ahmet Yılmaz',
      email: 'ahmet@test.com',
      role: 'student',
      ageGroup: '7-9',
      parentId: parentId,
      classId: 'class_001',
      className: '3-A',
      phoneNumber: '+905551234567',
      profilePictureUrl: null,
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const studentRef = await db.collection('users').add(studentData);
    const studentId = studentRef.id;

    console.log('✅ Öğrenci eklendi: Ahmet Yılmaz (ID:', studentId + ')');
    console.log('');

    // Ödev teslimlerini ekle
    console.log('📚 Ödev teslimlerini ekliyorum...');

    const homeworkSubmissions = [
      {
        studentId: studentId,
        homeworkTitle: 'Robotik Kodlama - Döngüler',
        status: 'graded',
        grade: 95,
        feedback: 'Harika bir çalışma! Döngüler konusunu çok iyi kavramışsın.',
        maxGrade: 100,
        submittedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-13T10:00:00Z')),
        gradedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-14T15:30:00Z')),
      },
      {
        studentId: studentId,
        homeworkTitle: 'Arduino LED Kontrol',
        status: 'graded',
        grade: 88,
        feedback: 'İyi bir başlangıç, kod yapısı daha da geliştirilebilir.',
        maxGrade: 100,
        submittedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-10T14:00:00Z')),
        gradedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-11T16:00:00Z')),
      },
      {
        studentId: studentId,
        homeworkTitle: 'Blok Kodlama - Koşullar',
        status: 'graded',
        grade: 92,
        feedback: 'Koşullu ifadeleri doğru kullanmışsın! Tebrikler.',
        maxGrade: 100,
        submittedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-08T11:00:00Z')),
        gradedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-09T13:00:00Z')),
      },
      {
        studentId: studentId,
        homeworkTitle: 'Sensör Kullanımı',
        status: 'graded',
        grade: 85,
        feedback: 'Sensör entegrasyonu başarılı.',
        maxGrade: 100,
        submittedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T09:00:00Z')),
        gradedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-06T10:00:00Z')),
      },
    ];

    for (const submission of homeworkSubmissions) {
      await db.collection('homework_submissions').add(submission);
      console.log('  ✓', submission.homeworkTitle, '- Not:', submission.grade + '/100');
    }

    console.log('');
    console.log('📝 Quiz sonuçlarını ekliyorum...');

    // Quiz sonuçlarını ekle
    const quizResults = [
      {
        userId: studentId,
        quizTitle: 'Robotik Temelleri Quiz',
        score: 8,
        totalQuestions: 10,
        percentage: 80,
        completedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-12T10:00:00Z')),
      },
      {
        userId: studentId,
        quizTitle: 'Arduino Başlangıç',
        score: 9,
        totalQuestions: 10,
        percentage: 90,
        completedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-07T14:00:00Z')),
      },
      {
        userId: studentId,
        quizTitle: 'Kodlama Mantığı',
        score: 7,
        totalQuestions: 10,
        percentage: 70,
        completedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-05T11:00:00Z')),
      },
      {
        userId: studentId,
        quizTitle: 'Temel Elektronik',
        score: 8,
        totalQuestions: 10,
        percentage: 80,
        completedAt: admin.firestore.Timestamp.fromDate(new Date('2025-11-02T09:00:00Z')),
      },
    ];

    for (const quiz of quizResults) {
      await db.collection('quiz_results').add(quiz);
      console.log('  ✓', quiz.quizTitle, '-', quiz.score + '/' + quiz.totalQuestions, '(' + quiz.percentage + '%)');
    }

    console.log('');
    console.log('🎉 Tüm test verileri başarıyla eklendi!');
    console.log('');
    console.log('📊 Özet:');
    console.log('  👤 Öğrenci: Ahmet Yılmaz');
    console.log('  👨‍👩‍👧 Parent: a@devkom.com');
    console.log('  📚 Ödev sayısı: 4');
    console.log('  📝 Quiz sayısı: 4');
    console.log('  📊 Ortalama: 90/100');
    console.log('');
    console.log('✨ Artık uygulamada Raporlar sekmesinden öğrenci verilerini görebilirsiniz!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Hata:', error.message);
    console.error(error);
    process.exit(1);
  }
}

addCompleteTestData();
