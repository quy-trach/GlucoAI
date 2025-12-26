// File: lib/features/home/presentation/widgets/home_section_title.dart
import 'package:flutter/material.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String iconPath; // <--- 1. Thêm biến chứa đường dẫn ảnh

  const HomeSectionTitle({
    super.key,
    required this.title,
    required this.iconPath, // <--- 2. Yêu cầu phải truyền ảnh vào
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath, 
          width: 27,
          height: 27,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}