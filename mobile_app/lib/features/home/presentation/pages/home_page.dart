import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'knowledge_detail_page.dart';
// --- IMPORTS CỦA BẠN ---
import '../widgets/home_header.dart'; 
import '../widgets/home_cta_card.dart';
import '../widgets/home_result_card.dart';
import '../widgets/home_health_stats.dart';
import '../widgets/home_section_title.dart'; 
import '../widgets/home_knowledge_list.dart'; 
// --- IMPORTS LOGIC MỚI ---
import '../../../../core/services/firestore_service.dart';
import '../../../prediction/presentation/pages/result_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      body: CustomScrollView(
        // 1. Hiệu ứng lướt mượt mà
        physics: const BouncingScrollPhysics(), 
        
        slivers: [
          // --- PHẦN 1: HEADER CO GIÃN ---
          const HomeSliverHeader(),

          // --- PHẦN 2: THẺ CTA ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: const RepaintBoundary( 
                child: HomeCtaCard(),
              ),
            ),
          ),

          // ============================================================
          // 🔥 PHẦN 3: KẾT QUẢ GẦN NHẤT (ĐÃ SỬA ĐỂ KẾT NỐI FIREBASE) 🔥
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: StreamBuilder<QuerySnapshot>(
                // Gọi hàm lấy 1 dòng mới nhất từ Service
                stream: FirestoreService().getLatestResultStream(),
                builder: (context, snapshot) {
                  // Biến chứa dữ liệu (mặc định là null)
                  Map<String, dynamic>? latestData;

                  // Nếu có dữ liệu tải về thành công
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    latestData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  }

                  // Truyền dữ liệu vào Card
                  return RepaintBoundary(
                    child: HomeResultCard(
                      resultData: latestData, // Truyền data vào đây
                      onTap: () {
                        if (latestData != null) {
                          // Có kết quả -> Bấm vào xem chi tiết
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(resultData: latestData!),
                            ),
                          );
                        } else {
                          // Chưa có kết quả -> Thông báo hoặc chuyển sang trang đo
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Bạn chưa có lịch sử đo nào.")),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // ============================================================

          // --- PHẦN 4: CHỈ SỐ SỨC KHỎE ---
          // ============================================================
          // PHẦN 4: CHỈ SỐ SỨC KHỎE (ĐÃ CẬP NHẬT STREAMBUILDER)
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              // 1. Bọc trong StreamBuilder để lấy dữ liệu
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getLatestResultStream(), // Gọi hàm lấy data mới nhất
                builder: (context, snapshot) {
                  
                  // 2. Xử lý dữ liệu lấy được
                  Map<String, dynamic>? latestData;
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    latestData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  }

                  // 3. Hiển thị giao diện
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const HomeSectionTitle(
                        title: "Chỉ số sức khỏe",
                        iconPath: "assets/icon/icon_heart_small.png", 
                      ),
                       const SizedBox(height: 12),
                       
                       // 4. TRUYỀN DỮ LIỆU VÀO WIDGET MỚI CỦA BẠN
                       HomeHealthStats(data: latestData), 
                    ],
                  );
                },
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

         // ============================================================
          // 🔥 PHẦN 6: DANH SÁCH BÀI VIẾT TỪ FIREBASE 🔥
          // ============================================================
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().getKnowledgeStream(),
            builder: (context, snapshot) {
              // 1. Đang tải hoặc lỗi -> Hiện khung chờ hoặc rỗng
              if (!snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              // 2. Danh sách bài viết
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Lấy dữ liệu từ Firestore
                      final data = docs[index].data() as Map<String, dynamic>;
                      
                      final String title = data['title'] ?? "Không có tiêu đề";
                      final String imagePath = data['image'] ?? "assets/images/thumb_default.png"; // Ảnh mặc định nếu thiếu
                      final String content = data['content'] ?? "Nội dung đang cập nhật...";
                      
                      // Logic màu nền xen kẽ cho đẹp (Cam nhạt -> Xanh nhạt)
                      final Color itemColor = (index % 2 == 0) 
                          ? const Color(0xFFFFF3E0) // Cam
                          : const Color(0xFFE8F5E9); // Xanh

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HomeKnowledgeItem(
                          title: title,
                          imagePath: imagePath,
                          bgColor: itemColor,
                          onTap: () {
                            // Mở trang chi tiết với nội dung từ Firebase
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KnowledgeDetailPage(
                                  title: title,
                                  imagePath: imagePath,
                                  bgColor: itemColor,
                                  content: content,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: docs.length, // Số lượng bài lấy về được
                  ),
                ),
              );
            },
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