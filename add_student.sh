#!/bin/bash

# Firebase Firestore'a REST API ile öğrenci ekle
PROJECT_ID="devkom-dfdca"

# Önce Firebase token al
TOKEN=$(firebase login:ci --no-localhost 2>&1 | grep -oP '1//.+' || echo "")

if [ -z "$TOKEN" ]; then
    echo "Firebase'e giriş yapılıyor..."
    firebase login
fi

# Firestore REST API kullanarak ekle
echo "Test öğrencisi ekleniyor..."

curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "name": {"stringValue": "Ahmet Yılmaz"},
      "displayName": {"stringValue": "Ahmet Yılmaz"},
      "email": {"stringValue": "ahmet.test@devkom.com"},
      "role": {"stringValue": "student"},
      "parentId": {"stringValue": "E0PzCzL6Y4R4IOjIdkIg6E0fIX43"},
      "classId": {"stringValue": "3A"},
      "className": {"stringValue": "3-A"},
      "grade": {"integerValue": "3"},
      "profilePictureUrl": {"nullValue": null}
    }
  }'

echo ""
echo "✅ Öğrenci eklendi!"
