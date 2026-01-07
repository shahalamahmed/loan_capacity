import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../utils/pdf_generator.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিস্তারিত রিপোর্ট'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            onPressed: () async {
              final provider = context.read<TransactionProvider>();
              await PDFGenerator.generatePDF(
                context: context,
                transactions: provider.transactions,
                totalIncome: provider.totalIncome,
                totalExpense: provider.totalExpense,
                netAmount: provider.netAmount,
                loanData: provider.loanData,
              );
            },
            icon: const Icon(Icons.download),
            tooltip: 'PDF ডাউনলোড',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final incomeTransactions = provider.incomeTransactions;
          final expenseTransactions = provider.expenseTransactions;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'মোট আয়',
                        provider.totalIncome,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSummaryCard(
                        'মোট খরচ',
                        provider.totalExpense,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildSummaryCard(
                  'নিট পরিমাণ',
                  provider.netAmount,
                  Colors.blue,
                ),

                // Loan Info
                if (provider.loanData != null) ...[
                  const SizedBox(height: 30),
                  _buildSectionHeader('ঋণ তথ্য', Colors.blue, null),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'ঋণের পরিমাণ',
                          '৳${NumberFormat('#,##,###').format(provider.loanData!.loanAmount)}',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'মাসিক পেমেন্ট',
                          '৳${NumberFormat('#,##,###').format(provider.loanData!.monthlyPayment)}',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'সুদের হার',
                          '${provider.loanData!.interestRate}%',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          'মেয়াদ',
                          '${provider.loanData!.loanTerm} মাস',
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Income Section
                _buildSectionHeader(
                  'আয়ের তালিকা',
                  Colors.green,
                  incomeTransactions.length,
                ),
                const SizedBox(height: 10),
                if (incomeTransactions.isEmpty)
                  _buildEmptyState('কোনো আয় নেই')
                else
                  ...incomeTransactions.map(
                        (t) => TransactionCard(transaction: t, showDelete: false),
                  ),

                const SizedBox(height: 30),

                // Expense Section
                _buildSectionHeader(
                  'খরচের তালিকা',
                  Colors.red,
                  expenseTransactions.length,
                ),
                const SizedBox(height: 10),
                if (expenseTransactions.isEmpty)
                  _buildEmptyState('কোনো খরচ নেই')
                else
                  ...expenseTransactions.map(
                        (t) => TransactionCard(transaction: t, showDelete: false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '৳${NumberFormat('#,##,###').format(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int? count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count টি',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}