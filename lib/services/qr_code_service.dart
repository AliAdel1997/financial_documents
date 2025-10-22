import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/final_document.dart';

class QRCodeService {
  static final QRCodeService _instance = QRCodeService._internal();
  factory QRCodeService() => _instance;
  QRCodeService._internal();

  /// إنشاء QR Code للمستند النهائي
  static QrImageView generateDocumentQR({
    required FinalDocument document,
    double size = 100.0,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) {
    final qrData = _buildQRData(document);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(8.0),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// إنشاء QR Code كـ widget للطباعة
  static Widget generateQRWidget({
    required FinalDocument document,
    double size = 80.0,
    Color foregroundColor = Colors.black,
  }) {
    final qrData = _buildQRData(document);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      foregroundColor: foregroundColor,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// إنشاء بيانات QR Code
  static String _buildQRData(FinalDocument document) {
    final documentInfo = {
      'docType': document.documentType,
      'docNum': document.documentNumber,
      'entity': document.entityName,
      'amount': document.amount.toStringAsFixed(2),
      'date': document.issueDate.toIso8601String().substring(0, 10), // YYYY-MM-DD
      'hash': _generateVerificationHash(document),
      'org': document.organizationName ?? 'المؤسسة',
      'iban': document.entityIban,
    };

    // تحويل إلى JSON مضغوط
    return jsonEncode(documentInfo);
  }

  /// إنشاء hash للتحقق من صحة المستند
  static String _generateVerificationHash(FinalDocument document) {
    final dataToHash = [
      document.documentNumber,
      document.entityName,
      document.amount.toString(),
      document.issueDate.millisecondsSinceEpoch.toString(),
      document.documentType,
    ].join('|');

    final bytes = utf8.encode(dataToHash);
    final digest = sha256.convert(bytes);
    
    // أخذ أول 8 أحرف من الـ hash
    return digest.toString().substring(0, 8);
  }

  /// إنشاء QR Code للتحقق عبر الإنترنت
  static String generateVerificationURL({
    required FinalDocument document,
    String baseURL = 'https://verify.financial-docs.gov.sa',
  }) {
    final hash = _generateVerificationHash(document);
    return '$baseURL/verify/${document.documentNumber}?hash=$hash';
  }

  /// إنشاء QR Code بسيط يحتوي على رابط التحقق فقط
  static QrImageView generateVerificationQR({
    required FinalDocument document,
    double size = 100.0,
    String baseURL = 'https://verify.financial-docs.gov.sa',
  }) {
    final verificationURL = generateVerificationURL(
      document: document,
      baseURL: baseURL,
    );
    
    return QrImageView(
      data: verificationURL,
      version: QrVersions.auto,
      size: size,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(8.0),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// فك تشفير QR Code والحصول على معلومات المستند
  static Map<String, dynamic>? decodeQRData(String qrData) {
    try {
      // محاولة فك التشفير كـ JSON
      final Map<String, dynamic> data = jsonDecode(qrData);
      return data;
    } catch (e) {
      // إذا فشل، قد يكون رابط بسيط
      if (qrData.startsWith('http')) {
        return {
          'type': 'verification_url',
          'url': qrData,
        };
      }
      return null;
    }
  }

  /// التحقق من صحة hash المستند
  static bool verifyDocumentHash({
    required String documentNumber,
    required String entityName,
    required double amount,
    required DateTime issueDate,
    required String documentType,
    required String providedHash,
  }) {
    final dataToHash = [
      documentNumber,
      entityName,
      amount.toString(),
      issueDate.millisecondsSinceEpoch.toString(),
      documentType,
    ].join('|');

    final bytes = utf8.encode(dataToHash);
    final digest = sha256.convert(bytes);
    final computedHash = digest.toString().substring(0, 8);

    return computedHash.toLowerCase() == providedHash.toLowerCase();
  }

  /// إنشاء QR Code مخصص للأنواع المختلفة من المستندات
  static QrImageView generateCustomDocumentQR({
    required FinalDocument document,
    required DocumentQRType qrType,
    double size = 100.0,
  }) {
    String qrData;
    
    switch (qrType) {
      case DocumentQRType.fullInfo:
        qrData = _buildQRData(document);
        break;
      case DocumentQRType.verificationOnly:
        qrData = generateVerificationURL(document: document);
        break;
      case DocumentQRType.basic:
        qrData = _buildBasicQRData(document);
        break;
    }
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(8.0),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// إنشاء بيانات أساسية للـ QR Code
  static String _buildBasicQRData(FinalDocument document) {
    return '${document.documentNumber}|${document.entityName}|${document.amount}|${document.issueDate.day}/${document.issueDate.month}/${document.issueDate.year}';
  }

  /// إنشاء QR Code للمعاينة (بدون تشفير كامل)
  static QrImageView generatePreviewQR({
    required String documentNumber,
    required String entityName,
    required double amount,
    double size = 100.0,
  }) {
    final previewData = 'معاينة|$documentNumber|$entityName|$amount|${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    
    return QrImageView(
      data: previewData,
      version: QrVersions.auto,
      size: size,
      foregroundColor: Colors.grey,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(8.0),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  /// تحويل QR Code إلى Uint8List للاستخدام في PDF
  static Future<Uint8List?> generateQRImageBytes({
    required FinalDocument document,
    int size = 200,
  }) async {
    try {
      final qrData = _buildQRData(document);
      
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: Colors.black,
          emptyColor: Colors.white,
        );

        final picData = await painter.toImageData(size.toDouble());
        return picData?.buffer.asUint8List();
      }
      
      return null;
    } catch (e) {
      print('خطأ في إنشاء صورة QR Code: $e');
      return null;
    }
  }

  /// اختبار خدمة QR Code
  static void testQRService() {
    print('اختبار خدمة QR Code...');
    
    // مثال على مستند للاختبار
    final testDoc = FinalDocument();
    testDoc.documentNumber = '123/تست/2024';
    testDoc.entityName = 'شركة الاختبار';
    testDoc.amount = 1500.75;
    testDoc.issueDate = DateTime.now();
    testDoc.documentType = 'deductions';
    testDoc.entityIban = 'SA1234567890123456789012';
    testDoc.organizationName = 'مؤسسة الاختبار';

    final qrData = _buildQRData(testDoc);
    print('بيانات QR Code: $qrData');

    final decodedData = decodeQRData(qrData);
    print('البيانات المفكوكة: $decodedData');

    final verificationURL = generateVerificationURL(document: testDoc);
    print('رابط التحقق: $verificationURL');
  }
}

/// أنواع QR Code للمستندات
enum DocumentQRType {
  fullInfo,        // معلومات كاملة
  verificationOnly, // رابط التحقق فقط
  basic,           // معلومات أساسية
}

/// Extension لـ FinalDocument لإضافة وظائف QR Code
extension DocumentQRExtension on FinalDocument {
  /// إنشاء QR Code للمستند
  QrImageView generateQR({double size = 100.0}) {
    return QRCodeService.generateDocumentQR(
      document: this,
      size: size,
    );
  }

  /// إنشاء رابط التحقق
  String getVerificationURL({String baseURL = 'https://verify.financial-docs.gov.sa'}) {
    return QRCodeService.generateVerificationURL(
      document: this,
      baseURL: baseURL,
    );
  }

  /// إنشاء hash التحقق
  String getVerificationHash() {
    return QRCodeService._generateVerificationHash(this);
  }
}