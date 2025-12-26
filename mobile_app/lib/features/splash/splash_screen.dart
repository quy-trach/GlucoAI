import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Import
import '../../navigation/bottom_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // 1. TẮT MÀN HÌNH NATIVE NGAY KHI VÀO ĐÂY
    // Lúc này màn hình Flutter đã hiện lên thay thế, người dùng sẽ thấy Slogan xuất hiện
    FlutterNativeSplash.remove();

    // 2. Đếm ngược 3 giây để vào App chính
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [QUAN TRỌNG] Ảnh này phải giống hệt ảnh Native Splash về kích thước (ước lượng)
            // Hoặc bạn dùng ảnh Full Logo (Robot + Chữ GlucoAI) ở đây cũng được
            Image.asset('assets/images/logo_intro.png', width: 250), 
            
            const SizedBox(height: 18),

            // Dòng chữ này sẽ tạo cảm giác "xuất hiện thêm" trên nền Native cũ
            const Text(
              '"Sức khỏe của bạn, sứ mệnh của chúng tôi"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            // Loading xoay xoay
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}