import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 

  // ----------------------------------------------------------------
  // HÀM LẤY USER ID HIỆN TẠI
  // ----------------------------------------------------------------
  String get currentUserId {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid; 
    } else {
      return "anonymous_device"; 
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
      final dataToSave = {
        "userId": currentUserId,
        "timestamp": FieldValue.serverTimestamp(),
        "prediction": result['prediction'],
        "prob_risk": result['prob_risk'],
        "prob_safe": result['prob_safe'],
        "bmi": result['bmi'] ?? 0.0,
        "input_data": inputs,
        "user_email": _auth.currentUser?.email ?? "No Email", 
      };

      await _db.collection('survey_history').add(dataToSave);
      debugPrint("✅ Đã lưu lịch sử cho user: $currentUserId");
    } catch (e) {
      debugPrint("❌ Lỗi khi lưu Firebase: $e");
    }
  }

  // ---------------------------------------------------
  // HÀM 2: LẤY DANH SÁCH LỊCH SỬ (STREAM - CHO BIỂU ĐỒ)
  // ---------------------------------------------------
  Stream<QuerySnapshot> getHistoryStream() {
    if (_auth.currentUser == null) {
      return const Stream.empty(); 
    }
    return _db
        .collection('survey_history')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ---------------------------------------------------
  // HÀM MỚI: LẤY LỊCH SỬ PHÂN TRANG 
  // ---------------------------------------------------
  Future<QuerySnapshot> getHistoryPaginated({
    int limit = 15,
    DocumentSnapshot? lastDoc,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    Query query = _db
        .collection('survey_history')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.get();
  }

  // ---------------------------------------------------
  // HÀM 3: LẤY KẾT QUẢ MỚI NHẤT (CHO HOME PAGE)
  // ---------------------------------------------------
  Stream<QuerySnapshot> getLatestResultStream() {
    if (_auth.currentUser == null) {
      return const Stream.empty();
    }
    return _db
        .collection('survey_history')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // ---------------------------------------------------
  // HÀM 4: LẤY DANH SÁCH KIẾN THỨC (REALTIME)
  // ---------------------------------------------------
  Stream<QuerySnapshot> getKnowledgeStream() {
    return _db
        .collection('knowledge')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
} 