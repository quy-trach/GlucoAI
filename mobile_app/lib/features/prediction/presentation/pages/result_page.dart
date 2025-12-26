// lib/features/prediction/presentation/pages/result_page.dart

import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Dữ liệu
  int level = 0;
  double riskPercent = 0.0;
  double safePercent = 0.0;
  String label = "";
  String advice = "";
  Color themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _parseData();

    // Setup Animation chạy từ 0 -> 1 trong 2 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseData() {
    final data = widget.resultData;
    level = (data['prediction_level'] as num?)?.toInt() ?? 0;
    riskPercent = (data['prob_risk'] as num?)?.toDouble() ?? 0.0;
    safePercent = (data['prob_safe'] as num?)?.toDouble() ?? (1.0 - riskPercent);
    label = data['label'] ?? "Kết quả";
    advice = data['advice'] ?? "Không có lời khuyên";

    // Chọn màu chủ đạo (Sửa lỗi thiếu ngoặc nhọn {})
    if (level == 2) {
      themeColor = Colors.red;       // Nguy hiểm
    } else if (level == 1) {
      themeColor = Colors.orange;    // Cảnh báo
    } else {
      themeColor = Colors.green;     // An toàn
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("KẾT QUẢ PHÂN TÍCH"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. PHẦN TIÊU ĐỀ KẾT QUẢ
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: themeColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            // 2. HAI VÒNG TRÒN % (ANIMATED)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedCircle("AN TOÀN", safePercent, Colors.green),
                _buildAnimatedCircle("NGUY CƠ", riskPercent, Colors.red),
              ],
            ),

            const SizedBox(height: 40),

            // 3. PHẦN LỜI KHUYÊN (Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Sửa lỗi deprecated: thay withOpacity bằng withValues(alpha: ...)
                color: themeColor.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: themeColor, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "LỜI KHUYÊN TỪ AI",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: themeColor
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    advice,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. NÚT VỀ TRANG CHỦ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text(
                  "VỀ TRANG CHỦ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ vòng tròn chạy số
  Widget _buildAnimatedCircle(String title, double percent, Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Giá trị hiện tại theo animation (0.0 -> percent)
        double currentPercent = percent * _animation.value;
        
        return Column(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Vòng tròn nền mờ
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    // Sửa lỗi deprecated
                    color: color.withValues(alpha: 0.1),
                  ),
                  // Vòng tròn giá trị chạy
                  CircularProgressIndicator(
                    value: currentPercent,
                    strokeWidth: 10,
                    color: color,
                    strokeCap: StrokeCap.round,
                  ),
                  // Số % ở giữa
                  Center(
                    child: Text(
                      "${(currentPercent * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: color
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey[700]
              ),
            ),
          ],
        );
      },
    );
  }
}