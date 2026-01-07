import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LoanCalculatorApp());
}

class LoanCalculatorApp extends StatelessWidget {
  const LoanCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'ঋণ ক্যালকুলেটর',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
