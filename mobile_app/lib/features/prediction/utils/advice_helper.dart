// lib/features/prediction/utils/advice_helper.dart

import 'package:flutter/material.dart';

class AdviceHelper {
  /// Hàm trả về bộ dữ liệu: Tiêu đề, Màu sắc, và Nội dung chi tiết
  static Map<String, dynamic> getAdvice(int prediction, double bmi) {
    if (prediction == 1) {
      return _getHighRiskAdvice(bmi);
    } else {
      return _getSafeAdvice(bmi);
    }
  }

  // --- 1. LỜI KHUYÊN CHO NGƯỜI CÓ NGUY CƠ CAO ---
  static Map<String, dynamic> _getHighRiskAdvice(double bmi) {
    String specificBmiAdvice = "";
    if (bmi >= 25) {
      specificBmiAdvice = "\n• Giảm cân: Bạn đang thừa cân/béo phì. Giảm 5-7% trọng lượng cơ thể sẽ giảm 50% nguy cơ tiến triển thành bệnh.";
    }

    return {
      "label": "NGUY CƠ CAO",
      "color": Colors.red,
      "content": 
        "Kết quả phân tích cho thấy bạn có nhiều yếu tố nguy cơ liên quan đến tiền tiểu đường hoặc tiểu đường type 2.\n\n"
        "🚑 HÀNH ĐỘNG NGAY LẬP TỨC:\n"
        "• Đi khám bác sĩ: Đừng hoang mang! Hãy đến bệnh viện để xét nghiệm máu (HbA1c và Glucose lúc đói) để có kết quả chính xác nhất.\n"
        "• Theo dõi triệu chứng: Chú ý xem bạn có hay khát nước, đi tiểu nhiều, sụt cân bất thường hay mệt mỏi không.\n\n"
        "🥗 ĐIỀU CHỈNH CHẾ ĐỘ ĂN:\n"
        "• Cắt giảm đường: Ngưng uống nước ngọt, trà sữa, bánh kẹo ngọt ngay hôm nay.\n"
        "• Giảm tinh bột nhanh: Hạn chế cơm trắng, bánh mì trắng. Thay bằng gạo lứt, khoai lang, yến mạch.\n"
        "• Tăng chất xơ: Ăn rau xanh trong mọi bữa ăn (bông cải, rau muống, dưa leo).$specificBmiAdvice\n\n"
        "🏃 CHẾ ĐỘ VẬN ĐỘNG:\n"
        "• Dành ít nhất 30 phút mỗi ngày để đi bộ nhanh, đạp xe hoặc bơi lội."
    };
  }

  // --- 2. LỜI KHUYÊN CHO NGƯỜI AN TOÀN ---
  static Map<String, dynamic> _getSafeAdvice(double bmi) {
    String specificBmiAdvice = "";
    if (bmi >= 25) {
      specificBmiAdvice = "\n⚠️ Lưu ý nhỏ: Tuy nguy cơ tiểu đường thấp nhưng BMI của bạn đang ở mức thừa cân. Hãy cố gắng tập luyện để về vóc dáng chuẩn nhé!";
    }

    return {
      "label": "AN TOÀN",
      "color": Colors.green,
      "content": 
        "Chúc mừng! Dựa trên các chỉ số sức khỏe, hiện tại bạn có nguy cơ thấp với bệnh tiểu đường.\n\n"
        "🛡️ ĐỂ DUY TRÌ SỨC KHỎE TỐT:\n"
        "• Kiểm tra định kỳ: Đừng chủ quan, hãy khám sức khỏe tổng quát 6 tháng/lần.\n"
        "• Uống đủ nước: Đảm bảo uống 1.5 - 2 lít nước mỗi ngày để hỗ trợ trao đổi chất.\n"
        "• Ngủ đủ giấc: Giấc ngủ tốt giúp ổn định đường huyết và giảm căng thẳng.$specificBmiAdvice\n\n"
        "🍎 CHẾ ĐỘ DINH DƯỠNG:\n"
        "• Ăn uống đa dạng: Cân bằng giữa đạm (thịt, cá), tinh bột và rau củ.\n"
        "• Hạn chế ăn đêm: Cố gắng không ăn sau 8 giờ tối để cơ thể được nghỉ ngơi."
    };
  }
}