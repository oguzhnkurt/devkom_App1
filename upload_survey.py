#!/usr/bin/env python3
"""
Ziyaretçi anketi Firestore'a yükler
"""
import json
from datetime import datetime

# Firebase Admin SDK kullanımı yerine, manuel olarak anketi konsola yazdıralım
# Firestore Console'dan manuel olarak ekleyebiliriz

with open('lib/data/visitor_survey_data.json', 'r', encoding='utf-8') as f:
    survey_data = json.load(f)

# Firestore formatına dönüştür
firestore_data = {
    "title": survey_data["title"],
    "description": survey_data["description"],
    "createdBy": "system",
    "createdByName": survey_data["createdByName"],
    "createdAt": {"_seconds": int(datetime.now().timestamp()), "_nanoseconds": 0},
    "expiresAt": None,
    "isActive": survey_data["isActive"],
    "questions": survey_data["questions"],
    "targetRoles": survey_data["targetRoles"]
}

print("=" * 80)
print("ZİYARETÇİ ANKETİ - FIRESTORE CONSOLE'A EKLEMEK İÇİN")
print("=" * 80)
print("\n📋 Firestore Console'a gidin:")
print("   https://console.firebase.google.com/project/devkom-dfdca/firestore")
print("\n📝 'surveys' collection'ına yeni döküman ekleyin ve aşağıdaki JSON'ı yapıştırın:\n")
print(json.dumps(firestore_data, indent=2, ensure_ascii=False))
print("\n" + "=" * 80)
print("✅ Anketi Firestore Console'dan manuel olarak ekleyin!")
print("=" * 80)

# Alternatif: Firebase CLI kullanarak
print("\n\n🔧 ALTERNATİF: Firebase CLI ile yüklemek için:")
print("firebase firestore:import surveys.json")
