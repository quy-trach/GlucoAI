import 'package:flutter/material.dart';
class KnowledgeDetailPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String content;
  final Color bgColor;

  const KnowledgeDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.content,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. ẢNH BÌA CO GIÃN (SLIVER APP BAR) ---
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white, 
            elevation: 0,
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8), 
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bgColor, 
                width: double.infinity,
                height: double.infinity,
                child: _buildHeaderImage(imagePath),
              ),
            ),
          ),

          // --- 2. NỘI DUNG BÀI VIẾT ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        "Cập nhật hôm nay",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.verified_user, size: 14, color: Colors.blue[600]),
                      const SizedBox(width: 6),
                      Text(
                        "Kiến thức y khoa",
                        style: TextStyle(fontSize: 12, color: Colors.blue[600], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM XỬ LÝ ẢNH (Cho phép cả Link mạng và Ảnh máy) ---
  Widget _buildHeaderImage(String path) {
    if (path.startsWith('http')) {
      // 1. Ảnh từ Firebase (URL)
      return Image.network(
        path,
        fit: BoxFit.cover, 
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => 
            const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      // 2. Ảnh từ Assets (Trong máy)
      return Image.asset(
        path,
        fit: BoxFit.cover, 
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => 
            const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
      );
    }
  }
}