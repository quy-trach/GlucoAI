import 'package:flutter/material.dart';

class HomeResultCard extends StatelessWidget {
  // Nhận dữ liệu kết quả mới nhất vào đây
  // Nếu resultData là null => Hiển thị trạng thái "Chưa có kết quả"
  final Map<String, dynamic>? resultData;
  final VoidCallback? onTap;

  const HomeResultCard({
    super.key, 
    this.resultData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Xử lý dữ liệu (Nếu null thì mặc định trạng thái chờ)
    bool hasData = resultData != null;
    
    // Lấy chỉ số dự đoán (0: An toàn, 1: Nguy cơ)
    int prediction = hasData ? (resultData!['prediction'] as num).toInt() : 0;
    
    // Lấy % rủi ro để hiển thị thanh đo
    double riskPercent = hasData ? (resultData!['prob_risk'] as num).toDouble() : 0.0;
    
    // 2. Xác định Màu sắc & Nội dung dựa trên kết quả
    Color themeColor;
    Color bgColor;
    String title;
    String subtitle;
    IconData iconData;

    if (!hasData) {
      // Trường hợp chưa đo lần nào
      themeColor = Colors.blue;
      bgColor = Colors.blue.shade50;
      title = "Chưa có dữ liệu";
      subtitle = "Bấm để kiểm tra ngay";
      iconData = Icons.health_and_safety;
    } else if (prediction == 1) {
      // Nguy cơ cao
      themeColor = Colors.red;
      bgColor = Colors.red.shade50;
      title = "NGUY CƠ CAO";
      subtitle = "Cần đi khám bác sĩ ngay";
      iconData = Icons.warning_rounded;
    } else {
      // An toàn
      themeColor = Colors.green;
      bgColor = Colors.green.shade50;
      title = "AN TOÀN";
      subtitle = "Tiếp tục duy trì nhé";
      iconData = Icons.check_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Cách trên dưới xíu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Bóng đổ nhẹ tạo cảm giác nổi (Card style)
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // --- PHẦN 1: ICON BOX (BÊN TRÁI) ---
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgColor, // Màu nền nhạt theo trạng thái
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    iconData,
                    color: themeColor,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),

                // --- PHẦN 2: NỘI DUNG CHÍNH (Ở GIỮA) ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề nhỏ (Ngày đo - giả sử lấy ngày hiện tại hoặc từ data)
                      Text(
                        hasData ? "Kết quả mới nhất" : "Khảo sát sức khỏe",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Trạng thái (AN TOÀN / NGUY CƠ)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --- THANH MINI PROGRESS BAR ---
                      // Chỉ hiện khi có dữ liệu
                      if (hasData)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: riskPercent, // Giá trị 0.0 -> 1.0
                                backgroundColor: Colors.grey[200],
                                color: themeColor, // Thanh màu đỏ hoặc xanh
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Dòng hiển thị % nhỏ xíu bên dưới
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tỉ lệ nguy cơ: ${(riskPercent * 100).toInt()}%",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            )
                          ],
                        )
                      else
                        // Nếu chưa có dữ liệu thì hiện subtitle
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // --- PHẦN 3: MŨI TÊN (BÊN PHẢI) ---
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}