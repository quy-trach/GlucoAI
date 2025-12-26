import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeHealthStats extends StatelessWidget {
  const HomeHealthStats({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu (Giữ nguyên)
    final List<Map<String, String?>> statsData = [
      {
        "label": "BMI",
        "value": "23.1",
        "unit": "kg/m²",
        "icon": "assets/icon/icon_bmi.png"
      },
      {
        "label": "Vòng bụng",
        "value": "85",
        "unit": "cm",
        "icon": "assets/icon/icon_waist.png"
      },
      {
        "label": "Cân nặng",
        "value": "70",
        "unit": "kg",
        "icon": "assets/icon/icon_weight.png"
      },
      {
        "label": "Huyết áp",
        "value": "120/80",
        "unit": "mmHg",
        "icon": "assets/icon/icon_blood_pressure.png"
      },
      {
        "label": "Vận động",
        "value": "30",
        "unit": "phút/ngày",
        "icon": "assets/icon/icon_run.png"
      },
    ];

    return CarouselSlider.builder(
      itemCount: statsData.length,
      options: CarouselOptions(
        height: 165, // Tăng nhẹ từ 160 lên 165 để an toàn hơn
        enlargeCenterPage: true,
        enlargeFactor: 0.2, // Giảm từ 0.25 xuống 0.2 để các item bên cạnh đỡ bị bóp méo quá nhiều
        viewportFraction: 0.38, // Tăng nhẹ để thẻ to hơn chút
        enableInfiniteScroll: false,
        initialPage: 1,
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      padding: const EdgeInsets.all(8), // Giảm padding chút cho đỡ chật
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
      // --- PHẦN QUAN TRỌNG NHẤT ---
      // Căn giữa nội dung
      alignment: Alignment.center, 
      child: FittedBox(
        // FittedBox: "Thần chú" chống tràn. 
        // Nó sẽ scale nội dung nhỏ lại nếu thẻ bị bé đi.
        fit: BoxFit.scaleDown, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Image.asset(
              iconPath,
              width: 34, 
              height: 34,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 34, color: Colors.grey),
            ),
            
            const SizedBox(height: 6), // Giảm khoảng cách chút

            // Giá trị (Value)
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),

            // Đơn vị (Unit)
            if (unit != null) ...[
              const SizedBox(height: 2),
              Text(
                unit!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 4),

            // Label
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