// lib/features/prediction/utils/advice_helper.dart

import 'package:flutter/material.dart';

class AdviceHelper {
  static Map<String, dynamic> getAdvice(int prediction, double bmi) {
    if (prediction == 1) {
      return _getHighRiskAdvice(bmi);
    } else {
      return _getSafeAdvice(bmi);
    }
  }

  // --- 1. PHÁC ĐỒ CHO NGUY CƠ CAO (Văn phong Y khoa) ---
  static Map<String, dynamic> _getHighRiskAdvice(double bmi) {
    String specificBmiAdvice = "";
    if (bmi >= 25) {
      specificBmiAdvice = "- Kiểm soát cân nặng: Chỉ số BMI hiện tại ở mức thừa cân/béo phì. Mục tiêu giảm 5-7% trọng lượng cơ thể để cải thiện độ nhạy Insulin.";
    }

    return {
      "label": "NGUY CƠ CAO",
      "color": Colors.red,
      "content": 
        "Kết quả phân tích cho thấy các chỉ số của bạn có độ tương quan cao với nhóm bệnh lý Tiểu đường Type 2. Dưới đây là phác đồ khuyến nghị:\n\n"
        
        "I. KHUYẾN NGHỊ Y KHOA\n"
        "- Thăm khám chuyên khoa: Cần đến cơ sở y tế gần nhất để thực hiện xét nghiệm chẩn đoán xác định (HbA1c, Glucose lúc đói).\n"
        "- Theo dõi lâm sàng: Lưu ý các triệu chứng như khát nước liên tục, đi tiểu nhiều (đa niệu), mệt mỏi mạn tính hoặc sụt cân không rõ nguyên nhân.\n\n"

        "II. ĐIỀU CHỈNH DINH DƯỠNG\n"
        "- Loại bỏ đường đơn: Ngưng sử dụng nước ngọt có gas, bánh kẹo và thực phẩm chế biến sẵn chứa đường tinh luyện.\n"
        "- Kiểm soát tinh bột (Carb): Thay thế gạo trắng, bánh mì bằng ngũ cốc nguyên hạt (gạo lứt, yến mạch) để giảm chỉ số đường huyết (GI).\n"
        "- Tăng cường chất xơ: Bổ sung rau xanh trong mọi khẩu phần ăn để làm chậm quá trình hấp thu đường.\n"
        "$specificBmiAdvice\n\n"

        "III. VẬN ĐỘNG TRỊ LIỆU\n"
        "- Duy trì hoạt động thể chất cường độ trung bình ít nhất 150 phút/tuần (đi bộ nhanh, bơi lội)."
    };
  }

  // --- 2. CHIẾN LƯỢC CHO NGƯỜI AN TOÀN ---
  static Map<String, dynamic> _getSafeAdvice(double bmi) {
    String specificBmiAdvice = "";
    if (bmi >= 25) {
      specificBmiAdvice = "- Lưu ý chỉ số BMI: Mặc dù nguy cơ tiểu đường thấp, nhưng thể trạng thừa cân có thể dẫn đến các vấn đề tim mạch. Cần điều chỉnh để về mức chuẩn (18.5 - 24.9).";
    }

    return {
      "label": "AN TOÀN",
      "color": Colors.green,
      "content": 
        "Các chỉ số phân tích hiện tại nằm trong ngưỡng an toàn. Tuy nhiên, việc duy trì lối sống lành mạnh là yếu tố tiên quyết để phòng ngừa bệnh.\n\n"

        "I. CHIẾN LƯỢC DỰ PHÒNG\n"
        "- Tầm soát định kỳ: Thực hiện kiểm tra sức khỏe tổng quát 6 tháng/lần để phát hiện sớm các bất thường.\n"
        "- Bù nước và điện giải: Đảm bảo cung cấp đủ 1.5 - 2 lít nước mỗi ngày để hỗ trợ quá trình chuyển hóa.\n"
        "$specificBmiAdvice\n\n"

        "II. CHẾ ĐỘ SINH HOẠT\n"
        "- Dinh dưỡng cân bằng: Duy trì tỷ lệ hợp lý giữa Đạm (Protein), Tinh bột (Carb) và Chất béo tốt (Lipid).\n"
        "- Giấc ngủ: Đảm bảo ngủ đủ 7-8 tiếng/ngày để ổn định nội tiết tố và đường huyết.\n"
        "- Hạn chế ăn đêm: Tránh nạp năng lượng sau 20:00 để cơ quan tiêu hóa được nghỉ ngơi."
    };
  }
}