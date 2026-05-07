import asyncio
from datetime import datetime, timezone


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


async def trigger_refund(*, claim_id: str, order_id: str, amount: int) -> dict[str, object]:
    await asyncio.sleep(0.5)
    return {
        "gateway": "midtrans-sandbox",
        "claim_id": claim_id,
        "order_id": order_id,
        "refund_amount": amount,
        "status": "processing",
        "reference_id": f"refund-{claim_id[:8]}",
        "processed_at": now_iso(),
    }
