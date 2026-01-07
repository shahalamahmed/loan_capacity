import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/dynamic_form.dart';
import '../utils/constants.dart';

class IncomeFormScreen extends StatefulWidget {
  const IncomeFormScreen({Key? key}) : super(key: key);

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  bool _isLoading = false;
  Map<String, double> _collectedData = {};

  Future<void> _saveIncome() async {
    if (_collectedData.isEmpty) return;

    setState(() => _isLoading = true);

    // Create transactions for each filled field
    for (var entry in _collectedData.entries) {
      final transaction = Transaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        title: entry.key,
        amount: entry.value,
        isIncome: true,
        date: DateTime.now(),
      );
      await context.read<TransactionProvider>().addTransaction(transaction);
    }

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_collectedData.length}টি আয় সংরক্ষিত হয়েছে'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DynamicForm(
        title: 'পারিবারিক আয়/Cash In Flow',
        color: Colors.green,
        icon: Icons.add_circle,
        predefinedFields: AppConstants.incomeFields,
        onDataCollected: (data) {
          _collectedData = data;
        },
        onSave: _saveIncome,
        isLoading: _isLoading,
      ),
    );
  }
}