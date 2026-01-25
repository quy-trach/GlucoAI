import 'package:flutter/material.dart';
import '../../../prediction/presentation/pages/intro_page.dart';

class HomeCtaCard extends StatelessWidget {
  const HomeCtaCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Định nghĩa màu
    const Color primaryBlue = Color(0xFF007BFF);
    const Color textRed = Color.fromARGB(255, 250, 1, 1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),

        // 1. Chỉ hiển thị ảnh gốc, không dùng ColorFilter hay Gradient đè lên
        image: const DecorationImage(
          image: ResizeImage(
            AssetImage('assets/images/heartrate_bg.jpg'),
            width: 600,
          ),
          fit: BoxFit.cover,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hình ảnh bác sĩ
                Image.asset(
                  'assets/images/GlucoAI_Doctor_like.png',
                  height: 90,
                  width: 80,
                  fit: BoxFit.contain,
                  cacheWidth: 300,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BẮT ĐẦU KHẢO SÁT",
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Chỉ mất 2 phút để biết kết quả",
                        style: TextStyle(
                          color: textRed, // Chữ đỏ
                          fontSize: 14,
                          height: 1.2,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút bấm
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const IntroPage(), 
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryBlue,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  "BẮT ĐẦU NGAY",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
