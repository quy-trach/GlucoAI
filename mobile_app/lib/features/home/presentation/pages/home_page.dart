import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'knowledge_detail_page.dart';

// --- IMPORTS CỦA TÔI ---
import '../widgets/home_header.dart';
import '../widgets/home_cta_card.dart';
import '../widgets/home_result_card.dart';
import '../widgets/home_health_stats.dart';
import '../widgets/home_section_title.dart';
import '../widgets/home_knowledge_list.dart';
import '../widgets/home_reminder_banner.dart';

// --- IMPORTS LOGIC MỚI (LOCATION & FIREBASE) ---
import '../../../../core/models/medical_center_model.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/medical_card.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../prediction/presentation/pages/result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- BIẾN STATE CHO TRUNG TÂM Y TẾ ---
  // MedicalCenterModel? _nearestCenter;
  List<MedicalCenterModel> _nearestCenters = [];
  bool _isLoadingMedical = true;

  @override
  void initState() {
    super.initState();
    _loadNearestHospital(); // Gọi hàm tải dữ liệu khi mở màn hình
  }

  // Hàm gọi Service lấy dữ liệu thật từ OpenStreetMap
  Future<void> _loadNearestHospital() async {
    final centers = await LocationService().getNearbyHospitals();
    
    if (mounted) {
      setState(() {
        // Lấy 2 cái đầu tiên (nếu danh sách đủ dài)
        _nearestCenters = centers.take(2).toList(); 
        _isLoadingMedical = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoadingMedical = true;
      _nearestCenters = []; // Reset danh sách
    });
    await _loadNearestHospital();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      // 🔥 1. BỌC RefreshIndicator ĐỂ KÉO XUỐNG RELOAD
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Gọi hàm reload khi kéo
        color: Colors.blue,
        
        child: CustomScrollView(
          // 🔥 Luôn cho phép cuộn để tính năng kéo-reload hoạt động ngay cả khi list ngắn
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          
          slivers: [
            // --- PHẦN 0: HEADER ---
            const HomeSliverHeader(),

            // --- PHẦN 1: BANNER ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: const RepaintBoundary(child: HomeReminderBanner()),
              ),
            ),

            // --- PHẦN 2: CTA CARD ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: const RepaintBoundary(child: HomeCtaCard()),
              ),
            ),

            // --- PHẦN 3: KẾT QUẢ GẦN NHẤT (FIREBASE) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getLatestResultStream(),
                  builder: (context, snapshot) {
                    Map<String, dynamic>? latestData;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      latestData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    }

                    return RepaintBoundary(
                      child: HomeResultCard(
                        resultData: latestData,
                        onTap: () {
                          if (latestData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultPage(resultData: latestData!),
                              ),
                            );
                          } else {
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
            // PHẦN MỚI: TRUNG TÂM Y TẾ GẦN NHẤT (CÓ NÚT RETRY)
            // ============================================================
          SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Column(
                  children: [
                    // Tiêu đề section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const HomeSectionTitle(
                          title: "Cơ sở y tế gần nhất",
                          iconPath: "assets/icon/icon_hospital.png", 
                        ),
                        if (_isLoadingMedical)
                          const SizedBox(
                            width: 14, height: 14, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                              )
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nội dung chính
                    if (_isLoadingMedical)
                      // Skeleton Loading
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      )
                    // 🟢 LOGIC MỚI: Check danh sách có rỗng không
                    else if (_nearestCenters.isNotEmpty)
                      Column(
                        children: _nearestCenters.map((center) {
                          // Duyệt qua từng cái để tạo Card
                          return MedicalCenterCard(
                            center: center,
                            isCompact: true, 
                          );
                        }).toList(),
                      )
                    else
                      // Nút thử lại (Giữ nguyên)
                      InkWell(
                        onTap: _onRefresh,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.refresh, color: Colors.red, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Không tìm thấy vị trí",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    Text(
                                      "Bật GPS rồi bấm vào đây để thử lại.",
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // ============================================================

            // --- PHẦN 4: CHỈ SỐ SỨC KHỎE ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getLatestResultStream(),
                  builder: (context, snapshot) {
                    Map<String, dynamic>? latestData;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      latestData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeSectionTitle(
                          title: "Thông tin sức khỏe",
                          iconPath: "assets/icon/icon_heart_small.png",
                        ),
                        const SizedBox(height: 10),
                        HomeHealthStats(data: latestData),
                      ],
                    );
                  },
                ),
              ),
            ),

            // --- PHẦN 5: GÓC KIẾN THỨC ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: const HomeSectionTitle(
                  title: "Góc kiến thức",
                  iconPath: "assets/icon/icon_book.png",
                ),
              ),
            ),

            // --- PHẦN 6: LIST KIẾN THỨC (FIREBASE) ---
            StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getKnowledgeStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final String title = data['title'] ?? "Không có tiêu đề";
                        final String imagePath = data['image'] ?? "assets/images/thumb_default.png";
                        final String content = data['content'] ?? "Nội dung đang cập nhật...";
                        final Color itemColor = (index % 2 == 0) ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HomeKnowledgeItem(
                            title: title,
                            imagePath: imagePath,
                            bgColor: itemColor,
                            onTap: () {
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
                      childCount: docs.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}