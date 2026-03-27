import os
import joblib
import pandas as pd
import numpy as np
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
from sklearn.base import BaseEstimator, TransformerMixin

# =======================================================
# CẤU HÌNH APP
# =======================================================
app = FastAPI(
    title="GlucoAI Service",
    description="API dự đoán nguy cơ tiểu đường (Hybrid AI + Rules)",
    version="2.0.0"
)

# TÊN FILE MODEL (Đảm bảo chính xác 100% với tên file bạn có)
PREPROCESSOR_FILENAME = "preprocessor_optimal_20251220_103654.joblib"
MODEL_FILENAME = "xgb_model_20251220_103729.pkl"

# =======================================================
# 1. TỰ ĐỘNG CẤU HÌNH ĐƯỜNG DẪN (LOCAL vs DOCKER)
# =======================================================
MODEL_DIR = "." # Mặc định là root (cho Docker)

# Kiểm tra nếu đang chạy local và có thư mục 'models'
if os.path.exists(os.path.join("models", PREPROCESSOR_FILENAME)):
    MODEL_DIR = "models"
    print(f"🖥️  PHÁT HIỆN MÔI TRƯỜNG: LOCAL (Thư mục '{MODEL_DIR}')")
elif os.path.exists(PREPROCESSOR_FILENAME):
    MODEL_DIR = "."
    print(f"☁️  PHÁT HIỆN MÔI TRƯỜNG: DOCKER / CLOUD (Thư mục gốc)")
else:
    print("⚠️ CẢNH BÁO: Không tìm thấy file model ở đâu cả!")

# =======================================================
# 2. LOAD MODEL & XỬ LÝ LỖI (DICT/LIST)
# =======================================================
preprocessor = None
xgb_model = None

def load_ai_assets():
    global preprocessor, xgb_model
    try:
        # --- A. LOAD PREPROCESSOR ---
        prep_path = os.path.join(MODEL_DIR, PREPROCESSOR_FILENAME)
        if os.path.exists(prep_path):
            raw_prep = joblib.load(prep_path)
            
            # Xử lý trường hợp lưu dưới dạng Dictionary
            if isinstance(raw_prep, dict):
                print("⚠️ Preprocessor là DICT. Đang trích xuất...")
                # Ưu tiên các key thường dùng
                if "scaler" in raw_prep: preprocessor = raw_prep["scaler"]
                elif "preprocessor" in raw_prep: preprocessor = raw_prep["preprocessor"]
                else:
                    # Quét toàn bộ values để tìm object có hàm transform
                    for k, v in raw_prep.items():
                        if hasattr(v, "transform"):
                            preprocessor = v
                            print(f"✅ Tìm thấy Transformer tại key: {k}")
                            break
            
            # Xử lý trường hợp lưu dưới dạng List
            elif isinstance(raw_prep, list):
                print("⚠️ Preprocessor là LIST. Đang trích xuất...")
                for item in raw_prep:
                    if hasattr(item, "transform"):
                        preprocessor = item
                        break
                if preprocessor is None and raw_prep: 
                    preprocessor = raw_prep[0] # Fallback lấy cái đầu
            
            # Trường hợp chuẩn
            elif hasattr(raw_prep, "transform"):
                preprocessor = raw_prep
            
            if preprocessor: print("✅ Preprocessor: OK")
            else: print("❌ Preprocessor: LỖI (Không tìm thấy object transform)")
        else:
            print(f"❌ Không tìm thấy file: {prep_path}")

        # --- B. LOAD XGBOOST ---
        mod_path = os.path.join(MODEL_DIR, MODEL_FILENAME)
        if os.path.exists(mod_path):
            xgb_model = joblib.load(mod_path)
            print("✅ XGBoost Model: OK")
        else:
            print(f"❌ Không tìm thấy file: {mod_path}")

    except Exception as e:
        print(f"🔥 CRITICAL ERROR khi load model: {e}")

# Gọi hàm load ngay khi khởi động
load_ai_assets()

# =======================================================
# 3. ĐỊNH NGHĨA DỮ LIỆU ĐẦU VÀO (SCHEMA)
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
# 4. API ENDPOINT
# =======================================================
@app.get("/")
def health_check():
    return {"status": "running", "model_dir": MODEL_DIR}

