import uuid
from datetime import datetime, timezone
from typing import Any


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


FILES_DB: dict[str, dict[str, Any]] = {}
CLAIMS_DB: dict[str, dict[str, Any]] = {}
NOTIFICATIONS_DB: list[dict[str, Any]] = []


def create_file(
    *,
    filename: str,
    content_type: str,
    size_bytes: int,
    gcs_uri: str,
    signed_url: str,
    content: bytes,
) -> dict[str, Any]:
    file_id = str(uuid.uuid4())
    record = {
        "file_id": file_id,
        "filename": filename,
        "content_type": content_type,
        "size_bytes": size_bytes,
        "gcs_uri": gcs_uri,
        "signed_url": signed_url,
        "uploaded_at": now_iso(),
        "content": content,
    }
    FILES_DB[file_id] = record
    return record


def get_file(file_id: str) -> dict[str, Any] | None:
    return FILES_DB.get(file_id)


def create_claim(
    *,
    user_id: str,
    order_id: str,
    claim_type: str,
    file_ids: list[str],
    voice_description: str,
) -> dict[str, Any]:
    claim_id = str(uuid.uuid4())
    claim = {
        "claim_id": claim_id,
        "user_id": user_id,
        "order_id": order_id,
        "claim_type": claim_type,
        "file_ids": file_ids,
        "voice_description": voice_description,
        "status": "PENDING",
        "current_step": "pending",
        "created_at": now_iso(),
        "updated_at": now_iso(),
        "decision_result": None,
        "analysis_started_at": None,
        "completed_at": None,
        "seller_notes": "",
        "error_message": None,
    }
    CLAIMS_DB[claim_id] = claim
    return claim


def get_claim(claim_id: str) -> dict[str, Any] | None:
    return CLAIMS_DB.get(claim_id)


def list_claims(*, user_id: str | None = None) -> list[dict[str, Any]]:
    claims = list(CLAIMS_DB.values())
    if user_id:
        claims = [claim for claim in claims if claim["user_id"] == user_id]
    return sorted(claims, key=lambda item: item["created_at"], reverse=True)


def update_claim(claim_id: str, **fields: Any) -> dict[str, Any]:
    claim = CLAIMS_DB[claim_id]
    claim.update(fields)
    claim["updated_at"] = now_iso()
    return claim


def mark_analysis_started(claim_id: str) -> dict[str, Any]:
    return update_claim(
        claim_id,
        status="PROCESSING",
        current_step="uploading_evidence",
        analysis_started_at=now_iso(),
        error_message=None,
    )


def add_notification(notification: dict[str, Any]) -> None:
    NOTIFICATIONS_DB.append(notification)
