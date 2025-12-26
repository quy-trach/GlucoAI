// lib/features/prediction/data/questions_data.dart

// 1. CẤU TRÚC DỮ LIỆU (MODEL)
class Question {
  final String id;        // ID định danh (HighBP, BMI...)
  final String text;      // Nội dung câu hỏi (chứa {xung_ho})
  final QuestionType type;// Loại câu hỏi
  final List<Option>? options; // Danh sách đáp án (cho loại trắc nghiệm)
  final String? icon;     // Tên icon để map ra giao diện

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.icon,
  });
}

enum QuestionType { yesNo, scale, inputBmi, inputDays, singleChoice }

class Option {
  final String text;      // Chữ hiển thị (VD: "Nhân viên văn phòng...")
  final Map<String, double> values; // Giá trị map vào model (Có thể map nhiều biến 1 lúc)

  Option(this.text, this.values);
}

// ========================================================
// 2. DANH SÁCH CÂU HỎI CHUẨN (FINALIZED)
// ========================================================
final List<Question> surveyQuestions = [
  // --- NHÓM 1: CHỈ SỐ CƠ THỂ (BMI) ---
  Question(
    id: "BMI_Group", // ID ảo để gom nhóm
    text: "Để bắt đầu, vui lòng cho biết chiều cao và cân nặng của {xung_ho}?",
    type: QuestionType.inputBmi, // Loại đặc biệt: Hiện 2 thanh Slider
    icon: "scale",
    // Giá trị sẽ được tính: BMI = Weight / (Height/100)^2
  ),

  // --- NHÓM 2: TIỀN SỬ BỆNH (QUAN TRỌNG) ---
  Question(
    id: "HighBP",
    text: "Bác sĩ có từng nói {xung_ho} bị cao huyết áp không?",
    type: QuestionType.yesNo,
    icon: "blood_pressure",
    options: [
      Option("Không, huyết áp ổn định", {"HighBP": 0}),
      Option("Có, {xung_ho} bị cao huyết áp", {"HighBP": 1}),
    ],
  ),
  Question(
    id: "HighChol",
    text: "Kết quả xét nghiệm mỡ máu (Cholesterol) gần đây của {xung_ho} thế nào?",
    type: QuestionType.yesNo,
    icon: "cholesterol",
    options: [
      Option("Bình thường / Chưa đo", {"HighChol": 0, "CholCheck": 0}), // Gán luôn CholCheck=0 nếu chưa đo
      Option("Bác sĩ báo Mỡ máu cao", {"HighChol": 1, "CholCheck": 1}),
    ],
  ),
  Question(
    id: "Heart_Stroke", // Gom tim mạch và đột quỵ cho gọn (hoặc tách nếu muốn kỹ)
    text: "{xung_ho} đã từng bị đột quỵ hay mắc bệnh tim mạch (nhồi máu cơ tim) chưa?",
    type: QuestionType.singleChoice,
    icon: "heart",
    options: [
      Option("Tim mạch hoàn toàn khỏe mạnh", {"Stroke": 0, "HeartDiseaseorAttack": 0}),
      Option("Đã từng bị Đột quỵ", {"Stroke": 1, "HeartDiseaseorAttack": 0}),
      Option("Có bệnh Tim mạch", {"Stroke": 0, "HeartDiseaseorAttack": 1}),
      Option("Bị cả hai (Tim mạch & Đột quỵ)", {"Stroke": 1, "HeartDiseaseorAttack": 1}),
    ],
  ),

  // --- NHÓM 3: THÓI QUEN SỐNG (GOM NHÓM) ---
  Question(
    id: "Diet_Group", // GOM FRUITS + VEGGIES
    text: "Thói quen ăn uống hàng ngày của {xung_ho} thường như thế nào?",
    type: QuestionType.singleChoice,
    icon: "food",
    options: [
      Option("Thích đồ ngọt/chiên rán, ít ăn rau củ", {"Fruits": 0, "Veggies": 0}),
      Option("Ăn uống cân bằng, có rau xanh/trái cây mỗi ngày", {"Fruits": 1, "Veggies": 1}),
    ],
  ),
  Question(
    id: "Smoker",
    text: "{xung_ho} có hút thuốc lá không? (Hoặc đã hút trên 100 điếu trong đời)",
    type: QuestionType.yesNo,
    icon: "smoking",
    options: [
      Option("Không hút thuốc", {"Smoker": 0}),
      Option("Có hút thuốc", {"Smoker": 1}),
    ],
  ),
  Question(
    id: "PhysActivity",
    text: "Trong 30 ngày qua, {xung_ho} có tập thể dục hay vận động chân tay không?",
    type: QuestionType.yesNo,
    icon: "running",
    options: [
      Option("Rất ít vận động", {"PhysActivity": 0}),
      Option("Có, vận động/thể dục đều đặn", {"PhysActivity": 1}),
    ],
  ),
   Question(
    id: "HvyAlcoholConsump",
    text: "{xung_ho} có thường xuyên uống nhiều rượu bia không?",
    type: QuestionType.yesNo,
    icon: "beer",
    options: [
      Option("Không / Uống rất ít", {"HvyAlcoholConsump": 0}),
      Option("Có, uống thường xuyên", {"HvyAlcoholConsump": 1}),
    ],
  ),

  // --- NHÓM 4: KINH TẾ & XÃ HỘI (GOM INCOME + EDUCATION) ---
  // Mẹo: Hỏi về "Công việc & Mức sống" để tế nhị hơn
  Question(
    id: "Socio_Group",
    text: "Nhóm nào dưới đây mô tả đúng nhất về công việc và mức sống hiện tại của {xung_ho}?",
    type: QuestionType.singleChoice,
    icon: "work",
    options: [
      // Mức 1: Thấp (Lao động phổ thông/Về hưu lương thấp) -> Edu: 2 (Cấp 1-2), Income: 2
      Option(
        "Lao động tự do / Về hưu (Mức sống cơ bản)", 
        {"Education": 2, "Income": 2}
      ),
      // Mức 2: Trung bình (Công nhân/NV Văn phòng) -> Edu: 4 (Cấp 3), Income: 4-5
      Option(
        "Công nhân / NV Văn phòng / Sinh viên (Mức sống trung bình)", 
        {"Education": 4, "Income": 5}
      ),
      // Mức 3: Khá (Đại học/Quản lý) -> Edu: 6 (Đại học), Income: 7-8
      Option(
        "Chuyên viên / Quản lý / Kinh doanh (Mức sống khá giả)", 
        {"Education": 6, "Income": 8}
      ),
    ],
  ),

  // --- NHÓM 5: TÌNH TRẠNG HIỆN TẠI ---
  Question(
    id: "GenHlth",
    text: "Nhìn chung, {xung_ho} tự đánh giá sức khỏe của mình ở mức nào?",
    type: QuestionType.singleChoice, // Scale 1-5
    icon: "health_rating",
    options: [
      Option("Tuyệt vời (Rất khỏe)", {"GenHlth": 1}),
      Option("Rất tốt", {"GenHlth": 2}),
      Option("Tốt", {"GenHlth": 3}),
      Option("Bình thường", {"GenHlth": 4}),
      Option("Kém (Hay đau ốm)", {"GenHlth": 5}),
    ],
  ),
  Question(
    id: "DiffWalk",
    text: "{xung_ho} có gặp khó khăn khi đi bộ hoặc leo cầu thang không?",
    type: QuestionType.yesNo,
    icon: "walking",
    options: [
      Option("Đi lại bình thường", {"DiffWalk": 0}),
      Option("Có, đi lại khó khăn", {"DiffWalk": 1}),
    ],
  ),
  Question(
    id: "Mental_Physical_Days", // Hỏi gộp hoặc tách tùy ý, ở đây để input số ngày
    text: "Trong 30 ngày qua, có bao nhiêu ngày {xung_ho} cảm thấy sức khỏe TÂM LÝ hoặc THỂ CHẤT không tốt?",
    type: QuestionType.inputDays, // Form nhập 2 ô số: Tâm lý & Thể chất
    icon: "calendar",
    // Giá trị trả về: MentHlth (0-30), PhysHlth (0-30)
  ),

  // --- NHÓM 6: THÔNG TIN CÁ NHÂN (MODEL) ---
  Question(
    id: "Sex",
    text: "Giới tính sinh học của {xung_ho}?",
    type: QuestionType.singleChoice,
    icon: "gender",
    options: [
      Option("Nữ", {"Sex": 0}),
      Option("Nam", {"Sex": 1}),
    ],
  ),
  Question(
    id: "Age",
    text: "Cuối cùng, vui lòng chọn nhóm tuổi chính xác của {xung_ho}:",
    type: QuestionType.singleChoice, // Scale 1-13
    icon: "age",
    options: [
      Option("18 - 24 tuổi", {"Age": 1}),
      Option("25 - 29 tuổi", {"Age": 2}),
      Option("30 - 34 tuổi", {"Age": 3}),
      Option("35 - 39 tuổi", {"Age": 4}),
      Option("40 - 44 tuổi", {"Age": 5}),
      Option("45 - 49 tuổi", {"Age": 6}),
      Option("50 - 54 tuổi", {"Age": 7}),
      Option("55 - 59 tuổi", {"Age": 8}),
      Option("60 - 64 tuổi", {"Age": 9}),
      Option("65 - 69 tuổi", {"Age": 10}),
      Option("70 - 74 tuổi", {"Age": 11}),
      Option("75 - 79 tuổi", {"Age": 12}),
      Option("80 tuổi trở lên", {"Age": 13}),
    ],
  ),
];