import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import '../../services/auth_service.dart'; // 2. Import Auth Service của bạn

import '../features/home/presentation/pages/home_page.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/history/presentation/pages/history_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [HomePage(), HistoryPage(), AccountPage()];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': CupertinoIcons.house_fill, 'label': 'Trang chủ'},
    {'icon': CupertinoIcons.calendar_today, 'label': 'Lịch sử'},
    {'icon': CupertinoIcons.person_fill, 'label': 'Tài khoản'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- HÀM HIỂN THỊ POPUP ĐĂNG NHẬP ---
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              "Thông báo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bạn cần đăng nhập để truy cập vào Tài khoản cá nhân.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Đóng popup hiện tại
                    Navigator.of(context).pop();
                    
                    // 2. Gọi hàm đăng nhập
                    User? user = await AuthService().signInWithGoogle();

                    // 3. Nếu thành công -> Chuyển sang tab Tài khoản
                    if (user != null && mounted) {
                      setState(() {
                        _currentIndex = 2; // Index của tab Tài khoản
                      });
                      _pageController.jumpToPage(2);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Xin chào ${user.displayName}!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Google
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Đăng nhập bằng Google",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- XỬ LÝ KHI BẤM NÚT NAV ---
  void _onItemTapped(int index) {
    // Logic chặn truy cập tab Tài khoản (Index = 2)
    if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Chưa đăng nhập -> Hiện Popup và Dừng lại
        _showLoginDialog();
        return; 
      }
    }

    // Nếu không bị chặn thì chạy bình thường
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF007BFF);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // QUAN TRỌNG: Tắt vuốt tay để bắt buộc dùng nav bar
        // (Tránh trường hợp vuốt từ Lịch sử sang Tài khoản để né login)
        physics: const NeverScrollableScrollPhysics(), 
        children: _pages,
      ),

      bottomNavigationBar: Container(
        height: 65 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
          top: 8,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF007BFF),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildFloatingPillItem(
              index: index,
              icon: _navItems[index]['icon'] as IconData,
              label: _navItems[index]['label'] as String,
              activeColor: activeColor,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFloatingPillItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final bool isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.6,
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Roboto',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}