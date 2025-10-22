import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/document.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

/// نتيجة طباعة دفعة
class PrintBatchResult {
  final bool success;
  final String batchId;
  final int? documentsCount;
  final String message;

  PrintBatchResult({
    required this.success,
    required this.batchId,
    this.documentsCount,
    required this.message,
  });
}

class PrintingService {
  static const double _pageMargin = 20;

  // متغيرات الخطوط العربية
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;
  static bool _fontsLoaded = false;

  /// تحميل الخطوط العربية
  static Future<void> _loadArabicFonts() async {
    if (_fontsLoaded) return;

    try {
      // استخدام Google Fonts من مكتبة printing
      _arabicFont = await PdfGoogleFonts.cairoRegular();
      
      _arabicBoldFont = await PdfGoogleFonts.cairoBold();

      print('تم تحميل خطوط Cairo العربية من Google Fonts بنجاح');
      _fontsLoaded = true;
    } catch (e) {
      try {
        // محاولة استخدام خط Amiri العربي كبديل
        _arabicFont = await PdfGoogleFonts.amiriRegular();
        _arabicBoldFont = await PdfGoogleFonts.amiriBold();

        print('تم تحميل خطوط Amiri العربية من Google Fonts بنجاح');
        _fontsLoaded = true;
      } catch (e2) {
        try {
          // محاولة استخدام Noto Sans Arabic
          _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
          _arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();

          print('تم تحميل خطوط Noto Sans Arabic من Google Fonts بنجاح');
          _fontsLoaded = true;
        } catch (e3) {
          print('تعذر تحميل الخطوط العربية من Google Fonts: $e3');
          // استخدام الخطوط الافتراضية مع تحذير
          _arabicFont = null;
          _arabicBoldFont = null;
          _fontsLoaded = true;
        }
      }
    }
  }

