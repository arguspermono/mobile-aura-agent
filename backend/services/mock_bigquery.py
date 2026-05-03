import asyncio

async def get_risk_score(user_id: str) -> float:
    """
    Mock BigQuery query to get user fraud risk score based on historical claims.
    Score from 0.0 (High Risk/Fraudulent) to 1.0 (Low Risk/Trustworthy).
    """
    await asyncio.sleep(0.5)
    # Mock rule: user "bad_actor" is high risk, others are generally trustworthy
    if user_id == "bad_actor":
        return 0.2
    return 0.85
