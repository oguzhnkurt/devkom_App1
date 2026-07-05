#!/bin/bash

# Firestore REST API kullanarak test öğrencisi ekle
# Parent ID: E0PzCzL6Y4R4IOjIdkIg6E0fIX43

PROJECT_ID="devkom-dfdca"
COLLECTION="users"

# Timestamp oluştur
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Öğrenci verisi
cat > student_data.json << 'EOF'
{
  "fields": {
    "name": {"stringValue": "Ahmet Yılmaz"},
    "displayName": {"stringValue": "Ahmet Yılmaz"},
    "email": {"stringValue": "ahmet.test@example.com"},
    "role": {"stringValue": "student"},
    "parentId": {"stringValue": "E0PzCzL6Y4R4IOjIdkIg6E0fIX43"},
    "classId": {"stringValue": "3A"},
    "className": {"stringValue": "3-A"},
    "profilePictureUrl": {"nullValue": null},
    "grade": {"integerValue": "3"}
  }
}
EOF

echo "Test öğrencisi ekleniyor..."

# Curl ile Firestore'a ekle
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}" \
  -H "Content-Type: application/json" \
  -d @student_data.json

echo ""
echo "✅ Tamamlandı!"

rm student_data.json
