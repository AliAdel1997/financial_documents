import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document_draft.dart';
import '../models/deduction_entity.dart';
import 'database_service.dart';

class DocumentDraftExcelService {
  static final DocumentDraftExcelService _instance = DocumentDraftExcelService._internal();
  factory DocumentDraftExcelService() => _instance;
  DocumentDraftExcelService._internal();

  // Import drafts from Excel file
  Future<ImportResult> importDraftsFromExcel({
    required String documentType,
    required int month,
    required int year,
    required String organizationBankName,
  }) async {
    print('🔄 بدء عملية استيراد Excel');
    print('📋 نوع المستند: $documentType');
    print('📅 الشهر: $month، السنة: $year');
    print('🏦 اسم المصرف: $organizationBankName');
    
    try {
      // Pick Excel file
      print('📁 فتح نافذة اختيار الملف...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
        dialogTitle: 'اختر ملف Excel للاستيراد',
      );

      if (result == null || result.files.isEmpty) {
        print('❌ لم يتم اختيار أي ملف');
        return ImportResult.error('لم يتم اختيار أي ملف');
      }

      final filePath = result.files.first.path!;
      final fileName = result.files.first.name;
      print('✅ تم اختيار الملف: $fileName');
      print('📂 مسار الملف: $filePath');

      // Read and decode Excel file
      print('📖 قراءة ملف Excel...');
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ الملف غير موجود');
        return ImportResult.error('الملف غير موجود');
      }

      final bytes = await file.readAsBytes();
      print('💾 حجم الملف: ${bytes.length} بايت');
      
      final excel = Excel.decodeBytes(bytes);
      print('📊 عدد الأوراق في الملف: ${excel.tables.length}');

      // Get the first sheet
      final sheet = excel.tables.values.first;
      final sheetName = excel.tables.keys.first;
      print('📄 اسم الورقة المحددة: $sheetName');
      print('📏 عدد الصفوف: ${sheet.rows.length}');
      
      if (sheet.rows.isEmpty) {
        print('❌ الملف فارغ');
        return ImportResult.error('الملف فارغ أو لا يحتوي على بيانات');
      }

      // Validate headers
      print('🔍 فحص رؤوس الأعمدة...');
      final headers = sheet.rows.first;
      print('📑 رؤوس الأعمدة: ${headers.map((cell) => cell?.value?.toString() ?? 'فارغ').join(' | ')}');
      
      if (!_validateHeaders(headers)) {
        print('❌ تنسيق رؤوس الأعمدة غير صحيح');
        return ImportResult.error('تنسيق الملف غير صحيح. يجب أن يحتوي على الأعمدة: اسم الجهة، المبلغ، الغرض (اختياري)');
      }
      print('✅ رؤوس الأعمدة صحيحة');

      // Process data rows
      print('🔄 بدء معالجة البيانات...');
      final drafts = <DocumentDraft>[];
      final errors = <String>[];
      
  // Get all deduction entities for lookup (as objects)
  print('🔍 جلب قائمة الجهات من قاعدة البيانات (ككائنات)...');
  final entities = await DatabaseService.getAllDeductionEntitiesAsObjects();
  print('📋 عدد الجهات المتاحة: ${entities.length}');
      
      // Normalize entities: DatabaseService may return Map<String, dynamic> (toJson)
      // or actual DeductionEntity instances depending on the call site. Accept both.
      final entityMap = <String, DeductionEntity>{};
      for (var ent in entities) {
        try {
          final key = ent.name.trim().toLowerCase();
          if (key.isNotEmpty) {
            entityMap[key] = ent;
          }
        } catch (e, st) {
          print('❌ فشل معالجة جهة من قاعدة البيانات: $e');
          print(st);
          continue;
        }
      }
      print('🗂️ تم إنشاء فهرس الجهات (normalized): ${entityMap.length}');

      // Process each data row
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        print('\n📝 معالجة الصف ${i + 1}...');
        
        try {
          final draft = await _processRow(
            row: row,
            rowNumber: i + 1,
            documentType: documentType,
            month: month,
            year: year,
            organizationBankName: organizationBankName,
            entityMap: entityMap,
          );
          
          if (draft != null) {
            drafts.add(draft);
            print('✅ تم إنشاء مسودة للصف ${i + 1}: ${draft.entityName}');
          } else {
            print('⚠️ تم تخطي الصف ${i + 1} (فارغ أو غير صالح)');
          }
        } catch (e) {
          final errorMsg = 'خطأ في الصف ${i + 1}: $e';
          errors.add(errorMsg);
          print('❌ $errorMsg');
        }
      }

