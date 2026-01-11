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

  // 🔥 UPDATED CALCULATION WITH INSTALLMENT COUNT
  Future<void> calculateLoan({
    required double interestRate,       // বার্ষিক সুদ (%)
    required int termInMonths,          // ঋণের মেয়াদ (মাসে)
    required int installmentCount,      // মোট কিস্তি সংখ্যা (n)
    required double monthlyNetIncome,   // মাসিক নীট আয়
    required double cashFlowPercent,    // Cash flow % (40 বা 50)
  }) async {
    try {
      // মাসিক পরিশোধ সক্ষমতা
      final monthlyCapacity = monthlyNetIncome * (cashFlowPercent / 100);

      // বার্ষিক পরিশোধ সক্ষমতা (E)
      final yearlyCapacity = monthlyCapacity * 12;

      // মেয়াদ বছরে (N)
      final termInYears = termInMonths / 12;

      // বার্ষিক সুদের হার (r)
      final annualInterestRate = interestRate / 100;

      if (yearlyCapacity <= 0) {
        throw Exception('ঋণ পরিশোধের সক্ষমতা শূন্যের চেয়ে বড় হতে হবে');
      }

      if (termInYears <= 0) {
        throw Exception('ঋণের মেয়াদ শূন্যের চেয়ে বড় হতে হবে');
      }

      if (installmentCount <= 0) {
        throw Exception('কিস্তি সংখ্যা শূন্যের চেয়ে বড় হতে হবে');
      }

      if (installmentCount > termInMonths) {
        throw Exception('কিস্তি সংখ্যা ঋণের মেয়াদের চেয়ে বেশি হতে পারে না');
      }

      // 🔥 NGO FORMULA: A = E / (1 + r)^N
      final proportionedYearlyCapacity = yearlyCapacity * termInYears;
      final loanAmount = proportionedYearlyCapacity / pow(1 + annualInterestRate, termInYears);

      // মোট পরিশোধ (পুরো মেয়াদে)
      final totalRepayment = yearlyCapacity * termInYears;

      // প্রতি কিস্তির পরিমাণ = মোট পরিশোধ / কিস্তি সংখ্যা
      final installmentAmount = totalRepayment / installmentCount;

      final loanData = LoanData(
        interestRate: interestRate,
        termInMonths: termInMonths,
        installmentCount: installmentCount,
        yearlyCapacity: yearlyCapacity,
        loanAmount: loanAmount,
        installmentAmount: installmentAmount,
        totalRepayment: totalRepayment,
        calculatedDate: DateTime.now(),
      );

      _loanData = loanData;
      await _storage.saveLoanData(_loanData!);
      notifyListeners();

    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearLoanData() async {
    _loanData = null;
    await _storage.saveLoanData(null);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _transactions.clear();
    _loanData = null;
    await _storage.clearAll();
    notifyListeners();
  }
}