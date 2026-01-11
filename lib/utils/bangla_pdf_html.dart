import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/LoanData.dart';

String buildLoanReportHTML({
  required double totalIncome,
  required double totalExpense,
  required double netAmount,
  required LoanData? loanData,
  required List<Transaction> transactions,
}) {
  final date = DateFormat(
    'dd MMMM yyyy, hh:mm a',
    'bn_BD',
  ).format(DateTime.now());

  String rows = '';
  for (final t in transactions) {
    rows +=
        '''
    <tr class="${t.isIncome ? 'income' : 'expense'}">
      <td>${t.title}</td>
      <td>${DateFormat('dd MMM yyyy', 'bn_BD').format(t.date)}</td>
      <td>${t.isIncome ? 'আয়' : 'খরচ'}</td>
      <td style="text-align:right;">৳${t.amount.toStringAsFixed(0)}</td>
    </tr>
    ''';
  }

  return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali&display=swap" rel="stylesheet">
<style>
body {
  font-family: 'Noto Sans Bengali', sans-serif;
  padding: 24px;
  background-color: #f5f5f5;
  color: #333;
}
h1 {
  text-align:center;
  color: #2e7d32;
}
.report-card {
  background: #fff;
  padding: 20px 30px;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
  max-width: 900px;
  margin: auto;
}
.summary p {
  font-size: 14px;
  margin: 4px 0;
}
.summary p span {
  font-weight: bold;
  color: #1b5e20;
}
table {
  width:100%;
  border-collapse: collapse;
  margin-top: 20px;
  font-size: 13px;
}
th, td {
  border:1px solid #ccc;
  padding:10px;
}
th {
  background-color: #2e7d32;
  color: #fff;
  text-align:left;
}
tr.income {
  background-color: #e8f5e9;
}
tr.expense {
  background-color: #ffebee;
}
tr:nth-child(even) {
  background-color: #f9f9f9;
}
tfoot td {
  font-weight: bold;
  color: #1b5e20;
}
.loan-info {
  margin-top: 20px;
  padding: 15px;
  border:1px solid #ffa726;
  background-color: #fff3e0;
  border-radius: 6px;
}
</style>
</head>

<body>
<div class="report-card">
<h1>আয়-ব্যয় রিপোর্ট</h1>
<p>তারিখ: $date</p>

<div class="summary">
<p>মোট আয়: <span>৳${totalIncome.toStringAsFixed(0)}</span></p>
<p>মোট খরচ: <span>৳${totalExpense.toStringAsFixed(0)}</span></p>
<p>নিট পরিমাণ: <span>৳${netAmount.toStringAsFixed(0)}</span></p>
</div>

${loanData == null ? '' : '''
<div class="loan-info">
<h3>ঋণ তথ্য</h3>
<p>ঋণের পরিমাণ: ৳${loanData.loanAmount}</p>
<p>প্রতি কিস্তি: ৳${loanData.installmentAmount}</p>
<p>বার্ষিক সুদের হার: ${loanData.interestRate}%</p>
<p>মেয়াদ: ${loanData.termInMonths} মাস</p>
<p>বার্ষিক পরিশোধ: ৳${loanData.yearlyCapacity}</p>
</div>
'''}

<table>
<thead>
<tr>
<th>নাম</th>
<th>তারিখ</th>
<th>ধরন</th>
<th style="text-align:right;">পরিমাণ</th>
</tr>
</thead>
<tbody>
$rows
</tbody>
<tfoot>
<tr>
<td colspan="3">মোট নেট পরিমাণ</td>
<td style="text-align:right;">৳${netAmount.toStringAsFixed(0)}</td>
</tr>
</tfoot>
</table>

<p style="text-align:center; margin-top: 30px; font-size:12px; color:#777;">ঋণ ক্যালকুলেটর অ্যাপ দ্বারা তৈরি</p>
</div>
</body>
</html>
''';
}
