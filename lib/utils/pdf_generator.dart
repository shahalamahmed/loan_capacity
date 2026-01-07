import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

    // Load Bangla Font
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansBengali-Regular.ttf',
    );
    final fontDataBold = await rootBundle.load(
      'assets/fonts/NotoSansBengali-Bold.ttf',
    );

    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontDataBold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.blue600),
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
                      font: ttfBold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'তারিখ: ${DateFormat('dd MMMM yyyy, hh:mm a', 'bn_BD').format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                      font: ttf,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Summary Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Column(
                children: [
                  _buildPDFRow(
                    'মোট আয়',
                    '৳${NumberFormat('#,##,###').format(totalIncome)}',
                    ttf,
                    ttfBold,
                    PdfColors.green700,
                  ),
                  pw.SizedBox(height: 8),
                  _buildPDFRow(
                    'মোট খরচ',
                    '৳${NumberFormat('#,##,###').format(totalExpense)}',
                    ttf,
                    ttfBold,
                    PdfColors.red700,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 2, color: PdfColors.blue200),
                  pw.SizedBox(height: 8),
                  _buildPDFRow(
                    'নিট পরিমাণ',
                    '৳${NumberFormat('#,##,###').format(netAmount)}',
                    ttf,
                    ttfBold,
                    PdfColors.blue700,
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
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                  font: ttfBold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPDFRow(
                      'ঋণের পরিমাণ',
                      '৳${NumberFormat('#,##,###').format(loanData.loanAmount)}',
                      ttf,
                      ttfBold,
                      PdfColors.grey900,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'মাসিক পেমেন্ট',
                      '৳${NumberFormat('#,##,###').format(loanData.monthlyPayment)}',
                      ttf,
                      ttfBold,
                      PdfColors.grey900,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'সুদের হার',
                      '${loanData.interestRate}%',
                      ttf,
                      ttfBold,
                      PdfColors.grey900,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPDFRow(
                      'মেয়াদ',
                      '${loanData.loanTerm} মাস',
                      ttf,
                      ttfBold,
                      PdfColors.grey900,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
            ],

            // Transactions Header
            pw.Text(
              'লেনদেনের বিবরণ',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
                font: ttfBold,
              ),
            ),
            pw.SizedBox(height: 12),

            // Transactions List
            ...transactions.map(
              (t) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: t.isIncome ? PdfColors.green50 : PdfColors.red50,
                  border: pw.Border.all(
                    color: t.isIncome ? PdfColors.green200 : PdfColors.red200,
                  ),
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
                              font: ttfBold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            DateFormat('dd MMM yyyy', 'bn_BD').format(t.date),
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                              font: ttf,
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
                        color: t.isIncome
                            ? PdfColors.green700
                            : PdfColors.red700,
                        font: ttfBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            pw.SizedBox(height: 30),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'ঋণ ক্যালকুলেটর অ্যাপ দ্বারা তৈরি',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  font: ttf,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Save or print the PDF
    final bytes = await pdf.save();
    try {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/loan_report.pdf');
        await file.writeAsBytes(bytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF ডাউনলোড হয়েছে: ${file.path}')),
          );
        }
      } else {
        await Printing.layoutPdf(onLayout: (format) async => bytes);
      }
    } catch (e) {
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    }
  }

  static pw.Widget _buildPDFRow(
    String label,
    String value,
    pw.Font regularFont,
    pw.Font boldFont,
    PdfColor valueColor,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 13,
            color: PdfColors.grey800,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
            fontSize: 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
