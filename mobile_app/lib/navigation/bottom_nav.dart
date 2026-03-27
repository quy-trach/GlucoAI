import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import các trang
import '../features/home/presentation/pages/home_page.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/history/presentation/pages/history_page.dart';

// Import Widgets helper
import '../../core/widgets/login_request_dialog.dart';
import '../../core/widgets/fade_indexed_stack.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': CupertinoIcons.house_fill, 'label': 'Trang chủ'},
    {'icon': CupertinoIcons.calendar_today, 'label': 'Lịch sử'},
    {'icon': CupertinoIcons.person_fill, 'label': 'Tài khoản'},
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showDialog(
          context: context,
          builder: (context) => LoginRequestDialog(
            onSuccess: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        );
        return;
      }
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Lắng nghe sự thay đổi của User tại đây
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final String uidKey = user?.uid ?? 'guest';

        final List<Widget> pages = [
          HomePage(key: ValueKey('home_$uidKey')), 
          HistoryPage(key: ValueKey('history_$uidKey')), 
          const AccountPage(),
        ];

        return Scaffold(
          extendBody: false,
          
          body: FadeIndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // --- NAV XANH FULL WIDTH---
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF007BFF), 
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                height: 65,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (index) {
                    return _buildBlueStyleItem(
                      index: index,
                      icon: _navItems[index]['icon'],
                      label: _navItems[index]['label'],
                      isSelected: index == _currentIndex,
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlueStyleItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    const Color activeContentColor = Colors.white;
    final Color inactiveContentColor = Colors.white.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? activeContentColor : inactiveContentColor,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: activeContentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
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