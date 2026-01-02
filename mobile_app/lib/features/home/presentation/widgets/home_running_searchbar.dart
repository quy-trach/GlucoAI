import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class RunningSearchBar extends StatefulWidget {
  const RunningSearchBar({super.key});

  @override
  State<RunningSearchBar> createState() => _RunningSearchBarState();
}

class _RunningSearchBarState extends State<RunningSearchBar> {
  // Controller để kiểm soát nội dung nhập
  final TextEditingController _controller = TextEditingController();
  // Biến kiểm tra xem ô nhập có trống không
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của text field
    _controller.addListener(() {
      setState(() {
        _isEmpty = _controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Dùng Stack để xếp chồng Hiệu ứng chữ xuống dưới TextField
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 1. LỚP HIỆU ỨNG CHỮ CHẠY (Nằm dưới)
          // Chỉ hiện khi TextField rỗng
          if (_isEmpty)
            Positioned(
              left: 48, // Cách lề trái để tránh Icon Search (12 padding + 24 icon + 12 gap)
              right: 12,
              child: IgnorePointer( // Cho phép bấm xuyên qua để vào TextField
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400, // Màu chữ mờ giống hintText
                  ),
                  child: AnimatedTextKit(
                    repeatForever: true, // Chạy lặp lại mãi mãi
                    pause: const Duration(seconds: 2), // Nghỉ 2s sau mỗi câu
                    animatedTexts: [
                      // Danh sách các câu slogan "uy tín" của bạn
                      TypewriterAnimatedText('Tìm kiếm thuốc...', speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText('Tra cứu chỉ số đường huyết...', speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText('Hỏi đáp với Bác sĩ AI...', speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText('Dấu hiệu tiểu đường...', speed: const Duration(milliseconds: 80)),
                    ],
                    onTap: () {
                      // Xử lý khi bấm vào chữ (thường không cần vì đã có IgnorePointer)
                    },
                  ),
                ),
              ),
            ),

          // 2. LỚP TEXTFIELD (Nằm trên cùng)
          TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              // QUAN TRỌNG: Không dùng hintText ở đây nữa
              hintText: null, 
              
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 22,
              ),
              border: InputBorder.none, // Bỏ viền mặc định
              contentPadding: const EdgeInsets.symmetric(
                vertical: 11, // Căn chỉnh cho chữ nhập vào giữa
                horizontal: 12,
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}