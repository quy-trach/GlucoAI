import 'package:flutter/material.dart';
// --- IMPORTS LOGIC ---
import '../../../../core/models/medical_center_model.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/medical_card.dart';
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
  String label = "";
  String advice = "";
  Color themeColor = Colors.green;

  // Dữ liệu bệnh viện
  List<MedicalCenterModel> _medicalCenters = [];
  bool _isLoadingMedical = true;

  @override
  void initState() {
    super.initState();
    _parseData();
    _fetchMedicalCenters();

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
    riskPercent = (data['prob_risk'] as num?)?.toDouble() ?? 0.0;
    safePercent = (data['prob_safe'] as num?)?.toDouble() ?? (1.0 - riskPercent);
    bmiValue = (data['bmi'] as num?)?.toDouble() ?? (data['BMI'] as num?)?.toDouble() ?? 0.0;
    int prediction = (data['prediction'] as num?)?.toInt() ?? 0;

    final adviceData = AdviceHelper.getAdvice(prediction, bmiValue);
    label = adviceData['label'];
    themeColor = adviceData['color'];
    advice = adviceData['content'];
  }

  Future<void> _fetchMedicalCenters() async {
    final centers = await LocationService().getNearbyHospitals();
    if (mounted) {
      setState(() {
        _medicalCenters = centers;
        _isLoadingMedical = false;
      });
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
        titleTextStyle: const TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 16
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. HEADER LABEL
            Text(
              label,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: themeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // 2. HAI VÒNG TRÒN (Giữ nguyên tối giản)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMinimalCircle("An toàn", safePercent, Colors.green),
                Container(width: 1, height: 50, color: Colors.grey[200]),
                _buildMinimalCircle("Nguy cơ", riskPercent, Colors.red),
              ],
            ),

            const SizedBox(height: 30),

            // 3. BMI CARD (Tách biệt, có border nhẹ)
            if (bmiValue > 0) 
              _buildSeparateBMICard(),

            const SizedBox(height: 20),

            // 4. LỜI KHUYÊN (Border nhẹ, chữ đậm)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                // Viền nhẹ bao quanh
                border: Border.all(color: Colors.grey.shade300), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_circle, color: themeColor, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        "LỜI KHUYÊN DÀNH CHO BẠN",
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: themeColor // Màu tiêu đề theo mức độ nguy cơ
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Nội dung chữ đậm màu hơn (black87)
                  Text(
                    advice,
                    style: const TextStyle(
                      fontSize: 15, 
                      height: 1.6, 
                      color: Colors.black87, // Đen rõ ràng, không mờ
                      fontWeight: FontWeight.w400
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: Color(0xFFF0F0F0), thickness: 1),
            const SizedBox(height: 20),

            // 5. DANH SÁCH BỆNH VIỆN
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Cơ sở y tế lân cận",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoadingMedical)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue
                  ),
              ))
            else if (_medicalCenters.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.map_outlined, color: Colors.grey[400], size: 30),
                    const SizedBox(height: 8),
                    const Text("Không tìm thấy cơ sở y tế.", style: TextStyle(color: Colors.grey)),
                    TextButton(onPressed: _fetchMedicalCenters, child: const Text("Thử lại"))
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medicalCenters.length,
                itemBuilder: (context, index) {
                  return MedicalCenterCard(
                    center: _medicalCenters[index],
                    isCompact: false,
                  );
                },
              ),
              
            const SizedBox(height: 30),
             // Nút Quay về
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Quay về Trang chủ", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET VÒNG TRÒN (Giữ nguyên) ---
  Widget _buildMinimalCircle(String title, double percent, Color color) {
    return Column(
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
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[100],
                    color: color,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  "${(percent * _animation.value * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  // --- WIDGET BMI RIÊNG BIỆT (ĐÃ SỬA DÙNG ẢNH) ---
  Widget _buildSeparateBMICard() {
    String status = "";
    Color color = Colors.grey;

    if (bmiValue < 18.5) {
      status = "Thiếu cân";
      color = Colors.orange;
    } else if (bmiValue < 25) {
      status = "Bình thường";
      color = Colors.green;
    } else if (bmiValue < 30) {
      status = "Thừa cân";
      color = Colors.orange;
    } else {
      status = "Béo phì";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // Viền mỏng phân cách
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[50], // Nền nhẹ cho ảnh đỡ trơ
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icon/icon_weight.png', 
              fit: BoxFit.contain,
              errorBuilder: (c, o, s) => Icon(Icons.monitor_weight, color: Colors.blue[300]), // Icon dự phòng
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Thông tin Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chỉ số BMI",
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      bmiValue.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    // Badge trạng thái nhỏ gọn
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}