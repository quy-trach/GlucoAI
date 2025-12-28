# 🏥 GlucoAI - Hệ Thống Dự Đoán Nguy Cơ Tiểu Đường

GlucoAI là một ứng dụng di động tích hợp trí tuệ nhân tạo (AI) giúp người dùng dự đoán nguy cơ mắc bệnh tiểu đường dựa trên các chỉ số sức khỏe cá nhân.

## 🚀 Kiến Trúc Dự Án

Dự án được chia làm hai phần chính:
* **Mobile App**: Phát triển bằng **Flutter**, cung cấp giao diện người dùng thân thiện.
* **AI Service**: Phát triển bằng **FastAPI**, triển khai mô hình **XGBoost** để đưa ra dự đoán.

---

## 🛠 Công Nghệ Sử Dụng

### Frontend (Mobile)
* **Framework**: Flutter
* **State Management**: Provider/Bloc (tùy chỉnh)
* **Communication**: HTTP (REST API)

### Backend (AI Service)
* **Language**: Python 3.9+
* **Framework**: FastAPI
* **AI Library**: XGBoost, Scikit-learn, Pandas
* **Deployment**: Hugging Face Spaces (Docker)

---

## 📂 Cấu Trúc Thư Mục

```text
GlucoAI/
├── mobile_app/          # Mã nguồn ứng dụng Flutter
├── ai_service/          # Mã nguồn Backend & AI Model
│   ├── models/          # Chứa file model .pkl hoặc .joblib
│   ├── main.py          # API khởi tạo bởi FastAPI
│   ├── requirements.txt # Danh sách thư viện Python
│   └── Dockerfile       # Cấu hình triển khai Hugging Face
└── README.md            # Tài liệu hướng dẫn dự án
