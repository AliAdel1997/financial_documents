import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';

class DeductionReportService {
  /// طباعة تقرير شامل لجميع جهات الاستقطاع
  static Future<bool> printAllEntitiesReport() async {
    try {
      final entities = await DatabaseService.getAllDeductionEntities();
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              // العنوان الرئيسي
              pw.Header(
                level: 0,
                text: 'تقرير شامل لجهات الاستقطاع',
                textStyle: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // معلومات التقرير
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تاريخ التقرير: ${_formatDate(DateTime.now())}'),
                  pw.Text('عدد الجهات: ${entities.length}'),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // جدول الجهات
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1),
                },
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('م', isHeader: true),
                      _buildTableCell('اسم الجهة', isHeader: true),
                      _buildTableCell('الوصف', isHeader: true),
                      _buildTableCell('إجمالي الاستقطاعات', isHeader: true),
                      _buildTableCell('الحالة', isHeader: true),
                    ],
                  ),
                  // بيانات الجهات
                  ...entities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final entity = entry.value;
                    return pw.TableRow(
                      children: [
                        _buildTableCell('${index + 1}'),
                        _buildTableCell(entity['name'] ?? ''),
                        _buildTableCell(entity['description'] ?? '-'),
                        _buildTableCell('${(entity['totalDeductions'] ?? 0.0).toStringAsFixed(0)} د.ع'),
                        _buildTableCell((entity['isActive'] == true) ? 'فعال' : 'غير فعال'),
                      ],
                    );
                  }),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // الإحصائيات
              pw.Header(
                level: 1,
                text: 'الإحصائيات',
                textStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  pw.TableRow(
                    children: [
                      _buildTableCell('إجمالي الجهات'),
                      _buildTableCell('${entities.length}'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('الجهات النشطة'),
                      _buildTableCell('${entities.where((e) => e['isActive'] == true).length}'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('الجهات غير النشطة'),
                      _buildTableCell('${entities.where((e) => e['isActive'] != true).length}'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('إجمالي الاستقطاعات'),
                      _buildTableCell('${entities.fold(0.0, (sum, e) => sum + (e['totalDeductions'] ?? 0.0)).toStringAsFixed(0)} د.ع'),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );
      
      return await _savePdf(pdf, 'تقرير_جهات_الاستقطاع_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      print('خطأ في طباعة تقرير جهات الاستقطاع: $e');
      return false;
    }
  }

  /// طباعة تقرير جهة استقطاع واحدة
  static Future<bool> printEntityReport(Map<String, dynamic> entity) async {
    try {
      final records = await DatabaseService.getEntityDeductionRecords(entity['id']);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              // العنوان الرئيسي
              pw.Header(
                level: 0,
                text: 'تقرير استقطاعات ${entity['name']}',
                textStyle: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // معلومات الجهة
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('معلومات الجهة:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('الاسم: ${entity['name']}'),
                    if (entity['description'] != null)
                      pw.Text('الوصف: ${entity['description']}'),
                    if (entity['contactInfo'] != null)
                      pw.Text('معلومات الاتصال: ${entity['contactInfo']}'),
                    pw.Text('إجمالي الاستقطاعات: ${(entity['totalDeductions'] ?? 0.0).toStringAsFixed(0)} د.ع'),
                    pw.Text('الحالة: ${(entity['isActive'] == true) ? 'فعال' : 'غير فعال'}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // سجلات الاستقطاع
              pw.Header(
                level: 1,
                text: 'سجلات الاستقطاع (${records.length})',
                textStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              if (records.isNotEmpty) ...[
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // رأس الجدول
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('م', isHeader: true),
                        _buildTableCell('اسم الموظف', isHeader: true),
                        _buildTableCell('نوع الاستقطاع', isHeader: true),
                        _buildTableCell('المبلغ', isHeader: true),
                        _buildTableCell('التاريخ', isHeader: true),
                      ],
                    ),
                    // بيانات السجلات
                    ...records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(record['employeeName'] ?? ''),
                          _buildTableCell(record['type'] ?? ''),
                          _buildTableCell('${(record['amount'] ?? 0.0).toStringAsFixed(0)} د.ع'),
                          _buildTableCell(_formatDate(DateTime.tryParse(record['deductionDate'] ?? '') ?? DateTime.now())),
                        ],
                      );
                    }),
                  ],
                ),
              ] else ...[
                pw.Center(
                  child: pw.Text(
                    'لا توجد سجلات استقطاع لهذه الجهة',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ],
            ];
          },
        ),
      );
      
      return await _savePdf(pdf, 'تقرير_${entity['name']}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      print('خطأ في طباعة تقرير الجهة: $e');
      return false;
    }
  }

  /// طباعة تقرير استقطاعات شهرية
  static Future<bool> printMonthlyReport(int year, int month) async {
    try {
      final records = await DatabaseService.getDeductionRecordsByPeriod(year, month);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              // العنوان الرئيسي
              pw.Header(
                level: 0,
                text: 'تقرير الاستقطاعات الشهرية',
                textStyle: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '${_getMonthName(month)} $year',
                style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),
              
              // معلومات التقرير
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تاريخ التقرير: ${_formatDate(DateTime.now())}'),
                  pw.Text('عدد السجلات: ${records.length}'),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              if (records.isNotEmpty) ...[
                // جدول السجلات
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.5),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1.5),
                    5: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // رأس الجدول
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('م', isHeader: true),
                        _buildTableCell('اسم الموظف', isHeader: true),
                        _buildTableCell('رقم الموظف', isHeader: true),
                        _buildTableCell('نوع الاستقطاع', isHeader: true),
                        _buildTableCell('المبلغ', isHeader: true),
                        _buildTableCell('التاريخ', isHeader: true),
                      ],
                    ),
                    // بيانات السجلات
                    ...records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(record['employeeName'] ?? ''),
                          _buildTableCell(record['employeeId'] ?? ''),
                          _buildTableCell(record['type'] ?? ''),
                          _buildTableCell('${(record['amount'] ?? 0.0).toStringAsFixed(0)} د.ع'),
                          _buildTableCell(_formatDate(DateTime.tryParse(record['deductionDate'] ?? '') ?? DateTime.now())),
                        ],
                      );
                    }),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // الإحصائيات
                pw.Header(
                  level: 1,
                  text: 'الإحصائيات',
                  textStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    pw.TableRow(
                      children: [
                        _buildTableCell('إجمالي السجلات'),
                        _buildTableCell('${records.length}'),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _buildTableCell('إجمالي الاستقطاعات'),
                        _buildTableCell('${records.fold(0.0, (sum, r) => sum + (r['amount'] ?? 0.0)).toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                pw.Center(
                  child: pw.Text(
                    'لا توجد سجلات استقطاع لهذا الشهر',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ],
            ];
          },
        ),
      );
      
      return await _savePdf(pdf, 'تقرير_شهري_${month}_${year}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      print('خطأ في طباعة التقرير الشهري: $e');
      return false;
    }
  }

  /// طباعة تقرير استقطاعات موظف
  static Future<bool> printEmployeeReport(String employeeId) async {
    try {
      final records = await DatabaseService.getEmployeeDeductionRecords(employeeId);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              // العنوان الرئيسي
              pw.Header(
                level: 0,
                text: 'تقرير استقطاعات الموظف',
                textStyle: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'رقم الموظف: $employeeId',
                style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),
              
              // معلومات التقرير
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('تاريخ التقرير: ${_formatDate(DateTime.now())}'),
                  pw.Text('عدد السجلات: ${records.length}'),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              if (records.isNotEmpty) ...[
                // جدول السجلات
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(0.5),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // رأس الجدول
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('م', isHeader: true),
                        _buildTableCell('نوع الاستقطاع', isHeader: true),
                        _buildTableCell('المبلغ', isHeader: true),
                        _buildTableCell('التاريخ', isHeader: true),
                        _buildTableCell('الوصف', isHeader: true),
                      ],
                    ),
                    // بيانات السجلات
                    ...records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(record['type'] ?? ''),
                          _buildTableCell('${(record['amount'] ?? 0.0).toStringAsFixed(0)} د.ع'),
                          _buildTableCell(_formatDate(DateTime.tryParse(record['deductionDate'] ?? '') ?? DateTime.now())),
                          _buildTableCell(record['description'] ?? '-'),
                        ],
                      );
                    }),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // الإحصائيات
                pw.Header(
                  level: 1,
                  text: 'الإحصائيات',
                  textStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    pw.TableRow(
                      children: [
                        _buildTableCell('إجمالي الاستقطاعات'),
                        _buildTableCell('${records.fold(0.0, (sum, r) => sum + (r['amount'] ?? 0.0)).toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                pw.Center(
                  child: pw.Text(
                    'لا توجد سجلات استقطاع لهذا الموظف',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ],
            ];
          },
        ),
      );
      
      return await _savePdf(pdf, 'تقرير_موظف_${employeeId}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      print('خطأ في طباعة تقرير الموظف: $e');
      return false;
    }
  }

  // دوال مساعدة
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month > 0 && month <= 12 ? months[month - 1] : 'غير محدد';
  }

  static Future<bool> _savePdf(pw.Document pdf, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());
      
      print('تم حفظ التقرير في: ${file.path}');
      return true;
    } catch (e) {
      print('خطأ في حفظ التقرير: $e');
      return false;
    }
  }
}