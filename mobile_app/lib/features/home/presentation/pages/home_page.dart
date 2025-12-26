import 'package:flutter/material.dart';

// Import các widgets
import '../widgets/home_header.dart'; 
import '../widgets/home_cta_card.dart';
import '../widgets/home_result_card.dart';
import '../widgets/home_health_stats.dart';
import '../widgets/home_section_title.dart'; 
import '../widgets/home_knowledge_list.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      body: CustomScrollView(
        // 1. Thêm Physics để lướt có trớn, mượt mà hơn (giống iOS)
        physics: const BouncingScrollPhysics(), 
        
        slivers: [
          // --- PHẦN 1: HEADER CO GIÃN ---
          const HomeSliverHeader(),

          // --- PHẦN 2: THẺ CTA (Tách riêng ra) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              // RepaintBoundary: Bảo Flutter "đừng vẽ lại cái này nếu chỉ lướt qua" -> Siêu mượt
              child: const RepaintBoundary( 
                child: HomeCtaCard(),
              ),
            ),
          ),

          // --- PHẦN 3: KẾT QUẢ GẦN NHẤT ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: const RepaintBoundary(
                child: HomeResultCard(),
              ),
            ),
          ),

          // --- PHẦN 4: CHỈ SỐ SỨC KHỎE (Carousel) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                   HomeSectionTitle(
                    title: "Chỉ số sức khỏe",
                    iconPath: "assets/icon/icon_heart_small.png", 
                  ),
                   SizedBox(height: 12),
                   // Carousel này nặng, tách ra giúp scroll mượt hơn nhiều
                   HomeHealthStats(), 
                ],
              ),
            ),
          ),

          // --- PHẦN 5: TIÊU ĐỀ GÓC KIẾN THỨC ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: const HomeSectionTitle(
                title: "Góc kiến thức",
                iconPath: "assets/icon/icon_book.png", 
              ),
            ),
          ),

          // --- PHẦN 6: DANH SÁCH BÀI VIẾT (QUAN TRỌNG NHẤT) ---
          // Thay vì dùng Column, ta dùng SliverList.
          // Nó chỉ render các item đang hiển thị trên màn hình.
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // Giả lập danh sách bài viết
                  // Trong thực tế bạn sẽ lấy từ List data
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeKnowledgeItem(
                        title: "5 dấu hiệu sớm của bệnh tiểu đường bạn cần biết",
                        imagePath: "assets/images/thumb_diabetes_signs.png",
                        bgColor: const Color(0xFFFFF3E0),
                        onTap: () {},
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeKnowledgeItem(
                        title: "Chế độ ăn Eat Clean giúp ổn định đường huyết",
                        imagePath: "assets/images/thumb_eat_clean.png",
                        bgColor: const Color(0xFFE8F5E9),
                        onTap: () {},
                      ),
                    );
                  }
                },
                childCount: 2, // Số lượng bài viết
              ),
            ),
          ),

          // --- KHOẢNG TRỐNG DƯỚI CÙNG ---
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}