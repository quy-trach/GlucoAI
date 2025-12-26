import 'package:flutter/material.dart';

class HomeResultCard extends StatelessWidget {
  const HomeResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo: Cam (Cảnh báo nhẹ nhàng)
    const Color statusColor = Colors.orange;
    // Màu nền: Cam pha rất nhạt (Pastel)
    final Color backgroundColor = Colors.orange.shade50; 

    return Container(
      // Padding nhỏ lại (12-16px) để thẻ gọn hơn
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
        // Không dùng bóng đổ (Shadow) để thẻ bớt "nặng nề"
        // Chỉ dùng viền mỏng nếu cần, hoặc bỏ luôn viền cũng được
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ICON: Nhỏ gọn, không đóng khung
          Image.asset(
            'assets/icon/icon_check_circle.png',
            width: 32, // Giảm kích thước xuống (trước là 60)
            height: 32,
            // color: statusColor, // Nếu icon đen trắng thì uncomment dòng này
            fit: BoxFit.contain,
          ),
          
          const SizedBox(width: 14),
          
          // NỘI DUNG: Gọn gàng hơn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dòng 1: Kết quả (Chữ to vừa phải)
                Row(
                  children: [
                    const Text(
                      "Nguy cơ: ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "TRUNG BÌNH",
                      style: TextStyle(
                        color: statusColor.withValues(alpha: 0.9), // Màu cam đậm
                        fontSize: 15,
                        fontWeight: FontWeight.w800, // Đậm đà
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2), // Khoảng cách rất nhỏ
                
                // Dòng 2: Lời khuyên (Chữ nhỏ, màu xám dịu)
                const Text(
                  "Hãy kiểm tra lại sau 3 tháng nhé.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontStyle: FontStyle.italic, // Nghiêng nhẹ cho thân thiện
                  ),
                ),
              ],
            ),
          ),
          
          // (Tùy chọn) Thêm mũi tên nhỏ để gợi ý bấm vào xem chi tiết
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: statusColor.withValues(alpha: 0.5),
          )
        ],
      ),
    );
  }
}