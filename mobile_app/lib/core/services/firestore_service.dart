import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // ----------------------------------------------------------------
  // HÀM LẤY USER ID HIỆN TẠI
  // ----------------------------------------------------------------
  String get currentUserId {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid; // Trả về ID thật của Google (ví dụ: 'A1b2C3d4...')
    } else {
      return "anonymous_device"; // Nếu chưa đăng nhập (để tránh lỗi null)
    }
  }

  // ---------------------------------------------------
  // HÀM 1: LƯU KẾT QUẢ
  // ---------------------------------------------------
  Future<void> saveSurveyResult({
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> result,
  }) async {
    try {
      // Kiểm tra xem đã đăng nhập chưa
      if (_auth.currentUser == null) {
        debugPrint("⚠️ Chưa đăng nhập, không lưu được vào tài khoản!");
        // Tùy bạn: Có thể return luôn hoặc vẫn lưu dạng anonymous
      }

      final dataToSave = {
        "userId": currentUserId, // <--- 3. Dùng ID động ở đây
        "timestamp": FieldValue.serverTimestamp(),
        "prediction": result['prediction'],
        "prob_risk": result['prob_risk'],
        "prob_safe": result['prob_safe'],
        "bmi": result['bmi'] ?? 0.0,
        "input_data": inputs,
        
        // (Tùy chọn) Lưu thêm email để dễ quản lý
        "user_email": _auth.currentUser?.email ?? "No Email", 
      };

      await _db.collection('survey_history').add(dataToSave);
      debugPrint("✅ Đã lưu lịch sử cho user: $currentUserId");

    } catch (e) {
      debugPrint("❌ Lỗi khi lưu Firebase: $e");
    }
  }

  // ---------------------------------------------------
  // HÀM 2: LẤY DANH SÁCH LỊCH SỬ
  // ---------------------------------------------------
  Stream<QuerySnapshot> getHistoryStream() {
    // Nếu chưa đăng nhập, trả về stream rỗng (để không lộ dữ liệu lung tung)
    if (_auth.currentUser == null) {
      return const Stream.empty(); 
    }

    return _db
        .collection('survey_history')
        .where('userId', isEqualTo: currentUserId) // <--- 4. Lọc theo ID động
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ---------------------------------------------------
  // HÀM 3: LẤY KẾT QUẢ MỚI NHẤT (CHO HOME PAGE)
  // ---------------------------------------------------
  Stream<QuerySnapshot> getLatestResultStream() {
    if (_auth.currentUser == null) {
      return const Stream.empty();
    }
    // Logic giống hệt lấy lịch sử, nhưng thêm limit(1)
    return _db
        .collection('survey_history')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(1) //Chỉ lấy đúng 1 bản ghi mới nhất
        .snapshots();
  }

  // ---------------------------------------------------
  // HÀM 4: LẤY DANH SÁCH KIẾN THỨC (REALTIME)
  // ---------------------------------------------------
  Stream<QuerySnapshot> getKnowledgeStream() {
    return _db
        .collection('knowledge')
        .orderBy('timestamp', descending: true) // Bài mới lên đầu
        .snapshots();
  }
}
