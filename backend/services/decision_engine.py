from typing import Tuple

def make_decision(ai_confidence: float, risk_score: float, exif_valid: bool) -> Tuple[str, str]:
    """
    Confidence-Based Decision Engine.
    Returns: (decision_action, final_status)
    """
    if not exif_valid:
        return "REJECTED_METADATA_INVALID", "REJECTED"

    # High Confidence: Trigger autonomous refund
    # Requires good AI confidence (>0.8) and low risk user (risk score > 0.7)
    if ai_confidence > 0.8 and risk_score > 0.7:
        return "REFUND_APPROVED", "APPROVED"

    # Medium Confidence: Flag for manual review
    if ai_confidence > 0.4:
        return "MANUAL_REVIEW", "PENDING_REVIEW"

    # Low Confidence or High Risk User: Automatic rejection or request evidence
    return "REQUEST_ADDITIONAL_EVIDENCE", "AWAITING_USER_INPUT"
