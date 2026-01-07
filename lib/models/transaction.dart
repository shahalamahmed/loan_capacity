class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.category = 'সাধারণ',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      isIncome: json['isIncome'],
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'সাধারণ',
    );
  }
}