import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class TransactionFormScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? transactionData;

  const TransactionFormScreen({
    super.key,
    this.isEdit = false,
    this.transactionData,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  String type = 'Chi tiêu';
  String category = 'Ăn uống';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

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
    if (widget.isEdit && widget.transactionData != null) {
      type = widget.transactionData!['type'] ?? 'Chi tiêu';
      category = widget.transactionData!['category'] ?? 'Ăn uống';
      _amountController.text = widget.transactionData!['amount'].toString();
      _dateController.text = widget.transactionData!['date'] ?? '';
      _noteController.text = widget.transactionData!['note'] ?? '';
    } else {
      DateTime now = DateTime.now();
      _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    }
  }

  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    Map<String, dynamic> row = {
      'type': type,
      'category': category,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'date': _dateController.text,
      'note': _noteController.text,
    };

    if (widget.isEdit && widget.transactionData != null) {
      row['id'] = widget.transactionData!['id'];
      await DatabaseHelper.instance.updateTransaction(row);
    } else {
      await DatabaseHelper.instance.insertTransaction(row);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút Chi tiêu / Thu nhập
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => type = 'Chi tiêu'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: type == 'Chi tiêu' ? Colors.redAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              color: type == 'Chi tiêu' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => type = 'Thu nhập'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: type == 'Thu nhập' ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: type == 'Thu nhập' ? Colors.white : Colors.black,
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
            const SizedBox(height: 20),

            // Dropdown Danh mục
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: categoryConfig.containsKey(category) ? category : 'Ăn uống',
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: categoryConfig.keys.map((catKey) {
                final cfg = categoryConfig[catKey]!;
                return DropdownMenuItem<String>(
                  value: catKey,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: cfg['bg'],
                        child: Icon(cfg['icon'], color: cfg['color'], size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(catKey),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    category = val;
                    // TỰ ĐỘNG CHUYỂN LOẠI THEO DANH MỤC
                    if (val == 'Lương') {
                      type = 'Thu nhập';
                    } else {
                      type = 'Chi tiêu';
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Số tiền
            const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                suffixText: 'đ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Ngày giao dịch
            const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'DD/MM/YYYY',
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Ghi chú
            const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}