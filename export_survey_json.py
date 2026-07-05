import json
from datetime import datetime

# Read survey data
with open('lib/data/visitor_survey_data.json', 'r', encoding='utf-8') as f:
    survey_data = json.load(f)

# Prepare Firestore data
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

# Output clean JSON
print(json.dumps(firestore_data, indent=2, ensure_ascii=False))
