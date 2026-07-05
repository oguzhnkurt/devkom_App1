import json
import subprocess

# Firebase Firestore REST API ile öğrenci ekle
student_data = {
    "fields": {
        "name": {"stringValue": "Ahmet Yılmaz"},
        "displayName": {"stringValue": "Ahmet Yılmaz"},
        "email": {"stringValue": "ahmet.test@example.com"},
        "role": {"stringValue": "student"},
        "parentId": {"stringValue": "E0PzCzL6Y4R4IOjIdkIg6E0fIX43"},
        "classId": {"stringValue": "3A"},
        "className": {"stringValue": "3-A"},
        "grade": {"integerValue": "3"}
    }
}

print("Firebase Console'dan manuel olarak ekleyin:")
print("https://console.firebase.google.com/project/devkom-dfdca/firestore/databases/-default-/data/~2Fusers")
print("\nEklenecek veri:")
print(json.dumps(student_data, indent=2))
