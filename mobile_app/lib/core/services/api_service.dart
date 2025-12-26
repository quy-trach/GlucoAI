// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // THAY ĐỔI TẠI ĐÂY: Dùng URL chính thức từ Hugging Face của bạn
  // Lưu ý: Đảm bảo URL có https:// và KHÔNG có dấu / ở cuối
 static const String baseUrl = "https://quydoantrung-glucoai-api.hf.space";

  Future<Map<String, dynamic>> predictDiabetes(Map<String, double> data) async {
    final url = Uri.parse("$baseUrl/predict");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // Hugging Face đôi khi yêu cầu Accept header
          "Accept": "application/json", 
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30)); // Tăng timeout vì HF Free có thể khởi động chậm

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Log lỗi chi tiết để dễ debug
        debugPrint("❌ Server Error: ${response.statusCode} - ${response.body}");
        throw Exception("Lỗi server (${response.statusCode})");
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      rethrow;
    }
  }
}