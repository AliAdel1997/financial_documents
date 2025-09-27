import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/document.dart';
import '../models/organization.dart';

class ExcelService {
  static const List<String> _documentHeaders = [
    'اسم الجهة',
    'المبلغ',
    'الملاحظات',
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

        // التأكد من أن الصف يحتوي على بيانات كافية (3 أعمدة: اسم الجهة، المبلغ، الملاحظات)
        if (row.length < 2) continue; // الحد الأدنى: اسم الجهة + المبلغ

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
      // قراءة البيانات من الخلايا الجديدة (اسم الجهة، المبلغ، الملاحظات)
      final recipientName = _parseStringFromCell(row[0]); // اسم الجهة
      final amount = _parseDoubleFromCell(row[1]); // المبلغ
      final notes = _parseStringFromCell(row[2]); // الملاحظات

      // التحقق من البيانات الأساسية المطلوبة
      if (recipientName == null || recipientName.trim().isEmpty) {
        return null;
      }

      if (amount == null || amount <= 0) {
        return null;
      }

      // إنشاء رقم صادر تلقائي مؤقت
      final outgoingNumber = DateTime.now().millisecondsSinceEpoch % 1000000;

      return Document(
        outgoingNumber: outgoingNumber,
        documentDate: DateTime.now(),
        amount: amount,
        amountInWords: null, // سيتم ملئها لاحقاً
        departmentIban: null, // سيتم ملئها من بيانات المؤسسة
        recipientIban: null, // سيتم ملئها من بيانات الجهة
        recipientAddress: recipientName.trim(), // استخدام اسم الجهة كعنوان مؤقت
        documentDetails: notes?.trim().isNotEmpty == true 
            ? 'استقطاع لصالح: ${recipientName.trim()} - ${notes!.trim()}'
            : 'استقطاع لصالح: ${recipientName.trim()}',
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
    sheet.cell(CellIndex.indexByString("B1")).value =
        organization.departmentName ?? '';

    sheet.cell(CellIndex.indexByString("A2")).value = 'اسم المصرف:';
    sheet.cell(CellIndex.indexByString("B2")).value =
        organization.bankName ?? '';

    sheet.cell(CellIndex.indexByString("A3")).value = 'الايبان:';
    sheet.cell(CellIndex.indexByString("B3")).value = organization.iban ?? '';

    sheet.cell(CellIndex.indexByString("A4")).value = 'اسم المدير:';
    sheet.cell(CellIndex.indexByString("B4")).value =
        organization.directorName ?? '';
  }

  /// إضافة عناوين الأعمدة
  static void _addHeaders(Sheet sheet, int startRow) {
    for (int i = 0; i < _documentHeaders.length; i++) {
      final cellIndex = CellIndex.indexByColumnRow(
        columnIndex: i,
        rowIndex: startRow,
      );
      sheet.cell(cellIndex).value = _documentHeaders[i];
    }
  }

  /// إضافة بيانات المستندات
  static void _addDocumentData(
    Sheet sheet,
    List<Document> documents,
    int startRow,
  ) {
    for (int i = 0; i < documents.length; i++) {
      final document = documents[i];
      final rowIndex = startRow + i;

      // رقم الصادر
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
              )
              .value =
          document.outgoingNumber ?? 0;

      // تاريخ المستند
      if (document.documentDate != null) {
        final dateStr =
            '${document.documentDate!.year}-${document.documentDate!.month.toString().padLeft(2, '0')}-${document.documentDate!.day.toString().padLeft(2, '0')}';
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 1,
                    rowIndex: rowIndex,
                  ),
                )
                .value =
            dateStr;
      }

      // المبلغ (رقماً)
      if (document.amount != null) {
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = document
            .amount!;
      }

