import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';
import '../services/local_storage_service.dart';
import 'dart:math';

class TransactionProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  List<Transaction> _transactions = [];
  LoanData? _loanData;
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  LoanData? get loanData => _loanData;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get netAmount => totalIncome - totalExpense;

  List<Transaction> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<Transaction> get expenseTransactions =>
      _transactions.where((t) => !t.isIncome).toList();

  TransactionProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await _storage.getTransactions();
    _loanData = await _storage.getLoanData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }


  Future<void> calculateLoan({
    required double interestRate,       // বার্ষিক সুদ (%)
    required int loanTerm,               // মোট মাস (N)
    required double repaymentCapacity,  // E (40% বা 50% already applied)
  }) async {
    final r = interestRate;
    final N = loanTerm;
    final E = repaymentCapacity;

    if (E <= 0) {
      throw Exception('ঋণ পরিশোধের সক্ষমতা শূন্যের চেয়ে বড় হতে হবে');
    }

    // মাসিক সুদের হার
    final monthlyRate = r / 12 / 100;

    // NGO / Bank Formula:
    // A = (E × N) ÷ ( (1 + monthlyRate) ^ N )
    final loanAmount = (E * N) / pow(1 + monthlyRate, N);

    final loanData = LoanData(
      interestRate: interestRate,
      loanTerm: loanTerm,
      monthlyNetIncome: netAmount,
      loanAmount: loanAmount,
      monthlyPayment: E,
      calculatedDate: DateTime.now(),
    );

    _loanData = loanData;
    await _storage.saveLoanData(_loanData!);
    notifyListeners();
  }


  Future<void> calculateLoanWithData(LoanData loanData) async {
    _loanData = loanData;
    await _storage.saveLoanData(_loanData!);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _transactions.clear();
    _loanData = null;
    await _storage.clearAll();
    notifyListeners();
  }
}
