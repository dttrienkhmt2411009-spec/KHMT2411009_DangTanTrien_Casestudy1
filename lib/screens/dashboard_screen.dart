import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'transaction_form_screen.dart';
import 'transaction_list_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart'; // Import màn hình Cá nhân

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  final Map<String, Map<String, dynamic>> categoryConfig = {
    'Ăn uống': {'icon': Icons.restaurant, 'color': Colors.redAccent, 'bg': const Color(0xFFFFEBEE)},
    'Mua sắm': {'icon': Icons.shopping_cart, 'color': Colors.lightBlue, 'bg': const Color(0xFFE1F5FE)},
    'Lương': {'icon': Icons.work, 'color': Colors.green, 'bg': const Color(0xFFE8F5E9)},
    'Đi lại': {'icon': Icons.directions_car, 'color': Colors.purple, 'bg': const Color(0xFFF3E5F5)},
    'Học tập': {'icon': Icons.menu_book, 'color': Colors.indigo, 'bg': const Color(0xFFE8EAF6)},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.queryAllTransactions();

    double income = 0;
    double expense = 0;

    for (var item in data) {
      if (item['type'] == 'Thu nhập') {
        income += (item['amount'] as num).toDouble();
      } else {
        expense += (item['amount'] as num).toDouble();
      }
    }

    if (!mounted) return;

    setState(() {
      _transactions = data;
      _totalIncome = income;
      _totalExpense = expense;
      _balance = income - expense;
    });
  }

  void _navigateAndRefresh(bool isEdit, [Map<String, dynamic>? tx]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
          isEdit: isEdit,
          transactionData: tx,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CỤM NỀN XANH PHÍA TRÊN & THẺ SỐ DƯ
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Xin chào!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Hôm nay là một ngày tốt lành!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),

                      // NÚT BẤM AVATAR VÀO TRANG CÁ NHÂN
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 110, left: 16, right: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Số dư hiện tại', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              '${_balance.toStringAsFixed(0)} đ',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.green,
                                child: Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                              ),
                              const SizedBox(height: 10),
                              const Text('Thu nhập', style: TextStyle(color: Colors.black54, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${_totalIncome.toStringAsFixed(0)} đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                              ),
                              const SizedBox(height: 10),
                              const Text('Chi tiêu', style: TextStyle(color: Colors.black54, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${_totalExpense.toStringAsFixed(0)} đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chi tiêu gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransactionListScreen()),
                          );
                          _loadData();
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text("Chưa có giao dịch nào")),
                    ),

                  ..._transactions.map((tx) {
                    bool isIncome = tx['type'] == 'Thu nhập';
                    String catName = tx['category'] ?? 'Khác';

                    final cfg = categoryConfig[catName] ?? {
                      'icon': Icons.category,
                      'color': Colors.grey,
                      'bg': Colors.grey[200],
                    };

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: cfg['bg'],
                        child: Icon(cfg['icon'], color: cfg['color']),
                      ),
                      title: Text(catName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}${tx['amount']} đ',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                        ],
                      ),
                      onTap: () => _navigateAndRefresh(true, tx),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _navigateAndRefresh(false),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // THANH ĐIỀU HƯỚNG BÊN DƯỚI
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 1) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionListScreen()));
            _loadData();
          } else if (index == 2) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
            _loadData();
          } else if (index == 3) {
            // NÚT BẤM TAB CÁ NHÂN VÀO TRANG CÁ NHÂN
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'), // index = 3
        ],
      ),
    );
  }
}