      print('\n💾 حفظ المسودات في قاعدة البيانات...');
      // Save drafts to database
      int savedCount = 0;
      if (drafts.isNotEmpty) {
        for (final draft in drafts) {
          try {
            await DatabaseService.addDocumentDraft(draft);
            savedCount++;
            print('✅ تم حفظ مسودة: ${draft.entityName}');
          } catch (e) {
            final errorMsg = 'خطأ في حفظ مسودة ${draft.entityName}: $e';
            errors.add(errorMsg);
            print('❌ $errorMsg');
          }
        }
      }

      print('\n📊 ملخص العملية:');
      print('✅ تم استيراد: $savedCount مسودة');
      print('❌ أخطاء: ${errors.length}');
      if (errors.isNotEmpty) {
        print('📝 تفاصيل الأخطاء:');
        for (var error in errors) {
          print('   • $error');
        }
      }

      return ImportResult.success(
        importedCount: savedCount,
        errorCount: errors.length,
        errors: errors,
      );

    } catch (e, stackTrace) {
      print('❌ خطأ عام في استيراد الملف: $e');
      print('📍 Stack trace: $stackTrace');
      return ImportResult.error('خطأ في استيراد الملف: $e');
    }
  }

  // Process a single row
  Future<DocumentDraft?> _processRow({
    required List<Data?> row,
    required int rowNumber,
    required String documentType,
    required int month,
    required int year,
    required String organizationBankName,
    required Map<String, DeductionEntity> entityMap,
  }) async {
    print('  🔍 تحليل الصف $rowNumber...');
    
    if (row.length < 2) {
      print('  ❌ عدد أعمدة غير كافي: ${row.length}');
      throw Exception('البيانات ناقصة - يجب وجود عمودين على الأقل');
    }

    // Extract data from row with detailed logging
    final entityName = row[0]?.value?.toString().trim() ?? '';
    final amountStr = row[1]?.value?.toString().trim() ?? '';
    final purpose = row.length > 2 ? row[2]?.value?.toString().trim() : null;

    print('  📝 اسم الجهة: "$entityName"');
    print('  💰 المبلغ الخام: "$amountStr"');
    print('  📄 الغرض: "${purpose ?? 'غير محدد'}"');

    // Validate required fields
    if (entityName.isEmpty) {
      print('  ❌ اسم الجهة فارغ');
      throw Exception('اسم الجهة مطلوب');
    }

    if (amountStr.isEmpty) {
      print('  ❌ المبلغ فارغ');
      throw Exception('المبلغ مطلوب');
    }

    // Parse amount with better error handling
    String cleanAmountStr = amountStr
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('ريال', '')
        .replaceAll('ر.س', '')
        .trim();
    
    print('  🧮 المبلغ بعد التنظيف: "$cleanAmountStr"');
    
    final amount = double.tryParse(cleanAmountStr);
    if (amount == null) {
      print('  ❌ فشل في تحويل المبلغ إلى رقم');
      throw Exception('المبلغ غير صحيح - لا يمكن تحويله إلى رقم: $amountStr');
    }
    
    if (amount <= 0) {
      print('  ❌ المبلغ يجب أن يكون أكبر من صفر');
      throw Exception('المبلغ يجب أن يكون أكبر من صفر: $amount');
    }
    
    print('  ✅ المبلغ النهائي: $amount');

    // Check if entity exists in our map
    final entityKey = entityName.toLowerCase();
    print('  🔍 البحث عن الجهة في قاعدة البيانات...');
    print('  🔑 مفتاح البحث: "$entityKey"');
    
    DeductionEntity? existingEntity = entityMap[entityKey];
    
    if (existingEntity == null) {
      // Try fuzzy matching
      print('  ⚠️ لم يتم العثور على مطابقة مباشرة، جارٍ البحث المرن...');
      for (var key in entityMap.keys) {
        if (key.contains(entityKey) || entityKey.contains(key)) {
          existingEntity = entityMap[key];
          print('  ✅ تم العثور على مطابقة مرنة: "$key" -> "${existingEntity!.name}"');
          break;
        }
      }
    }

    if (existingEntity == null) {
      print('  ⚠️ لم يتم العثور على الجهة، سيتم إنشاء جهة جديدة');
      // Create new entity
      existingEntity = DeductionEntity(
        name: entityName,
      );
      
      try {
        await DatabaseService.addDeductionEntity(existingEntity.toJson());
        entityMap[entityKey] = existingEntity; // Add to cache
        print('  ✅ تم إنشاء وحفظ جهة جديدة: "${existingEntity.name}"');
      } catch (e) {
        print('  ❌ فشل في إنشاء جهة جديدة: $e');
        throw Exception('فشل في إنشاء جهة جديدة: $e');
      }
    } else {
      print('  ✅ تم العثور على الجهة: "${existingEntity.name}"');
    }

    // Create draft document
    print('  📄 إنشاء مسودة المستند...');
    final draft = DocumentDraft()
      ..entityName = existingEntity.name
      ..amount = amount
      ..documentType = documentType
      ..month = month
      ..year = year
      ..purpose = purpose?.isNotEmpty == true ? purpose : null
      ..organizationBankName = organizationBankName
      ..status = DocumentDraftStatus.draft
      ..createdAt = DateTime.now()
      ..entityIban = existingEntity.iban ?? ''
      ..entityEmail = existingEntity.email ?? ''
      ..entityPhone = existingEntity.phone ?? ''
      ..entityAddress = existingEntity.address ?? '';

    print('  ✅ تم إنشاء المسودة بنجاح');
    print('  📋 تفاصيل المسودة:');
    print('     • الجهة: ${draft.entityName}');
    print('     • المبلغ: ${draft.amount}');
    print('     • النوع: ${draft.documentType}');
    print('     • التاريخ: ${draft.month}/${draft.year}');
    print('     • الغرض: ${draft.purpose ?? 'غير محدد'}');

    return draft;
  }

  // Validate Excel headers
  bool _validateHeaders(List<Data?> headers) {
    print('🔍 فحص رؤوس الأعمدة...');
    print('📊 عدد الأعمدة: ${headers.length}');
    
    if (headers.length < 2) {
      print('❌ عدد أعمدة غير كافي - يجب وجود عمودين على الأقل');
      return false;
    }

    final header1 = headers[0]?.value?.toString().trim().toLowerCase() ?? '';
    final header2 = headers[1]?.value?.toString().trim().toLowerCase() ?? '';
    final header3 = headers.length > 2 ? headers[2]?.value?.toString().trim().toLowerCase() ?? '' : '';

    print('📝 العمود الأول: "$header1"');
    print('📝 العمود الثاني: "$header2"');
    if (header3.isNotEmpty) {
      print('📝 العمود الثالث: "$header3"');
    }

    // Check for required columns (flexible matching)
    final entityNameKeywords = ['جهة', 'اسم', 'entity', 'name', 'موظف', 'employee'];
    final amountKeywords = ['مبلغ', 'amount', 'قيمة', 'value', 'مال', 'money'];

    bool hasEntityName = false;
    bool hasAmount = false;

    // Check first column for entity name
    for (String keyword in entityNameKeywords) {
      if (header1.contains(keyword)) {
        hasEntityName = true;
        print('✅ العمود الأول يحتوي على اسم الجهة (كلمة مفتاحية: $keyword)');
        break;
      }
    }

    // Check second column for amount
    for (String keyword in amountKeywords) {
      if (header2.contains(keyword)) {
        hasAmount = true;
        print('✅ العمود الثاني يحتوي على المبلغ (كلمة مفتاحية: $keyword)');
        break;
      }
    }

    if (!hasEntityName) {
      print('❌ العمود الأول لا يحتوي على اسم الجهة');
      print('💡 الكلمات المتوقعة: ${entityNameKeywords.join(', ')}');
    }

    if (!hasAmount) {
      print('❌ العمود الثاني لا يحتوي على المبلغ');
      print('💡 الكلمات المتوقعة: ${amountKeywords.join(', ')}');
    }

    final isValid = hasEntityName && hasAmount;
    print(isValid ? '✅ رؤوس الأعمدة صحيحة' : '❌ رؤوس الأعمدة غير صحيحة');
    
    return isValid;
  }

  // Create template Excel file
  Future<String?> createTemplate({
    required String documentType,
    required int month,
    required int year,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Template'];

      // Headers
      sheet.cell(CellIndex.indexByString('A1')).value = 'اسم الجهة';
      sheet.cell(CellIndex.indexByString('B1')).value = 'المبلغ';
      sheet.cell(CellIndex.indexByString('C1')).value = 'الغرض (اختياري)';

      // Style headers
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#E3F2FD',
        horizontalAlign: HorizontalAlign.Center,
      );

      sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('B1')).cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('C1')).cellStyle = headerStyle;

      // Example rows
      sheet.cell(CellIndex.indexByString('A2')).value = 'مثال: شركة التأمين';
      sheet.cell(CellIndex.indexByString('B2')).value = 1500.00;
      sheet.cell(CellIndex.indexByString('C2')).value = 'استقطاع تأمين صحي';

      sheet.cell(CellIndex.indexByString('A3')).value = 'مثال: صندوق التقاعد';
      sheet.cell(CellIndex.indexByString('B3')).value = 2000.00;
      sheet.cell(CellIndex.indexByString('C3')).value = 'استقطاع تقاعدي';

      // Instructions
      sheet.cell(CellIndex.indexByString('A5')).value = 'تعليمات:';
      sheet.cell(CellIndex.indexByString('A6')).value = '1. أدخل اسم الجهة في العمود الأول';
      sheet.cell(CellIndex.indexByString('A7')).value = '2. أدخل المبلغ رقماً في العمود الثاني';
      sheet.cell(CellIndex.indexByString('A8')).value = '3. الغرض اختياري في العمود الثالث';
      sheet.cell(CellIndex.indexByString('A9')).value = '4. احذف الصفوف المثالية قبل الاستيراد';
      sheet.cell(CellIndex.indexByString('A10')).value = '5. تأكد من وجود الجهات في قاعدة البيانات';

      // Document info
      sheet.cell(CellIndex.indexByString('E1')).value = 'معلومات المستند:';
      sheet.cell(CellIndex.indexByString('E2')).value = 'النوع: ${_getDocumentTypeArabic(documentType)}';
      sheet.cell(CellIndex.indexByString('E3')).value = 'الشهر: ${_getMonthArabic(month)}';
      sheet.cell(CellIndex.indexByString('E4')).value = 'السنة: $year';

      // Save file
      final monthName = _getMonthArabic(month);
      final docTypeArabic = _getDocumentTypeArabic(documentType);
      final fileName = 'قالب_${docTypeArabic}_${monthName}_$year.xlsx';
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ قالب Excel',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(excel.encode()!);
        return result;
      }

      return null;
    } catch (e) {
      throw Exception('خطأ في إنشاء القالب: $e');
    }
  }

  // Export existing drafts to Excel
  Future<String?> exportDraftsToExcel({
    String? documentType,
    int? month,
    int? year,
  }) async {
    try {
      final drafts = await DatabaseService.getDocumentDrafts(
        documentType: documentType,
        month: month,
        year: year,
      );

      if (drafts.isEmpty) {
        throw Exception('لا توجد مسودات للتصدير');
      }

      final excel = Excel.createExcel();
      final sheet = excel['المسودات'];

      // Headers
      final headers = [
        'رقم المسودة',
        'اسم الجهة',
        'المبلغ',
        'نوع المستند',
        'الشهر',
        'السنة',
        'الغرض',
        'IBAN',
        'الهاتف',
        'البريد الإلكتروني',
        'الحالة',
        'تاريخ الإنشاء'
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: '#E3F2FD',
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Data rows
      for (int i = 0; i < drafts.length; i++) {
        final draft = drafts[i];
        final rowIndex = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = draft.id;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = draft.entityName;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = draft.amount;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = draft.documentTypeArabic;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = draft.monthNameArabic;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = draft.year;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = draft.purpose ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = draft.entityIban ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = draft.entityPhone ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = draft.entityEmail ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value = draft.statusNameArabic;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value = 
            '${draft.createdAt.day}/${draft.createdAt.month}/${draft.createdAt.year}';
      }

      // Save file
      final typeFilter = documentType != null ? '_${_getDocumentTypeArabic(documentType)}' : '';
      final monthFilter = month != null ? '_${_getMonthArabic(month)}' : '';
      final yearFilter = year != null ? '_$year' : '';
      final fileName = 'مسودات$typeFilter$monthFilter$yearFilter.xlsx';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'تصدير المسودات',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(excel.encode()!);
        return result;
      }

      return null;
    } catch (e) {
      throw Exception('خطأ في تصدير المسودات: $e');
    }
  }

  // Helper methods
  String _getDocumentTypeArabic(String type) {
    switch (type.toLowerCase()) {
      case 'deductions':
        return 'استقطاعات';
      case 'payments':
        return 'مدفوعات';
      case 'transfers':
        return 'تحويلات';
      default:
        return type;
    }
  }

  String _getMonthArabic(int month) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month >= 1 && month <= 12 ? arabicMonths[month - 1] : 'غير محدد';
  }
}

// Result classes
class ImportResult {
  final bool success;
  final String? message;
  final int importedCount;
  final int errorCount;
  final List<String> errors;

  ImportResult._({
    required this.success,
    this.message,
    this.importedCount = 0,
    this.errorCount = 0,
    this.errors = const [],
  });

  factory ImportResult.success({
    required int importedCount,
    required int errorCount,
    required List<String> errors,
  }) {
    return ImportResult._(
      success: true,
      importedCount: importedCount,
      errorCount: errorCount,
      errors: errors,
      message: 'تم استيراد $importedCount مسودة بنجاح${errorCount > 0 ? ' مع $errorCount أخطاء' : ''}',
    );
  }

  factory ImportResult.error(String message) {
    return ImportResult._(
      success: false,
      message: message,
    );
  }
}