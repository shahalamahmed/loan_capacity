import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _transactionsKey = 'transactions';
  static const String _loanDataKey = 'loan_data';

  Future<List<Transaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_transactionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = transactions.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_transactionsKey, jsonString);
    } catch (e) {
      // Handle error
    }
  }

  Future<LoanData?> getLoanData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_loanDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return LoanData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLoanData(LoanData? loanData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (loanData == null) {
        await prefs.remove(_loanDataKey);
      } else {
        final jsonString = jsonEncode(loanData.toJson());
        await prefs.setString(_loanDataKey, jsonString);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_transactionsKey);
      await prefs.remove(_loanDataKey);
    } catch (e) {
      // Handle error
    }
  }
}