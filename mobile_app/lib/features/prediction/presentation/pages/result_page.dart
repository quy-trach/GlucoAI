import 'package:flutter/material.dart';
// Nhớ import file vừa tạo ở trên (sửa đường dẫn nếu cần)
import '../../utils/advice_helper.dart'; 

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Dữ liệu hiển thị
  double riskPercent = 0.0;
  double safePercent = 0.0;
  double bmiValue = 0.0;
  
  // Các biến này sẽ lấy từ AdviceHelper
  String label = "";
  String advice = "";
  Color themeColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _parseData(); // <-- Hàm này giờ sẽ gọi AdviceHelper

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

  // --- ĐÂY LÀ PHẦN SỬA ĐỔI CHÍNH ---
  void _parseData() {
    final data = widget.resultData;

    // 1. Lấy dữ liệu số
    riskPercent = (data['prob_risk'] as num?)?.toDouble() ?? 0.0;
    safePercent = (data['prob_safe'] as num?)?.toDouble() ?? (1.0 - riskPercent);
    bmiValue = (data['bmi'] as num?)?.toDouble() ?? (data['BMI'] as num?)?.toDouble() ?? 0.0;
    int prediction = (data['prediction'] as num?)?.toInt() ?? 0;

    // 2. Gọi Helper để lấy lời khuyên chi tiết
    // Truyền kết quả dự đoán và BMI vào để lấy lời khuyên phù hợp
    final adviceData = AdviceHelper.getAdvice(prediction, bmiValue);

    // 3. Gán dữ liệu vào biến giao diện
    label = adviceData['label'];
    themeColor = adviceData['color'];
    advice = adviceData['content'];
  }
  // ----------------------------------

  @override
  Widget build(BuildContext context) {
    // ... (Phần UI bên dưới GIỮ NGUYÊN KHÔNG ĐỔI) ...
    // Copy lại toàn bộ phần build() và các widget con từ code trước
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("KẾT QUẢ PHÂN TÍCH"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // TIÊU ĐỀ
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800, 
                color: themeColor,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 24),

            // HAI THẺ KÍNH
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassPercentCard("AN TOÀN", safePercent, Colors.green),
                const SizedBox(width: 16),
                _buildGlassPercentCard("NGUY CƠ", riskPercent, Colors.red),
              ],
            ),

            const SizedBox(height: 24),

            // BMI
            if (bmiValue > 0) ...[
              _buildBMICard(),
              const SizedBox(height: 24),
            ],

            // LỜI KHUYÊN (Đã chi tiết hơn nhờ Helper)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.08), 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: themeColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "LỜI KHUYÊN CHUYÊN GIA", // Đổi tiêu đề cho ngầu
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: themeColor
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    advice,
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // NÚT HOME
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  "VỀ TRANG CHỦ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Giữ nguyên các hàm _buildGlassPercentCard và _buildBMICard cũ) ...
  // --- WIDGET 1: THẺ KÍNH HIỂN THỊ % ---
  Widget _buildGlassPercentCard(String title, double percent, Color color) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2), 
            width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: percent * _animation.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        color: color,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      "${(percent * _animation.value * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: color
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: Colors.grey[700]
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 2: THẺ BMI ---
  Widget _buildBMICard() {
    String bmiStatus = "Bình thường";
    Color bmiColor = Colors.green;
    
    if (bmiValue < 18.5) {
      bmiStatus = "Thiếu cân";
      bmiColor = Colors.orange;
    } else if (bmiValue >= 25 && bmiValue < 30) {
      bmiStatus = "Thừa cân";
      bmiColor = Colors.orange;
    } else if (bmiValue >= 30) {
      bmiStatus = "Béo phì";
      bmiColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monitor_weight, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chỉ số BMI của bạn",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      bmiValue.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.black87
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bmiColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bmiStatus,
                        style: TextStyle(
                          color: bmiColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}