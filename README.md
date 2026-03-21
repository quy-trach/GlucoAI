# 🏥 GlucoAI - Hệ Thống Dự Đoán Nguy Cơ Tiểu Đường

GlucoAI là một ứng dụng di động tích hợp trí tuệ nhân tạo (AI) giúp người dùng dự đoán nguy cơ mắc bệnh tiểu đường dựa trên các chỉ số sức khỏe cá nhân.

<img width="2752" height="1536" alt="glucoai" src="https://github.com/user-attachments/assets/b69668c3-dd6a-4415-a713-46e9ca6dd8e7" />

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
## 🖼 Giao Diện & Minh Họa Hệ Thống

### 📱 1. Giao diện trang chủ
<p align="center">
<img width="300" alt="image" src="https://github.com/user-attachments/assets/c0074e71-858a-4cf0-b877-b0a4678db01b" />
</p>
---

### 📊 2. Kết quả dự đoán nguy cơ tiểu đường
<p align="center">
<img  width="300" alt="image" src="https://github.com/user-attachments/assets/fd38c242-4b4e-48e8-b5aa-7be7e5a08283" />
</p>
---

### 🧠 3. Lịch sử khảo sát
<p align="center">
<img width="300" alt="image" src="https://github.com/user-attachments/assets/ca5dc99b-0714-4b07-9ae6-43873b89614a" />
</p>
---

### 🚀 4. Setting
<p align="center">
<img width="300" alt="image" src="https://github.com/user-attachments/assets/10aefb2d-c947-4cbd-a99e-a74b34ebe66f" />
</p>
 ---
## 📂 Cấu Trúc Thư Mục

```text
GlucoAI/
├── mobile_app/          # Mã nguồn ứng dụng Flutter
├── ai_service/          # Mã nguồn Backend & AI Model
│   ├── models/          # Chứa file model .pkl hoặc .joblib
│   ├── main.py          # API khởi tạo bởi FastAPI
│   ├── requirements.txt # Danh sách thư viện Python
│   └── Dockerfile       # Cấu hình triển khai Hugging Face
└── README.md            # Tài liệu hướng dẫn dự án

viết lại cái này thành tiếng anh cho chuyên nghiệp hơn ảnh giữ nguyên nhé
