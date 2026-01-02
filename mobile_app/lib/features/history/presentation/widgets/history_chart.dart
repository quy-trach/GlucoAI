import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Đã xóa import 'package:intl/intl.dart'; vì không dùng đến

class HistoryChart extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const HistoryChart({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    // 1. Xử lý dữ liệu
    final List<BarChartGroupData> barGroups = _processData();

    if (barGroups.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // SỬA LỖI DEPRECATED 1
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Xu hướng sức khỏe (6 tháng gần nhất)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "T${value.toInt()}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    // SỬA LỖI DEPRECATED 2
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM LOGIC XỬ LÝ DỮ LIỆU ---
  List<BarChartGroupData> _processData() {
    Map<int, List<double>> monthlyData = {};

    DateTime now = DateTime.now();
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp? timestamp = data['timestamp'];
      final double risk = (data['prob_risk'] ?? 0.0) * 100;

      if (timestamp != null) {
        DateTime date = timestamp.toDate();
        if (now.difference(date).inDays < 180) {
          int month = date.month;
          if (!monthlyData.containsKey(month)) {
            monthlyData[month] = [];
          }
          monthlyData[month]!.add(risk);
        }
      }
    }

    List<BarChartGroupData> items = [];
    var sortedKeys = monthlyData.keys.toList()..sort();

    for (var month in sortedKeys) {
      List<double> risks = monthlyData[month]!;
      double avgRisk = risks.reduce((a, b) => a + b) / risks.length;
      Color barColor = avgRisk > 50 ? Colors.redAccent : Colors.greenAccent;

      items.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: avgRisk,
              color: barColor,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 100,
                // SỬA LỖI DEPRECATED 3
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      );
    }
    return items;
  }
}