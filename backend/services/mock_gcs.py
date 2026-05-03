import asyncio
from fastapi import UploadFile

async def upload_to_gcs(file: UploadFile) -> str:
    """Mock uploading a file to Google Cloud Storage."""
    await asyncio.sleep(0.5)
    return f"gs://mock-bucket-aura-agent/{file.filename}"
