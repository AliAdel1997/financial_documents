import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/document_draft.dart';
import '../models/final_document.dart';
import '../services/arabic_number_to_words_service.dart';
import '../services/qr_code_service.dart';

class AdvancedPDFService {
  static final AdvancedPDFService _instance = AdvancedPDFService._internal();
  factory AdvancedPDFService() => _instance;
  AdvancedPDFService._internal();

  /// إنشاء PDF للمعاينة (بدون تشفير)
  static Future<List<int>> generatePreviewPDF({
    required DocumentDraft draft,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس المستند
              _buildPreviewHeader(draft, organizationName),
              pw.SizedBox(height: 30),
              
              // معلومات المعاينة
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'هذا المستند للمعاينة فقط',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'لن يحتوي على رقم صادر أو QR Code للتحقق',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // محتوى المستند
              _buildDocumentContent(
                entityName: draft.entityName,
                amount: draft.amount,
                amountInWords: draft.amount.toArabicWords(),
                documentType: draft.documentTypeArabic,
                month: draft.monthNameArabic,
                year: draft.year.toString(),
                purpose: draft.purpose,
                iban: draft.entityIban,
                organizationBankName: draft.organizationBankName ?? '',
                isPreview: true,
              ),
              
              pw.Spacer(),
              
              // تذييل المعاينة
              pw.Center(
                child: pw.Text(
                  'تم إنشاء هذه المعاينة في ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  /// إنشاء PDF نهائي مع QR Code ورقم صادر
  static Future<List<int>> generateFinalPDF({
    required FinalDocument document,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
    Uint8List? organizationLogo,
  }) async {
    final pdf = pw.Document();
    
    // إنشاء QR Code
    final qrBytes = await QRCodeService.generateQRImageBytes(document: document);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس المستند النهائي
              _buildFinalHeader(document, organizationName, organizationLogo),
              pw.SizedBox(height: 30),
              
              // رقم الصادر والتاريخ
              _buildDocumentInfo(document),
              pw.SizedBox(height: 30),
              
              // محتوى المستند
              _buildDocumentContent(
                entityName: document.entityName,
                amount: document.amount,
                amountInWords: document.amountInWords,
                documentType: document.documentTypeArabic,
                month: document.monthNameArabic,
                year: document.year.toString(),
                purpose: document.purpose,
                iban: document.entityIban,
                organizationBankName: document.organizationBankName,
                isPreview: false,
              ),
              
              pw.Spacer(),
              
              // QR Code والتوقيع الرقمي
              _buildSecuritySection(document, qrBytes),
              
              pw.SizedBox(height: 20),
              
              // تذييل رسمي
              _buildOfficialFooter(organizationName, organizationAddress),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  /// رأس المعاينة
  static pw.Widget _buildPreviewHeader(DocumentDraft draft, String organizationName) {
    return pw.Column(
      children: [
        pw.Text(
          organizationName,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'مستند ${draft.documentTypeArabic}',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '${draft.monthNameArabic} ${draft.year}',
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// رأس المستند النهائي
  static pw.Widget _buildFinalHeader(FinalDocument document, String organizationName, Uint8List? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                organizationName,
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                document.documentTitle,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        if (logo != null)
          pw.Container(
            width: 80,
            height: 80,
            child: pw.Image(pw.MemoryImage(logo)),
          ),
      ],
    );
  }

  /// معلومات المستند (رقم صادر وتاريخ)
  static pw.Widget _buildDocumentInfo(FinalDocument document) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            document.formattedDocumentNumber,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            document.formattedIssueDate,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// محتوى المستند
  static pw.Widget _buildDocumentContent({
    required String entityName,
    required double amount,
    required String amountInWords,
    required String documentType,
    required String month,
    required String year,
    String? purpose,
    String? iban,
    required String organizationBankName,
    required bool isPreview,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildContentRow('اسم الجهة:', entityName),
          pw.SizedBox(height: 12),
          
          if (iban != null && iban.isNotEmpty) ...[
            _buildContentRow('رقم الحساب (IBAN):', iban),
            pw.SizedBox(height: 12),
          ],
          
          _buildContentRow('المبلغ رقماً:', '${amount.toStringAsFixed(2)} ريال سعودي'),
          pw.SizedBox(height: 12),
          
          _buildContentRow('المبلغ كتابةً:', '$amountInWords فقط لا غير'),
          pw.SizedBox(height: 12),
          
          _buildContentRow('الشهر:', month),
          pw.SizedBox(height: 12),
          
          _buildContentRow('السنة:', year),
          pw.SizedBox(height: 12),
          
          if (purpose != null && purpose.isNotEmpty) ...[
            _buildContentRow('الغرض:', purpose),
            pw.SizedBox(height: 12),
          ],
          
          _buildContentRow('اسم المصرف:', organizationBankName),
          
          if (isPreview) ...[
            pw.SizedBox(height: 20),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow100,
                border: pw.Border.all(color: PdfColors.orange),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'ملاحظة: هذا المستند للمعاينة فقط ولا يحتوي على توقيع رقمي أو QR Code للتحقق',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// صف محتوى
  static pw.Widget _buildContentRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// قسم الأمان (QR Code والتوقيع الرقمي)
  static pw.Widget _buildSecuritySection(FinalDocument document, Uint8List? qrBytes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'التوقيع الرقمي:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  document.verificationHash ?? '',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'للتحقق من صحة المستند، امسح QR Code',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'أو قم بزيارة: ${document.getVerificationURL()}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue700),
                ),
              ],
            ),
          ),
          if (qrBytes != null)
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(pw.MemoryImage(qrBytes)),
            )
          else
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Center(
                child: pw.Text(
                  'QR Code',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// تذييل رسمي
  static pw.Widget _buildOfficialFooter(String organizationName, String organizationAddress) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'تم إصدار هذا المستند إلكترونياً من $organizationName',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          if (organizationAddress.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              organizationAddress,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'تاريخ الطباعة: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// طباعة المعاينة
  static Future<void> printPreview({
    required DocumentDraft draft,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
  }) async {
    final pdfBytes = await generatePreviewPDF(
      draft: draft,
      organizationName: organizationName,
      organizationAddress: organizationAddress,
    );
    
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
      name: 'معاينة_${draft.documentTypeArabic}_${draft.entityName}',
    );
  }

  /// طباعة المستند النهائي
  static Future<void> printFinal({
    required FinalDocument document,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
    Uint8List? organizationLogo,
  }) async {
    final pdfBytes = await generateFinalPDF(
      document: document,
      organizationName: organizationName,
      organizationAddress: organizationAddress,
      organizationLogo: organizationLogo,
    );
    
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
      name: 'مستند_${document.documentNumber.replaceAll('/', '_')}',
    );
    
    // تحديث عداد الطباعة
    document.markAsPrinted();
  }

  /// إنشاء دفعة من المستندات
  static Future<List<int>> generateBatchPDF({
    required List<FinalDocument> documents,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
    Uint8List? organizationLogo,
  }) async {
    final pdf = pw.Document();
    
    for (int i = 0; i < documents.length; i++) {
      final document = documents[i];
      final qrBytes = await QRCodeService.generateQRImageBytes(document: document);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildFinalHeader(document, organizationName, organizationLogo),
                pw.SizedBox(height: 30),
                _buildDocumentInfo(document),
                pw.SizedBox(height: 30),
                _buildDocumentContent(
                  entityName: document.entityName,
                  amount: document.amount,
                  amountInWords: document.amountInWords,
                  documentType: document.documentTypeArabic,
                  month: document.monthNameArabic,
                  year: document.year.toString(),
                  purpose: document.purpose,
                  iban: document.entityIban,
                  organizationBankName: document.organizationBankName,
                  isPreview: false,
                ),
                pw.Spacer(),
                _buildSecuritySection(document, qrBytes),
                pw.SizedBox(height: 20),
                _buildOfficialFooter(organizationName, organizationAddress),
                
                // معلومات الدفعة
                pw.SizedBox(height: 10),
                pw.Text(
                  'صفحة ${i + 1} من ${documents.length}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }
    
    return pdf.save();
  }

  /// طباعة دفعة
  static Future<void> printBatch({
    required List<FinalDocument> documents,
    String organizationName = 'المؤسسة',
    String organizationAddress = '',
    Uint8List? organizationLogo,
  }) async {
    final pdfBytes = await generateBatchPDF(
      documents: documents,
      organizationName: organizationName,
      organizationAddress: organizationAddress,
      organizationLogo: organizationLogo,
    );
    
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
      name: 'دفعة_مستندات_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}