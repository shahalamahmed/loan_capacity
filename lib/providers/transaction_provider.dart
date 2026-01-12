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
    required double interestRate,
    required double term,
    required TermUnit termUnit,
    required int installmentCount,
    required double monthlyNetIncome,
    required double cashFlowPercent,
  }) async {
    try {
      final monthlyCapacity = monthlyNetIncome * (cashFlowPercent / 100);

      final termInMonths = _convertToMonths(term, termUnit);

      final termInYears = termInMonths / 12;

      final yearlyCapacity = monthlyCapacity * 12;

      final proportionedCapacity = yearlyCapacity * termInYears;

      final annualInterestRate = interestRate / 100;

      final loanAmount = proportionedCapacity / pow(1 + annualInterestRate, termInYears);

      final totalRepayment = proportionedCapacity;

      final installmentAmount = totalRepayment / installmentCount;

      final totalDays = _convertToDays(term, termUnit);

      final daysBetweenInstallments = totalDays / installmentCount;

      final loanData = LoanData(
        interestRate: interestRate,
        termInMonths: termInMonths,
        termUnit: termUnit,
        installmentCount: installmentCount,
        yearlyCapacity: yearlyCapacity,
        loanAmount: loanAmount,
        installmentAmount: installmentAmount,
        totalRepayment: totalRepayment,
        daysBetweenInstallments: daysBetweenInstallments.round(),
        calculatedDate: DateTime.now(),
      );

      _loanData = loanData;
      await _storage.saveLoanData(_loanData!);
      notifyListeners();

    } catch (e) {
      rethrow;
    }
  }

  double _convertToMonths(double term, TermUnit unit) {
    switch (unit) {
      case TermUnit.days:
        return term / 30;
      case TermUnit.months:
        return term;
      case TermUnit.years:
        return term * 12;
    }
  }

  double _convertToDays(double term, TermUnit unit) {
    switch (unit) {
      case TermUnit.days:
        return term;
      case TermUnit.months:
        return term * 30;
      case TermUnit.years:
        return term * 365;
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