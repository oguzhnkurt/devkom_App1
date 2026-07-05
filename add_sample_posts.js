const admin = require('firebase-admin');

// Firebase Admin SDK'yı başlat
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'devkom-dfdca',
  });
}

const db = admin.firestore();

async function addSamplePosts() {
  try {
    // Örnek kullanıcı ID'si (mevcut bir öğrenci kullanıcısı olmalı)
    // Bu ID'yi gerçek bir kullanıcı ID'si ile değiştirmeliyiz
    const postsRef = db.collection('posts');

    // Örnek Post 1 - AI & Robotik kategorisinde
    const post1 = {
      userId: 'sample_user_1', // Gerçek kullanıcı ID'si ile değiştirilecek
      content: '🤖 Bugün Arduino ile ilk robotumu yaptım! Engelden kaçan bir robot tasarladım ve ultrasonik sensör kullandım. Çok heyecanlıydı! 🚀',
      imageUrl: null,
      category: 'ai',
      tags: ['arduino', 'robotik', 'proje'],
      likeCount: 15,
      commentCount: 3,
      isApproved: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    };

    // Örnek Post 2 - Kodlama kategorisinde
    const post2 = {
      userId: 'sample_user_2', // Gerçek kullanıcı ID'si ile değiştirilecek
      content: '💻 Python ile ilk oyunumu yazdım! Tahmin oyunu yapıyorum, 1-100 arası sayı tahmin etmeye çalışıyorsunuz. Kim denemek ister? 😄',
      imageUrl: null,
      category: 'coding',
      tags: ['python', 'oyun', 'kodlama'],
      likeCount: 8,
      commentCount: 5,
      isApproved: true,
      createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 3600000)), // 1 saat önce
      updatedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 3600000)),
    };

    // Örnek Post 3 - Eğlenceli kategorisinde
    const post3 = {
      userId: 'sample_user_1',
      content: '😂 Bugün kodlarken en komik hata: "Merhaba Dünya" yerine "Merhaba Düyna" yazmışım. Bilgisayar "Düyna kimdir?" diye sordu sanki! 🌍',
      imageUrl: null,
      category: 'funny',
      tags: ['komik', 'hata', 'kodlama'],
      likeCount: 25,
      commentCount: 8,
      isApproved: true,
      createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 7200000)), // 2 saat önce
      updatedAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 7200000)),
    };

    console.log('Adding sample posts...');

    await postsRef.add(post1);
    console.log('✅ Post 1 added (AI & Robotik)');

    await postsRef.add(post2);
    console.log('✅ Post 2 added (Kodlama)');

    await postsRef.add(post3);
    console.log('✅ Post 3 added (Eğlenceli)');

    console.log('\n🎉 Successfully added 3 sample posts!');
    console.log('\nNote: These posts use placeholder user IDs.');
    console.log('For real posts, you need to use actual user IDs from your users collection.');

  } catch (error) {
    console.error('❌ Error adding sample posts:', error);
  }
}

addSamplePosts();
