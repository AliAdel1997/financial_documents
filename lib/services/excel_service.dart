import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/document.dart';
import '../models/organization.dart';

class ExcelService {
  static const List<String> _documentHeaders = [
    'رقم الصادر',
    'تاريخ المستند',
    'المبلغ (رقماً)',
    'المبلغ (كتابة)',
    'ايبان الدائرة',
    'ايبان الجهة المراد التحويل إليها',
    'عنوان الجهة',
    'تفاصيل الكتاب',
    'الحالة',
    'تاريخ الرفع',
    'رقم الإشعار البنكي',
    'ملاحظات'
  ];

  /// قراءة المستندات من ملف Excel
  static Future<List<Document>> readDocumentsFromExcel() async {
    try {
      // اختيار ملف Excel
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('لم يتم اختيار ملف');
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      
      return _parseExcelFile(bytes);
    } catch (e) {
      throw Exception('خطأ في قراءة ملف Excel: $e');
    }
  }

  /// تحليل ملف Excel وإستخراج المستندات
  static List<Document> _parseExcelFile(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final documents = <Document>[];

      // البحث عن الورقة الأولى أو ورقة تحتوي على بيانات
      Sheet? sheet;
      for (var tableName in excel.tables.keys) {
        final currentSheet = excel.tables[tableName];
        if (currentSheet != null && currentSheet.rows.isNotEmpty) {
          sheet = currentSheet;
          break;
        }
      }

      if (sheet == null || sheet.rows.isEmpty) {
        throw Exception('ملف Excel فارغ أو لا يحتوي على بيانات');
      }

      // تخطي الصف الأول (العناوين) والبدء من الصف الثاني
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        
        // التأكد من أن الصف يحتوي على بيانات كافية
        if (row.length < 8) continue;

        try {
          final document = _createDocumentFromRow(row);
          if (document != null) {
            documents.add(document);
          }
        } catch (e) {
          // تجاهل الصفوف التي تحتوي على أخطاء وإستكمال المعالجة
          print('خطأ في معالجة الصف ${i + 1}: $e');
          continue;
        }
      }

