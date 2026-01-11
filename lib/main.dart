import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('bn_BD');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LoanCalculatorApp());
}

class LoanCalculatorApp extends StatelessWidget {
  const LoanCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        title: 'ঋণ ক্যালকুলেটর',
        debugShowCheckedModeBanner: false,

        // 🔥 Use Bengali-safe font
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'NotoSansBengali',
          scaffoldBackgroundColor: Colors.grey[50],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'NotoSansBengali'),
            bodyMedium: TextStyle(fontFamily: 'NotoSansBengali'),
            bodySmall: TextStyle(fontFamily: 'NotoSansBengali'),
            titleLarge: TextStyle(fontFamily: 'NotoSansBengali'),
            titleMedium: TextStyle(fontFamily: 'NotoSansBengali'),
            titleSmall: TextStyle(fontFamily: 'NotoSansBengali'),
            headlineLarge: TextStyle(fontFamily: 'NotoSansBengali'),
            headlineMedium: TextStyle(fontFamily: 'NotoSansBengali'),
            headlineSmall: TextStyle(fontFamily: 'NotoSansBengali'),
          ),
        ),

        home: const HomeScreen(),

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('bn', 'BD'),
          Locale('en', 'US'),
        ],
        locale: const Locale('bn', 'BD'),
      ),
    );
  }
}
