# Aura-Agent: AI-powered Autonomous Complaint Resolution System

Aura-Agent is an end-to-end prototype for automating customer complaint resolution using Multimodal AI (Vertex AI Gemini), BigQuery risk scoring, and Google Cloud Storage.

This project is divided into:
- **Frontend:** A Flutter application (Customer Portal & Seller Dashboard)
- **Backend:** A FastAPI application orchestrating the decision flow.

## Prerequisites & Google Cloud Setup

To fully run the real integrations (beyond the current Mock Mode), you need to configure your GCP Environment:

1. **Create a Google Cloud Project** with an active Billing Account.
2. **Enable APIs** in the GCP Console:
   - Vertex AI API
   - Cloud Storage API
   - BigQuery API
   - Firestore API
   - Cloud Speech-to-Text API
3. **Create a Service Account:**
   - Go to IAM & Admin > Service Accounts.
   - Create a new service account with roles: `Storage Admin`, `Vertex AI User`, `BigQuery Data Viewer`, `Cloud Datastore User`.
   - Create a JSON key and download it to your machine (e.g., `credentials.json`).
4. **Set Environment Variable:**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"
   ```

## Running the Backend (FastAPI)

1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Run the FastAPI server:
   ```bash
   uvicorn main:app --reload --host 127.0.0.1 --port 8000
   ```

## Running the Frontend (Flutter)

1. Ensure the backend is running.
2. Open another terminal in the root project folder:
   ```bash
   flutter pub get
   flutter run -d chrome  # Run on Web, or specify your emulator
   ```
3. **Important:** If running on a physical Android device or Web, the `baseUrl` in `lib/services/api_service.dart` needs to be updated to your machine's local IP address (e.g., `http://192.168.1.5:8000/api/v1`). For Android emulator, use `http://10.0.2.2:8000/api/v1`. The current default is `127.0.0.1`.

## Testing the Flow

1. **Customer Upload:** Go to the Customer Portal, select an image/video file, type a description containing the word `"broken"` (to trigger the mocked high-confidence AI response), and submit.
2. **Seller Dashboard:** Go to the Seller Dashboard, watch the claim appear as `PENDING`, transition to `PROCESSING`, and finally `APPROVED` based on the AI's autonomous decision.
