import asyncio
import uuid
from datetime import datetime
from fastapi import FastAPI, UploadFile, File, Form, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List

from services.mock_firestore import db, update_claim_status, get_claim
from services.mock_gcs import upload_to_gcs
from services.mock_ai import analyze_media
from services.mock_bigquery import get_risk_score
from services.decision_engine import make_decision

app = FastAPI(title="Aura-Agent API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ClaimResponse(BaseModel):
    claim_id: str
    status: str
    message: str

async def process_claim_workflow(claim_id: str, user_id: str, media_urls: List[str], text_description: str):
    """
    Background task to process the claim through the AI pipeline.
    """
    try:
        # 1. Update status to PROCESSING
        update_claim_status(claim_id, "PROCESSING")
        
        # 2. Extract Metadata (Mocked)
        await asyncio.sleep(1) # simulate extraction
        exif_valid = True

        # 3. Pull Risk Score
        risk_score = await get_risk_score(user_id)
        
        # 4. Multimodal AI Analysis (Vertex AI / Gemini mock)
        ai_confidence, ai_explanation, ai_detected_anomalies = await analyze_media(media_urls, text_description)

        # 5. Decision Engine
        decision, final_status = make_decision(ai_confidence, risk_score, exif_valid)

        # 6. Execute action (Dummy Payment Gateway)
        if decision == "REFUND_APPROVED":
            await asyncio.sleep(1) # simulate payment gateway
            action_taken = "Refund of $50.00 processed."
        elif decision == "MANUAL_REVIEW":
            action_taken = "Flagged for manual review."
        else:
            action_taken = "Claim rejected automatically."

        # 7. Update Firestore with results
        db[claim_id].update({
            "status": final_status,
            "decision": decision,
            "ai_confidence": ai_confidence,
            "ai_explanation": ai_explanation,
            "risk_score": risk_score,
            "anomalies": ai_detected_anomalies,
            "action_taken": action_taken,
            "updated_at": datetime.utcnow().isoformat()
        })
        print(f"Claim {claim_id} processed successfully. Status: {final_status}")

    except Exception as e:
        print(f"Error processing claim {claim_id}: {e}")
        update_claim_status(claim_id, "ERROR")

@app.post("/api/v1/claims/upload", response_model=ClaimResponse)
async def upload_claim(
    background_tasks: BackgroundTasks,
    user_id: str = Form(...),
    description: str = Form(""),
    files: List[UploadFile] = File(...)
):
    claim_id = str(uuid.uuid4())
    
    # Simulate GCS upload
    media_urls = []
    for file in files:
        url = await upload_to_gcs(file)
        media_urls.append(url)
    
    # Initialize in Firestore
    db[claim_id] = {
        "claim_id": claim_id,
        "user_id": user_id,
        "description": description,
        "media_urls": media_urls,
        "status": "PENDING",
        "created_at": datetime.utcnow().isoformat(),
        "decision": None,
        "ai_confidence": None,
        "risk_score": None,
        "action_taken": None
    }

    # Trigger async orchestration
    background_tasks.add_task(process_claim_workflow, claim_id, user_id, media_urls, description)

    return ClaimResponse(
        claim_id=claim_id,
        status="PENDING",
        message="Claim received. Processing asynchronously."
    )

@app.get("/api/v1/claims/{claim_id}")
async def check_claim_status(claim_id: str):
    claim = get_claim(claim_id)
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    return claim

@app.get("/api/v1/claims")
async def get_all_claims():
    """Endpoint for Seller Dashboard to fetch all claims."""
    return list(db.values())

@app.post("/api/v1/claims/{claim_id}/override")
async def override_claim(claim_id: str, new_status: str = Form(...), seller_notes: str = Form("")):
    claim = get_claim(claim_id)
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    
    db[claim_id].update({
        "status": new_status,
        "decision": "MANUAL_OVERRIDE",
        "action_taken": seller_notes,
        "updated_at": datetime.utcnow().isoformat()
    })
    return {"message": "Claim overridden successfully", "claim": db[claim_id]}