      return documents;
    } catch (e) {
      throw Exception('خطأ في تحليل ملف Excel: $e');
    }
  }

  /// إنشاء مستند من صف Excel
  static Document? _createDocumentFromRow(List<Data?> row) {
    try {
      // قراءة البيانات من الخلايا
      final outgoingNumber = _parseIntFromCell(row[0]);
      final documentDate = _parseDateFromCell(row[1]);
      final amount = _parseDoubleFromCell(row[2]);
      final amountInWords = _parseStringFromCell(row[3]);
      final departmentIban = _parseStringFromCell(row[4]);
      final recipientIban = _parseStringFromCell(row[5]);
      final recipientAddress = _parseStringFromCell(row[6]);
      final documentDetails = _parseStringFromCell(row[7]);

      // التحقق من البيانات الأساسية المطلوبة
      if (outgoingNumber == null || documentDetails == null || documentDetails.trim().isEmpty) {
        return null;
      }

      return Document(
        outgoingNumber: outgoingNumber,
        documentDate: documentDate ?? DateTime.now(),
        amount: amount,
        amountInWords: amountInWords,
        departmentIban: departmentIban,
        recipientIban: recipientIban,
        recipientAddress: recipientAddress,
        documentDetails: documentDetails.trim(),
        status: DocumentStatus.draft,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('خطأ في إنشاء المستند من الصف: $e');
      return null;
    }
  }

  /// تصدير المستندات إلى ملف Excel
  static Future<String> exportDocumentsToExcel(
    List<Document> documents, {
    String? fileName,
    Organization? organization,
  }) async {
    try {
      final excel = Excel.createExcel();
      
      // إنشاء ورقة جديدة
      final sheetName = 'المستندات';
      excel.rename(excel.getDefaultSheet() ?? 'Sheet1', sheetName);
      final sheet = excel[sheetName];

      // إضافة معلومات المؤسسة (إن وجدت)
      if (organization != null) {
        _addOrganizationInfo(sheet, organization);
      }

      // إضافة عناوين الأعمدة
      _addHeaders(sheet, organization != null ? 5 : 0);

      // إضافة بيانات المستندات
      _addDocumentData(sheet, documents, organization != null ? 6 : 1);

      // تنسيق الجدول
      _formatSheet(sheet);

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'documents_export_$timestamp.xlsx';
      final filePath = path.join(directory.path, finalFileName);
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      } else {
        throw Exception('فشل في حفظ ملف Excel');
      }
    } catch (e) {
      throw Exception('خطأ في تصدير ملف Excel: $e');
    }
  }

  /// إضافة معلومات المؤسسة
  static void _addOrganizationInfo(Sheet sheet, Organization organization) {
    // عنوان المؤسسة
    sheet.cell(CellIndex.indexByString("A1")).value = 'اسم الدائرة:';
    sheet.cell(CellIndex.indexByString("B1")).value = organization.departmentName ?? '';
    
    sheet.cell(CellIndex.indexByString("A2")).value = 'اسم المصرف:';
    sheet.cell(CellIndex.indexByString("B2")).value = organization.bankName ?? '';
    
    sheet.cell(CellIndex.indexByString("A3")).value = 'الايبان:';
    sheet.cell(CellIndex.indexByString("B3")).value = organization.iban ?? '';
    
    sheet.cell(CellIndex.indexByString("A4")).value = 'اسم المدير:';
    sheet.cell(CellIndex.indexByString("B4")).value = organization.directorName ?? '';
  }

  /// إضافة عناوين الأعمدة
  static void _addHeaders(Sheet sheet, int startRow) {
    for (int i = 0; i < _documentHeaders.length; i++) {
      final cellIndex = CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow);
      sheet.cell(cellIndex).value = _documentHeaders[i];
    }
  }

  /// إضافة بيانات المستندات
  static void _addDocumentData(Sheet sheet, List<Document> documents, int startRow) {
    for (int i = 0; i < documents.length; i++) {
      final document = documents[i];
      final rowIndex = startRow + i;

      // رقم الصادر
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = document.outgoingNumber ?? 0;

      // تاريخ المستند
      if (document.documentDate != null) {
        final dateStr = '${document.documentDate!.year}-${document.documentDate!.month.toString().padLeft(2, '0')}-${document.documentDate!.day.toString().padLeft(2, '0')}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = dateStr;
      }

      // المبلغ (رقماً)
      if (document.amount != null) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = document.amount!;
      }

      // المبلغ (كتابة)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = document.amountInWords ?? '';

      // ايبان الدائرة
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = document.departmentIban ?? '';

      // ايبان الجهة المراد التحويل إليها
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = document.recipientIban ?? '';

      // عنوان الجهة
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = document.recipientAddress ?? '';

      // تفاصيل الكتاب
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = document.documentDetails ?? '';

      // الحالة
      String statusText = _getStatusText(document.status);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
          .value = statusText;

      // تاريخ الرفع
      if (document.uploadDate != null) {
        final dateStr = '${document.uploadDate!.year}-${document.uploadDate!.month.toString().padLeft(2, '0')}-${document.uploadDate!.day.toString().padLeft(2, '0')}';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = dateStr;
      }

      // رقم الإشعار البنكي
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
          .value = document.bankNotificationNumber ?? '';

      // ملاحظات
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex))
          .value = document.remarks ?? '';
    }
  }

  /// تنسيق الورقة
  static void _formatSheet(Sheet sheet) {
    // يمكن إضافة تنسيقات إضافية هنا
    // مثل عرض الأعمدة، وألوان الخلايا، والخطوط
  }

  /// Helper functions لتحليل البيانات من خلايا Excel
  static int? _parseIntFromCell(Data? cell) {
    if (cell == null || cell.value == null) return null;
    
    final value = cell.value;
    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      final text = value.trim();
      return int.tryParse(text);
    }
    
    return null;
  }

  static double? _parseDoubleFromCell(Data? cell) {
    if (cell == null || cell.value == null) return null;
    
    final value = cell.value;
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      final text = value.trim();
      return double.tryParse(text);
    }
    
    return null;
  }

  static String? _parseStringFromCell(Data? cell) {
    if (cell == null || cell.value == null) return null;
    
    final value = cell.value;
    if (value is String) {
      return value;
    } else if (value is int) {
      return value.toString();
    } else if (value is double) {
      return value.toString();
    }
    
    return null;
  }

  static DateTime? _parseDateFromCell(Data? cell) {
    if (cell == null || cell.value == null) return null;
    
    final value = cell.value;
    if (value is String) {
      final text = value.trim();
      
      // محاولة تحليل التاريخ بعدة تنسيقات مختلفة
      final dateFormats = [
        RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})'), // YYYY-MM-DD
        RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})'), // DD/MM/YYYY
        RegExp(r'(\d{1,2})-(\d{1,2})-(\d{4})'), // DD-MM-YYYY
      ];

      for (var format in dateFormats) {
        final match = format.firstMatch(text);
        if (match != null) {
          try {
            int year, month, day;
            
            if (format.pattern.contains(r'(\d{4})')) {
              // تنسيق YYYY-MM-DD
              year = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              day = int.parse(match.group(3)!);
            } else {
              // تنسيق DD/MM/YYYY أو DD-MM-YYYY
              day = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
            }
            
            return DateTime(year, month, day);
          } catch (e) {
            continue;
          }
        }
      }
    }
    
    return null;
  }

  static String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return 'مسودة';
      case DocumentStatus.printed:
        return 'مطبوع';
      case DocumentStatus.uploaded:
        return 'مرفوع';
      case DocumentStatus.notUploaded:
        return 'غير مرفوع';
      case DocumentStatus.archived:
        return 'مؤرشف';
    }
  }
}