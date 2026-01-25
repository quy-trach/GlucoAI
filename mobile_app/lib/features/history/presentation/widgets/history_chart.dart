import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryChart extends StatelessWidget {
  final List<DocumentSnapshot> docs;
  final int filterType;

  const HistoryChart({super.key, required this.docs, required this.filterType});

  @override
  Widget build(BuildContext context) {
    Map<int, List<double>> grouped = {};
    DateTime now = DateTime.now();

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['timestamp'] as Timestamp?)?.toDate();
      if (date == null) continue;

      int key = -1;

      if (filterType == 0) {
        int diff = now.difference(date).inDays;
        if (diff < 7) key = 6 - diff;
      } else if (filterType == 1) {
        int diff = now.difference(date).inDays;
        if (diff < 30) key = 29 - diff;
      } else if (filterType == 2) {
        if (date.year == now.year) key = date.month;
      }

      if (key != -1) {
        grouped.putIfAbsent(key, () => []).add((data['prob_risk'] ?? 0) * 100);
      }
    }

    List<BarChartGroupData> groups = grouped.entries.map((e) {
      double avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return BarChartGroupData(
        x: e.key,
        showingTooltipIndicators: [0], // 🔥 Hiển thị số trên đầu cột
        barRods: [
          BarChartRodData(
            toY: avg,
            gradient: LinearGradient(
              colors: avg > 50
                  ? [Colors.redAccent, Colors.orangeAccent]
                  : [Colors.blueAccent, Colors.cyanAccent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: filterType == 1 ? 8 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          )
        ],
      );
    }).toList();

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 25, 20, 10), 
      child: BarChart(
        BarChartData(
          maxY: 100, 
          barGroups: groups,
         
          barTouchData: BarTouchData(
            enabled: false, 
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 4,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}%',
                  const TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}%', 
                    style: const TextStyle(
                      color: Colors.black87, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String t = '';
                  int v = value.toInt();

                  if (filterType == 0) {
                    DateTime labelDate = now.subtract(Duration(days: 6 - v));
                    t = v == 6 ? "Nay" : _getWeekdayVi(labelDate.weekday);
                  } 
                  else if (filterType == 1) {
                    DateTime labelDate = now.subtract(Duration(days: 29 - v));
                    if (v == 29) {
                      t = "Nay";
                    } else if (v % 7 == 0) {
                      t = "${labelDate.day}/${labelDate.month}";
                    }
                  } 
                  else {
                    t = 'Th$v';
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      t, 
                      style: const TextStyle(
                        fontSize: 10, 
                        color: Colors.black87, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  String _getWeekdayVi(int weekday) {
    const days = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[weekday];
  }
}