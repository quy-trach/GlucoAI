import 'package:flutter/material.dart';

class HomeKnowledgeItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color bgColor;
  final VoidCallback? onTap;

  const HomeKnowledgeItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(
                0,
              ), 
              clipBehavior: Clip.hardEdge, // Cắt ảnh nếu tràn viền
              child: _buildImage(imagePath), // <--- GỌI HÀM XỬ LÝ ẢNH Ở ĐÂY
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    // TRƯỜNG HỢP 1: Nếu là link Online (http/https)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    } 
    
    // TRƯỜNG HỢP 2: Nếu là ảnh trong máy (assets/)
    else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Nếu lỡ trên Firebase gõ sai tên ảnh assets thì hiện icon lỗi
          return const Icon(Icons.image_not_supported, color: Colors.grey);
        },
      );
    }
  }
}
