import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glucoai/navigation/bottom_nav.dart';
import '../../../../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user = FirebaseAuth.instance.currentUser;

  // --- LOGIC NGÀY/ĐÊM ---
  bool get _isNight {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  // --- LOGIC LỜI CHÀO ---
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Chào buổi sáng,";
    } else if (hour >= 12 && hour < 18) {
      return "Chào buổi chiều,";
    } else {
      return "Chào buổi tối,";
    }
  }

  // --- ẢNH NỀN HEADER ---
  String get _backgroundImagePath {
    if (_isNight) {
      return "assets/images/night_bg.jpg";
    } else {
      return "assets/images/day_bg.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ========================================================
          // PHẦN 1: HEADER (NGANG HÀNG + GRADIENT)
          // ========================================================
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_backgroundImagePath),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Hiệu ứng mờ dần ở chân ảnh (Gradient Overlay)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Nội dung Header
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. AVATAR
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? const Icon(Icons.person, size: 24, color: Colors.grey)
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 2. TEXT (LỜI CHÀO & TÊN)
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _greeting,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.displayName ?? "Khách Hàng",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),

                        // 3. ICONS
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                           
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // PHẦN 2: BODY (CẢNH BÁO Y TẾ & THÔNG TIN AI)
          // ========================================================
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    // 1. THẺ CẢNH BÁO Y TẾ (Tăng độ uy tín/trách nhiệm)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1), // Màu vàng nhạt
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFECB3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 24),
                              const SizedBox(width: 8),
                              Text(
                                "Khuyến cáo y tế",
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Kết quả dự đoán từ GlucoAI được tạo ra bởi mô hình trí tuệ nhân tạo và CHỈ MANG TÍNH CHẤT THAM KHẢO.",
                            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ứng dụng không thay thế cho các xét nghiệm y khoa hay chẩn đoán từ bác sĩ chuyên môn.",
                            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. THÔNG TIN MÔ HÌNH (Chứng minh cơ sở khoa học)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.psychology, "Mô hình", "XGBoost & Neural Network"),
                          const Divider(height: 24, thickness: 0.5),
                          _buildInfoRow(Icons.data_usage, "Dữ liệu", "BRFSS Annual Survey Data"),
                          const Divider(height: 24, thickness: 0.5),
                          _buildInfoRow(Icons.verified, "Hiệu suất", "~89.5% (Kiểm thử)"),
                          const Divider(height: 24, thickness: 0.5),
                          _buildInfoRow(Icons.security, "Bảo mật", "Mã hóa cục bộ"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. NÚT ĐĂNG XUẤT
                   SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: () async {
      // BƯỚC 1: Gọi hàm đăng xuất từ Firebase
      await AuthService().signOut();

      // Kiểm tra xem màn hình còn tồn tại không trước khi dùng context
      if (!context.mounted) return;

      // BƯỚC 2: Hiện thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã đăng xuất thành công!"),
          duration: Duration(seconds: 2), // Hiện nhanh trong 2s
          backgroundColor: Colors.green,
        ),
      );

      // BƯỚC 3: Chuyển hướng về trang Home
      // Cách 1: Nếu bạn dùng Route có tên (Named Route)
      // Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

      // Cách 2: Nếu bạn muốn gọi trực tiếp Widget trang chủ (Ví dụ: MainPage hoặc HomePage)
      // Lưu ý: Nhớ import file chứa trang Home của bạn ở đầu file
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const BottomNav() 
        ),
        (route) => false, 
      );
    },
    icon: const Icon(Icons.logout_rounded, size: 20),
    label: const Text(
      "Đăng xuất",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.redAccent,
      elevation: 0,
      side: const BorderSide(color: Colors.redAccent, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

                    const SizedBox(height: 20),

                    // 4. VERSION INFO
                    const Text(
                      "Phiên bản 1.0.0 (Beta)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PHỤ: Dòng thông tin AI ---
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}