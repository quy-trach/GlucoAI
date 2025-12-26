from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import numpy as np
import os
import sklearn
from sklearn.base import BaseEstimator, TransformerMixin

# =======================================================
# CONFIG & KHỞI TẠO
# =======================================================
app = FastAPI(title="GlucoAI - 3 Level Hybrid System")

MODEL_DIR = "models"
print("⏳ Đang khởi động Server...")

preprocessor = None
xgb_model = None

# =======================================================
# 1. LOAD MODEL (LOGIC VÉT CẠN TÌM PREPROCESSOR)
# =======================================================
try:
    # --- Load Preprocessor ---
    prep_path = os.path.join(MODEL_DIR, "preprocessor_optimal_20251220_103654.joblib")
    
    if os.path.exists(prep_path):
        raw_prep = joblib.load(prep_path)
        
        # Logic tìm transformer trong List hoặc Object
        if hasattr(raw_prep, "transform"):
            preprocessor = raw_prep
        elif isinstance(raw_prep, list):
            for item in raw_prep:
                if hasattr(item, "transform") or hasattr(item, "fit_transform"):
                    preprocessor = item
                    break
            if preprocessor is None and len(raw_prep) > 0:
                preprocessor = raw_prep[0]
        print("✅ Đã tải Preprocessor.")
    else:
        print(f"⚠️ Không tìm thấy file Preprocessor: {prep_path}")

    # --- Load XGBoost ---
    model_path = os.path.join(MODEL_DIR, "xgb_model_20251220_103729.pkl")
    if os.path.exists(model_path):
        xgb_model = joblib.load(model_path)
        print("✅ Đã tải XGBoost Model.")
    else:
        print(f"⚠️ Không tìm thấy file Model: {model_path}")

except Exception as e:
    print(f"❌ LỖI KHỞI TẠO: {e}")

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
# 3. API DỰ ĐOÁN (CORE LOGIC)
# =======================================================
@app.post("/predict")
def predict_diabetes(data: PatientData):
    input_dict = data.dict()
    
    # ---------------------------------------------------
    # A. TÍNH ĐIỂM RỦI RO (RULE-BASED)
    # ---------------------------------------------------
    risk_score = 0
    if input_dict['BMI'] >= 30: risk_score += 2
    if input_dict['HighBP'] == 1: risk_score += 2
    if input_dict['HeartDiseaseorAttack'] == 1: risk_score += 3
    if input_dict['GenHlth'] >= 4: risk_score += 2 
    
    # Xử lý tuổi: Năm sinh hoặc Nhóm tuổi
    age_val = input_dict['Age']
    is_old = False
    if age_val > 1000: # Năm sinh
        if (2025 - age_val) >= 55:
            risk_score += 2
            is_old = True
    elif age_val >= 8: # Nhóm tuổi (8 ~ 55 tuổi)
        risk_score += 2
        is_old = True

    # ---------------------------------------------------
    # B. CHẠY MODEL AI
    # ---------------------------------------------------
    prob_risk = 0.25 # Giá trị mặc định an toàn
    
    try:
        if xgb_model and preprocessor:
            cols = ["HighBP", "HighChol", "CholCheck", "BMI", "Smoker", 
                    "Stroke", "HeartDiseaseorAttack", "PhysActivity", "Fruits", 
                    "Veggies", "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", 
                    "GenHlth", "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", 
                    "Education", "Income"]
            df = pd.DataFrame([input_dict])[cols]
            
            # Transform
            try:
                processed_data = preprocessor.transform(df)
            except:
                # Fallback: Chèn số 0 nếu lỗi shape
                features = df.values
                zeros = np.zeros((1, 26 - features.shape[1]))
                processed_data = np.hstack((features, zeros))

            # Predict
            probs = xgb_model.predict_proba(processed_data)
            prob_risk = float(probs[0][1])
            print(f"🤖 AI Output: {prob_risk:.4f}")

    except Exception as e:
        print(f"❌ Lỗi AI: {e}")

    # ---------------------------------------------------
    # C. HYBRID LOGIC (KẾT HỢP ĐỂ RA 3 MÀU)
    # ---------------------------------------------------
    final_prob = prob_risk

    # 1. NGUY HIỂM (ĐỎ): Risk >= 5
    if risk_score >= 5:
        print("🔴 Risk cao -> Ép NGUY HIỂM.")
        final_prob = max(final_prob, 0.75)

    # 2. CẢNH BÁO (VÀNG): Risk 3 hoặc 4
    # Ép xác suất vào khoảng 0.35 - 0.49
    elif 3 <= risk_score <= 4:
        print("🟡 Risk trung bình -> Ép CẢNH BÁO.")
        if final_prob < 0.35: final_prob = 0.45
        elif final_prob >= 0.50: final_prob = 0.49

    # 3. AN TOÀN (XANH): Risk < 3 và Không già
    elif risk_score < 3 and not is_old:
        print("🟢 Risk thấp -> Ép AN TOÀN.")
        final_prob = min(final_prob, 0.15)

    # ---------------------------------------------------
    # D. PHÂN LOẠI & LỜI KHUYÊN
    # ---------------------------------------------------
    prob_safe = 1.0 - final_prob
    
    # Logic phân ngưỡng 3 mức
    if final_prob < 0.30:
        level = 0
        label = "An toàn"
        advice = "Chỉ số tốt! Hãy duy trì lối sống lành mạnh."
        color = "#4CAF50"
    elif final_prob < 0.50:
        level = 1
        label = "Cảnh báo"
        advice = "Có dấu hiệu rủi ro. Nên giảm đường/tinh bột và tập thể dục."
        color = "#FFC107"
    else:
        level = 2
        label = "Nguy cơ cao"
        advice = "Nguy cơ tiểu đường cao. Bạn cần đi khám bác sĩ chuyên khoa."
        color = "#F44336"

    return {
        "status": "success",
        "prediction_level": level,
        "prob_risk": final_prob,
        "prob_safe": prob_safe,
        "label": label,
        "advice": advice,
        "color_hex": color,
        "risk_score_debug": risk_score
    }