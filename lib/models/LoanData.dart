
import 'package:flutter/material.dart';

enum TermUnit { years, months, days }

class LoanData {
  final double interestRate;
  final double termInMonths;
  final TermUnit termUnit;
  final int installmentCount;
  final double yearlyCapacity;
  final double loanAmount;
  final double installmentAmount;
  final double totalRepayment;
  final int daysBetweenInstallments;
  final DateTime calculatedDate;

  LoanData({
    required this.interestRate,
    required this.termInMonths,
    required this.termUnit,
    required this.installmentCount,
    required this.yearlyCapacity,
    required this.loanAmount,
    required this.installmentAmount,
    required this.totalRepayment,
    required this.daysBetweenInstallments,
    required this.calculatedDate,
  });


  double get termInSelectedUnit {
    switch (termUnit) {
      case TermUnit.days:
        return termInMonths * 30;
      case TermUnit.months:
        return termInMonths;
      case TermUnit.years:
        return termInMonths / 12;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'interestRate': interestRate,
      'termInMonths': termInMonths,
      'termUnit': termUnit.index,
      'installmentCount': installmentCount,
      'yearlyCapacity': yearlyCapacity,
      'loanAmount': loanAmount,
      'installmentAmount': installmentAmount,
      'totalRepayment': totalRepayment,
      'daysBetweenInstallments': daysBetweenInstallments,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      interestRate: (json['interestRate'] as num).toDouble(),
      termInMonths: (json['termInMonths'] as num).toDouble(),
      termUnit: TermUnit.values[(json['termUnit'] as num).toInt()],
      installmentCount: (json['installmentCount'] as num).toInt(),
      yearlyCapacity: (json['yearlyCapacity'] as num).toDouble(),
      loanAmount: (json['loanAmount'] as num).toDouble(),
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      totalRepayment: (json['totalRepayment'] as num).toDouble(),
      daysBetweenInstallments: (json['daysBetweenInstallments'] as num).toInt(),
      calculatedDate: DateTime.parse(json['calculatedDate'] as String),
    );
  }
}