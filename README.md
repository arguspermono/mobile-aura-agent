# Aura-Agent

Aura-Agent is a demo implementation of an autonomous AI customer support agent for e-commerce claim resolution.

This repository contains:
- A Flutter frontend for Android/mobile-oriented claim submission and result tracking
- A FastAPI backend that simulates GCS upload, Gemini multimodal analysis, EXIF validation, BigQuery trust scoring, Firestore-style realtime status, Midtrans refund triggering, and FCM notifications

## Architecture

Frontend:
- Flutter
- `http` for API access
- `file_picker` for selecting evidence files
- Polling-based `FirestoreService` shim for realtime claim progress in mock mode

Backend:
- FastAPI
- Mock GCS, Firestore, BigQuery, Midtrans, and FCM services
- Pillow-based image metadata inspection hook for EXIF validation
- Cloud Run-ready Dockerfile scaffold

## API Contract

Base URL:
```text
http://127.0.0.1:8000/api/v1
```

Routes:
- `POST /upload/`
- `POST /claims/`
- `GET /claims/{claim_id}`
- `GET /claims/?user_id={uid}`
- `POST /claims/{claim_id}/analyze`
- `GET /claims/{claim_id}/status`

Response envelope:

```json
{
  "status": "ok|error",
  "data": {},
  "message": "Human readable message",
  "timestamp": "ISO8601"
}
```

Status pipeline used by the UI:
- `uploading_evidence`
- `analyzing_evidence`
- `detecting_damage_patterns`
- `calculating_confidence_score`
- `generating_report`
- `complete`
- `failed`

Decision thresholds:
- `>= 0.90` -> `APPROVED`
- `0.75 - 0.89` -> `NEEDS_REVIEW`
- `< 0.75` -> `REJECTED`

## Running The Backend Locally

From the repo root:

```powershell
cd backend
py -3.13 -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Health endpoints:
- `http://127.0.0.1:8000/health`
- `http://127.0.0.1:8000/docs`

## Running The Flutter App

From the repo root:

```powershell
flutter pub get
flutter run
```

Override the API URL with `dart-define` when needed:

```powershell
flutter run --dart-define=AURA_API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Recommended URLs:
- Android emulator: `http://10.0.2.2:8000/api/v1`
- Web/desktop on same machine: `http://127.0.0.1:8000/api/v1`
- Physical device: `http://<your-local-ip>:8000/api/v1`

## Demo Scenarios

Use filenames or text descriptions to force each path in mock mode:

- Auto approve:
  - Include `damaged`, `broken`, `defect`, or `crack`
- Needs review:
  - Include `ambiguous`, `unclear`, or `scratch`
- Rejected / fraud:
  - Include `fake`, `old`, `tampered`, or `manipulated`
- Missing item:
  - Include `missing`

Suggested demo:
1. Open the app
2. Tap `Create New Claim`
3. Choose `Product Defect`
4. Upload a file named `damaged-box.jpg`
5. Add description text containing `damaged`
6. Submit and watch the audit screen animate through the backend pipeline
7. Observe the `APPROVED` result with high confidence
8. Tap the final CTA to simulate refund processing

Fraud demo:
1. Upload `old-photo.jpg` or `manipulated-proof.png`
2. Submit any claim type
3. The EXIF validation step will lower the metadata score
4. Final decision becomes `REJECTED`

## Cloud Run Deployment

Build and deploy the backend:

```powershell
cd backend
gcloud builds submit --tag asia-southeast2-docker.pkg.dev/<PROJECT_ID>/aura-agent/backend
gcloud run deploy aura-agent-backend `
  --image asia-southeast2-docker.pkg.dev/<PROJECT_ID>/aura-agent/backend `
  --platform managed `
  --region asia-southeast2 `
  --allow-unauthenticated
```

If you prefer plain Docker:

```powershell
cd backend
docker build -t aura-agent-backend .
docker run -p 8000:8000 aura-agent-backend
```

## GCP Setup Reference

Enable these APIs in your Google Cloud project:
- Vertex AI API
- Firestore API
- BigQuery API
- Cloud Storage API
- Cloud Functions API
- Firebase Cloud Messaging / Firebase project integration

Recommended runtime service roles:
- `Vertex AI User`
- `Storage Admin`
- `BigQuery Data Viewer`
- `Cloud Datastore User`
- `Cloud Run Admin`
- `Service Account User`

## Environment Variables

Backend reference values are documented in [backend/.env.example](backend/.env.example).

Example categories:
- GCP project and region
- Bucket name
- Midtrans sandbox keys
- Firebase project values
- Mock mode toggle

Frontend:
- `AURA_API_BASE_URL` via `--dart-define`

## Notes

- The current implementation is a demo stack. External integrations are mocked but the API contract, UI state flow, and orchestration shape match the intended production architecture.
- The Flutter app currently uses a polling-based realtime shim instead of the Firebase SDK. That keeps the demo self-contained while preserving the same UI state flow.
