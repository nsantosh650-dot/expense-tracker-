import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'खर्च ट्र्याकर',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6F1),
      ),
      home: const HomePage(),
    );
  }
}

class Expense {
  final String desc;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.desc,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'desc': desc,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        desc: json['desc'],
        amount: (json['amount'] as num).toDouble(),
        category: json['category'],
        date: DateTime.parse(json['date']),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Expense> _expenses = [];
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'खाना';
  String? _errorText;

  final List<String> _categories = ['खाना', 'यातायात', 'मनोरञ्जन', 'बिल', 'अन्य'];

  final Map<String, Color> _categoryColors = {
    'खाना': const Color(0xFFD85A30),
    'यातायात': const Color(0xFF378ADD),
    'मनोरञ्जन': const Color(0xFF7F77DD),
    'बिल': const Color(0xFFBA7517),
    'अन्य': const Color(0xFF888780),
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('expenses');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        _expenses.addAll(decoded.map((e) => Expense.fromJson(e)));
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString('expenses', raw);
  }

  void _addExpense() {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (desc.isEmpty || amount == null || amount <= 0) {
      setState(() {
        _errorText = 'कृपया विवरण र सही रकम भर्नुहोस्';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _expenses.insert(
        0,
        Expense(
          desc: desc,
          amount: amount,
          category: _selectedCategory,
          date: DateTime.now(),
        ),
      );
      _descController.clear();
      _amountController.clear();
    });
    _saveExpenses();
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
    _saveExpenses();
  }

  double get _grandTotal => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get _todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return 'रु. ${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('खर्च ट्र्याकर'),
        backgroundColor: const Color(0xFF0F6E56),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('आजको खर्च', _formatMoney(_todayTotal)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('जम्मा खर्च', _formatMoney(_grandTotal)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAddForm(),
              const SizedBox(height: 16),
              Expanded(
                child: _expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'अहिलेसम्म कुनै खर्च थपिएको छैन',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final e = _expenses[index];
                          return _buildExpenseRow(e, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              hintText: 'के मा खर्च भयो? (जस्तै: चिया)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'रकम',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCategory = v);
                  },
                ),
              ),
            ],
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addExpense,
              icon: const Icon(Icons.add),
              label: const Text('खर्च थप्नुहोस्'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(Expense e, int index) {
    final color = _categoryColors[e.category] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              e.category,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(e.desc, style: const TextStyle(fontSize: 14)),
          ),
          Text(_formatMoney(e.amount),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black38),
            onPressed: () => _deleteExpense(index),
          ),
        ],
      ),
    );
  }
}
