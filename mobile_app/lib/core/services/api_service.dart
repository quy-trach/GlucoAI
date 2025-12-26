// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://192.168.1.5:8000";
  Future<Map<String, dynamic>> predictDiabetes(Map<String, double> data) async {
    final url = Uri.parse("$_baseUrl/predict");
    
    try {
      debugPrint("🚀 Đang gửi dữ liệu đến: $url");
      debugPrint("📦 Data: $data");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      debugPrint("📩 Server phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Thành công!
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối: $e");
      throw Exception("Không kết nối được với Server. Hãy kiểm tra IP và Wifi.");
    }
  }
}