  /// الحصول على نمط النص العربي
  static pw.TextStyle _getArabicTextStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor? color,
  }) {
    // التأكد من تحميل الخطوط
    final font = bold ? _arabicBoldFont : _arabicFont;

    if (font != null) {
      // استخدام الخط العربي المحمل
      return pw.TextStyle(
        font: font,
        fontSize: fontSize,
        color: color ?? PdfColors.black,
      );
    } else {
      // في حالة عدم توفر خطوط عربية، استخدم خط افتراضي مع وزن مناسب
      return pw.TextStyle(
        fontSize: fontSize,
        color: color ?? PdfColors.black,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
    }
  }

  /// طباعة مستند مفرد مع معاينة وخيارات متقدمة
  static Future<bool> printSingleDocument(
    Document document,
    BuildContext context, {
    bool showPreview = true,
    bool requireConfirmation = true,
  }) async {
    try {
      // تحميل الخطوط العربية
      await _loadArabicFonts();

      // التحقق من البيانات المطلوبة
      if (document.outgoingNumber == null) {
        throw Exception('رقم الصادر مطلوب للطباعة');
      }

      // الحصول على معلومات المؤسسة
      final organization = await DatabaseService.getMainOrganization();
      if (organization == null) {
        throw Exception('يرجى إعداد معلومات المؤسسة أولاً');
      }

      // إنشاء PDF للمعاينة (بدون تشفير أو QR)
      final previewPdf = await _createDocumentPDF(
        document,
        organization,
        false,
      );

      // عرض المعاينة إذا كانت مطلوبة
      if (showPreview) {
        final shouldContinue = await _showPrintPreview(
          context,
          previewPdf,
          'معاينة المستند ${document.outgoingNumber}',
          requireConfirmation,
        );

        if (!shouldContinue) {
          return false; // المستخدم ألغى العملية
        }
      }

      // إنشاء النسخة النهائية مع QR Code والتشفير
      final finalPdf = await _createDocumentPDF(document, organization, true);

      // الطباعة
      await _executePrint(
        context,
        finalPdf,
        'المستند ${document.outgoingNumber}',
      );

      // تحديث حالة المستند في قاعدة البيانات
      document.isPrinted = true;
      document.printedDate = DateTime.now();
      if (document.status == DocumentStatus.draft) {
        document.status = DocumentStatus.printed;
      }
      await DatabaseService.saveDocument(document);

      return true;
    } catch (e) {
      throw Exception('خطأ في طباعة المستند: $e');
    }
  }

  /// عرض معاينة للطباعة مع إمكانية التأكيد
  static Future<bool> _showPrintPreview(
    BuildContext context,
    Uint8List pdfData,
    String title,
    bool requireConfirmation,
  ) async {
    if (!requireConfirmation) {
      // عرض المعاينة فقط
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: title,
      );
      return true;
    }

    // عرض حوار التأكيد مع المعاينة
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الطباعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تريد طباعة هذا المستند؟'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfData,
                  name: title,
                );
              },
              child: const Text('معاينة PDF'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('طباعة'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// تنفيذ عملية الطباعة
  static Future<void> _executePrint(
    BuildContext context,
    Uint8List pdfData,
    String documentName,
  ) async {
    try {
      // محاولة اختيار طابعة
      final selectedPrinter = await Printing.pickPrinter(context: context);

      if (selectedPrinter != null) {
        // طباعة مباشرة على الطابعة المحددة
        await Printing.directPrintPdf(
          printer: selectedPrinter,
          onLayout: (PdfPageFormat format) async => pdfData,
          name: documentName,
        );
      } else {
        // المستخدم لم يختر طابعة، عرض حوار الطباعة العام
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData,
          name: documentName,
        );
      }
    } catch (e) {
      throw Exception('فشل في الطباعة: $e');
    }
  }

  /// طباعة عدة مستندات في دفعة واحدة
  static Future<PrintBatchResult> printMultipleDocuments(
    List<Document> documents, {
    int? startingNumber,
    int? endingNumber,
    required BuildContext context,
    bool showPreview = true,
    bool requireConfirmation = true,
  }) async {
    try {
      // تحميل الخطوط العربية
      await _loadArabicFonts();

      if (documents.isEmpty) {
        throw Exception('قائمة المستندات فارغة');
      }

      // الحصول على معلومات المؤسسة
      final organization = await DatabaseService.getMainOrganization();
      if (organization == null) {
        throw Exception('يرجى إعداد معلومات المؤسسة أولاً');
      }

      // تعيين أرقام الصادر إذا تم تحديد النطاق
      if (startingNumber != null && endingNumber != null) {
        await _assignOutgoingNumbers(documents, startingNumber, endingNumber);
      }

      // إنشاء معرف دفعة فريد
      final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';

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

      // إنشاء PDF للمعاينة (بدون تشفير)
      final previewPdf = await _createBatchPDF(documents, organization, false);

      // عرض المعاينة إذا كانت مطلوبة
      if (showPreview) {
        final shouldContinue = await _showBatchPreview(
          context,
          previewPdf,
          'معاينة الدفعة $batchId (${documents.length} مستندات)',
          requireConfirmation,
        );

        if (!shouldContinue) {
          // إلغاء الدفعة
          printBatch.status = PrintBatchStatus.cancelled;
          await DatabaseService.savePrintBatch(printBatch);
          return PrintBatchResult(
            success: false,
            batchId: batchId,
            message: 'تم إلغاء الطباعة بواسطة المستخدم',
          );
        }
      }

      // تحديث حالة الدفعة إلى جاري الطباعة
      printBatch.status = PrintBatchStatus.printing;
      await DatabaseService.savePrintBatch(printBatch);

      // إنشاء النسخة النهائية مع QR Codes والتشفير
      final finalPdf = await _createBatchPDF(documents, organization, true);

      // الطباعة
      await _executePrint(context, finalPdf, 'دفعة المستندات $batchId');

      // تحديث حالة المستندات والدفعة
      final now = DateTime.now();
      for (var doc in documents) {
        doc.isPrinted = true;
        doc.printedDate = now;
        if (doc.status == DocumentStatus.draft) {
          doc.status = DocumentStatus.printed;
        }
      }
      await DatabaseService.saveDocuments(documents);

      printBatch.status = PrintBatchStatus.completed;
      printBatch.completedDate = now;
      await DatabaseService.savePrintBatch(printBatch);

      // تصدير تقرير الطباعة إلى Excel
      await _exportPrintReport(documents, organization, batchId);

      return PrintBatchResult(
        success: true,
        batchId: batchId,
        documentsCount: documents.length,
        message: 'تم طباعة ${documents.length} مستندات بنجاح',
      );
    } catch (e) {
      throw Exception('خطأ في طباعة عدة مستندات: $e');
    }
  }

  /// عرض معاينة لدفعة من المستندات فقط (بدون طباعة نهائية)
  static Future<bool> previewMultipleDocuments(
    List<Document> documents,
    BuildContext context, {
    bool requireConfirmation = false,
  }) async {
    try {
      await _loadArabicFonts();

      if (documents.isEmpty) {
        throw Exception('قائمة المستندات فارغة');
      }

      final organization = await DatabaseService.getMainOrganization();
      if (organization == null) {
        throw Exception('يرجى إعداد معلومات المؤسسة أولاً');
      }

      // إنشاء PDF للمعاينة (بدون تشفير)
      final previewPdf = await _createBatchPDF(documents, organization, false);

      // عرض المعاينة
      final shouldContinue = await _showBatchPreview(
        context,
        previewPdf,
        'معاينة الدفعة (${documents.length} مستندات)',
        requireConfirmation,
      );

      return shouldContinue;
    } catch (e) {
      throw Exception('خطأ في عرض معاينة الدفعة: $e');
    }
  }

  /// عرض معاينة الدفعة
  static Future<bool> _showBatchPreview(
    BuildContext context,
    Uint8List pdfData,
    String title,
    bool requireConfirmation,
  ) async {
    if (!requireConfirmation) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: title,
      );
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد طباعة الدفعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل تريد طباعة هذه الدفعة؟'),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdfData,
                        name: title,
                      );
                    },
                    child: const Text('معاينة PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('طباعة الدفعة'),
          ),
        ],
      ),
    );

    return result ?? false;
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
        document.encryptedContent = await EncryptionService.encryptDocument(
          document,
        );
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
              _buildDocumentInfo(
                document.outgoingNumber?.toString() ?? 'غير محدد',
                _formatDate(document.documentDate),
              ),
              pw.SizedBox(height: 20),

              // محتوى المستند
              _buildDocumentContent(
                to: organization?.bankName ?? '',
                subject: document.subject ?? '',
                amount: document.amount.toString(),
                amountInWords: document.amountInWords ?? '',
                accountNumber: organization!.accountNumber ?? '',
                organizationaccountnumber: organization.accountNumber ?? '',
                organizationIban: organization.iban ?? '',
                recipientAddress: document.recipientAddress ?? '',
                recipientIban: document.recipientIban ?? '',
                month: document.documentDate!.month.toString(),
                year: document.documentDate!.year.toString(),
                details: document.remarks ?? '',
              ),
              pw.Spacer(),

              // QR Code إذا كان مطلوباً
              if (includeQR && qrData != null) _buildQRCode(qrData),

              // توقيع وتاريخ
              _buildDocumentFooter(
                organization.directorName ?? '',
                organization.jobTitle ?? '',
                '',
                'msc180271@gmail.com',
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// إنشاء PDF لدفعة من المستندات
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
        document.encryptedContent = await EncryptionService.encryptDocument(
          document,
        );
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
                _buildDocumentInfo(
                  document.outgoingNumber?.toString() ?? 'غير محدد',
                  _formatDate(document.documentDate),
                ),
                pw.SizedBox(height: 20),

                // محتوى المستند
                // _buildDocumentContent(document),
                pw.Spacer(),

                // QR Code إذا كان مطلوباً
                if (includeQR && qrData != null) _buildQRCode(qrData),

                // توقيع وتاريخ
                _buildDocumentFooter(
                  organization?.directorName ?? '',
                  organization?.jobTitle ?? '',
                  '', // copyTo
                  'msc180271@gmail.com', // email
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  // /// بناء رأس المستند
  // static pw.Widget _buildDocumentHeader(Organization? organization) {
  //   return pw.Container(
  //     width: double.infinity,
  //     padding: const pw.EdgeInsets.all(15),
  //     decoration: pw.BoxDecoration(
  //       color: PdfColors.blue50,
  //       border: pw.Border.all(color: PdfColors.blue200),
  //       borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //     ),
  //     child: pw.Column(
  //       children: [
  //         // اسم الدائرة
  //         pw.Container(
  //           margin: const pw.EdgeInsets.only(bottom: 10),
  //           child: pw.Text(textDirection: pw.TextDirection.rtl,
  //             organization?.departmentName ?? 'اسم الدائرة',
  //             style: _getArabicTextStyle(
  //               fontSize: _headerFontSize + 2,
  //               bold: true,
  //               color: PdfColors.blue800,
  //             ),
  //             textAlign: pw.TextAlign.center,
  //           ),
  //         ),

  //         // خط فاصل
  //         pw.Container(
  //           width: 150,
  //           height: 2,
  //           color: PdfColors.blue300,
  //           margin: const pw.EdgeInsets.symmetric(vertical: 8),
  //         ),

  //         // عنوان المستند
  //         pw.Text(textDirection: pw.TextDirection.rtl,
  //           'كتاب تحويل مصرفي',
  //           style: _getArabicTextStyle(
  //             fontSize: _headerFontSize,
  //             bold: true,
  //             color: PdfColors.blue700,
  //           ),
  //           textAlign: pw.TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // /// بناء معلومات المستند
  // static pw.Widget _buildDocumentInfo(Document document) {
  //   return pw.Container(
  //     padding: const pw.EdgeInsets.all(12),
  //     decoration: pw.BoxDecoration(
  //       border: pw.Border.all(color: PdfColors.grey400),
  //       borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //     ),
  //     child: pw.Row(
  //       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //       children: [
  //         // رقم الصادر
  //         pw.Container(
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.green50,
  //             border: pw.Border.all(color: PdfColors.green200),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
  //           ),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 'رقم الصادر',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize - 1,
  //                   bold: true,
  //                   color: PdfColors.green800,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 4),
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 '${document.outgoingNumber ?? 'غير محدد'}',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize + 2,
  //                   bold: true,
  //                   color: PdfColors.green900,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // التاريخ
  //         pw.Container(
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.orange50,
  //             border: pw.Border.all(color: PdfColors.orange200),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
  //           ),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.center,
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 'التاريخ',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize - 1,
  //                   bold: true,
  //                   color: PdfColors.orange800,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 4),
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 _formatDate(document.documentDate),
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize,
  //                   bold: true,
  //                   color: PdfColors.orange900,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // /// بناء محتوى المستند
  // static pw.Widget _buildDocumentContent(Document document) {
  //   return pw.Container(
  //     padding: const pw.EdgeInsets.all(12),
  //     decoration: pw.BoxDecoration(
  //       // color: PdfColors.grey50,
  //       // border: pw.Border.all(color: PdfColors.grey300),
  //       borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //     ),
  //     child: pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         // عنوان القسم
  //         pw.Container(
  //           width: double.infinity,
  //           padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //           decoration: pw.BoxDecoration(
  //             gradient: const pw.LinearGradient(
  //               colors: [PdfColors.blue600, PdfColors.blue700],
  //               begin: pw.Alignment.centerLeft,
  //               end: pw.Alignment.centerRight,
  //             ),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //           ),
  //           child: pw.Text(textDirection: pw.TextDirection.rtl,
  //             'تفاصيل التحويل المصرفي',
  //             style: _getArabicTextStyle(
  //               fontSize: _bodyFontSize + 1,
  //               bold: true,
  //               color: PdfColors.white,
  //             ),
  //             textAlign: pw.TextAlign.center,
  //           ),
  //         ),
  //         pw.SizedBox(height: 16),

  //         // المبلغ - صندوق مميز
  //         pw.Container(
  //           width: double.infinity,
  //           padding: const pw.EdgeInsets.all(12),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.green50,
  //             border: pw.Border.all(color: PdfColors.green300, width: 2),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
  //           ),
  //           child: pw.Column(
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 'المبلغ المطلوب تحويله',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize,
  //                   bold: true,
  //                   color: PdfColors.green800,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 6),
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 '${document.amount ?? 0} دينار عراقي',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize + 3,
  //                   bold: true,
  //                   color: PdfColors.green900,
  //                 ),
  //               ),
  //               if (document.amountInWords != null && document.amountInWords!.isNotEmpty) ...[
  //                 pw.SizedBox(height: 4),
  //                 pw.Text(textDirection: pw.TextDirection.rtl,
  //                   '(${document.amountInWords})',
  //                   style: _getArabicTextStyle(
  //                     fontSize: _bodyFontSize - 1,
  //                     color: PdfColors.green700,
  //                   ),
  //                   textAlign: pw.TextAlign.center,
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),

  //         pw.SizedBox(height: 16),

  //         // معلومات الحسابات المصرفية
  //         pw.Container(
  //           padding: const pw.EdgeInsets.all(10),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.indigo50,
  //             border: pw.Border.all(color: PdfColors.indigo200),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //           ),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 'معلومات الحسابات المصرفية',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize,
  //                   bold: true,
  //                   color: PdfColors.indigo800,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 8),
  //               _buildContentRow('ايبان الدائرة:', document.departmentIban ?? 'غير محدد'),
  //               _buildContentRow('ايبان المستلم:', document.recipientIban ?? 'غير محدد'),
  //             ],
  //           ),
  //         ),

  //         pw.SizedBox(height: 12),

  //         // معلومات إضافية
  //         pw.Container(
  //           padding: const pw.EdgeInsets.all(10),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.orange50,
  //             border: pw.Border.all(color: PdfColors.orange200),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //           ),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 'معلومات إضافية',
  //                 style: _getArabicTextStyle(
  //                   fontSize: _bodyFontSize,
  //                   bold: true,
  //                   color: PdfColors.orange800,
  //                 ),
  //               ),
  //               pw.SizedBox(height: 8),
  //               _buildContentRow('عنوان الجهة:', document.recipientAddress ?? 'غير محدد'),
  //               _buildContentRow('تفاصيل الكتاب:', document.documentDetails ?? 'غير محدد'),
  //               if (document.bankNotificationNumber != null) ...[
  //                 _buildContentRow('رقم الإشعار البنكي:', document.bankNotificationNumber!),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// بناء QR Code
  static pw.Widget _buildQRCode(String qrData) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: qrData,
          width: 100,
          height: 100,
        ),
      ],
    );
  }

  // /// بناء تذييل المستند
  // static pw.Widget _buildDocumentFooter(Organization? organization) {
  //   return pw.Container(
  //     margin: const pw.EdgeInsets.only(top: 20),
  //     child: pw.Column(
  //       children: [
  //         // خط فاصل
  //         pw.Container(
  //           width: double.infinity,
  //           height: 1,
  //           color: PdfColors.grey400,
  //           margin: const pw.EdgeInsets.symmetric(vertical: 10),
  //         ),

  //         // صف التوقيع والتاريخ
  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           children: [
  //             pw.Container(
  //               padding: const pw.EdgeInsets.all(8),
  //               decoration: pw.BoxDecoration(
  //                 border: pw.Border.all(color: PdfColors.grey400),
  //                 borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
  //               ),
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   pw.Text(textDirection: pw.TextDirection.rtl,
  //                     'التوقيع:',
  //                     style: _getArabicTextStyle(fontSize: _bodyFontSize - 1, bold: true),
  //                   ),
  //                   pw.SizedBox(height: 20),
  //                   pw.Container(width: 120, height: 1, color: PdfColors.grey400),
  //                 ],
  //               ),
  //             ),
  //             pw.Container(
  //               padding: const pw.EdgeInsets.all(8),
  //               decoration: pw.BoxDecoration(
  //                 border: pw.Border.all(color: PdfColors.grey400),
  //                 borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
  //               ),
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                 children: [
  //                   pw.Text(textDirection: pw.TextDirection.rtl,
  //                     'التاريخ:',
  //                     style: _getArabicTextStyle(fontSize: _bodyFontSize - 1, bold: true),
  //                   ),
  //                   pw.SizedBox(height: 5),
  //                   pw.Text(textDirection: pw.TextDirection.rtl,
  //                     _formatDate(DateTime.now()),
  //                     style: _getArabicTextStyle(fontSize: _bodyFontSize),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //         pw.SizedBox(height: 20),

  //         // معلومات المسؤول
  //         pw.Container(
  //           padding: const pw.EdgeInsets.all(10),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.blue50,
  //             border: pw.Border.all(color: PdfColors.blue200),
  //             borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
  //           ),
  //           child: pw.Column(
  //             children: [
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 organization?.directorName ?? 'اسم المدير',
  //                 style: _getArabicTextStyle(fontSize: _bodyFontSize + 1, bold: true),
  //                 textAlign: pw.TextAlign.center,
  //               ),
  //               pw.SizedBox(height: 5),
  //               pw.Text(textDirection: pw.TextDirection.rtl,
  //                 organization?.jobTitle ?? 'العنوان الوظيفي',
  //                 style: _getArabicTextStyle(fontSize: _bodyFontSize),
  //                 textAlign: pw.TextAlign.center,
  //               ),
  //               if (organization?.assignedWork != null) ...[
  //                 pw.SizedBox(height: 3),
  //                 pw.Text(textDirection: pw.TextDirection.rtl,
  //                   organization!.assignedWork!,
  //                   style: _getArabicTextStyle(fontSize: _bodyFontSize - 1),
  //                   textAlign: pw.TextAlign.center,
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// تعيين أرقام الصادر للمستندات
  static Future<void> _assignOutgoingNumbers(
    List<Document> documents,
    int startingNumber,
    int endingNumber,
  ) async {
    if (documents.length > (endingNumber - startingNumber + 1)) {
      throw Exception('عدد المستندات أكبر من النطاق المحدد للأرقام');
    }

    for (int i = 0; i < documents.length; i++) {
      documents[i].outgoingNumber = startingNumber + i;
    }
  }

  /// إنشاء بيانات QR Code
  static Future<String> _generateQRData(Document document) async {
    return 'DOC:${document.id}-${document.outgoingNumber}-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// تصدير تقرير الطباعة
  static Future<void> _exportPrintReport(
    List<Document> documents,
    Organization? organization,
    String batchId,
  ) async {
    try {
      // TODO: إضافة وظيفة تصدير Excel
      // await ExcelService.exportDocuments(
      //   documents,
      //   'تقرير_طباعة_$batchId',
      // );
      print('تم إنشاء تقرير الطباعة للدفعة: $batchId');
    } catch (e) {
      print('خطأ في تصدير تقرير الطباعة: $e');
    }
  }

  /// تنسيق التاريخ
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// طباعة مستند فردي سريعة (بدون معاينة)
  static Future<bool> quickPrintDocument(
    Document document,
    BuildContext context,
  ) async {
    return await printSingleDocument(
      document,
      context,
      showPreview: false,
      requireConfirmation: false,
    );
  }

  /// معاينة مستند بدون طباعة
  static Future<void> previewDocument(
    Document document,
    BuildContext context,
  ) async {
    // تحميل الخطوط العربية
    await _loadArabicFonts();

    final organization = await DatabaseService.getMainOrganization();
    final pdfData = await _createDocumentPDF(document, organization, false);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'معاينة المستند ${document.outgoingNumber}',
    );
  }

  

  static pw.Widget _buildDocumentHeader(
    Organization? organization, {
    Uint8List? logoBytes,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // يسار (English + org logo)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Ministry of Health and Environment",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              "Babil Health Directorate",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              "Mirjan Medical City",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 5),
            if (logoBytes != null)
              pw.Image(pw.MemoryImage(logoBytes), width: 50, height: 50),
          ],
        ),

        // وسط (جمهورية العراق + شعار الجمهورية)
        pw.Column(
          children: [
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "جمهورية العراق",
              style: _getArabicTextStyle(fontSize: 12, bold: true),
            ),
            pw.SizedBox(height: 5),
            // شعار الجمهورية من الأصول
            // يجب تحميل الصورة مسبقاً وتمريرها هنا
            if (logoBytes != null)
              pw.Image(pw.MemoryImage(logoBytes), width: 60, height: 60),
          ],
        ),

        // يمين (عربي)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "وزارة الصحة والبيئة",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "دائرة صحة محافظة بابل",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "مدينة مرجان الطبية",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "شعبة الأمور الإدارية والمالية",
              style: _getArabicTextStyle(fontSize: 10),
            ),
            pw.Text(
              textDirection: pw.TextDirection.rtl,
              "الحسابات",
              style: _getArabicTextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDocumentInfo(String number, String date) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        textDirection: pw.TextDirection.rtl,
        "العدد: $number    التاريخ: $date",
        style: _getArabicTextStyle(fontSize: 11),
      ),
    );
  }

  static pw.Widget _buildDocumentContent({
    String? to,
    String? subject,
    String? amount,
    String? amountInWords,
    String? accountNumber,
    String? organizationIban,
    String? organizationaccountnumber,
    String? recipientAddress,
    String? recipientIban,
    String? month,
    String? year,
    String? details,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "إلى: $to",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "الموضوع: $subject",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.SizedBox(height: 15),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "يرجى تحويل مبلغ وقدره ${amount}",
          style: _getArabicTextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          " من حسابنا الجاري المفتوع لديكم بالرقم : $accountNumber ",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          " IBAN:$organizationIban",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "إلى حساب: $recipientAddress",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "IBAN: $recipientIban",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "عن شهر: $month / $year",
          style: _getArabicTextStyle(fontSize: 11),
        ),
        pw.Text(
          textDirection: pw.TextDirection.rtl,
          "التفاصيل: $details",
          style: _getArabicTextStyle(fontSize: 11),
        ),
      ],
    );
  }

  static pw.Widget _buildDocumentFooter(
    String directorName,
    String directorTitle,
    String copyTo,
    String? email,
  ) {
    return pw.Column(
      children: [
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                textDirection: pw.TextDirection.rtl,
                directorName,
                style: _getArabicTextStyle(fontSize: 12, bold: true),
              ),
              pw.Text(
                textDirection: pw.TextDirection.rtl,
                directorTitle,
                style: _getArabicTextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                textDirection: pw.TextDirection.rtl,
                "نسخة منه إلى:",
                style: _getArabicTextStyle(fontSize: 11, bold: true),
              ),
              pw.Text(
                textDirection: pw.TextDirection.rtl,
                copyTo,
                style: _getArabicTextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        if (email != null)
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              textDirection: pw.TextDirection.rtl,
              email,
              style: _getArabicTextStyle(fontSize: 10),
            ),
          ),
      ],
    );
  }
}
