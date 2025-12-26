import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // Biến để hiện vòng xoay khi đang tải

  @override
  void initState() {
    super.initState();

    // 1. Lấy thông tin User hiện tại từ Firebase
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Khách Demo';
    final String userEmail = user?.email ?? 'demo@glucoai.com';

    // 2. Link Tawk.to của bạn (Đã lấy từ mã bạn gửi)
    const String tawkBaseUrl = 'https://tawk.to/chat/6948227bf105e0197a371eaa/1jd0sdd0q';
    
    // 3. Tạo URL có kèm thông tin User (Để bên Tawk.to biết ai đang chat)
    // Cú pháp: url?name=TEN&email=EMAIL
    final String fullUrl = '$tawkBaseUrl?name=${Uri.encodeComponent(userName)}&email=${Uri.encodeComponent(userEmail)}';

    // 4. Cấu hình WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Bắt buộc để Tawk.to chạy
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Bắt đầu tải
          },
          onPageFinished: (String url) {
            // Tải xong -> Tắt vòng xoay loading
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Lỗi WebView: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(fullUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hỗ trợ trực tuyến"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        // Chỉnh màu nút Back và Tiêu đề
        iconTheme: const IconThemeData(color: Colors.black), 
        titleTextStyle: const TextStyle(
          color: Colors.black, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
      ),
      body: Stack(
        children: [
          // Widget hiển thị trang Chat
          WebViewWidget(controller: _controller),

          // Hiển thị vòng loading khi trang chưa tải xong
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
        ],
      ),
    );
  }
}