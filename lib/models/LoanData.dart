
class LoanData {
  final double interestRate;
  final int loanTerm;
  final double monthlyNetIncome;
  final double loanAmount;
  final double monthlyPayment;
  final DateTime calculatedDate;

  LoanData({
    required this.interestRate,
    required this.loanTerm,
    required this.monthlyNetIncome,
    required this.loanAmount,
    required this.monthlyPayment,
    required this.calculatedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'interestRate': interestRate,
      'loanTerm': loanTerm,
      'monthlyNetIncome': monthlyNetIncome,
      'loanAmount': loanAmount,
      'monthlyPayment': monthlyPayment,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      interestRate: json['interestRate'],
      loanTerm: json['loanTerm'],
      monthlyNetIncome: json['monthlyNetIncome'],
      loanAmount: json['loanAmount'],
      monthlyPayment: json['monthlyPayment'],
      calculatedDate: DateTime.parse(json['calculatedDate']),
    );
  }
}
