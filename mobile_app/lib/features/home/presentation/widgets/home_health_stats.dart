import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeHealthStats extends StatelessWidget {
  // Dữ liệu từ Firebase truyền vào
  final Map<String, dynamic>? data;

  const HomeHealthStats({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    // Nếu chưa có dữ liệu, dùng dữ liệu mặc định rỗng
    final inputs = data?['input_data'] ?? {};
    final bmiVal = data?['bmi'] ?? 0.0;

    // --- LOGIC CHUYỂN ĐỔI DỮ LIỆU ---
    
    // 1. Xử lý Vận động
    String physStatus = "Chưa rõ";
    if (inputs['PhysActivity'] != null) {
      physStatus = (inputs['PhysActivity'] == 1) ? "Tích cực" : "Ít vận động";
    }

    // 2. Xử lý Ăn uống
    String dietStatus = "Chưa rõ";
    if (inputs['Veggies'] != null && inputs['Fruits'] != null) {
      bool hasVeggies = inputs['Veggies'] == 1;
      bool hasFruits = inputs['Fruits'] == 1;
      
      if (hasVeggies && hasFruits) {
        dietStatus = "Lành mạnh";
      } else if (hasVeggies || hasFruits) {
        dietStatus = "Khá tốt";
      } else {
        dietStatus = "Thiếu rau";
      }
    }

    // 3. Xử lý Sức khỏe chung (GenHlth: 1-Excellent -> 5-Poor)
    // ĐÃ SỬA: Thêm ngoặc nhọn {} đầy đủ
    String healthGen = "---";
    if (inputs['GenHlth'] != null) {
      int gen = (inputs['GenHlth'] as num).toInt();
      if (gen <= 1) {
        healthGen = "Tuyệt vời";
      } else if (gen <= 2) {
        healthGen = "Rất tốt";
      } else if (gen <= 3) {
        healthGen = "Bình thường";
      } else {
        healthGen = "Cần chú ý";
      }
    }

    // --- DANH SÁCH HIỂN THỊ ---
    final List<Map<String, String?>> statsData = [
      {
        "label": "Chỉ số BMI",
        "value": (bmiVal > 0) ? bmiVal.toStringAsFixed(1) : "--",
        "unit": "kg/m²",
        "icon": "assets/icon/icon_bmi.png"
      },
      {
        "label": "Tiền sử HA",
        "value": (inputs['HighBP'] == 1) ? "Có cao HA" : "Bình thường",
        "unit": "Tình trạng",
        "icon": "assets/icon/icon_blood_pressure.png"
      },
      {
        "label": "Vận động",
        "value": physStatus,
        "unit": "Thói quen",
        "icon": "assets/icon/icon_run.png"
      },
      {
        "label": "Chế độ ăn",
        "value": dietStatus,
        "unit": "Dinh dưỡng",
        "icon": "assets/icon/icon_nutrition.png"
      },
      {
        "label": "Sức khỏe chung",
        "value": healthGen,
        "unit": "Tự đánh giá",
        "icon": "assets/icon/icon_heart_small.png"
      },
    ];

    return CarouselSlider.builder(
      itemCount: statsData.length,
      options: CarouselOptions(
        height: 165,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        viewportFraction: 0.38,
        enableInfiniteScroll: false,
        initialPage: 0, 
        scrollPhysics: const BouncingScrollPhysics(),
        padEnds: true,
      ),
      itemBuilder: (context, index, realIndex) {
        final item = statsData[index];
        return StatCard(
          label: item["label"]!,
          value: item["value"]!,
          unit: item["unit"],
          iconPath: item["icon"]!,
        );
      },
    );
  }
}

// --- WIDGET CARD CON ---
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String iconPath;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = Colors.black87;
    if (value == "Có cao HA" || value == "Thiếu rau" || value == "Ít vận động") {
      valueColor = Colors.orange.shade800;
    } else if (value == "Lành mạnh" || value == "Tích cực") {
      valueColor = Colors.green.shade700;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center, 
      child: FittedBox(
        fit: BoxFit.scaleDown, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 34, 
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.info, size: 34, color: Colors.grey),
            ),
            
            const SizedBox(height: 8),

            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),

            if (unit != null) ...[
              const SizedBox(height: 2),
              Text(
                unit!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF007BFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}