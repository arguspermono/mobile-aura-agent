import asyncio
import random


_rng = random.Random(42)
MOCK_USERS: dict[str, dict[str, float | int | str]] = {}

for index in range(1, 51):
    user_id = f"demo-user-{index:03d}"
    trust_score = round(_rng.uniform(0.35, 0.98), 2)
    claim_history = _rng.randint(0, 6)
    approved_claims = _rng.randint(0, claim_history) if claim_history > 0 else 0
    MOCK_USERS[user_id] = {
        "user_id": user_id,
        "trust_score": trust_score,
        "claim_history": claim_history,
        "approved_claims": approved_claims,
        "risk_tier": "trusted" if trust_score >= 0.75 else "watchlist",
    }

MOCK_USERS["bad_actor"] = {
    "user_id": "bad_actor",
    "trust_score": 0.18,
    "claim_history": 9,
    "approved_claims": 1,
    "risk_tier": "high_risk",
}


async def get_user_profile(user_id: str) -> dict[str, float | int | str]:
    await asyncio.sleep(0.3)
    return MOCK_USERS.get(
        user_id,
        {
            "user_id": user_id,
            "trust_score": 0.72,
            "claim_history": 1,
            "approved_claims": 1,
            "risk_tier": "new_user",
        },
    )
