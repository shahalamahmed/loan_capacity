import 'package:printing/printing.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';
import 'bangla_pdf_html.dart';

Future<void> generateBanglaPDF(
    double totalIncome,
    double totalExpense,
    double netAmount,
    LoanData? loanData,
    List<Transaction> transactions,
    ) async {
  await initializeDateFormatting('bn_BD');

  final html = buildLoanReportHTML(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netAmount: netAmount,
    loanData: loanData,
    transactions: transactions,
  );

  await Printing.layoutPdf(
    onLayout: (format) async {
      return await Printing.convertHtml(html: html, format: format);
    },
  );
}
