import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/deduction_entity.dart';
import '../services/database_service.dart';

class DeductionExcelService {
  /// استيراد جهات الاستقطاع من ملف Excel
  static Future<List<DeductionEntity>> importFromExcel() async {
    try {
      // اختيار الملف
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
      final excel = Excel.decodeBytes(bytes);

      List<DeductionEntity> entities = [];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // تخطي الصف الأول (العناوين)
        for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          final row = sheet.rows[rowIndex];
          
          // التأكد من وجود بيانات في الصف
          if (row.isEmpty || _isEmptyRow(row)) continue;

          try {
            final entity = _parseRowToEntity(row, rowIndex + 1);
            if (entity != null) {
              entities.add(entity);
            }
          } catch (e) {
            print('خطأ في الصف ${rowIndex + 1}: $e');
            // متابعة باقي الصفوف حتى لو فشل صف واحد
          }
        }
      }

      if (entities.isEmpty) {
        throw Exception('لم يتم العثور على بيانات صالحة في الملف');
      }

      // حفظ البيانات في قاعدة البيانات
      for (var entity in entities) {
        await DatabaseService.addDeductionEntity(entity.toJson());
      }

      return entities;
    } catch (e) {
      print('خطأ في استيراد ملف Excel: $e');
      rethrow;
    }
  }

  /// تحويل صف Excel إلى كائن DeductionEntity
  static DeductionEntity? _parseRowToEntity(List<Data?> row, int rowNumber) {
    try {
      // التحقق من وجود الحد الأدنى من البيانات المطلوبة
      if (row.length < 2 || row[0]?.value == null) {
        return null;
      }

      final name = _getCellValue(row, 0);
      if (name.isEmpty) {
        return null;
      }

      return DeductionEntity(
        name: name,
        iban: _getCellValue(row, 1),
        email: _getCellValue(row, 2),
        address: _getCellValue(row, 3),
        phone: _getCellValue(row, 4),
        notes: _getCellValue(row, 5),
        totalDeductions: _parseDouble(_getCellValue(row, 6)),
        isActive: _parseBoolean(_getCellValue(row, 7)),
      );
    } catch (e) {
      throw Exception('خطأ في تحليل الصف $rowNumber: $e');
    }
  }

  /// استخراج قيمة الخلية كنص
  static String _getCellValue(List<Data?> row, int columnIndex) {
    if (columnIndex >= row.length || row[columnIndex] == null) {
      return '';
    }
    return row[columnIndex]!.value?.toString().trim() ?? '';
  }

  /// تحويل النص إلى رقم عشري
  static double _parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  /// تحويل النص إلى قيمة منطقية
  static bool _parseBoolean(String value) {
    if (value.isEmpty) return true;
    final lowerValue = value.toLowerCase();
    return lowerValue == 'true' || 
           lowerValue == '1' || 
           lowerValue == 'نعم' || 
           lowerValue == 'فعال' ||
           lowerValue == 'active';
  }

  /// التحقق من كون الصف فارغاً
  static bool _isEmptyRow(List<Data?> row) {
    return row.every((cell) => cell == null || 
                              cell.value == null || 
                              cell.value.toString().trim().isEmpty);
  }

  /// تصدير جهات الاستقطاع إلى ملف Excel
  static Future<String> exportToExcel(List<DeductionEntity> entities) async {
    try {
      final excel = Excel.createExcel();
      
      // إزالة الورقة الافتراضية إذا كانت موجودة
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }
      
      final sheet = excel['جهات الاستقطاع'];

      // إضافة العناوين
      final headers = [
        'اسم الجهة',
        'ايبان الجهة',
        'البريد الالكتروني',
        'العنوان',
        'رقم الهاتف',
        'ملاحظات',
        'إجمالي الاستقطاعات',
        'الحالة',
        'تاريخ الإنشاء',
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = headers[i];
        
        // تنسيق العناوين
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = CellStyle(
              bold: true,
              backgroundColorHex: 'FF4285F4',
              fontColorHex: 'FFFFFFFF',
            );
      }

      // إضافة البيانات
      for (int rowIndex = 0; rowIndex < entities.length; rowIndex++) {
        final entity = entities[rowIndex];
        final dataRow = rowIndex + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: dataRow))
            .value = entity.name;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: dataRow))
            .value = entity.iban ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: dataRow))
            .value = entity.email ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: dataRow))
            .value = entity.address ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: dataRow))
            .value = entity.phone ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: dataRow))
            .value = entity.notes ?? '';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: dataRow))
            .value = entity.totalDeductions;
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: dataRow))
            .value = entity.isActive ? 'فعال' : 'غير فعال';
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: dataRow))
            .value = '${entity.createdAt.day}/${entity.createdAt.month}/${entity.createdAt.year}';
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'جهات_الاستقطاع_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(excel.encode()!);
      
      return file.path;
    } catch (e) {
      print('خطأ في تصدير ملف Excel: $e');
      rethrow;
    }
  }

  /// إنشاء قالب Excel فارغ لجهات الاستقطاع
  static Future<String> createTemplate() async {
    try {
      final excel = Excel.createExcel();
      
      // إزالة الورقة الافتراضية إذا كانت موجودة
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }
      
      final sheet = excel['قالب جهات الاستقطاع'];

      // إضافة العناوين
      final headers = [
        'اسم الجهة*',
        'ايبان الجهة',
        'البريد الالكتروني',
        'العنوان',
        'رقم الهاتف',
        'ملاحظات',
        'إجمالي الاستقطاعات',
        'الحالة (فعال/غير فعال)',
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = headers[i];
        
        // تنسيق العناوين
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = CellStyle(
              bold: true,
              backgroundColorHex: 'FF34A853',
              fontColorHex: 'FFFFFFFF',
            );
      }

      // إضافة أمثلة
      final examples = [
        [
          'التأمينات الاجتماعية',
          'IQ33BBBB1234567890123456',
          'social@gov.iq',
          'بغداد - الكرادة',
          '07901234567',
          'جهة التأمينات الاجتماعية',
          '1500000',
          'فعال'
        ],
        [
          'الهيئة العامة للضرائب',
          'IQ33CCCC1234567890123456',
          'tax@gov.iq',
          'بغداد - الجادرية',
          '07901234568',
          'هيئة الضرائب العامة',
          '2000000',
          'فعال'
        ],
      ];

      for (int rowIndex = 0; rowIndex < examples.length; rowIndex++) {
        final example = examples[rowIndex];
        final dataRow = rowIndex + 2; // البدء من الصف الثالث (بعد العناوين وصف فارغ)

        for (int colIndex = 0; colIndex < example.length; colIndex++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: dataRow))
              .value = example[colIndex];
          
          // تنسيق الأمثلة
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: dataRow))
              .cellStyle = CellStyle(
                backgroundColorHex: 'FFD3D3D3',
              );
        }
      }

      // إضافة ملاحظات في ورقة منفصلة
      final notesSheet = excel['تعليمات الاستخدام'];
      final instructions = [
        'تعليمات ملء قالب جهات الاستقطاع:',
        '',
        '1. اسم الجهة*: مطلوب - اسم جهة الاستقطاع',
        '2. ايبان الجهة: رقم الحساب المصرفي للجهة (اختياري)',
        '3. البريد الالكتروني: عنوان البريد الالكتروني (اختياري)',
        '4. العنوان: عنوان الجهة (اختياري)',
        '5. رقم الهاتف: رقم الهاتف للتواصل (اختياري)',
        '6. ملاحظات: أي ملاحظات إضافية (اختياري)',
        '7. إجمالي الاستقطاعات: المبلغ الإجمالي (رقم، اختياري)',
        '8. الحالة: فعال أو غير فعال (افتراضي: فعال)',
        '',
        'ملاحظات مهمة:',
        '- الحقول المميزة بـ (*) مطلوبة',
        '- يمكن ترك الحقول الاختيارية فارغة',
        '- للحالة: استخدم "فعال" أو "غير فعال"',
        '- احذف الأمثلة قبل إضافة البيانات الحقيقية',
      ];

      for (int i = 0; i < instructions.length; i++) {
        notesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
            .value = instructions[i];
        
        if (i == 0) {
          // تنسيق العنوان الرئيسي
          notesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
              .cellStyle = CellStyle(
                bold: true,
                fontSize: 16,
                backgroundColorHex: 'FF4285F4',
                fontColorHex: 'FFFFFFFF',
              );
        } else if (instructions[i].startsWith('ملاحظات مهمة:')) {
          // تنسيق عنوان القسم
          notesSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
              .cellStyle = CellStyle(
                bold: true,
                backgroundColorHex: 'FFFF9800',
                fontColorHex: 'FFFFFFFF',
              );
        }
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'قالب_جهات_الاستقطاع_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(excel.encode()!);
      
      return file.path;
    } catch (e) {
      print('خطأ في إنشاء قالب Excel: $e');
      rethrow;
    }
  }
}