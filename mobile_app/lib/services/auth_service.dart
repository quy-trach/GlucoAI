import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Hàm đăng nhập Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Mở popup chọn Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // Người dùng bấm hủy
      }

      // 2. Lấy xác thực từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Tạo credential cho Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;

    } catch (e) {
      // Dùng print để debug tạm thời (VS Code sẽ cảnh báo, kệ nó)
      debugPrint("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  // Hàm đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}