// lib/features/history/presentation/pages/history_page.dart

import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Bỏ từ khóa 'const' khỏi Scaffold()
    return Scaffold(
      // Thêm const vào các thành phần con nếu chúng là hằng số (luôn tốt)
      appBar: AppBar(title: const Text("Lịch sử đánh giá")), 
      body: const Center(child: Text("Nội dung Lịch sử")),
    );
  }
}