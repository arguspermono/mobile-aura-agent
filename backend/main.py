import asyncio
from datetime import datetime, timezone
from typing import Any

from fastapi import BackgroundTasks, FastAPI, File, Form, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from services.decision_engine import make_decision
from services.mock_ai import analyze_media
from services.mock_bigquery import get_user_profile
from services.mock_exif import validate_file_metadata
from services.mock_fcm import send_claim_notification
from services.mock_firestore import (
    create_claim,
    get_claim,
    get_file,
    list_notifications,
    list_claims,
    mark_analysis_started,
    update_claim,
)
from services.mock_gcs import fetch_files, upload_to_gcs
from services.mock_midtrans import trigger_refund

app = FastAPI(title="Aura-Agent API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(HTTPException)
async def http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": "error",
            "data": {},
            "message": exc.detail,
            "timestamp": now_iso(),
        },
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(_: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=500,
        content={
            "status": "error",
            "data": {},
            "message": str(exc),
            "timestamp": now_iso(),
        },
    )


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def response_ok(data: Any, message: str) -> dict[str, Any]:
    return {
        "status": "ok",
        "data": data,
        "message": message,
        "timestamp": now_iso(),
    }


class CreateClaimRequest(BaseModel):
    user_id: str
    order_id: str
    claim_type: str
    file_ids: list[str] = Field(min_length=1)
    voice_description: str | None = ""


def ensure_claim(claim_id: str) -> dict[str, Any]:
    claim = get_claim(claim_id)
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    return claim


async def run_analysis_pipeline(claim_id: str) -> None:
    claim = ensure_claim(claim_id)
    file_records = await fetch_files(claim["file_ids"])

    try:
        update_claim(
            claim_id,
            status="PROCESSING",
            current_step="uploading_evidence",
        )
        await asyncio.sleep(0.5)

        update_claim(claim_id, current_step="analyzing_evidence")
        ai_result = await analyze_media(
            file_records=file_records,
            claim_type=claim["claim_type"],
            voice_description=claim.get("voice_description", ""),
        )

        update_claim(claim_id, current_step="detecting_damage_patterns")
        exif_result = await validate_file_metadata(file_records)

        update_claim(claim_id, current_step="calculating_confidence_score")
        user_profile = await get_user_profile(claim["user_id"])
        confidence_score = (
            ai_result["visual_score"] * 0.6
            + exif_result["exif_score"] * 0.2
            + user_profile["trust_score"] * 0.2
        )
        decision = make_decision(confidence_score)

        refund_result = None
        if decision == "APPROVED":
            refund_result = await trigger_refund(
                claim_id=claim_id,
                order_id=claim["order_id"],
                amount=ai_result["refund_value"],
            )

        update_claim(claim_id, current_step="generating_report")
        await asyncio.sleep(0.5)

        decision_result = {
            "confidence_score": round(confidence_score, 4),
            "decision": decision,
            "visual_score": ai_result["visual_score"],
            "exif_score": exif_result["exif_score"],
            "trust_score": user_profile["trust_score"],
            "ai_explanation": ai_result["ai_explanation"],
            "damage_type": ai_result["damage_type"],
            "refund_value": ai_result["refund_value"],
            "coverage": ai_result["coverage"],
            "trust_profile": user_profile,
            "exif_validation": exif_result,
            "refund": refund_result,
            "anomalies": ai_result["anomalies"],
        }

        final_status = decision
        notification_message = {
            "APPROVED": "Refund claim approved automatically.",
            "NEEDS_REVIEW": "Claim needs seller review.",
            "REJECTED": "Claim rejected after automated validation.",
        }[decision]

        update_claim(
            claim_id,
            status=final_status,
            current_step="complete",
            decision_result=decision_result,
            analysis_started_at=claim.get("analysis_started_at") or now_iso(),
            completed_at=now_iso(),
        )
        await send_claim_notification(
            claim_id=claim_id,
            user_id=claim["user_id"],
            title=f"Claim {final_status}",
            body=notification_message,
        )
    except Exception as exc:  # pragma: no cover - defensive path
        update_claim(
            claim_id,
            status="ERROR",
            current_step="failed",
            error_message=str(exc),
        )


