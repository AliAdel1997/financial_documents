import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/document.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/excel_service.dart';

class PrintingService {
  static const double _pageMargin = 20;
  static const double _fontSize = 12;
  static const double _headerFontSize = 16;

  /// طباعة مستند مفرد مع معاينة
  static Future<void> printSingleDocument(Document document, BuildContext? context) async {
    try {
      // الحصول على معلومات المؤسسة
      final organization = await DatabaseService.getMainOrganization();
      
      // إنشاء PDF للمعاينة
      final previewPdf = await _createDocumentPDF(document, organization, false);
      
      // عرض المعاينة
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => previewPdf,
        name: 'معاينة المستند ${document.outgoingNumber}',
      );

      // السؤال عن المتابعة للطباعة النهائية
      // في التطبيق الحقيقي، ستكون هذه واجهة مستخدم
      print('هل تريد المتابعة للطباعة النهائية؟');
      
      // إنشاء النسخة المشفرة مع QR Code
      final finalPdf = await _createDocumentPDF(document, organization, true);
      
      // اختيار الطابعة والطباعة
      if (context != null) {
        final selectedPrinter = await Printing.pickPrinter(context: context);
        if (selectedPrinter != null) {
          await Printing.directPrintPdf(
            printer: selectedPrinter,
            onLayout: (PdfPageFormat format) async => finalPdf,
            name: 'المستند ${document.outgoingNumber}',
          );
        } else {
          throw Exception('لم يتم اختيار طابعة');
        }
      } else {
        // استخدام الطباعة المباشرة بدون تحديد طابعة
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => finalPdf,
          name: 'المستند ${document.outgoingNumber}',
        );
      }

