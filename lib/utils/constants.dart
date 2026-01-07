import 'package:flutter/material.dart';

class AppConstants {
  // ==================== Colors ====================
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryRed = Color(0xFFC62828);
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color accentOrange = Color(0xFFFF6F00);
  static const Color backgroundLight = Color(0xFFF5F5F5);

  // ==================== Gradients ====================
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFFEBEE), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== Text Styles ====================
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2E7D32),
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ==================== Spacing ====================
  static const double defaultPadding = 20.0;
  static const double smallPadding = 10.0;
  static const double largePadding = 30.0;
  static const double extraSmallPadding = 5.0;

  // ==================== Border Radius ====================
  static const double defaultRadius = 12.0;
  static const double largeRadius = 15.0;
  static const double smallRadius = 8.0;
  static const double buttonRadius = 12.0;

  // ==================== Sizes ====================
  static const double buttonHeight = 55.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // ==================== Cash Flow Adjustment Factor ====================
  static const double cashFlowAdjustment = 17550.0;

  // ==================== Predefined Income Fields ====================
  static const List<String> incomeFields = [
    'নিজের বেতন',
    'স্বামীর/স্ত্রীর বেতন',
    'ছেলে/মেয়ের বেতন',
    'মা/বাবার বেতন',
    'সঞ্চয় থেকে লাভ',
    'বাড়ী ভাড়া থাকে আয়',
    'ব্যবসা থেকে আয়',
    'কৃষি খাতে আয়',
    'পশু/পাখি পালন থেকে আয়',
    'গাছপালা বিক্রি থেকে আয়',
    'ফলমূল বিক্রি থেকে আয়',
    'অন্যান্য (উল্লেখ করুন)',
  ];

  // ==================== Predefined Expense Fields ====================
  static const List<String> expenseFields = [
    'খাবার খরচ',
    'বাড়ী ভাড়া',
    'স্কুলের কিস্তি',
    'ডিপিএস',
    'বিদ্যুৎ বিল',
    'চিকিৎসা',
    'শিক্ষা',
    'জ্বালানী খরচ',
    'যাতায়াত/ পরিবহন খরচ',
    'মোবাইল ও ইন্টারনেট বিল',
    'ঘর বাড়ী মেরামত',
    'ভূমি বাজারা/ট্যাক্স',
    'উৎসব খরচ',
    'জীম বিল',
    'জেনারেটর বিল',
    'গৃহ কর্মীর বেতন',
    'সাজিং চার্জ',
    'নামলাত বিল',
  ];

  // ==================== Income Categories (For Icons/Colors) ====================
  static const Map<String, IconData> incomeCategoryIcons = {
    'নিজের বেতন': Icons.account_balance_wallet,
    'স্বামীর/স্ত্রীর বেতন': Icons.person,
    'ছেলে/মেয়ের বেতন': Icons.family_restroom,
    'মা/বাবার বেতন': Icons.elderly,
    'সঞ্চয় থেকে লাভ': Icons.savings,
    'বাড়ী ভাড়া থাকে আয়': Icons.home,
    'ব্যবসা থেকে আয়': Icons.business,
    'কৃষি খাতে আয়': Icons.agriculture,
    'পশু/পাখি পালন থেকে আয়': Icons.pets,
    'গাছপালা বিক্রি থেকে আয়': Icons.park,
    'ফলমূল বিক্রি থেকে আয়': Icons.eco,
    'অন্যান্য (উল্লেখ করুন)': Icons.more_horiz,
  };

  // ==================== Expense Categories (For Icons/Colors) ====================
  static const Map<String, IconData> expenseCategoryIcons = {
    'খাবার খরচ': Icons.restaurant,
    'বাড়ী ভাড়া': Icons.home,
    'স্কুলের কিস্তি': Icons.school,
    'ডিপিএস': Icons.account_balance,
    'বিদ্যুৎ বিল': Icons.bolt,
    'চিকিৎসা': Icons.medical_services,
    'শিক্ষা': Icons.menu_book,
    'জ্বালানী খরচ': Icons.local_gas_station,
    'যাতায়াত/ পরিবহন খরচ': Icons.directions_bus,
    'মোবাইল ও ইন্টারনেট বিল': Icons.phone_android,
    'ঘর বাড়ী মেরামত': Icons.construction,
    'ভূমি বাজারা/ট্যাক্স': Icons.landscape,
    'উৎসব খরচ': Icons.celebration,
    'জীম বিল': Icons.fitness_center,
    'জেনারেটর বিল': Icons.power,
    'গৃহ কর্মীর বেতন': Icons.cleaning_services,
    'সাজিং চার্জ': Icons.electric_bolt,
    'নামলাত বিল': Icons.description,
  };

  // ==================== App Strings ====================
  static const String appName = 'ঋণ ক্যালকুলেটর';
  static const String totalIncome = 'মোট আয়';
  static const String totalExpense = 'মোট খরচ';
  static const String netAmount = 'নিট পরিমাণ';
  static const String addIncome = 'আয় যোগ করুন';
  static const String addExpense = 'খরচ যোগ করুন';
  static const String calculateLoan = 'ঋণ হিসাব করুন';
  static const String report = 'রিপোর্ট';
  static const String save = 'সংরক্ষণ করুন';
  static const String reset = 'রিসেট';
  static const String cancel = 'বাতিল';
  static const String confirm = 'নিশ্চিত করুন';

  // ==================== Messages ====================
  static const String confirmReset = 'সব ডাটা মুছে ফেলতে চান?';
  static const String dataCleared = 'সব ডাটা মুছে ফেলা হয়েছে';
  static const String incomeSaved = 'আয় সংরক্ষিত হয়েছে';
  static const String expenseSaved = 'খরচ সংরক্ষিত হয়েছে';
  static const String fillAllFields = 'সব ফিল্ড পূরণ করুন';
  static const String transactionDeleted = 'লেনদেন মুছে ফেলা হয়েছে';
  static const String loanCalculated = 'ঋণ হিসাব সম্পন্ন হয়েছে';
  static const String noTransactions = 'এখনো কোনো লেনদেন নেই';
  static const String noIncome = 'কোনো আয় নেই';
  static const String noExpense = 'কোনো খরচ নেই';

  // ==================== Validation Messages ====================
  static const String enterValidAmount = 'সঠিক টাকার পরিমাণ লিখুন';
  static const String enterDescription = 'বিবরণ লিখুন';
  static const String amountMustBePositive = 'টাকার পরিমাণ শূন্যের চেয়ে বড় হতে হবে';
  static const String insufficientIncome = 'আপনার নিট আয় ঋণ গ্রহণের জন্য যথেষ্ট নয়';

  // ==================== Box Shadows ====================
  static List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== Animation Durations ====================
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // ==================== Helper Methods ====================

  /// Format number to Bangla style (লক্ষ, কোটি)
  static String formatNumberBangla(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} কোটি';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} লক্ষ';
    } else if (number >= 1000) {
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    }
    return number.toStringAsFixed(0);
  }

  /// Get color based on transaction type
  static Color getTransactionColor(bool isIncome) {
    return isIncome ? primaryGreen : primaryRed;
  }

  /// Get icon for category
  static IconData getCategoryIcon(String category, bool isIncome) {
    if (isIncome) {
      return incomeCategoryIcons[category] ?? Icons.account_balance_wallet;
    } else {
      return expenseCategoryIcons[category] ?? Icons.shopping_bag;
    }
  }

  /// Create gradient for widget background
  static LinearGradient createGradient(Color color) {
    return LinearGradient(
      colors: [color.withOpacity(0.1), Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Create box decoration with shadow
  static BoxDecoration createCardDecoration({
    Color? color,
    double? radius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius ?? defaultRadius),
      boxShadow: shadows ?? cardShadow,
    );
  }

  /// Validate amount input
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return enterValidAmount;
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return amountMustBePositive;
    }
    return null;
  }

  /// Validate description input
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return enterDescription;
    }
    return null;
  }
}