import asyncio
from typing import Tuple, List

async def analyze_media(media_urls: List[str], text_description: str) -> Tuple[float, str, List[str]]:
    """
    Mock Vertex AI (Gemini 3.1 Pro) analysis for multimodal anomaly detection.
    Returns: (confidence_score, explanation, anomalies_detected)
    """
    await asyncio.sleep(2) # Simulate heavy AI inference
    
    # Simple rule for mocking: if description contains "broken", high confidence anomaly
    if "broken" in text_description.lower() or "damaged" in text_description.lower():
        return 0.92, "Visual analysis of video frame 00:12 matches audio description: 'broken seal detected'. Box appears crushed on the corner.", ["broken seal", "crushed box"]
    elif "missing" in text_description.lower():
        return 0.85, "Visual contents of unboxing video show 2 items, receipt claims 3. Missing item confirmed.", ["missing item"]
    else:
        # Ambiguous or no clear issue
        return 0.45, "No clear visual evidence of damage in the provided media. User claim is ambiguous.", []
