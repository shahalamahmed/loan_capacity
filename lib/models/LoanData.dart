import 'package:intl/intl.dart';

class LoanData {
  final double interestRate;           // বার্ষিক সুদ (%)
  final int termInMonths;              // ঋণের মেয়াদ (মাসে)
  final int installmentCount;          // মোট কিস্তি সংখ্যা (n)
  final double yearlyCapacity;         // বার্ষিক পরিশোধ সক্ষমতা (E)
  final double loanAmount;             // ঋণের পরিমাণ (A)
  final double installmentAmount;      // প্রতি কিস্তির পরিমাণ
  final double totalRepayment;         // মোট পরিশোধ (পুরো মেয়াদে)
  final DateTime calculatedDate;

  LoanData({
    required this.interestRate,
    required this.termInMonths,
    required this.installmentCount,
    required this.yearlyCapacity,
    required this.loanAmount,
    required this.installmentAmount,
    required this.totalRepayment,
    required this.calculatedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestRate': interestRate,
      'termInMonths': termInMonths,
      'installmentCount': installmentCount,
      'yearlyCapacity': yearlyCapacity,
      'loanAmount': loanAmount,
      'installmentAmount': installmentAmount,
      'totalRepayment': totalRepayment,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      interestRate: json['interestRate'],
      termInMonths: json['termInMonths'],
      installmentCount: json['installmentCount'],
      yearlyCapacity: json['yearlyCapacity'],
      loanAmount: json['loanAmount'],
      installmentAmount: json['installmentAmount'],
      totalRepayment: json['totalRepayment'],
      calculatedDate: DateTime.parse(json['calculatedDate']),
    );
  }

  // Helper getters
  double get termInYears => termInMonths / 12;
  double get monthlyCapacity => yearlyCapacity / 12;

  String get formattedLoanAmount => NumberFormat('#,##,###').format(loanAmount);
  String get formattedYearlyCapacity => NumberFormat('#,##,###').format(yearlyCapacity);
  String get formattedInstallmentAmount => NumberFormat('#,##,###').format(installmentAmount);
  String get formattedTotalRepayment => NumberFormat('#,##,###').format(totalRepayment);

  String get termDisplayText => '$termInMonths মাস (${termInYears.toStringAsFixed(1)} বছর)';
  String get installmentInfoText => 'মোট $installmentCount কিস্তি';

  String get installmentFrequencyText {
    final monthsPerInstallment = termInMonths / installmentCount;
    return 'প্রতি ${monthsPerInstallment.toStringAsFixed(1)} মাসে';
  }
}