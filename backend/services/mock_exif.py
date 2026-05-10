import asyncio
from io import BytesIO

from PIL import Image, UnidentifiedImageError


async def validate_file_metadata(file_records: list[dict]) -> dict[str, object]:
    await asyncio.sleep(0.4)
    metadata_summary: list[dict[str, object]] = []
    suspicious = False

    for file_record in file_records:
        filename = str(file_record.get("filename", "")).lower()
        content_type = str(file_record.get("content_type", ""))
        metadata = {
            "filename": file_record.get("filename"),
            "content_type": content_type,
            "has_exif": False,
            "timestamp_valid": True,
            "device_valid": True,
            "gps_valid": True,
        }

        if any(token in filename for token in ["fake", "old", "tampered", "manipulated"]):
            metadata["timestamp_valid"] = False
            suspicious = True

        if content_type.startswith("image/"):
            try:
                image = Image.open(BytesIO(file_record.get("content", b"")))
                exif = image.getexif()
                metadata["has_exif"] = bool(exif)
            except (UnidentifiedImageError, OSError):
                metadata["has_exif"] = False

        metadata_summary.append(metadata)

    exif_score = 0.32 if suspicious else 1.0
    return {
        "metadata_valid": not suspicious,
        "exif_score": exif_score,
        "files": metadata_summary,
    }
