import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class LoginRequestDialog extends StatelessWidget {
  final VoidCallback onSuccess; // Hàm chạy khi đăng nhập thành công

  const LoginRequestDialog({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24), // Cách lề màn hình
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icon minh họa (Ổ khóa hoặc User)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1), // Nền xanh nhạt
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded, // Icon ổ khóa + người
                size: 40,
                color: Color(0xFF007BFF),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. Tiêu đề
            const Text(
              "Yêu cầu đăng nhập",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // 3. Nội dung mô tả
            const Text(
              "Bạn cần đăng nhập tài khoản để truy cập tính năng này và đồng bộ dữ liệu của mình.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5, // Giãn dòng cho dễ đọc
              ),
            ),

            const SizedBox(height: 30),

            // 4. Nút Google (Đã đổi sang Image.asset)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Đóng popup trước để tránh lỗi context
                  Navigator.of(context).pop();

                  // Gọi hàm đăng nhập
                  User? user = await AuthService().signInWithGoogle();

                  if (user != null) {
                    onSuccess(); // Chuyển trang
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Xin chào ${user.displayName}!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc vừa phải
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 NƠI BẠN TỰ THÊM ẢNH LOCAL 🔥
                    Image.asset(
                      'assets/images/google_logo.png', // Thay đường dẫn của bạn vào đây
                      height: 24,
                      width: 24,
                      // Nếu chưa có ảnh, nó sẽ báo lỗi đỏ. 
                      // Bạn có thể dùng tạm Icon để test:
                      // errorBuilder: (ctx, _, __) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Tiếp tục bằng Google",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 5. Nút Hủy (Để sau)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Để sau",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}