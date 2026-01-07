import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';

class LocalStorageService {
  static const String _transactionsKey = 'transactions';
  static const String _loanDataKey = 'loanData';

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
  }

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_transactionsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> saveLoanData(LoanData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loanDataKey, jsonEncode(data.toJson()));
  }

  Future<LoanData?> getLoanData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_loanDataKey);
    if (jsonString == null) return null;

    return LoanData.fromJson(jsonDecode(jsonString));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }
}