      // تحديث حالة المستند
      document.isPrinted = true;
      document.printedDate = DateTime.now();
      document.status = DocumentStatus.printed;
      await DatabaseService.saveDocument(document);
      
    } catch (e) {
      throw Exception('خطأ في طباعة المستند: $e');
    }
  }

  /// طباعة عدة مستندات في دفعة واحدة
  static Future<void> printMultipleDocuments(
    List<Document> documents, {
    int? startingNumber,
    int? endingNumber,
    BuildContext? context,
  }) async {
    try {
      if (documents.isEmpty) {
        throw Exception('قائمة المستندات فارغة');
      }

      // الحصول على معلومات المؤسسة
      final organization = await DatabaseService.getMainOrganization();
      
      // إنشاء معرف دفعة فريد
      final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';
      
      // تعيين أرقام الصادر إذا تم تحديد النطاق
      if (startingNumber != null && endingNumber != null) {
        await _assignOutgoingNumbers(documents, startingNumber, endingNumber);
      }

      // إنشاء دفعة الطباعة
      final printBatch = PrintBatch()
        ..batchId = batchId
        ..createdDate = DateTime.now()
        ..startNumber = startingNumber ?? documents.first.outgoingNumber ?? 0
        ..endNumber = endingNumber ?? documents.last.outgoingNumber ?? 0
        ..totalDocuments = documents.length
        ..status = PrintBatchStatus.created;

      await DatabaseService.savePrintBatch(printBatch);

      // تحديث بيانات المستندات
      for (var doc in documents) {
        doc.batchId = batchId;
      }
      await DatabaseService.saveDocuments(documents);

      // إنشاء PDF للمعاينة (النسخة الأولى بدون تشفير)
      final previewPdf = await _createBatchPDF(documents, organization, false);
      
      // عرض المعاينة
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => previewPdf,
        name: 'معاينة الدفعة $batchId',
      );

      print('هل تريد المتابعة للطباعة النهائية؟');
      
      // تحديث حالة الدفعة
      printBatch.status = PrintBatchStatus.printing;
      await DatabaseService.savePrintBatch(printBatch);

      // إنشاء النسخة المشفرة مع QR Codes
      final finalPdf = await _createBatchPDF(documents, organization, true);
      
      // اختيار الطابعة والطباعة
      if (context != null) {
        final selectedPrinter = await Printing.pickPrinter(context: context);
        if (selectedPrinter != null) {
          await Printing.directPrintPdf(
            printer: selectedPrinter,
            onLayout: (PdfPageFormat format) async => finalPdf,
            name: 'دفعة المستندات $batchId',
          );
        } else {
          throw Exception('لم يتم اختيار طابعة');
        }
      } else {
        // استخدام الطباعة المباشرة بدون تحديد طابعة
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => finalPdf,
          name: 'دفعة المستندات $batchId',
        );
      }

      // تحديث حالة المستندات والدفعة
      final now = DateTime.now();
      for (var doc in documents) {
        doc.isPrinted = true;
        doc.printedDate = now;
        doc.status = DocumentStatus.printed;
      }
      await DatabaseService.saveDocuments(documents);

      printBatch.status = PrintBatchStatus.completed;
      printBatch.completedDate = now;
      await DatabaseService.savePrintBatch(printBatch);

      // تصدير بيانات الطباعة إلى Excel
      await _exportPrintReport(documents, organization, batchId);
      
    } catch (e) {
      throw Exception('خطأ في طباعة عدة مستندات: $e');
    }
  }

  /// إنشاء PDF لمستند مفرد
  static Future<Uint8List> _createDocumentPDF(
    Document document,
    Organization? organization,
    bool includeQR,
  ) async {
    final pdf = pw.Document();

    // إنشاء QR Code إذا كان مطلوباً
    String? qrData;
    if (includeQR) {
      qrData = await _generateQRData(document);
      document.qrCodeData = qrData;
      
      // تشفير المحتوى إذا كان مطلوباً
      if (includeQR) {
        document.encryptedContent = await EncryptionService.encryptDocument(document);
        document.isEncrypted = true;
      }
    }

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(_pageMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس المستند
              _buildDocumentHeader(organization),
              
              pw.SizedBox(height: 20),
              
              // معلومات المستند
              _buildDocumentInfo(document),
              
              pw.SizedBox(height: 20),
              
              // محتوى المستند
              _buildDocumentContent(document),
              
              pw.Spacer(),
              
              // QR Code إذا كان مطلوباً
              if (includeQR && qrData != null)
                _buildQRCode(qrData),
                
              // توقيع وتاريخ
              _buildDocumentFooter(organization),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// إنشاء PDF لعدة مستندات
  static Future<Uint8List> _createBatchPDF(
    List<Document> documents,
    Organization? organization,
    bool includeQR,
  ) async {
    final pdf = pw.Document();

    for (var document in documents) {
      // إنشاء QR Code إذا كان مطلوباً
      String? qrData;
      if (includeQR) {
        qrData = await _generateQRData(document);
        document.qrCodeData = qrData;
        
        // تشفير المحتوى
        document.encryptedContent = await EncryptionService.encryptDocument(document);
        document.isEncrypted = true;
      }

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(_pageMargin),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // رأس المستند
                _buildDocumentHeader(organization),
                
                pw.SizedBox(height: 20),
                
                // معلومات المستند
                _buildDocumentInfo(document),
                
                pw.SizedBox(height: 20),
                
                // محتوى المستند
                _buildDocumentContent(document),
                
                pw.Spacer(),
                
                // QR Code إذا كان مطلوباً
                if (includeQR && qrData != null)
                  _buildQRCode(qrData),
                  
                // توقيع وتاريخ
                _buildDocumentFooter(organization),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// بناء رأس المستند
  static pw.Widget _buildDocumentHeader(Organization? organization) {
    return pw.Column(
      children: [
        pw.Text(
          organization?.departmentName ?? 'اسم الدائرة',
          style: pw.TextStyle(
            fontSize: _headerFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'كتاب رسمي',
          style: pw.TextStyle(
            fontSize: _fontSize,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.Divider(),
      ],
    );
  }

  /// بناء معلومات المستند
  static pw.Widget _buildDocumentInfo(Document document) {
    final dateStr = document.documentDate != null 
        ? '${document.documentDate!.day}/${document.documentDate!.month}/${document.documentDate!.year}'
        : '';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('رقم الصادر: ${document.outgoingNumber ?? ''}'),
        pw.Text('التاريخ: $dateStr'),
      ],
    );
  }

  /// بناء محتوى المستند
  static pw.Widget _buildDocumentContent(Document document) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (document.recipientAddress != null && document.recipientAddress!.isNotEmpty)
          pw.Text(
            'إلى: ${document.recipientAddress}',
            style: pw.TextStyle(fontSize: _fontSize),
          ),
          
        pw.SizedBox(height: 15),
        
        pw.Text(
          'الموضوع: ${document.documentDetails ?? ''}',
          style: pw.TextStyle(fontSize: _fontSize, fontWeight: pw.FontWeight.bold),
        ),
        
        pw.SizedBox(height: 15),
        
        if (document.amount != null && document.amount! > 0) ...[
          pw.Text(
            'المبلغ: ${document.amount} دينار',
            style: pw.TextStyle(fontSize: _fontSize),
          ),
          
          if (document.amountInWords != null && document.amountInWords!.isNotEmpty)
            pw.Text(
              'كتابة: ${document.amountInWords}',
              style: pw.TextStyle(fontSize: _fontSize),
            ),
            
          pw.SizedBox(height: 10),
        ],
        
        if (document.departmentIban != null && document.departmentIban!.isNotEmpty)
          pw.Text(
            'ايبان الدائرة: ${document.departmentIban}',
            style: pw.TextStyle(fontSize: _fontSize),
          ),
          
        if (document.recipientIban != null && document.recipientIban!.isNotEmpty)
          pw.Text(
            'ايبان الجهة المراد التحويل إليها: ${document.recipientIban}',
            style: pw.TextStyle(fontSize: _fontSize),
          ),
      ],
    );
  }

  /// بناء QR Code
  static pw.Widget _buildQRCode(String qrData) {
    return pw.Center(
      child: pw.Container(
        width: 100,
        height: 100,
        child: pw.Text('QR Code: $qrData'), // مؤقتاً حتى نجد مكتبة QR مناسبة للـ PDF
      ),
    );
  }

  /// بناء تذييل المستند
  static pw.Widget _buildDocumentFooter(Organization? organization) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${organization?.directorName ?? 'اسم المدير'}'),
                pw.Text('${organization?.jobTitle ?? 'المنصب'}'),
                pw.Text('التوقيع: _______________'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('الختم الرسمي'),
                pw.SizedBox(height: 40, width: 80),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// توليد بيانات QR Code
  static Future<String> _generateQRData(Document document) async {
    final qrData = {
      'id': document.id,
      'outgoingNumber': document.outgoingNumber,
      'date': document.documentDate?.toIso8601String(),
      'amount': document.amount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    return qrData.toString();
  }

  /// تعيين أرقام الصادر للمستندات
  static Future<void> _assignOutgoingNumbers(
    List<Document> documents,
    int startNumber,
    int endNumber,
  ) async {
    if (documents.length != (endNumber - startNumber + 1)) {
      throw Exception('عدد المستندات لا يتطابق مع نطاق الأرقام المحدد');
    }

    for (int i = 0; i < documents.length; i++) {
      documents[i].outgoingNumber = startNumber + i;
    }

    // تحديث آخر رقم صادر في الإعدادات
    await DatabaseService.updateCurrentOutgoingNumber(endNumber);
  }

  /// تصدير تقرير الطباعة إلى Excel
  static Future<void> _exportPrintReport(
    List<Document> documents,
    Organization? organization,
    String batchId,
  ) async {
    try {
      // استخدام خدمة Excel لتصدير التقرير
      final filePath = await ExcelService.exportDocumentsToExcel(
        documents,
        fileName: 'print_report_$batchId.xlsx',
        organization: organization,
      );
      
      print('تم تصدير تقرير الطباعة إلى: $filePath');
    } catch (e) {
      print('خطأ في تصدير تقرير الطباعة: $e');
    }
  }

  /// حفظ PDF إلى ملف
  static Future<String> savePDFToFile(
    Uint8List pdfData,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(pdfData);
    return filePath;
  }

  /// طباعة تقرير بالمستندات
  static Future<void> printDocumentReport(
    List<Document> documents, {
    DateTime? startDate,
    DateTime? endDate,
    DocumentStatus? statusFilter,
  }) async {
    try {
      final organization = await DatabaseService.getMainOrganization();
      final pdf = await _createReportPDF(
        documents,
        organization,
        startDate: startDate,
        endDate: endDate,
        statusFilter: statusFilter,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'تقرير المستندات',
      );
    } catch (e) {
      throw Exception('خطأ في طباعة التقرير: $e');
    }
  }

  /// إنشاء PDF للتقرير
  static Future<Uint8List> _createReportPDF(
    List<Document> documents,
    Organization? organization, {
    DateTime? startDate,
    DateTime? endDate,
    DocumentStatus? statusFilter,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(_pageMargin),
        build: (pw.Context context) {
          return [
            // رأس التقرير
            pw.Text(
              'تقرير المستندات',
              style: pw.TextStyle(
                fontSize: _headerFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
            
            pw.SizedBox(height: 20),
            
            // معلومات التقرير
            if (startDate != null || endDate != null) ...[
              pw.Text('فترة التقرير:'),
              if (startDate != null)
                pw.Text('من: ${startDate.day}/${startDate.month}/${startDate.year}'),
              if (endDate != null)
                pw.Text('إلى: ${endDate.day}/${endDate.month}/${endDate.year}'),
              pw.SizedBox(height: 10),
            ],
            
            if (statusFilter != null)
              pw.Text('الحالة: ${_getStatusText(statusFilter)}'),
              
            pw.SizedBox(height: 20),
            
            // جدول المستندات
            _buildDocumentTable(documents),
            
            pw.SizedBox(height: 20),
            
            // إحصائيات
            _buildReportStatistics(documents),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// بناء جدول المستندات
  static pw.Widget _buildDocumentTable(List<Document> documents) {
    return pw.Table.fromTextArray(
      headers: ['رقم الصادر', 'التاريخ', 'المبلغ', 'الحالة'],
      data: documents.map((doc) => [
        doc.outgoingNumber?.toString() ?? '',
        doc.documentDate != null 
            ? '${doc.documentDate!.day}/${doc.documentDate!.month}/${doc.documentDate!.year}'
            : '',
        doc.amount?.toString() ?? '',
        _getStatusText(doc.status),
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 10),
    );
  }

  /// بناء إحصائيات التقرير
  static pw.Widget _buildReportStatistics(List<Document> documents) {
    final totalAmount = documents
        .where((doc) => doc.amount != null)
        .fold(0.0, (sum, doc) => sum + doc.amount!);
        
    final statusCounts = <DocumentStatus, int>{};
    for (var status in DocumentStatus.values) {
      statusCounts[status] = documents.where((doc) => doc.status == status).length;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'إحصائيات التقرير',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text('إجمالي المستندات: ${documents.length}'),
        pw.Text('إجمالي المبالغ: $totalAmount دينار'),
        pw.SizedBox(height: 10),
        pw.Text('توزيع حسب الحالة:'),
        ...statusCounts.entries.map((entry) => 
          pw.Text('${_getStatusText(entry.key)}: ${entry.value}')),
      ],
    );
  }

  /// تحويل حالة المستند إلى نص
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