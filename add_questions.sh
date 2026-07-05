#!/bin/bash

# Firebase project details
PROJECT_ID="devkom-dfdca"

# Add questions using Firebase REST API
questions=(
  '{"fields":{"question":{"stringValue":"Bir algoritma nedir?"},"options":{"arrayValue":{"values":[{"stringValue":"Bir müzik aleti"},{"stringValue":"Bir problemi çözmek için adım adım yapılan işlemler"},{"stringValue":"Bir yemek tarifi"},{"stringValue":"Bir oyun"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"1"},"prize":{"integerValue":"1000"}}}'
  '{"fields":{"question":{"stringValue":"Hangisi bir programlama dili değildir?"},"options":{"arrayValue":{"values":[{"stringValue":"Python"},{"stringValue":"Java"},{"stringValue":"Microsoft Word"},{"stringValue":"C++"}]}},"correctAnswerIndex":{"integerValue":"2"},"difficulty":{"integerValue":"2"},"prize":{"integerValue":"2000"}}}'
  '{"fields":{"question":{"stringValue":"Bir döngü (loop) ne işe yarar?"},"options":{"arrayValue":{"values":[{"stringValue":"Bilgisayarı kapatır"},{"stringValue":"Aynı işlemi tekrar tekrar yapar"},{"stringValue":"Programı siler"},{"stringValue":"İnternete bağlanır"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"3"},"prize":{"integerValue":"3000"}}}'
  '{"fields":{"question":{"stringValue":"IF-ELSE yapısı ne için kullanılır?"},"options":{"arrayValue":{"values":[{"stringValue":"Karar verme için"},{"stringValue":"Dosya kaydetmek için"},{"stringValue":"Ekrana yazdırmak için"},{"stringValue":"Değişken tanımlamak için"}]}},"correctAnswerIndex":{"integerValue":"0"},"difficulty":{"integerValue":"4"},"prize":{"integerValue":"5000"}}}'
  '{"fields":{"question":{"stringValue":"Hangisi bir veri tipi değildir?"},"options":{"arrayValue":{"values":[{"stringValue":"Integer"},{"stringValue":"String"},{"stringValue":"Boolean"},{"stringValue":"Calculator"}]}},"correctAnswerIndex":{"integerValue":"3"},"difficulty":{"integerValue":"5"},"prize":{"integerValue":"10000"}}}'
  '{"fields":{"question":{"stringValue":"Array (dizi) nedir?"},"options":{"arrayValue":{"values":[{"stringValue":"Tek bir değer saklayan yapı"},{"stringValue":"Birden fazla değer saklayan yapı"},{"stringValue":"Sadece metin saklayan yapı"},{"stringValue":"Hiçbir şey saklamayan yapı"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"6"},"prize":{"integerValue":"20000"}}}'
  '{"fields":{"question":{"stringValue":"Fonksiyon (Function) ne işe yarar?"},"options":{"arrayValue":{"values":[{"stringValue":"Sadece toplama işlemi yapar"},{"stringValue":"Kodları gruplar ve tekrar kullanılabilir hale getirir"},{"stringValue":"Sadece ekrana yazı yazar"},{"stringValue":"Programı başlatır"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"7"},"prize":{"integerValue":"40000"}}}'
  '{"fields":{"question":{"stringValue":"Binary sistemde 1010 sayısının ondalık karşılığı nedir?"},"options":{"arrayValue":{"values":[{"stringValue":"8"},{"stringValue":"10"},{"stringValue":"12"},{"stringValue":"14"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"8"},"prize":{"integerValue":"80000"}}}'
  '{"fields":{"question":{"stringValue":"Hangisi bir sıralama algoritması değildir?"},"options":{"arrayValue":{"values":[{"stringValue":"Bubble Sort"},{"stringValue":"Quick Sort"},{"stringValue":"Binary Search"},{"stringValue":"Merge Sort"}]}},"correctAnswerIndex":{"integerValue":"2"},"difficulty":{"integerValue":"9"},"prize":{"integerValue":"160000"}}}'
  '{"fields":{"question":{"stringValue":"Object Oriented Programming (OOP) prensiplerinden biri hangisidir?"},"options":{"arrayValue":{"values":[{"stringValue":"Döngü"},{"stringValue":"Kapsülleme (Encapsulation)"},{"stringValue":"Değişken"},{"stringValue":"Array"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"10"},"prize":{"integerValue":"320000"}}}'
  '{"fields":{"question":{"stringValue":"Recursion (Özyineleme) ne demektir?"},"options":{"arrayValue":{"values":[{"stringValue":"Bir fonksiyonun kendisini çağırması"},{"stringValue":"Bir değişkenin değerinin artması"},{"stringValue":"Bir döngünün sonsuza kadar devam etmesi"},{"stringValue":"Bir programın baştan başlaması"}]}},"correctAnswerIndex":{"integerValue":"0"},"difficulty":{"integerValue":"11"},"prize":{"integerValue":"640000"}}}'
  '{"fields":{"question":{"stringValue":"Stack veri yapısında hangi prensip geçerlidir?"},"options":{"arrayValue":{"values":[{"stringValue":"FIFO"},{"stringValue":"LIFO"},{"stringValue":"LILO"},{"stringValue":"FILO"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"12"},"prize":{"integerValue":"1250000"}}}'
  '{"fields":{"question":{"stringValue":"Big O notasyonu neyi ifade eder?"},"options":{"arrayValue":{"values":[{"stringValue":"Programın boyutunu"},{"stringValue":"Algoritmanın karmaşıklığını"},{"stringValue":"Değişken sayısını"},{"stringValue":"Satır sayısını"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"13"},"prize":{"integerValue":"2500000"}}}'
  '{"fields":{"question":{"stringValue":"Polymorphism (Çok biçimlilik) ne anlama gelir?"},"options":{"arrayValue":{"values":[{"stringValue":"Aynı metodun farklı davranışlar sergilemesi"},{"stringValue":"Birden fazla sınıf oluşturma"},{"stringValue":"Değişken türü değiştirme"},{"stringValue":"Program dilini değiştirme"}]}},"correctAnswerIndex":{"integerValue":"0"},"difficulty":{"integerValue":"14"},"prize":{"integerValue":"5000000"}}}'
  '{"fields":{"question":{"stringValue":"Turing Complete bir sistem ne demektir?"},"options":{"arrayValue":{"values":[{"stringValue":"Sadece toplama işlemi yapabilen sistem"},{"stringValue":"Herhangi bir hesaplanabilir fonksiyonu çalıştırabilen sistem"},{"stringValue":"Sadece web sayfası gösterebilen sistem"},{"stringValue":"Sadece oyun oynatabilen sistem"}]}},"correctAnswerIndex":{"integerValue":"1"},"difficulty":{"integerValue":"15"},"prize":{"integerValue":"10000000"}}}'
)

echo "Firebase'e sorular ekleniyor..."
count=0

for question_data in "${questions[@]}"; do
  curl -X POST \
    "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/millionaire_questions" \
    -H "Content-Type: application/json" \
    -d "$question_data" \
    2>&1 | grep -q "name" && echo "Soru $((++count)) eklendi" || echo "Soru eklenirken hata"
done

echo "Tamamlandı! $count soru eklendi."
