import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../support/presentation/pages/chat_page.dart'; 
import 'home_running_searchbar.dart';
class HomeSliverHeader extends StatelessWidget {
  const HomeSliverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _HomeHeaderDelegate(),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const String _logoPath = 'assets/images/logo_glucoAI.png';
  static const Color _primaryColor = Color(0xFF007BFF);

  @override
  double get maxExtent => 170.0;

  @override
  double get minExtent => 120.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final User? user = FirebaseAuth.instance.currentUser;

    final double percent = shrinkOffset / (maxExtent - minExtent);
    final double opacity = (1.0 - percent * 1.5).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // 1. PHẦN LOGO + AVATAR + ICON
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cụm Logo bên trái 
                      Row(
                        children: [
                          Image.asset(
                            _logoPath,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                     
                        ],
                      ),

                      // 3. Cụm bên phải: Avatar + Nút tin nhắn
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            // SỰ KIỆN CHUYỂN TRANG
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          
                          if (user != null)
                            Container(
                              margin: const EdgeInsets.only(
                                right: 12,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ), 
                              ),
                              child: CircleAvatar(
                                radius: 14, 
                                backgroundColor: Colors.grey[300],
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. THANH TÌM KIẾM
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 45,
             child: RunningSearchBar(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}