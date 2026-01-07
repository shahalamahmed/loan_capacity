import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/dynamic_form.dart';
import '../utils/constants.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  bool _isLoading = false;
  Map<String, double> _collectedData = {};

  Future<void> _saveExpense() async {
    if (_collectedData.isEmpty) return;

    setState(() => _isLoading = true);

    // Create transactions for each filled field
    for (var entry in _collectedData.entries) {
      final transaction = Transaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        title: entry.key,
        amount: entry.value,
        isIncome: false,
        date: DateTime.now(),
      );
      await context.read<TransactionProvider>().addTransaction(transaction);
    }

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_collectedData.length}টি খরচ সংরক্ষিত হয়েছে'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DynamicForm(
        title: 'পারিবারিক খরচ/Cash Out Flow',
        color: Colors.red,
        icon: Icons.remove_circle,
        predefinedFields: AppConstants.expenseFields,
        onDataCollected: (data) {
          _collectedData = data;
        },
        onSave: _saveExpense,
        isLoading: _isLoading,
      ),
    );
  }
}