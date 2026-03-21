
🏥 GlucoAI - Diabetes Risk Prediction System
GlucoAI is an AI-integrated mobile application designed to help users assess their risk of diabetes based on personal health metrics.

<img width="2752" height="1536" alt="glucoai" src="https://github.com/user-attachments/assets/b69668c3-dd6a-4415-a713-46e9ca6dd8e7" />

🚀 System Architecture
The project is architected into two main components:

Mobile App: Built with Flutter, providing a seamless and intuitive user experience.

AI Service: Developed using FastAPI, deploying an XGBoost model to deliver real-time risk predictions.

🛠 Tech Stack
Frontend (Mobile)
Framework: Flutter

State Management: Provider / BLoC

Communication: RESTful API (HTTP)

Backend (AI Service)
Language: Python 3.9+

Framework: FastAPI

Machine Learning: XGBoost, Scikit-learn, Pandas

Deployment: Dockerized on Hugging Face Spaces

🖼 UI & System Preview
📱 1. Home Dashboard
<p align="center">
<img width="300" alt="home-interface" src="https://github.com/user-attachments/assets/c0074e71-858a-4cf0-b877-b0a4678db01b" />
</p>

📊 2. Prediction Results
<p align="center">
<img width="300" alt="prediction-results" src="https://github.com/user-attachments/assets/fd38c242-4b4e-48e8-b5aa-7be7e5a08283" />
</p>

🧠 3. Assessment History
<p align="center">
<img width="300" alt="survey-history" src="https://github.com/user-attachments/assets/ca5dc99b-0714-4b07-9ae6-43873b89614a" />
</p>

🚀 4. Settings
<p align="center">
<img width="300" alt="settings" src="https://github.com/user-attachments/assets/10aefb2d-c947-4cbd-a99e-a74b34ebe66f" />
</p>

📂 Project Structure
Plaintext
GlucoAI/
├── mobile_app/          # Flutter source code
├── ai_service/          # Backend & AI Model source code
│   ├── models/          # Serialized models (.pkl or .joblib)
│   ├── main.py          # FastAPI entry point
│   ├── requirements.txt # Python dependencies
│   └── Dockerfile       # Deployment configuration for Hugging Face
└── README.md            # Project documentation
