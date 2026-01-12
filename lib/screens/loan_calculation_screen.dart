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
  TermUnit _selectedTermUnit = TermUnit.months;

  double? _calculatedLoanAmount;
  double? _installmentAmount;
  double? _totalRepayment;
  int? _daysBetweenInstallments;

  @override
  void initState() {
    super.initState();
    _interestController.text = '';
    _termController.text = '';
    _installmentController.text = '';
    _repaymentCapacityController.text = '';
  }

  @override
  void dispose() {
    _interestController.dispose();
    _termController.dispose();
    _installmentController.dispose();
    _repaymentCapacityController.dispose();
    super.dispose();
  }

  double _getMonthlyRepaymentCapacity(double monthlyNetIncome) {
    if (_useCustomCapacity && _repaymentCapacityController.text.isNotEmpty) {
      return double.tryParse(_repaymentCapacityController.text) ?? 0;
    }
    return monthlyNetIncome * (_cashFlowAdjustmentPercent / 100);
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

  double _calculateTermInMonths() {
    final term = double.tryParse(_termController.text) ?? 0;
    return _convertToMonths(term, _selectedTermUnit);
  }

  double _calculateTermInYears() {
    final termInMonths = _calculateTermInMonths();
    if (termInMonths <= 0) return 0.0;
    return termInMonths / 12;
  }

  double _calculateTotalDays() {
    final term = double.tryParse(_termController.text) ?? 0;
    return _convertToDays(term, _selectedTermUnit);
  }

  double _calculateDaysBetweenInstallments() {
    final installmentCount = int.tryParse(_installmentController.text) ?? 1;
    if (installmentCount <= 0) return 0;
    return _calculateTotalDays() / installmentCount;
  }

  Future<void> _calculateLoan() async {
    final provider = context.read<TransactionProvider>();

    if (_interestController.text.isEmpty ||
        _termController.text.isEmpty ||
        _installmentController.text.isEmpty) {
      _showError('সব তথ্য পূরণ করুন');
      return;
    }

    final interestRate = double.tryParse(_interestController.text);
    final term = double.tryParse(_termController.text);
    final installmentCount = int.tryParse(_installmentController.text);

    if (interestRate == null || term == null || installmentCount == null) {
      _showError('সঠিক মান লিখুন');
      return;
    }

    if (interestRate <= 0 || term <= 0 || installmentCount <= 0) {
      _showError('মান শূন্যের চেয়ে বড় হতে হবে');
      return;
    }

    final daysBetween = _calculateDaysBetweenInstallments();
    if (daysBetween < 1) {
      _showError('প্রতি কিস্তির মধ্যবর্তী সময় কমপক্ষে ১ দিন হতে হবে');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final monthlyNetIncome = provider.netAmount;
      if (monthlyNetIncome <= 0) {
        throw Exception('প্রথমে আয়-ব্যয় যোগ করুন');
      }

      final monthlyCapacity = _getMonthlyRepaymentCapacity(monthlyNetIncome);
      if (monthlyCapacity <= 0) {
        throw Exception('ঋণ পরিশোধের সক্ষমতা শূন্যের চেয়ে বড় হতে হবে');
      }

      await provider.calculateLoan(
        interestRate: interestRate,
        term: term,
        termUnit: _selectedTermUnit,
        installmentCount: installmentCount,
        monthlyNetIncome: monthlyNetIncome,
        cashFlowPercent: _cashFlowAdjustmentPercent,
      );

      final loanData = provider.loanData;
      if (loanData != null) {
        setState(() {
          _calculatedLoanAmount = loanData.loanAmount;
          _installmentAmount = loanData.installmentAmount;
          _totalRepayment = loanData.totalRepayment;
          _daysBetweenInstallments = loanData.daysBetweenInstallments;
        });
        _showSuccess('ঋণ হিসাব সম্পন্ন হয়েছে!');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTermUnitLabel(TermUnit unit) {
    switch (unit) {
      case TermUnit.days:
        return 'দিন';
      case TermUnit.months:
        return 'মাস';
      case TermUnit.years:
        return 'বছর';
    }
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
                final monthlyCapacity = _getMonthlyRepaymentCapacity(
                  monthlyNetIncome,
                );
                final yearlyCapacity = monthlyCapacity * 12;
                final termInMonths = _calculateTermInMonths();
                final termInYears = termInMonths / 12;
                final installmentCount =
                    int.tryParse(_installmentController.text) ?? 6;
                final totalDays = _calculateTotalDays();
                final daysBetween = _calculateDaysBetweenInstallments();
                final term = double.tryParse(_termController.text) ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.money, color: Colors.blue, size: 32),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'এনজিও ঋণ হিসাব',
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

                    _buildInfoCard(
                      title: 'মাসিক পারিবারিক নীট আয়',
                      subtitle: '(মাসিক আয় - মাসিক খরচ)',
                      amount: monthlyNetIncome,
                      color: Colors.blue,
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(height: 15),

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
                              fontSize: 16,
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

                    _buildInfoCard(
                      title: 'মাসিক ঋণ পরিশোধের সক্ষমতা',
                      subtitle:
                          'নীট আয় × ${_cashFlowAdjustmentPercent.toInt()}%',
                      amount: monthlyCapacity,
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
                      ),
                    ),

                    if (_useCustomCapacity) ...[
                      const SizedBox(height: 15),
                      TextField(
                        controller: _repaymentCapacityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'কাস্টম মাসিক সক্ষমতা',
                          hintText: 'যেমন: 5000',
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

                    if (monthlyCapacity > 0) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'বার্ষিক ঋণ পরিশোধের সক্ষমতা',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '৳${_formatNumber(yearlyCapacity)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  Text(
                                    'মাসিক ${_formatNumber(monthlyCapacity)} × ১২ মাস',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ঋণের মেয়াদ নির্বাচন করুন',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              RadioListTile<TermUnit>(
                                title: const Text('দিন'),
                                value: TermUnit.days,
                                groupValue: _selectedTermUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTermUnit = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                              RadioListTile<TermUnit>(
                                title: const Text('মাস'),
                                value: TermUnit.months,
                                groupValue: _selectedTermUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTermUnit = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                              RadioListTile<TermUnit>(
                                title: const Text('বছর'),
                                value: TermUnit.years,
                                groupValue: _selectedTermUnit,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTermUnit = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _termController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        labelText:
                            'ঋণের মেয়াদ (${_getTermUnitLabel(_selectedTermUnit)})',
                        prefixIcon: const Icon(Icons.calendar_month),
                        helperText:
                            'ঋণ কত ${_getTermUnitLabel(_selectedTermUnit)} নিতে চান',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    if (_termController.text.isNotEmpty && term > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'মোট দিন:',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${totalDays.round()} দিন',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'মোট মাস:',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${termInMonths.toStringAsFixed(1)} মাস',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'মোট বছর:',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  '${termInYears.toStringAsFixed(2)} বছর',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _installmentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'কিস্তি সংখ্যা (n)',
                        prefixIcon: const Icon(Icons.format_list_numbered),
                        helperText:
                            'যেকোনো সংখ্যা হতে পারে (যেমন: ২০ দিনে ৪৫ কিস্তি)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    if (_termController.text.isNotEmpty &&
                        _installmentController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'প্রতি কিস্তির মধ্যবর্তী সময়:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '${daysBetween.toStringAsFixed(1)} দিন',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'মেয়াদ: ${totalDays.round()} দিন ÷ $installmentCount কিস্তি',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _interestController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'বার্ষিক সুদের হার (%)',
                        prefixIcon: const Icon(Icons.percent),
                        helperText: 'বার্ষিক সুদের হার লিখুন',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'এনজিও ঋণ সূত্র:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'A = (E × N) ÷ (1 + r)ᴺ',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 20),
                          Text(
                            'A = ঋণের পরিমাণ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'E = বার্ষিক পরিশোধ সক্ষমতা = ৳${_formatNumber(yearlyCapacity)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'N = মেয়াদ (বছর) = ${termInYears.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'r = সুদের হার = ${_interestController.text}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'কিস্তি = (E × N) ÷ n = ৳${_formatNumber((yearlyCapacity * termInYears) / (installmentCount > 0 ? installmentCount : 1))}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

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
                              'প্রাপ্য ঋণের পরিমাণ',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'বিস্তারিত তথ্য',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 20),
                            _buildResultRow(
                              'বার্ষিক পরিশোধ সক্ষমতা',
                              '৳${_formatNumber(yearlyCapacity)}',
                            ),
                            _buildResultRow(
                              'প্রতি কিস্তির পরিমাণ',
                              '৳${_formatNumber(_installmentAmount!)}',
                              subText:
                                  'মোট $installmentCount কিস্তি (প্রতি ${_daysBetweenInstallments} দিনে)',
                            ),
                            _buildResultRow(
                              'ঋণের মেয়াদ',
                              '$term ${_getTermUnitLabel(_selectedTermUnit)}',
                              subText:
                                  '(${termInYears.toStringAsFixed(1)} বছর / ${totalDays.round()} দিন)',
                            ),
                            _buildResultRow(
                              'সুদের হার',
                              '${_interestController.text}%',
                              subText: 'বার্ষিক',
                            ),
                            _buildResultRow(
                              'মোট পরিশোধ',
                              '৳${_formatNumber(_totalRepayment!)}',
                              subText: '${termInYears.toStringAsFixed(1)} বছরে',
                              isTotal: true,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'গ্রাহক বছরে সর্বোচ্চ ৳${_formatNumber(yearlyCapacity)} টাকা পরিশোধ করতে পারবেন',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
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
                const SizedBox(height: 5),
                Text(
                  '৳${_formatNumber(amount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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

  Widget _buildResultRow(
    String label,
    String value, {
    String? subText,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isTotal ? Colors.green[700] : Colors.grey[700],
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    fontSize: isTotal ? 16 : 14,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
                  fontSize: isTotal ? 18 : 16,
                  color: isTotal ? Colors.green[700] : Colors.black,
                ),
              ),
            ],
          ),
          if (subText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2),
              child: Text(
                subText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return NumberFormat('#,##,###').format(number.round());
  }
}
