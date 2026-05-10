import asyncio

from fastapi import UploadFile

from services.mock_firestore import create_file, get_file


async def upload_to_gcs(file: UploadFile) -> dict[str, str | int]:
    await asyncio.sleep(0.3)
    content = await file.read()
    filename = file.filename or "evidence.bin"
    gcs_uri = f"gs://mock-bucket-aura-agent/uploads/{filename}"
    signed_url = f"https://storage.googleapis.com/mock-bucket-aura-agent/uploads/{filename}"
    return create_file(
        filename=filename,
        content_type=file.content_type or "application/octet-stream",
        size_bytes=len(content),
        gcs_uri=gcs_uri,
        signed_url=signed_url,
        content=content,
    )


async def fetch_files(file_ids: list[str]) -> list[dict[str, str | int | bytes]]:
    await asyncio.sleep(0.2)
    return [get_file(file_id) for file_id in file_ids if get_file(file_id) is not None]
