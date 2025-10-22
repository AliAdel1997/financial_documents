class ArabicNumberToWordsService {
  static final ArabicNumberToWordsService _instance = ArabicNumberToWordsService._internal();
  factory ArabicNumberToWordsService() => _instance;
  ArabicNumberToWordsService._internal();

  // الأرقام الأساسية
  static const Map<int, String> _ones = {
    0: '',
    1: 'واحد',
    2: 'اثنان',
    3: 'ثلاثة',
    4: 'أربعة',
    5: 'خمسة',
    6: 'ستة',
    7: 'سبعة',
    8: 'ثمانية',
    9: 'تسعة',
    10: 'عشرة',
    11: 'أحد عشر',
    12: 'اثنا عشر',
    13: 'ثلاثة عشر',
    14: 'أربعة عشر',
    15: 'خمسة عشر',
    16: 'ستة عشر',
    17: 'سبعة عشر',
    18: 'ثمانية عشر',
    19: 'تسعة عشر',
  };

  static const Map<int, String> _tens = {
    20: 'عشرون',
    30: 'ثلاثون',
    40: 'أربعون',
    50: 'خمسون',
    60: 'ستون',
    70: 'سبعون',
    80: 'ثمانون',
    90: 'تسعون',
  };

  static const Map<int, String> _hundreds = {
    100: 'مائة',
    200: 'مائتان',
    300: 'ثلاثمائة',
    400: 'أربعمائة',
    500: 'خمسمائة',
    600: 'ستمائة',
    700: 'سبعمائة',
    800: 'ثمانمائة',
    900: 'تسعمائة',
  };

  // وحدات الآلاف
  static const List<String> _thousands = [
    '',
    'ألف',
    'مليون',
    'مليار',
    'تريليون',
  ];

  /// تحويل الرقم إلى كلمات بالعربية
  static String convertToWords(double number, {String currency = 'ريال'}) {
    try {
      if (number == 0) {
        return 'صفر $currency';
      }

      if (number < 0) {
        return 'سالب ${convertToWords(-number, currency: currency)}';
      }

      // فصل الجزء الصحيح عن الجزء العشري
      int wholePart = number.floor();
      int fractionalPart = ((number - wholePart) * 100).round();

      String result = '';

      // تحويل الجزء الصحيح
      if (wholePart > 0) {
        result += _convertWholeNumber(wholePart);
        
        // إضافة العملة
        if (wholePart == 1) {
          result += ' $currency واحد';
        } else if (wholePart == 2) {
          result += ' ${currency}ان';
        } else if (wholePart >= 3 && wholePart <= 10) {
          result += ' $currency';
        } else if (wholePart >= 11 && wholePart <= 99) {
          result += ' $currency';
        } else {
          result += ' $currency';
        }
      }

      // تحويل الجزء العشري (الهلالات)
      if (fractionalPart > 0) {
        if (result.isNotEmpty) {
          result += ' و';
        }
        result += _convertWholeNumber(fractionalPart);
        
        if (fractionalPart == 1) {
          result += ' هللة واحدة';
        } else if (fractionalPart == 2) {
          result += ' هللتان';
        } else if (fractionalPart >= 3 && fractionalPart <= 10) {
          result += ' هللات';
        } else {
          result += ' هللة';
        }
      }

      return result.trim();
    } catch (e) {
      return 'خطأ في التحويل';
    }
  }

  /// تحويل الرقم الصحيح إلى كلمات
  static String _convertWholeNumber(int number) {
    if (number == 0) return '';

    String result = '';
    int thousandIndex = 0;

    while (number > 0) {
      int group = number % 1000;
      if (group > 0) {
        String groupText = _convertGroup(group);
        
        if (thousandIndex > 0) {
          groupText += ' ${_getThousandText(group, thousandIndex)}';
        }
        
        if (result.isNotEmpty) {
          result = groupText + ' ' + result;
        } else {
          result = groupText;
        }
      }
      
      number ~/= 1000;
      thousandIndex++;
    }

    return result;
  }

  /// تحويل مجموعة من 3 أرقام
  static String _convertGroup(int number) {
    if (number == 0) return '';

    String result = '';
    
    // المئات
    int hundreds = number ~/ 100;
    if (hundreds > 0) {
      result += _hundreds[hundreds * 100]!;
    }

    // العشرات والآحاد
    int remainder = number % 100;
    if (remainder > 0) {
      if (result.isNotEmpty) {
        result += ' ';
      }
      
      if (remainder < 20) {
        result += _ones[remainder]!;
      } else {
        int tens = (remainder ~/ 10) * 10;
        int ones = remainder % 10;
        
        result += _tens[tens]!;
        if (ones > 0) {
          result += ' ' + _ones[ones]!;
        }
      }
    }

    return result;
  }

  /// الحصول على نص الآلاف المناسب
  static String _getThousandText(int number, int thousandIndex) {
    if (thousandIndex >= _thousands.length) {
      return _thousands.last;
    }

    String thousandText = _thousands[thousandIndex];
    
    // تطبيق قواعد الجمع والتثنية
    if (number == 1) {
      return thousandText;
    } else if (number == 2) {
      if (thousandIndex == 1) return 'ألفان'; // ألفان
      if (thousandIndex == 2) return 'مليونان'; // مليونان
      return thousandText + 'ان';
    } else if (number >= 3 && number <= 10) {
      if (thousandIndex == 1) return 'آلاف'; // آلاف
      if (thousandIndex == 2) return 'ملايين'; // ملايين
      return thousandText;
    } else {
      return thousandText;
    }
  }

  /// تحويل سريع للمبالغ المالية الشائعة
  static String convertCurrency(double amount, {
    String currency = 'ريال سعودي',
    String subCurrency = 'هللة',
  }) {
    return convertToWords(amount, currency: currency);
  }

  /// تحويل للعملات المختلفة
  static String convertToWordsWithCurrency(double amount, String currencyCode) {
    String currency;
    
    switch (currencyCode.toUpperCase()) {
      case 'SAR':
        currency = 'ريال سعودي';
        break;
      case 'USD':
        currency = 'دولار أمريكي';
        break;
      case 'EUR':
        currency = 'يورو';
        break;
      case 'AED':
        currency = 'درهم إماراتي';
        break;
      case 'KWD':
        currency = 'دينار كويتي';
        break;
      case 'QAR':
        currency = 'ريال قطري';
        break;
      case 'BHD':
        currency = 'دينار بحريني';
        break;
      case 'OMR':
        currency = 'ريال عماني';
        break;
      default:
        currency = currencyCode;
    }
    
    return convertToWords(amount, currency: currency);
  }

  /// تحويل للتطبيقات المحاسبية (مع فقط)
  static String convertForAccounting(double amount, {String currency = 'ريال سعودي'}) {
    String words = convertToWords(amount, currency: currency);
    return '$words فقط لا غير';
  }

  /// فحص صحة الرقم
  static bool isValidNumber(String numberStr) {
    try {
      double.parse(numberStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// تنسيق الرقم للعرض
  static String formatNumber(double number) {
    return number.toStringAsFixed(2);
  }

  /// أمثلة لاختبار الخدمة
  static void testService() {
    print('اختبار خدمة التفقيط العربي:');
    print('1.50 -> ${convertToWords(1.50)}');
    print('25.75 -> ${convertToWords(25.75)}');
    print('100.00 -> ${convertToWords(100.00)}');
    print('1000.00 -> ${convertToWords(1000.00)}');
    print('1500.25 -> ${convertToWords(1500.25)}');
    print('12345.67 -> ${convertToWords(12345.67)}');
    print('1000000.00 -> ${convertToWords(1000000.00)}');
  }
}

/// Extension للأرقام
extension NumberToArabicWords on double {
  String toArabicWords({String currency = 'ريال'}) {
    return ArabicNumberToWordsService.convertToWords(this, currency: currency);
  }
  
  String toArabicWordsWithCurrency(String currencyCode) {
    return ArabicNumberToWordsService.convertToWordsWithCurrency(this, currencyCode);
  }
  
  String toAccountingFormat({String currency = 'ريال سعودي'}) {
    return ArabicNumberToWordsService.convertForAccounting(this, currency: currency);
  }
}