import 'package:flutter/material.dart';

class HomeReminderBanner extends StatelessWidget {
  const HomeReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const double bannerHeight = 40;
    // Độ rộng phần bên phải (Màu xanh nhạt)
    const double rightSectionWidth = 130;

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ==========================================
            // LỚP 1: BÊN TRÁI (LINH VẬT + TEXT TĨNH)
            // ==========================================
            Positioned.fill(
              child: Row(
                children: [
                  const SizedBox(width: 8),

                  // Hiệu ứng bong bóng + Linh vật
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/GlucoAI_Doctor.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.smart_toy_rounded,
                            size: 20,
                            color: Colors.orange,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(width: 6),

                  // TEXT TĨNH
                  const Text(
                    "Lắng nghe cơ thể mỗi ngày",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // LỚP 2: BÊN PHẢI
            // ==========================================
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: rightSectionWidth,
              child: ClipPath(
                clipper: _DiagonalClipper(),
                child: Container(
                  color: const Color.fromARGB(255, 255, 107, 1).withValues(alpha: 0.8),
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hỗ trợ 24/7", 
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                       const SizedBox(width: 6),
                      const Icon(
                        Icons.headset_mic_rounded,
                        size: 16,
                        color: Colors.white,
                      ),  
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// CLASS CẮT HÌNH & VẼ BÓNG
// ----------------------------------------------------

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(35, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
