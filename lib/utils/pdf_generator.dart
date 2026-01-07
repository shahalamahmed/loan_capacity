import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';

class PDFGenerator {
  static Future<void> generatePDF({
    required BuildContext context,
    required List<Transaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required double netAmount,
    LoanData? loanData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'আয়-ব্যয় রিপোর্ট',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'তারিখ: ${DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Summary Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  _buildPDFRow(
                    'মোট আয়',
                    '৳${NumberFormat('#,##,###').format(totalIncome)}',
                    true,
                  ),
                  pw.SizedBox(height: 8),
                  _buildPDFRow(
                    'মোট খরচ',
                    '৳${NumberFormat('#,##,###').format(totalExpense)}',
                    true,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 8),
                  _buildPDFRow(
                    'নিট পরিমাণ',
                    '৳${NumberFormat('#,##,###').format(netAmount)}',
                    true,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Loan Information
            if (loanData != null) ...[
              pw.Text(
                'ঋণ তথ্য',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPDFRow(
                      'ঋণের পরিমাণ',
                      '৳${NumberFormat('#,##,###').format(loanData.loanAmount)}',
                      false,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'মাসিক পেমেন্ট',
                      '৳${NumberFormat('#,##,###').format(loanData.monthlyPayment)}',
                      false,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'সুদের হার',
                      '${loanData.interestRate}%',
                      false,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow('মেয়াদ', '${loanData.loanTerm} মাস', false),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
            ],

            // Transactions
            pw.Text(
              'লেনদেনের বিবরণ',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 12),

            ...transactions.map(
              (t) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            t.title,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            DateFormat('dd MMM yyyy').format(t.date),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      '৳${NumberFormat('#,##,###').format(t.amount)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: t.isIncome ? PdfColors.green : PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildPDFRow(String label, String value, bool isBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
