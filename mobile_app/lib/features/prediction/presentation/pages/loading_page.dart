// lib/features/prediction/presentation/pages/loading_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'result_page.dart'; 

class LoadingPage extends StatefulWidget {
  final Map<String, double> answers;

  const LoadingPage({super.key, required this.answers});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _processData();
  }

  void _processData() async {
    // 1. Giả lập độ trễ 3 giây
    final minWaitTime = Future.delayed(const Duration(seconds: 3));

    try {
      // 2. Gọi API gửi dữ liệu đi
      final apiCall = ApiService().predictDiabetes(widget.answers);

      // 3. Đợi cả 2 việc xong
      final results = await Future.wait([minWaitTime, apiCall]);
      
      // Lấy kết quả từ API
      final apiResult = results[1] as Map<String, dynamic>;

      if (!mounted) return;

      // ============================================================
      // GỘP BMI VÀO KẾT QUẢ
      // ============================================================
      
      Map<String, dynamic> finalData = Map.from(apiResult);
      finalData['bmi'] = widget.answers['BMI'] ?? 0.0;

      // ============================================================
      // 🔥 [MỚI THÊM] LƯU LỊCH SỬ LÊN FIREBASE TẠI ĐÂY 🔥
      // ============================================================
      // Không cần await để người dùng không phải đợi thêm
      FirestoreService().saveSurveyResult(
        inputs: widget.answers, 
        result: finalData
      );
      // ============================================================

      // 4. Chuyển sang trang Kết quả
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(resultData: finalData),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiệu ứng Loading
            const SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                color: Colors.blueAccent,
                backgroundColor: Colors.black12,
              ),
            ),
            const SizedBox(height: 30),
            
            // Text thông báo
            const Text(
              "AI ĐANG PHÂN TÍCH...",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueAccent,
                letterSpacing: 1.5
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Đang tổng hợp dữ liệu sức khỏe của bạn",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}