from typing import Dict, Any

# In-memory dictionary to mock Firestore database
db: Dict[str, Any] = {}

def update_claim_status(claim_id: str, status: str):
    if claim_id in db:
        db[claim_id]['status'] = status

def get_claim(claim_id: str):
    return db.get(claim_id)
