import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeHealthStats extends StatelessWidget {
  final Map<String, dynamic>? data;

  const HomeHealthStats({super.key, this.data});

  // --- TÁCH LOGIC XỬ LÝ DỮ LIỆU RA HÀM RIÊNG ---
  List<Map<String, String?>> _processData() {
    final inputs = data?['input_data'] ?? {};
    final bmiVal = data?['bmi'] ?? 0.0;

    // 1. Vận động
    String physStatus = "Chưa rõ";
    if (inputs['PhysActivity'] != null) {
      physStatus = (inputs['PhysActivity'] == 1) ? "Tích cực" : "Ít vận động";
    }

    // 2. Ăn uống
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

    // 3. Sức khỏe chung
    String healthGen = "---";
    if (inputs['GenHlth'] != null) {
      int gen = (inputs['GenHlth'] as num).toInt();
      // 🔥 ĐÃ SỬA: Thêm ngoặc nhọn {} cho các dòng if/else
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

    return [
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
        "icon": "assets/icon/medical _summary.png"
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String?>> statsData = _processData();

    return CarouselSlider.builder(
      itemCount: statsData.length,
      options: CarouselOptions(
        height: 165,
        enableInfiniteScroll: true,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        viewportFraction: 0.4,
        initialPage: 0,
        scrollPhysics: const BouncingScrollPhysics(),
        autoPlay: false,
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
    if (["Có cao HA", "Thiếu rau", "Ít vận động", "Cần chú ý"].contains(value)) {
      valueColor = Colors.orange.shade900;
    } else if (["Lành mạnh", "Tích cực", "Tuyệt vời", "Rất tốt"].contains(value)) {
      valueColor = Colors.green.shade700;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            cacheWidth: 100,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.info, size: 36, color: Colors.grey),
          ),
          
          const Spacer(),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1.2,
              ),
            ),
          ),

          if (unit != null) ...[
            const SizedBox(height: 2),
            Text(
              unit!,
              style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],

          const Spacer(),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF007BFF),
            ),
          ),
        ],
      ),
    );
  }
}