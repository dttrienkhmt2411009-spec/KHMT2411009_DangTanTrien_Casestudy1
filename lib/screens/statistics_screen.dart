import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _transactionType = 'Chi tiêu'; // 'Chi tiêu' hoặc 'Thu nhập'
  String _selectedTimeFilter = 'Tháng này'; // 'Hôm nay', 'Tháng này', 'Tháng trước', 'Năm nay'

  List<Map<String, dynamic>> _allTransactions = [];
  Map<String, double> _categoryTotals = {};
  double _totalAmount = 0;

  final Map<String, Map<String, dynamic>> categoryConfig = {
    'Ăn uống': {'icon': Icons.restaurant, 'color': const Color(0xFFFF5252), 'bg': const Color(0xFFFFEBEE)},
    'Mua sắm': {'icon': Icons.shopping_cart, 'color': const Color(0xFF40C4FF), 'bg': const Color(0xFFE1F5FE)},
    'Lương': {'icon': Icons.work, 'color': const Color(0xFF66BB6A), 'bg': const Color(0xFFE8F5E9)},
    'Đi lại': {'icon': Icons.directions_car, 'color': const Color(0xFFAB47BC), 'bg': const Color(0xFFF3E5F5)},
    'Học tập': {'icon': Icons.menu_book, 'color': const Color(0xFF5C6BC0), 'bg': const Color(0xFFE8EAF6)},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.queryAllTransactions();
    if (!mounted) return;
    setState(() {
      _allTransactions = data;
    });
    _calculateStatistics();
  }

  void _calculateStatistics() {
    DateTime now = DateTime.now();
    Map<String, double> categorySums = {};
    double total = 0;

    for (var tx in _allTransactions) {
      // Làm sạch chuỗi type để tránh lỗi dính khoảng trắng hoặc viết hoa/thường
      String txType = (tx['type'] ?? '').toString().trim().toLowerCase();
      String currentSelectedType = _transactionType.trim().toLowerCase();

      // So sánh loại giao dịch
      if (txType != currentSelectedType) continue;

      String dateStr = (tx['date'] ?? '').toString().trim();
      List<String> parts = dateStr.split('/');

      bool isMatch = false;

      if (parts.length == 3) {
        int day = int.tryParse(parts[0]) ?? 1;
        int month = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? now.year;
        DateTime txDate = DateTime(year, month, day);

        if (_selectedTimeFilter == 'Hôm nay') {
          isMatch = txDate.year == now.year && txDate.month == now.month && txDate.day == now.day;
        } else if (_selectedTimeFilter == 'Tháng này') {
          isMatch = txDate.year == now.year && txDate.month == now.month;
        } else if (_selectedTimeFilter == 'Tháng trước') {
          DateTime prevMonth = DateTime(now.year, now.month - 1);
          isMatch = txDate.year == prevMonth.year && txDate.month == prevMonth.month;
        } else if (_selectedTimeFilter == 'Năm nay') {
          isMatch = txDate.year == now.year;
        }
      } else {
        // Nếu ngày lưu chưa đúng định dạng thì vẫn hiển thị khi chọn Tháng này
        isMatch = true;
      }

      if (isMatch) {
        String cat = (tx['category'] ?? 'Khác').toString().trim();
        double amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
        categorySums[cat] = (categorySums[cat] ?? 0) + amount;
        total += amount;
      }
    }

    setState(() {
      _categoryTotals = categorySums;
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thống kê', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab chọn Chi tiêu / Thu nhập
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _transactionType = 'Chi tiêu');
                        _calculateStatistics();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'Chi tiêu' ? Colors.redAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              color: _transactionType == 'Chi tiêu' ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _transactionType = 'Thu nhập');
                        _calculateStatistics();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _transactionType == 'Thu nhập' ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: _transactionType == 'Thu nhập' ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thanh chọn mốc thời gian
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Hôm nay', 'Tháng này', 'Tháng trước', 'Năm nay'].map((filter) {
                  bool isSelected = _selectedTimeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeFilter = filter;
                        });
                        _calculateStatistics();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Biểu đồ
            SizedBox(
              height: 220,
              child: _totalAmount == 0
                  ? Center(
                child: Text(
                  "Không có dữ liệu $_transactionType",
                  style: const TextStyle(color: Colors.grey),
                ),
              )
                  : Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 70,
                      sections: _buildPieChartSections(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_totalAmount.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng $_transactionType',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danh sách danh mục
            if (_categoryTotals.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chi tiết danh mục',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ..._categoryTotals.entries.map((entry) {
                String catName = entry.key;
                double amount = entry.value;
                double percentage = _totalAmount > 0 ? (amount / _totalAmount) * 100 : 0;

                final cfg = categoryConfig[catName] ?? {
                  'icon': Icons.category,
                  'color': Colors.grey,
                  'bg': Colors.grey[200],
                };

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cfg['bg'],
                        child: Icon(cfg['icon'], color: cfg['color'], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('${amount.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (cfg['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: cfg['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return _categoryTotals.entries.map((entry) {
      String catName = entry.key;
      double amount = entry.value;

      final cfg = categoryConfig[catName] ?? {'color': Colors.grey};

      return PieChartSectionData(
        color: cfg['color'],
        value: amount,
        title: '',
        radius: 22,
      );
    }).toList();
  }
}