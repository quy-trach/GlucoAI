import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import '../widgets/history_chart.dart';
import '../../../../core/services/firestore_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhạt
      appBar: AppBar(
        title: const Text("Lịch sử khảo sát"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // StreamBuilder giúp màn hình tự update khi có dữ liệu mới
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getHistoryStream(),
        builder: (context, snapshot) {
          // 1. Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Nếu có lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // 3. Nếu chưa có dữ liệu nào
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Bạn chưa thực hiện bài khảo sát nào."),
            );
          }

          // 4. Có dữ liệu -> Hiển thị danh sách
          final docs = snapshot.data!.docs;

         return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Hiển thị Biểu đồ
              HistoryChart(docs: docs),
              
              const SizedBox(height: 10),
              const Text(
                "Chi tiết lịch sử",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // 2. Hiển thị Danh sách
              // Dùng spread operator (...) để trải danh sách ra
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final int prediction = data['prediction'] ?? 0;
                final double risk = (data['prob_risk'] ?? 0) * 100;
                final Timestamp? time = data['timestamp'];
                
                String dateStr = "Vừa xong";
                if (time != null) {
                  dateStr = DateFormat('HH:mm - dd/MM/yyyy').format(time.toDate());
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHistoryCard(prediction, risk, dateStr),
                );
              }), // <--- CHÚ Ý DÒNG NÀY: Kết thúc sạch sẽ, không có chữ gì thêm
            ],
          );
        },
      ),
    );
  }

  // Widget vẽ từng thẻ lịch sử cho gọn code
  Widget _buildHistoryCard(int prediction, double risk, String date) {
    // Xác định màu sắc: Đỏ (Nguy hiểm) hoặc Xanh (An toàn)
    bool isHighRisk = prediction == 1;
    Color statusColor = isHighRisk ? Colors.red : Colors.green;
    String statusText = isHighRisk ? "NGUY CƠ CAO" : "AN TOÀN";
    IconData icon = isHighRisk ? Icons.warning_rounded : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Đổ bóng nhẹ
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        // Viền mỏng theo màu trạng thái
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Cột 1: Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),

          const SizedBox(width: 16),

          // Cột 2: Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          // Cột 3: Số %
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${risk.toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: statusColor,
                ),
              ),
              Text(
                "Tỉ lệ",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          )
        ],
      ),
    );
  }
}