@app.post("/predict")
def predict_diabetes(data: PatientData):
    input_dict = data.dict()
    
    # --- BƯỚC 1: TÍNH ĐIỂM CHUYÊN GIA (RISK SCORE) ---
    risk_score = 0
    if input_dict['BMI'] >= 30: risk_score += 2
    if input_dict['HighBP'] == 1: risk_score += 2
    if input_dict['HeartDiseaseorAttack'] == 1: risk_score += 3
    if input_dict['GenHlth'] >= 4: risk_score += 2
    
    # Xử lý Logic Tuổi (Năm sinh vs Thang đo)
    age_val = input_dict['Age']
    is_old = False
    current_year = 2026 
    
    if age_val > 1000: # Nhập năm sinh (VD: 1970)
        if (current_year - age_val) >= 55:
            risk_score += 2
            is_old = True
    elif age_val >= 8: # Nhập thang đo (1-13)
        risk_score += 2
        is_old = True

    # --- BƯỚC 2: AI DỰ ĐOÁN (MẶC ĐỊNH) ---
    prob_safe = 0.80
    prob_risk = 0.20
    
    try:
        if xgb_model:
            # Tạo DataFrame đúng thứ tự cột lúc train
            cols = ["HighBP", "HighChol", "CholCheck", "BMI", "Smoker", 
                    "Stroke", "HeartDiseaseorAttack", "PhysActivity", "Fruits", 
                    "Veggies", "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost", 
                    "GenHlth", "MentHlth", "PhysHlth", "DiffWalk", "Sex", "Age", 
                    "Education", "Income"]
            df = pd.DataFrame([input_dict])[cols]
            
            # Transform dữ liệu
            processed_data = None
            if preprocessor:
                try:
                    processed_data = preprocessor.transform(df)
                except Exception as p_err:
                    print(f"⚠️ Transform lỗi: {p_err}. Dùng Raw Data.")
            
            # Fallback nếu transform lỗi hoặc null
            if processed_data is None:
                features = df.values
                # Nếu model cần nhiều cột hơn (do OneHot), bù thêm số 0
                expected_feats = xgb_model.n_features_in_ if hasattr(xgb_model, "n_features_in_") else features.shape[1]
                if features.shape[1] < expected_feats:
                    zeros = np.zeros((1, expected_feats - features.shape[1]))
                    processed_data = np.hstack((features, zeros))
                else:
                    processed_data = features

            # Dự đoán
            probs = xgb_model.predict_proba(processed_data)
            prob_safe = float(probs[0][0])
            prob_risk = float(probs[0][1])
            print(f"🤖 AI Raw Output: Safe={prob_safe:.2f}, Risk={prob_risk:.2f}")

    except Exception as e:
        print(f"❌ Lỗi tính toán AI: {e}")

    # --- BƯỚC 3: HYBRID LOGIC (HẬU XỬ LÝ) ---
    final_prob = prob_risk

  # Rule A: Risk cao (>=5) mà AI đánh thấp (< 35%) -> Kéo lên
    if risk_score >= 5 and prob_risk < 0.35:
        print("⚠️ [HYBRID] Risk cao nhưng AI thấp -> Force High Risk")
        final_prob = 0.75
        prob_safe = 0.25

   # Rule B: Risk thấp (<3), Trẻ, mà AI đánh hơi cao (> 35%) -> Kéo xuống
    if risk_score < 3 and not is_old and prob_risk > 0.35:
        print("🛡️ [HYBRID] Người khỏe nhưng AI cao -> Force Low Risk")
        final_prob = 0.15
        prob_safe = 0.85

    # --- BƯỚC 4: KẾT QUẢ CUỐI CÙNG ---
    is_sick = 1 if final_prob >= 0.30 else 0 # Ngưỡng cắt 20%

    return {
        "status": "success",
        "prediction": is_sick,            # 0 hoặc 1
        "prob_risk": round(final_prob, 4), # Tỉ lệ bệnh
        "prob_safe": round(prob_safe, 4),  # Tỉ lệ an toàn
        "risk_score": risk_score,          # Điểm chuyên gia
        "message": "Nguy cơ cao" if is_sick else "An toàn"
    }

# =======================================================
# 5. CHẠY TRỰC TIẾP (ENTRY POINT)
# =======================================================
if __name__ == "__main__":
    print("🚀 Đang khởi động Server Local tại http://127.0.0.1:8000")
    uvicorn.run(app, host="127.0.0.1", port=8000)