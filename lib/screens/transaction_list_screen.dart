import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];

  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  final Map<String, Map<String, dynamic>> categoryConfig = {
    'Ăn uống': {'icon': Icons.restaurant, 'color': Colors.redAccent, 'bg': Color(0xFFFFEBEE)},
    'Mua sắm': {'icon': Icons.shopping_cart, 'color': Colors.lightBlue, 'bg': Color(0xFFE1F5FE)},
    'Lương': {'icon': Icons.work, 'color': Colors.green, 'bg': Color(0xFFE8F5E9)},
    'Đi lại': {'icon': Icons.directions_car, 'color': Colors.purple, 'bg': Color(0xFFF3E5F5)},
    'Học tập': {'icon': Icons.menu_book, 'color': Colors.indigo, 'bg': Color(0xFFE8EAF6)},
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
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        bool matchesType = true;
        if (_selectedFilter != 'Tất cả') {
          matchesType = tx['type'] == _selectedFilter;
        }

        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          String searchLower = _searchQuery.toLowerCase();
          String category = tx['category'].toString().toLowerCase();
          String note = (tx['note'] ?? '').toString().toLowerCase();
          matchesSearch = category.contains(searchLower) || note.contains(searchLower);
        }

        return matchesType && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Ô Tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      _searchQuery = val;
                      _applyFilter();
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm giao dịch...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 3 Nút Lọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['Tất cả', 'Thu nhập', 'Chi tiêu'].map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _applyFilter();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Danh sách Giao dịch
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text("Không tìm thấy giao dịch nào"))
                : ListView.builder(
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = _filteredTransactions[index];
                bool isIncome = tx['type'] == 'Thu nhập';
                String catName = tx['category'] ?? 'Khác';

                final cfg = categoryConfig[catName] ?? {
                  'icon': Icons.category,
                  'color': Colors.grey,
                  'bg': Colors.grey[200],
                };

                return ListTile(
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
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20), // Dấu mũi tên
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionFormScreen(
                          isEdit: true,
                          transactionData: tx,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}