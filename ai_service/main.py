from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
from fastapi.middleware.cors import CORSMiddleware # Thêm dòng này

# =======================================================
# CONFIG & KHỞI TẠO
# =======================================================
app = FastAPI(title="GlucoAI - Hugging Face Cloud")

# Cấu hình CORS để App Flutter có thể kết nối
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cho phép tất cả các nguồn
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Sử dụng đường dẫn tương đối dựa trên vị trí file hiện tại
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models")

print("⏳ Đang khởi động Server và tải Model...")

preprocessor = None
xgb_model = None

# =======================================================
# 1. LOAD MODEL
# =======================================================
try:
    prep_path = os.path.join(MODEL_DIR, "preprocessor_optimal_20251220_103654.joblib")
    if os.path.exists(prep_path):
        raw_prep = joblib.load(prep_path)
        if hasattr(raw_prep, "transform"):
            preprocessor = raw_prep
        elif isinstance(raw_prep, list):
            for item in raw_prep:
                if hasattr(item, "transform") or hasattr(item, "fit_transform"):
                    preprocessor = item
                    break
        print("✅ Đã tải Preprocessor.")

    model_path = os.path.join(MODEL_DIR, "xgb_model_20251220_103729.pkl")
    if os.path.exists(model_path):
        xgb_model = joblib.load(model_path)
        print("✅ Đã tải XGBoost Model.")
except Exception as e:
    print(f"❌ LỖI KHỞI TẠO: {e}")

# Thêm endpoint này để kiểm tra trên trình duyệt
@app.get("/")
def home():
    return {"message": "GlucoAI Service is Running!", "model_loaded": xgb_model is not None}

# =======================================================
# 2. DATA MODEL
# =======================================================
class PatientData(BaseModel):
    HighBP: float
    HighChol: float
    CholCheck: float
    BMI: float
    Smoker: float
    Stroke: float
    HeartDiseaseorAttack: float
    PhysActivity: float
    Fruits: float
    Veggies: float
    HvyAlcoholConsump: float
    AnyHealthcare: float
    NoDocbcCost: float
    GenHlth: float
    MentHlth: float
    PhysHlth: float
    DiffWalk: float
    Sex: float
    Age: float
    Education: float
    Income: float

# =======================================================
# 3. API DỰ ĐOÁN (Giữ nguyên logic của bạn)
# =======================================================
@app.post("/predict")
def predict_diabetes(data: PatientData):
    input_dict = data.dict()
    
    # Logic tính Risk Score
    risk_score = 0
    if input_dict['BMI'] >= 30: risk_score += 2
    if input_dict['HighBP'] == 1: risk_score += 2
    if input_dict['HeartDiseaseorAttack'] == 1: risk_score += 3
    if input_dict['GenHlth'] >= 4: risk_score += 2 
    
    age_val = input_dict['Age']
    is_old = False
    if age_val > 1000: 
        if (2025 - age_val) >= 55:
            risk_score += 2
            is_old = True
    elif age_val >= 8:
        risk_score += 2
        is_old = True

    prob_risk = 0.25 
    
    try:
        if xgb_model and preprocessor:
            cols = ["HighBP", "HighChol", "CholCheck", "BMI", "Smoker", 
                    "Stroke", "HeartDiseaseorAttack", "PhysActivity", "Fruits", 
                    "Veggies", "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", 
                    "GenHlth", "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", 
                    "Education", "Income"]
            df = pd.DataFrame([input_dict])[cols]
            
            try:
                processed_data = preprocessor.transform(df)
            except:
                features = df.values
                zeros = np.zeros((1, 26 - features.shape[1]))
                processed_data = np.hstack((features, zeros))

            probs = xgb_model.predict_proba(processed_data)
            prob_risk = float(probs[0][1])

    except Exception as e:
        print(f"❌ Lỗi AI: {e}")

    final_prob = prob_risk

    if risk_score >= 5:
        final_prob = max(final_prob, 0.75)
    elif 3 <= risk_score <= 4:
        if final_prob < 0.35: final_prob = 0.45
        elif final_prob >= 0.50: final_prob = 0.49
    elif risk_score < 3 and not is_old:
        final_prob = min(final_prob, 0.15)

    prob_safe = 1.0 - final_prob
    
    if final_prob < 0.30:
        level, label, color = 0, "An toàn", "#4CAF50"
        advice = "Chỉ số tốt! Hãy duy trì lối sống lành mạnh."
    elif final_prob < 0.50:
        level, label, color = 1, "Cảnh báo", "#FFC107"
        advice = "Có dấu hiệu rủi ro. Nên giảm đường/tinh bột và tập thể dục."
    else:
        level, label, color = 2, "Nguy cơ cao", "#F44336"
        advice = "Nguy cơ tiểu đường cao. Bạn cần đi khám bác sĩ chuyên khoa."

    return {
        "status": "success",
        "prediction_level": level,
        "prob_risk": final_prob,
        "prob_safe": prob_safe,
        "label": label,
        "advice": advice,
        "color_hex": color
    }