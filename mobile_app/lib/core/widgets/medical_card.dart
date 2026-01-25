import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/medical_center_model.dart';

class MedicalCenterCard extends StatelessWidget {
  final MedicalCenterModel center;
  final bool isCompact; // True: Hiện ở Home (gọn), False: Hiện ở Result (chi tiết)

  const MedicalCenterCard({
    super.key,
    required this.center,
    this.isCompact = false,
  });

  // Hàm mở bản đồ chỉ đường
Future<void> _openMap() async {
    // 🔥 SỬ DỤNG LINK CHUẨN CỦA GOOGLE MAPS
    // Cấu trúc: https://www.google.com/maps/search/?api=1&query=LAT,LON
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${center.lat},${center.lon}'
    );

    try {
      // Logic mở app chuẩn
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        // Nếu không mở được app thì mở trình duyệt
        await launchUrl(googleUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("❌ Lỗi mở map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // 1. Icon Bệnh viện
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_hospital_rounded, color: Colors.blue[700], size: 28),
          ),
          const SizedBox(width: 12),

          // 2. Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Địa chỉ (Chỉ hiện nếu không phải Compact mode)
                if (!isCompact)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      center.address,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                // Dòng Khoảng cách & Thời gian
                Row(
                  children: [
                    Icon(Icons.near_me, size: 12, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      "${center.distanceKm.toStringAsFixed(1)} km",
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer_outlined, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "~${center.timeMinutes} phút",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Nút chỉ đường
          InkWell(
            onTap: _openMap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue, // Nút màu xanh nổi bật
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))
                ],
              ),
              child: const Icon(Icons.directions, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}