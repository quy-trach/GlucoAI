from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="GlucoAI - Local Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models")

# Load Model (Thêm try-except để không crash nếu thiếu file)
try:
    preprocessor = joblib.load(os.path.join(MODEL_DIR, "preprocessor_optimal_20251220_103654.joblib"))
    xgb_model = joblib.load(os.path.join(MODEL_DIR, "xgb_model_20251220_103729.pkl"))
    print("✅ Đã tải Model & Preprocessor thành công!")
except:
    print("⚠️ Không tìm thấy Model! Đang chạy chế độ giả lập (Dummy Mode).")
    preprocessor = None
    xgb_model = None

class PatientData(BaseModel):
    HighBP: float; HighChol: float; CholCheck: float; BMI: float
    Smoker: float; Stroke: float; HeartDiseaseorAttack: float
    PhysActivity: float; Fruits: float; Veggies: float
    HvyAlcoholConsump: float; AnyHealthcare: float; NoDocbcCost: float
    GenHlth: float; MentHlth: float; PhysHlth: float; DiffWalk: float
    Sex: float; Age: float; Education: float; Income: float

@app.post("/predict")
def predict_diabetes(data: PatientData):
    input_dict = data.dict()
    print(f"📥 Nhận dữ liệu từ App: BMI={input_dict['BMI']}, Tuổi={input_dict['Age']}")

    # 1. Tính điểm rủi ro (Risk Score)
    risk_score = 0
    if input_dict['HighBP'] == 1: risk_score += 3
    if input_dict['HighChol'] == 1: risk_score += 3
    if input_dict['BMI'] >= 30: risk_score += 3
    if input_dict['GenHlth'] >= 4: risk_score += 2
    if input_dict['Age'] >= 9: risk_score += 2
    if input_dict['HeartDiseaseorAttack'] == 1: risk_score += 2
    if input_dict['PhysHlth'] >= 15: risk_score += 1
    if input_dict['DiffWalk'] == 1: risk_score += 1

    # 2. AI Dự đoán (Lấy số lẻ)
    ai_prob = 0.5
    if xgb_model:
        cols = ["HighBP", "HighChol", "CholCheck", "BMI", "Smoker", "Stroke", 
                "HeartDiseaseorAttack", "PhysActivity", "Fruits", "Veggies", 
                "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", "GenHlth", 
                "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", "Education", "Income"]
        df = pd.DataFrame([input_dict])[cols]
        processed = preprocessor.transform(df) if preprocessor else df.values
        ai_prob = float(xgb_model.predict_proba(processed)[0][1])

    # 3. CÔNG THỨC PHA TRỘN (Đảm bảo ra số tự nhiên)
    # Tỷ lệ: 70% tin AI + 30% tin vào Risk Score
    clinical_prob = min(risk_score / 18.0, 1.0)
    
    final_prob = (ai_prob * 0.7) + (clinical_prob * 0.3)

    # In ra Terminal để kiểm chứng số lẻ
    print(f"🧮 TÍNH TOÁN: AI({ai_prob:.3f}) + Risk({clinical_prob:.3f}) = FINAL({final_prob:.3f})")

    # 4. Phân loại kết quả
    if final_prob < 0.35:
        level, label, color = 0, "An toàn", "#4CAF50"
        advice = "Chỉ số rất tốt. Hãy duy trì nhé!"
    elif final_prob < 0.65:
        level, label, color = 1, "Cảnh báo", "#FFC107"
        advice = "Có nguy cơ. Nên thay đổi lối sống ngay."
    else:
        level, label, color = 2, "Nguy cơ cao", "#F44336"
        advice = "Nguy hiểm! Cần đi khám bác sĩ."

    return {
        "prediction_level": level,
        "prob_risk": final_prob, 
        "prob_safe": 1.0 - final_prob,
        "label": label,
        "color_hex": color,
        "advice": advice
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)