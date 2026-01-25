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
  // --- NHÓM 1: THÔNG TIN CƠ BẢN (DEMOGRAPHICS) ---
  Question(
    id: "Sex",
    text: "Giới tính sinh học của {xung_ho} là gì?",
    type: QuestionType.singleChoice,
    icon: "gender",
    options: [
      Option("Nam giới", {"Sex": 1.0}),
      Option("Nữ giới", {"Sex": 0.0}),
    ],
  ),

  Question(
    id: "Age",
    text: "Độ tuổi hiện tại của {xung_ho} thuộc nhóm nào?",
    type: QuestionType.singleChoice,
    icon: "cake",
    options: [
      Option("Thanh niên (Dưới 30 tuổi)", {"Age": 2.0}), 
      Option("Trung niên (30 - 45 tuổi)", {"Age": 5.0}),
      Option("Đứng tuổi (46 - 60 tuổi)", {"Age": 8.0}),
      Option("Cao tuổi (Trên 60 tuổi)", {"Age": 11.0}),
    ],
  ),

  // --- NHÓM 2: CHỈ SỐ CƠ THỂ & TIỀN SỬ (MEDICAL) ---
  Question(
    id: "BMI",
    text: "Vui lòng cung cấp chiều cao và cân nặng để tính chỉ số BMI:",
    type: QuestionType.inputBmi,
    icon: "scale",
  ),

  Question(
    id: "HighBP",
    text: "Tình trạng huyết áp của {xung_ho} như thế nào?",
    type: QuestionType.singleChoice,
    icon: "blood_pressure",
    options: [
      Option("Ổn định / Bình thường", {"HighBP": 0.0}),
      Option("Hơi cao (Tiền cao huyết áp)", {"HighBP": 0.0}), // Vẫn chưa tính là HighBP theo dataset
      Option("Cao (Đang dùng thuốc kiểm soát)", {"HighBP": 1.0}),
      Option("Rất cao / Thường xuyên mất kiểm soát", {"HighBP": 1.0}),
    ],
  ),

  Question(
    id: "HighChol",
    text: "Chỉ số Cholesterol (mỡ máu) gần nhất của {xung_ho}?",
    type: QuestionType.singleChoice,
    icon: "cholesterol",
    options: [
      Option("Rất tốt / Dưới mức cảnh báo", {"HighChol": 0.0}),
      Option("Bình thường", {"HighChol": 0.0}),
      Option("Cao (Bác sĩ đã cảnh báo)", {"HighChol": 1.0}),
      Option("Rất cao / Đang điều trị", {"HighChol": 1.0}),
    ],
  ),

  Question(
    id: "CholCheck",
    text: "Lần cuối {xung_ho} thực hiện xét nghiệm mỡ máu là khi nào?",
    type: QuestionType.singleChoice,
    icon: "history",
    options: [
      Option("Trong vòng 1 năm qua", {"CholCheck": 1.0}),
      Option("Khoảng 1-2 năm trước", {"CholCheck": 1.0}),
      Option("Đã lâu (trên 5 năm) chưa đo", {"CholCheck": 0.0}),
      Option("Chưa bao giờ xét nghiệm", {"CholCheck": 0.0}),
    ],
  ),

  Question(
    id: "Stroke",
    text: "{xung_ho} đã từng có tiền sử bị Đột quỵ (Tai biến) chưa?",
    type: QuestionType.singleChoice,
    icon: "brain",
    options: [
      Option("Chưa bao giờ", {"Stroke": 0.0}),
      Option("Có dấu hiệu nhẹ (Thoáng qua)", {"Stroke": 0.0}),
      Option("Đã từng bị và đã hồi phục", {"Stroke": 1.0}),
      // Option("Đã bị nhiều lần", {"Stroke": 1.0}),
    ],
  ),

  Question(
    id: "HeartDiseaseorAttack",
    text: "{xung_ho} đã từng được chẩn đoán mắc bệnh tim mạch hoặc nhồi máu cơ tim chưa?",
    type: QuestionType.singleChoice,
    icon: "heart",
    options: [
      Option("Tim mạch khỏe mạnh", {"HeartDiseaseorAttack": 0.0}),
      Option("Hay bị đau thắt ngực", {"HeartDiseaseorAttack": 0.0}),
      Option("Có bệnh lý tim mạch vành", {"HeartDiseaseorAttack": 1.0}),
      Option("Đã từng bị nhồi máu cơ tim", {"HeartDiseaseorAttack": 1.0}),
    ],
  ),

  // --- NHÓM 3: LỐI SỐNG (LIFESTYLE) ---
  Question(
    id: "Smoker",
    text: "{xung_ho} có thói quen hút thuốc lá không?",
    type: QuestionType.singleChoice,
    icon: "smoking",
    options: [
      Option("Không bao giờ hút", {"Smoker": 0.0}),
      Option("Đã từng hút nhưng đã bỏ", {"Smoker": 0.0}),
      Option("Thỉnh thoảng mới hút", {"Smoker": 1.0}),
      Option("Hút thường xuyên (trên 100 điếu)", {"Smoker": 1.0}),
    ],
  ),

  Question(
    id: "PhysActivity",
    text: "Trong 30 ngày qua, {xung_ho} có tập thể dục hoặc vận động mạnh không?",
    type: QuestionType.singleChoice,
    icon: "fitness",
    options: [
      Option("Tập thể dục đều đặn hàng ngày", {"PhysActivity": 1.0}),
      Option("Tập 3-4 buổi/tuần", {"PhysActivity": 1.0}),
      Option("Ít vận động (1 lần/tuần)", {"PhysActivity": 0.0}),
      Option("Hoàn toàn không vận động", {"PhysActivity": 0.0}),
    ],
  ),

  Question(
    id: "Fruits",
    text: "{xung_ho} có thói quen ăn trái cây hàng ngày không?",
    type: QuestionType.singleChoice,
    icon: "apple",
    options: [
      Option("Ăn nhiều lần trong ngày", {"Fruits": 1.0}),
      Option("Ít nhất 1 quả mỗi ngày", {"Fruits": 1.0}),
      Option("Vài ngày mới ăn một lần", {"Fruits": 0.0}),
      Option("Rất hiếm khi ăn trái cây", {"Fruits": 0.0}),
    ],
  ),

  Question(
    id: "Veggies",
    text: "{xung_ho} có thói quen ăn rau xanh hàng ngày không?",
    type: QuestionType.singleChoice,
    icon: "leaf",
    options: [
      Option("Luôn có rau trong mọi bữa ăn", {"Veggies": 1.0}),
      Option("Ăn rau ít nhất 1 lần/ngày", {"Veggies": 1.0}),
      Option("Thỉnh thoảng mới ăn", {"Veggies": 0.0}),
      Option("Hầu như không ăn rau", {"Veggies": 0.0}),
    ],
  ),

  Question(
    id: "HvyAlcoholConsump",
    text: "Mức độ sử dụng rượu bia hàng tuần?",
    type: QuestionType.singleChoice,
    icon: "alcohol",
    options: [
      Option("Không uống / Cực kỳ hiếm", {"HvyAlcoholConsump": 0.0}),
      Option("Uống xã giao (ít)", {"HvyAlcoholConsump": 0.0}),
      Option("Nam >14 ly / Nữ >7 ly mỗi tuần", {"HvyAlcoholConsump": 1.0}),
      Option("Uống thường xuyên mỗi ngày", {"HvyAlcoholConsump": 1.0}),
    ],
  ),

  // --- NHÓM 4: SỨC KHỎE TỔNG QUÁT ---
  Question(
    id: "GenHlth",
    text: "Tự đánh giá tình trạng sức khỏe tổng quát của {xung_ho}?",
    type: QuestionType.singleChoice,
    icon: "health_card",
    options: [
      Option("Tuyệt vời (Rất khỏe)", {"GenHlth": 1.0}),
      Option("Tốt / Khá", {"GenHlth": 2.0}),
      Option("Bình thường", {"GenHlth": 3.0}),
      Option("Kém (Hay mệt mỏi/đau ốm)", {"GenHlth": 5.0}),
    ],
  ),

  Question(
    id: "MentHlth",
    text: "Trong 30 ngày qua, bao nhiêu ngày {xung_ho} thấy căng thẳng, áp lực (Stress)?",
    type: QuestionType.singleChoice,
    icon: "mental",
    options: [
      Option("Không có ngày nào (0 ngày)", {"MentHlth": 0.0}),
      Option("Khoảng 1 tuần (1-7 ngày)", {"MentHlth": 5.0}),
      Option("Khoảng nửa tháng (15 ngày)", {"MentHlth": 15.0}),
      Option("Gần như cả tháng (trên 25 ngày)", {"MentHlth": 30.0}),
    ],
  ),

  Question(
    id: "PhysHlth",
    text: "Trong 30 ngày qua, bao nhiêu ngày {xung_ho} cảm thấy mệt mỏi hoặc đau ốm?",
    type: QuestionType.singleChoice,
    icon: "body",
    options: [
      Option("Hoàn toàn khỏe mạnh (0 ngày)", {"PhysHlth": 0.0}),
      Option("Bị mệt/ốm vài ngày (1-5 ngày)", {"PhysHlth": 3.0}),
      Option("Ốm khoảng nửa tháng", {"PhysHlth": 15.0}),
      Option("Ốm yếu cả tháng", {"PhysHlth": 30.0}),
    ],
  ),

  Question(
    id: "DiffWalk",
    text: "{xung_ho} có gặp khó khăn khi đi bộ hoặc leo cầu thang?",
    type: QuestionType.singleChoice,
    icon: "walk",
    options: [
      Option("Đi lại chạy nhảy bình thường", {"DiffWalk": 0.0}),
      Option("Hơi khó khăn khi leo cao", {"DiffWalk": 0.0}),
      Option("Khó đi bộ đoạn dài", {"DiffWalk": 1.0}),
      Option("Cần dụng cụ hỗ trợ / Xe lăn", {"DiffWalk": 1.0}),
    ],
  ),

  // --- NHÓM 5: KINH TẾ & Y TẾ ---
  Question(
    id: "AnyHealthcare",
    text: "{xung_ho} có đang sử dụng bảo hiểm y tế không?",
    type: QuestionType.singleChoice,
    icon: "insurance",
    options: [
      Option("Có BH bắt buộc/tự nguyện", {"AnyHealthcare": 1.0}),
      Option("Có BH cao cấp/Quốc tế", {"AnyHealthcare": 1.0}),
      Option("Sắp hết hạn / Đang chờ cấp", {"AnyHealthcare": 0.0}),
      Option("Không có bảo hiểm", {"AnyHealthcare": 0.0}),
    ],
  ),

  Question(
    id: "NoDocbcCost",
    text: "{xung_ho} có từng bỏ khám vì lo ngại viện phí?",
    type: QuestionType.singleChoice,
    icon: "cost",
    options: [
      Option("Chưa bao giờ lo lắng", {"NoDocbcCost": 0.0}),
      Option("Đôi khi thấy tốn kém", {"NoDocbcCost": 0.0}),
      Option("Thường xuyên bỏ khám vì tiền", {"NoDocbcCost": 1.0}),
      Option("Không đủ khả năng chi trả", {"NoDocbcCost": 1.0}),
    ],
  ),

  Question(
    id: "Education",
    text: "Trình độ học vấn cao nhất {xung_ho} đạt được?",
    type: QuestionType.singleChoice,
    icon: "school",
    options: [
      Option("Sau Đại học / Chuyên gia", {"Education": 6.0}),
      Option("Đại học / Cao đẳng", {"Education": 5.0}),
      Option("Trung cấp / Cấp 3", {"Education": 4.0}),
      Option("Dưới cấp 3", {"Education": 2.0}),
    ],
  ),

  Question(
    id: "Income",
    text: "Mức thu nhập hàng tháng của {xung_ho}?",
    type: QuestionType.singleChoice,
    icon: "income",
    options: [
      Option("Dư dả (Trên 30 triệu)", {"Income": 8.0}),
      Option("Khá (15 - 30 triệu)", {"Income": 6.0}),
      Option("Trung bình (7 - 15 triệu)", {"Income": 4.0}),
      Option("Thấp (Dưới 7 triệu)", {"Income": 2.0}),
    ],
  ),
];