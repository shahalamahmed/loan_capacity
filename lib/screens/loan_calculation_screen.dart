import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/transaction_provider.dart';
import '../models/LoanData.dart';

class LoanCalculationScreen extends StatefulWidget {
  const LoanCalculationScreen({super.key});

  @override
  State<LoanCalculationScreen> createState() => _LoanCalculationScreenState();
}

class _LoanCalculationScreenState extends State<LoanCalculationScreen> {
  final _interestController = TextEditingController();
  final _termController = TextEditingController();
  final _installmentController = TextEditingController();
  final _repaymentCapacityController = TextEditingController();

  bool _isLoading = false;
  bool _useCustomCapacity = false;
  double _cashFlowAdjustmentPercent = 40.0;

  double? _calculatedLoanAmount;
  double? _monthlyInstallment;
  double? _totalRepayment;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _installmentController.text = '18';
  }

  @override
  void dispose() {
    _interestController.dispose();
    _termController.dispose();
    _installmentController.dispose();
    _repaymentCapacityController.dispose();
    super.dispose();
  }

  void _loadSavedData() {
    final loanData = context.read<TransactionProvider>().loanData;
    if (loanData != null) {
      _interestController.text = loanData.interestRate.toString();
      _termController.text = loanData.loanTerm.toString();
    }
  }

  double _getRepaymentCapacity(double monthlyNetIncome) {
    if (_useCustomCapacity && _repaymentCapacityController.text.isNotEmpty) {
      return double.tryParse(_repaymentCapacityController.text) ?? 0;
    }
    // Calculate: Monthly Net Income * Cash Flow Adjustment Factor
    return monthlyNetIncome * (_cashFlowAdjustmentPercent / 100);
  }

  Future<void> _calculateLoan() async {
    final provider = context.read<TransactionProvider>();

    if (_interestController.text.isEmpty ||
        _termController.text.isEmpty ||
        _installmentController.text.isEmpty) {
      _showError('সব ফিল্ড পূরণ করুন');
      return;
    }

    final interestRate = double.tryParse(_interestController.text);
    final loanTerm = int.tryParse(_termController.text);
    final installmentCount = int.tryParse(_installmentController.text);

    if (interestRate == null || loanTerm == null || installmentCount == null) {
      _showError('সঠিক মান লিখুন');
      return;
    }

    if (interestRate <= 0 || loanTerm <= 0 || installmentCount <= 0) {
      _showError('মান শূন্যের চেয়ে বড় হতে হবে');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final monthlyNetIncome = provider.netAmount;
      final E = _getRepaymentCapacity(monthlyNetIncome);

      if (E <= 0) {
        throw Exception('ঋণ পরিশোধের সক্ষমতা শূন্যের চেয়ে বড় হতে হবে');
      }

      // Formula: A = (E * n) / ((1 + r/100) ^ N)
      // Where:
      // A = Loan Amount
      // E = Repayment Capacity (ঋণ পরিশোধের সক্ষমতা)
      // n = Number of Installments (ঋণের কিস্তি সংখ্যা)
      // N = Loan Term in months (ঋণের মেয়াদ কাল)
      // r = Interest Rate (সুদের হার)

      final r = interestRate;
      final n = installmentCount;
      final N = loanTerm;
      final monthlyRate = r / 12 / 100;

      final loanAmount = (E * n) / pow(1 + monthlyRate, N);

      final monthlyInstallment = E;

      final totalRepayment = monthlyInstallment * N;

      setState(() {
        _calculatedLoanAmount = loanAmount;
        _monthlyInstallment = monthlyInstallment;
        _totalRepayment = totalRepayment;
      });

      // Save loan data
      final loanData = LoanData(
        interestRate: interestRate,
        loanTerm: loanTerm,
        monthlyNetIncome: monthlyNetIncome,
        loanAmount: loanAmount,
        monthlyPayment: monthlyInstallment,
        calculatedDate: DateTime.now(),
      );
      await provider.calculateLoanWithData(loanData);

      _showSuccess('ঋণ হিসাব সম্পন্ন হয়েছে');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final monthlyNetIncome = provider.netAmount;
                final repaymentCapacity = _getRepaymentCapacity(
                  monthlyNetIncome,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.calculate,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'ঋণ হিসাব',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Monthly Net Income Display
                    _buildInfoCard(
                      title: 'মাসিক পারিবারিক নীট আয়',
                      subtitle: '(মাসিক আয় - মাসিক খরচ)',
                      amount: monthlyNetIncome,
                      color: Colors.blue,
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(height: 15),

                    // Cash Flow Adjustment Factor
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cash Flow Adjustment Factor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<double>(
                                  title: const Text('নতুন সদস্য (40%)'),
                                  value: 40.0,
                                  groupValue: _cashFlowAdjustmentPercent,
                                  onChanged: (value) {
                                    setState(() {
                                      _cashFlowAdjustmentPercent = value!;
                                      _useCustomCapacity = false;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<double>(
                                  title: const Text('পুরাতন সদস্য (50%)'),
                                  value: 50.0,
                                  groupValue: _cashFlowAdjustmentPercent,
                                  onChanged: (value) {
                                    setState(() {
                                      _cashFlowAdjustmentPercent = value!;
                                      _useCustomCapacity = false;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Repayment Capacity Display
                    _buildInfoCard(
                      title: 'ঋণ পরিশোধের সক্ষমতা',
                      subtitle:
                          'নীট আয় × ${_cashFlowAdjustmentPercent.toInt()}%',
                      amount: repaymentCapacity,
                      color: Colors.green,
                      icon: Icons.trending_up,
                      trailing: IconButton(
                        icon: Icon(
                          _useCustomCapacity ? Icons.edit : Icons.edit_outlined,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            _useCustomCapacity = !_useCustomCapacity;
                            if (!_useCustomCapacity) {
                              _repaymentCapacityController.clear();
                            }
                          });
                        },
                        tooltip: 'কাস্টম সক্ষমতা',
                      ),
                    ),

                    // Custom Repayment Capacity Input
                    if (_useCustomCapacity) ...[
                      const SizedBox(height: 15),
                      TextField(
                        controller: _repaymentCapacityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'কাস্টম ঋণ পরিশোধের সক্ষমতা',
                          hintText: 'যেমন: 17550',
                          prefixIcon: const Icon(Icons.edit),
                          prefixText: '৳ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    // Input Fields
                    _buildTextField(
                      controller: _installmentController,
                      label: 'ঋণের কিস্তি সংখ্যা (n)',
                      hint: 'যেমন: 18',
                      icon: Icons.format_list_numbered,
                      isNumber: true,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _termController,
                      label: 'ঋণের মেয়াদ কাল (N) - মাসে',
                      hint: 'যেমন: 18',
                      icon: Icons.calendar_month,
                      isNumber: true,
                      helperText: 'মোট কত মাসে শেষ করবেন',
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      controller: _interestController,
                      label: 'সুদের হার (r) - %',
                      hint: 'যেমন: 8.5',
                      icon: Icons.percent,
                      isDecimal: true,
                      helperText: 'বার্ষিক সুদের হার',
                    ),
                    const SizedBox(height: 25),

                    // Formula Display
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'সূত্র:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'A = (E × n) ÷ ((1 + r/100) ^ N)',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Divider(height: 20),
                          Text(
                            'A = ঋণের পরিমাণ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'E = ঋণ পরিশোধের সক্ষমতা = ৳${_formatNumber(repaymentCapacity)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'n = কিস্তি সংখ্যা = ${_installmentController.text.isEmpty ? "?" : _installmentController.text}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'N = মেয়াদ (মাস) = ${_termController.text.isEmpty ? "?" : _termController.text}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'r = সুদের হার = ${_interestController.text.isEmpty ? "?" : _interestController.text}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculateLoan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calculate, size: 24),
                                  SizedBox(width: 10),
                                  Text(
                                    'হিসাব করুন',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Results
                    if (_calculatedLoanAmount != null) ...[
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[700]!, Colors.green[500]!],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 60,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'ঋণের পরিমাণ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '৳${_formatNumber(_calculatedLoanAmount!)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detailed Breakdown
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'বিস্তারিত তথ্য',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),
                            _buildResultRow(
                              'মাসিক কিস্তি',
                              '৳${_formatNumber(_monthlyInstallment!)}',
                            ),
                            _buildResultRow(
                              'মোট কিস্তি সংখ্যা',
                              '${_installmentController.text} টি',
                            ),
                            _buildResultRow(
                              'মোট পরিশোধ',
                              '৳${_formatNumber(_totalRepayment!)}',
                            ),
                            _buildResultRow(
                              'সুদের হার',
                              '${_interestController.text}%',
                            ),
                            _buildResultRow(
                              'মেয়াদ',
                              '${_termController.text} মাস',
                            ),
                            _buildResultRow(
                              'হিসাবের তারিখ',
                              DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(DateTime.now()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required double amount,
    required Color color,
    required IconData icon,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${_formatNumber(amount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool isDecimal = false,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : (isNumber ? TextInputType.number : TextInputType.text),
      inputFormatters: isDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : (isNumber ? [FilteringTextInputFormatter.digitsOnly] : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return NumberFormat('#,##,###').format(number.round());
  }
}

// ==================== providers/transaction_provider.dart (ADD METHOD) ====================
// Add this method to TransactionProvider class:

/*
Future<void> calculateLoanWithData(LoanData loanData) async {
  _loanData = loanData;
  await _storage.saveLoanData(_loanData!);
  notifyListeners();
}
*/
