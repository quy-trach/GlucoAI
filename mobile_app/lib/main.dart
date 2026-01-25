import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
// Chuyển main thành async để đợi Firebase nạp xong
void main() async {
  // 1. Dòng này BẮT BUỘC phải có khi dùng Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Khởi tạo Firebase
  await Firebase.initializeApp();
  // 3. Khởi tạo định dạng ngày tháng cho tiếng Việt
 await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlucoAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Bạn có thể để SplashScreen trước, 
      // trong SplashScreen sẽ kiểm tra Auth để chuyển hướng sau
      home: const SplashScreen(), 
    );
  }
}