@app.get("/")
async def root() -> dict[str, Any]:
    return response_ok({"service": "Aura-Agent API"}, "Aura-Agent backend is running")


@app.get("/health")
async def health() -> dict[str, Any]:
    return response_ok({"healthy": True}, "Service healthy")


@app.post("/api/v1/upload/")
async def upload_file(file: UploadFile = File(...)) -> dict[str, Any]:
    file_record = await upload_to_gcs(file)
    return response_ok(
        {
            "file_id": file_record["file_id"],
            "filename": file_record["filename"],
            "content_type": file_record["content_type"],
            "signed_url": file_record["signed_url"],
            "gcs_uri": file_record["gcs_uri"],
            "size_bytes": file_record["size_bytes"],
        },
        "File uploaded successfully",
    )


@app.post("/api/v1/claims/")
async def create_claim_endpoint(payload: CreateClaimRequest) -> dict[str, Any]:
    for file_id in payload.file_ids:
        if not get_file(file_id):
            raise HTTPException(status_code=400, detail=f"Unknown file_id: {file_id}")

    claim = create_claim(
        user_id=payload.user_id,
        order_id=payload.order_id,
        claim_type=payload.claim_type,
        file_ids=payload.file_ids,
        voice_description=payload.voice_description or "",
    )
    await send_claim_notification(
        claim_id=claim["claim_id"],
        user_id=claim["user_id"],
        title="Claim Created",
        body=f"Claim {claim['claim_id'][:8]} has been created and queued for analysis.",
    )
    return response_ok(claim, "Claim created successfully")


@app.get("/api/v1/claims/")
async def list_claims_endpoint(user_id: str | None = None) -> dict[str, Any]:
    return response_ok(list_claims(user_id=user_id), "Claims fetched successfully")


@app.get("/api/v1/claims/{claim_id}")
async def get_claim_endpoint(claim_id: str) -> dict[str, Any]:
    claim = ensure_claim(claim_id)
    return response_ok(claim, "Claim fetched successfully")


@app.post("/api/v1/claims/{claim_id}/analyze")
async def analyze_claim(
    claim_id: str,
    background_tasks: BackgroundTasks,
) -> dict[str, Any]:
    claim = ensure_claim(claim_id)
    if claim["status"] == "PROCESSING":
        return response_ok(
            {
                "claim_id": claim_id,
                "status": claim["status"],
                "current_step": claim["current_step"],
                "updated_at": claim["updated_at"],
            },
            "Claim analysis already in progress",
        )

    mark_analysis_started(claim_id)
    background_tasks.add_task(run_analysis_pipeline, claim_id)
    claim = ensure_claim(claim_id)
    return response_ok(
        {
            "claim_id": claim_id,
            "status": claim["status"],
            "current_step": claim["current_step"],
            "updated_at": claim["updated_at"],
        },
        "Claim analysis started",
    )


@app.get("/api/v1/claims/{claim_id}/status")
async def get_claim_status(claim_id: str) -> dict[str, Any]:
    claim = ensure_claim(claim_id)
    return response_ok(
        {
            "claim_id": claim["claim_id"],
            "status": claim["status"],
            "current_step": claim["current_step"],
            "updated_at": claim["updated_at"],
        },
        "Claim status fetched successfully",
    )


@app.get("/api/v1/notifications/")
async def list_notifications_endpoint(user_id: str | None = None) -> dict[str, Any]:
    return response_ok(
        list_notifications(user_id=user_id),
        "Notifications fetched successfully",
    )


@app.post("/api/v1/claims/{claim_id}/override")
async def override_claim(
    claim_id: str,
    new_status: str = Form(...),
    seller_notes: str = Form(""),
) -> dict[str, Any]:
    ensure_claim(claim_id)
    update_claim(
        claim_id,
        status=new_status,
        current_step="complete",
        seller_notes=seller_notes,
    )
    claim = ensure_claim(claim_id)
    return response_ok(claim, "Claim overridden successfully")
