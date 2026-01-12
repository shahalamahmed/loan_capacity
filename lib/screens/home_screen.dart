import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/transaction_card.dart';
import 'income_form_screen.dart';
import 'expense_form_screen.dart';
import 'loan_calculation_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _resetAll(BuildContext context) async {
    final provider = context.read<TransactionProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text('সব ডাটা মুছে ফেলতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.resetAll();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('সব ডাটা মুছে ফেলা হয়েছে')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
              Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F172A)),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF0F172A),
                onRefresh: () => provider.loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ঋণ ক্যালকুলেটর',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd MMMM yyyy',
                                ).format(DateTime.now()),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _resetAll(context),
                              icon: const Icon(Icons.refresh, size: 24),
                              color: const Color(0xFFDC2626),
                              tooltip: 'সব রিসেট করুন',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'মোট আয়',
                              amount: provider.totalIncome,
                              color: const Color(0xFF059669),
                              icon: Icons.arrow_upward,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: SummaryCard(
                              title: 'মোট খরচ',
                              amount: provider.totalExpense,
                              color: const Color(0xFFDC2626),
                              icon: Icons.arrow_downward,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SummaryCard(
                        title: 'নিট পরিমাণ',
                        amount: provider.netAmount,
                        color: provider.netAmount >= 0
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFEA580C),
                        icon: Icons.account_balance_wallet,
                        isLarge: true,
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'আয় যোগ করুন',
                              icon: Icons.add_circle,
                              color: const Color(0xFF059669),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IncomeFormScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: CustomButton(
                              text: 'খরচ যোগ করুন',
                              icon: Icons.remove_circle,
                              color: const Color(0xFFDC2626),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExpenseFormScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      CustomButton(
                        text: 'ঋণ হিসাব করুন',
                        icon: Icons.calculate,
                        color: const Color(0xFF0F172A),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoanCalculationScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      if (provider.transactions.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'সাম্প্রতিক লেনদেন',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReportScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(
                                  0xFF2563EB,
                                ),
                              ),
                              child: const Text('সব দেখুন'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...provider.transactions
                            .take(5)
                            .map(
                              (t) => TransactionCard(
                                transaction: t,
                                showDelete: true,
                              ),
                            ),
                      ] else ...[
                        const SizedBox(height: 50),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'এখনো কোনো লেনদেন নেই',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'আয় বা খরচ যোগ করে শুরু করুন',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        icon: const Icon(Icons.assessment_outlined, size: 22),
        label: const Text(
          'রিপোর্ট',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF264653),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
