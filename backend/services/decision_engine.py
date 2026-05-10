def make_decision(confidence_score: float) -> str:
    if confidence_score >= 0.90:
        return "APPROVED"
    if confidence_score >= 0.75:
        return "NEEDS_REVIEW"
    return "REJECTED"
