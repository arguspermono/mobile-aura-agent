import asyncio
from datetime import datetime, timezone

from services.mock_firestore import add_notification


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


async def send_claim_notification(*, claim_id: str, user_id: str, title: str, body: str) -> None:
    await asyncio.sleep(0.1)
    add_notification(
        {
            "claim_id": claim_id,
            "user_id": user_id,
            "title": title,
            "body": body,
            "created_at": now_iso(),
        }
    )