      // المبلغ (كتابة)
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
              )
              .value =
          document.amountInWords ?? '';

      // ايبان الدائرة
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
              )
              .value =
          document.departmentIban ?? '';

      // ايبان الجهة المراد التحويل إليها
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
              )
              .value =
          document.recipientIban ?? '';

      // عنوان الجهة
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
              )
              .value =
          document.recipientAddress ?? '';

      // تفاصيل الكتاب
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
              )
              .value =
          document.documentDetails ?? '';

      // الحالة
      String statusText = _getStatusText(document.status);
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex),
              )
              .value =
          statusText;

      // تاريخ الرفع
      if (document.uploadDate != null) {
        final dateStr =
            '${document.uploadDate!.year}-${document.uploadDate!.month.toString().padLeft(2, '0')}-${document.uploadDate!.day.toString().padLeft(2, '0')}';
        sheet
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: 9,
                    rowIndex: rowIndex,
                  ),
                )
                .value =
            dateStr;
      }

      // رقم الإشعار البنكي
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex),
              )
              .value =
          document.bankNotificationNumber ?? '';

      // ملاحظات
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex),
              )
              .value =
          document.remarks ?? '';
    }
  }

  /// تنسيق الورقة
  static void _formatSheet(Sheet sheet) {
    // يمكن إضافة تنسيقات إضافية هنا
    // مثل عرض الأعمدة، وألوان الخلايا، والخطوط
  }

  /// Helper functions لتحليل البيانات من خلايا Excel
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

  /// إنشاء قالب Excel فارغ للاستيراد
  static Future<String> createImportTemplate({
    String? fileName,
    Organization? organization,
  }) async {
    try {
      // إنشاء Excel جديد
      final excel = Excel.createExcel();
      
      // الحصول على الورقة الافتراضية أو إنشاء جديدة
      const sheetName = 'قالب المستندات';
      final defaultSheet = excel.getDefaultSheet();
      
      Sheet sheet;
      if (defaultSheet != null) {
        sheet = excel.tables[defaultSheet]!;
        // مسح الورقة الافتراضية
        excel.delete(defaultSheet);
      }
      
      // إنشاء ورقة جديدة
      sheet = excel[sheetName];

      int currentRow = 0;

      // إضافة معلومات المؤسسة (إن وجدت)
      if (organization != null) {
        // عنوان التوضيح
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        cell.value = 'معلومات الدائرة:';
        cell.cellStyle = CellStyle(bold: true, fontSize: 14);
        currentRow++;

        // معلومات الدائرة
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = 'اسم الدائرة:';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = organization.departmentName ?? '';
        currentRow++;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = 'اسم المصرف:';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = organization.bankName ?? '';
        currentRow++;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = 'الايبان:';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = organization.iban ?? '';
        currentRow++;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value = 'اسم المدير:';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value = organization.directorName ?? '';
        currentRow++;

        // إضافة صف فارغ
        currentRow++;
      }

      // إضافة تعليمات الاستخدام
      var instructionCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      instructionCell.value = 'تعليمات الاستخدام:';
      instructionCell.cellStyle = CellStyle(bold: true, fontSize: 14);
      currentRow++;

      final instructions = [
        '1. اتبع تنسيق العناوين الموضحة أدناه بدقة',
        '2. لا تغير ترتيب الأعمدة أو أسماء العناوين',
        '3. اكتب اسم الجهة بالضبط كما هو موجود في النظام',
        '4. المبلغ يجب أن يكون رقماً فقط (مثال: 169590105)',
        '5. اسم الجهة مطلوب والمبلغ مطلوب',
        '6. احذف هذه التعليمات والصف التجريبي قبل الاستيراد',
      ];

      for (var instruction in instructions) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        cell.value = instruction;
        cell.cellStyle = CellStyle(fontSize: 10);
        currentRow++;
      }

      // إضافة صف فارغ
      currentRow++;

      // إضافة عناوين الأعمدة
      for (int i = 0; i < _documentHeaders.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
        cell.value = _documentHeaders[i];
        cell.cellStyle = CellStyle(
          bold: true,
          fontSize: 12,
          backgroundColorHex: "FFE6E6E6", // لون رمادي فاتح
        );
      }
      currentRow++;

      // إضافة بيانات تجريبية كمثال
      final sampleData = [
        'تقاعد', // اسم الجهة
        '169590105', // المبلغ
        'مثال توضيحي - احذف هذا الصف', // ملاحظات
      ];

      // إضافة البيانات التجريبية
      for (int colIdx = 0; colIdx < sampleData.length && colIdx < _documentHeaders.length; colIdx++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: currentRow));
        cell.value = sampleData[colIdx];
        cell.cellStyle = CellStyle(
          fontSize: 10,
          backgroundColorHex: "FFE6F3FF", // لون أزرق فاتح
        );
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'template_documents_$timestamp.xlsx';
      final filePath = path.join(directory.path, finalFileName);

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      } else {
        throw Exception('فشل في حفظ قالب Excel');
      }
    } catch (e) {
      throw Exception('خطأ في إنشاء قالب Excel: $e');
    }
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
