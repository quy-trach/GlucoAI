import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/history_chart.dart';
import '../../../../core/services/firestore_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _historyDocs = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  int _selectedChartFilter = 1;
  final int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    // Chỉ tải dữ liệu nếu đã có User
    if (FirebaseAuth.instance.currentUser != null) {
      _loadMoreData();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestoreService.getHistoryPaginated(
        limit: _pageSize,
        lastDoc: _lastDoc,
      );

      if (mounted) {
        setState(() {
          if (snapshot.docs.length < _pageSize) _hasMore = false;
          if (snapshot.docs.isNotEmpty) {
            _lastDoc = snapshot.docs.last;
            _historyDocs.addAll(snapshot.docs);
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải dữ liệu: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _historyDocs.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    await _loadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 QUAN TRỌNG: Lấy user hiện tại ở đây để kiểm tra Auth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lịch sử khảo sát"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 18
        ),
      ),
      // 🔥 Kiểm tra nếu user null thì hiện màn hình yêu cầu đăng nhập
      body: user == null 
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text("Vui lòng đăng nhập để xem lịch sử"),
            ],
          ),
        )
      : RefreshIndicator(
          onRefresh: _refreshData,
           color: Colors.blue,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _filterBtn("Tuần", 0),
                          const SizedBox(width: 8),
                          _filterBtn("Tháng", 1),
                          const SizedBox(width: 8),
                          _filterBtn("Năm", 2),
                        ],
                      ),
                    ),
                    HistoryChart(docs: _historyDocs, filterType: _selectedChartFilter),
                    const Divider(thickness: 8, color: Color(0xFFF8F8F8)),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Chi tiết lịch sử", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _historyDocs.length) {
                      return _hasMore 
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        )))
                        : const SizedBox(height: 50);
                    }
                    final data = _historyDocs[index].data() as Map<String, dynamic>;
                    return _buildHistoryRow(data);
                  },
                  childCount: _historyDocs.length + 1,
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _filterBtn(String label, int index) {
    bool isSelected = _selectedChartFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedChartFilter = index);
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black, 
        fontWeight: FontWeight.bold
      ),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildHistoryRow(Map<String, dynamic> data) {
    final DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final double risk = (data['prob_risk'] ?? 0) * 100;
    bool isDanger = (data['prediction'] ?? 0) == 1;
    Color statusColor = isDanger ? Colors.redAccent : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withAlpha(25), width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat("EEEE, dd/MM", 'vi').format(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Lúc ${DateFormat('HH:mm').format(date)}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${risk.toInt()}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w300, 
                            color: statusColor,
                          ),
                        ),
                        TextSpan(
                          text: "%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isDanger ? "NGUY CƠ CAO" : "AN TOÀN",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}