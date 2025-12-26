// lib/features/prediction/presentation/pages/loading_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/services/api_service.dart';
import 'result_page.dart'; // Chúng ta sẽ tạo file này ở bước 2

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
    // 1. Bắt đầu đếm thời gian tối thiểu (ví dụ 3 giây cho ngầu)
    // Dù API trả về nhanh thì vẫn bắt đợi đủ 3s mới hiện kết quả
    final minWaitTime = Future.delayed(const Duration(seconds: 3));

    try {
      // 2. Gọi API thực tế song song
      final apiCall = ApiService().predictDiabetes(widget.answers);

      // 3. Đợi cả 2 việc xong (Time & API)
      final results = await Future.wait([minWaitTime, apiCall]);
      
      // Lấy kết quả từ API (phần tử thứ 2 trong mảng results)
      final apiResult = results[1] as Map<String, dynamic>;

      if (!mounted) return;

      // 4. Chuyển sang trang Kết quả (Xóa trang loading khỏi lịch sử back)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(resultData: apiResult),
        ),
      );

    } catch (e) {
      // Xử lý lỗi
      if (!mounted) return;
      Navigator.pop(context); // Quay về Survey
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
            // Ảnh hoặc Icon động
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