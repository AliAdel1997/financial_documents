import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../models/document.dart';
import '../services/database_service.dart';

class EncryptionService {
  static const String _defaultKey = 'financial_documents_2024_secure_key';
  static Encrypter? _encrypter;
  static IV? _iv;

  /// تهيئة خدمة التشفير
  static Future<void> initialize() async {
    try {
      // الحصول على مفتاح التشفير من الإعدادات أو استخدام المفتاح الافتراضي
      final settings = await DatabaseService.getSettings();
      String encryptionKey = settings?.encryptionKey ?? _defaultKey;
      
      // التأكد من أن المفتاح بطول 32 حرف (256 بت)
      encryptionKey = _normalizeKey(encryptionKey);
      
      // إنشاء مفتاح التشفير
      final key = Key.fromBase64(base64Encode(utf8.encode(encryptionKey)));
      
      // إنشاء IV (Initialization Vector)
      _iv = IV.fromSecureRandom(16);
      
      // إنشاء المشفر باستخدام AES
      _encrypter = Encrypter(AES(key));
      
    } catch (e) {
      throw Exception('فشل في تهيئة خدمة التشفير: $e');
    }
  }

  /// تشفير مستند
  static Future<String> encryptDocument(Document document) async {
    try {
      await _ensureInitialized();
      
      // إنشاء بيانات المستند كـ JSON
      final documentData = {
        'id': document.id,
        'outgoingNumber': document.outgoingNumber,
        'documentDate': document.documentDate?.toIso8601String(),
        'amount': document.amount,
        'amountInWords': document.amountInWords,
        'departmentIban': document.departmentIban,
        'recipientIban': document.recipientIban,
        'recipientAddress': document.recipientAddress,
        'documentDetails': document.documentDetails,
        'status': document.status.toString(),
        'createdAt': document.createdAt?.toIso8601String(),
        'encryptedAt': DateTime.now().toIso8601String(),
      };

      // تحويل البيانات إلى JSON string
      final jsonString = jsonEncode(documentData);
      
      // تشفير البيانات
      final encrypted = _encrypter!.encrypt(jsonString, iv: _iv!);
      
      // إرجاع البيانات المشفرة مع IV
      return '${_iv!.base64}:${encrypted.base64}';
      
    } catch (e) {
      throw Exception('فشل في تشفير المستند: $e');
    }
  }

  /// فك تشفير مستند
  static Future<Map<String, dynamic>> decryptDocument(String encryptedData) async {
    try {
      await _ensureInitialized();
      
      // فصل IV عن البيانات المشفرة
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('تنسيق البيانات المشفرة غير صحيح');
      }

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];
      
      // إنشاء IV من البيانات
      final iv = IV.fromBase64(ivBase64);
      
      // إنشاء كائن مشفر من البيانات
      final encrypted = Encrypted.fromBase64(encryptedBase64);
      
      // فك التشفير
      final decrypted = _encrypter!.decrypt(encrypted, iv: iv);
      
      // تحويل JSON string إلى Map
      return jsonDecode(decrypted) as Map<String, dynamic>;
      
    } catch (e) {
      throw Exception('فشل في فك تشفير المستند: $e');
    }
  }

  /// تشفير نص عادي
  static Future<String> encryptText(String text) async {
    try {
      await _ensureInitialized();
      
      final encrypted = _encrypter!.encrypt(text, iv: _iv!);
      return '${_iv!.base64}:${encrypted.base64}';
      
    } catch (e) {
      throw Exception('فشل في تشفير النص: $e');
    }
  }

  /// فك تشفير نص
  static Future<String> decryptText(String encryptedText) async {
    try {
      await _ensureInitialized();
      
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('تنسيق النص المشفر غير صحيح');
      }

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];
      
      final iv = IV.fromBase64(ivBase64);
      final encrypted = Encrypted.fromBase64(encryptedBase64);
      
      return _encrypter!.decrypt(encrypted, iv: iv);
      
    } catch (e) {
      throw Exception('فشل في فك تشفير النص: $e');
    }
  }

  /// توليد hash للتحقق من سلامة البيانات
  static String generateHash(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// التحقق من hash
  static bool verifyHash(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// تشفير ملف
  static Future<Uint8List> encryptFile(Uint8List fileData) async {
    try {
      await _ensureInitialized();
      
      // تشفير بيانات الملف
      final base64Data = base64Encode(fileData);
      final encrypted = _encrypter!.encrypt(base64Data, iv: _iv!);
      
      // إضافة IV إلى بداية الملف المشفر
      final ivBytes = _iv!.bytes;
      final encryptedBytes = encrypted.bytes;
      
      // دمج IV مع البيانات المشفرة
      final result = Uint8List(ivBytes.length + encryptedBytes.length);
      result.setRange(0, ivBytes.length, ivBytes);
      result.setRange(ivBytes.length, result.length, encryptedBytes);
      
      return result;
      
    } catch (e) {
      throw Exception('فشل في تشفير الملف: $e');
    }
  }

  /// فك تشفير ملف
  static Future<Uint8List> decryptFile(Uint8List encryptedFileData) async {
    try {
      await _ensureInitialized();
      
      // استخراج IV من بداية الملف
      final ivBytes = encryptedFileData.sublist(0, 16);
      final encryptedBytes = encryptedFileData.sublist(16);
      
      final iv = IV(ivBytes);
      final encrypted = Encrypted(encryptedBytes);
      
      // فك التشفير
      final decrypted = _encrypter!.decrypt(encrypted, iv: iv);
      
      // تحويل من base64 إلى bytes
      return base64Decode(decrypted);
      
    } catch (e) {
      throw Exception('فشل في فك تشفير الملف: $e');
    }
  }

  /// توليد مفتاح تشفير عشوائي
  static String generateRandomKey() {
    final secureRandom = IV.fromSecureRandom(32);
    return base64Encode(secureRandom.bytes);
  }

  /// تحديث مفتاح التشفير
  static Future<void> updateEncryptionKey(String newKey) async {
    try {
      // تطبيع المفتاح الجديد
      final normalizedKey = _normalizeKey(newKey);
      
      // إنشاء مشفر جديد
      final key = Key.fromBase64(base64Encode(utf8.encode(normalizedKey)));
      _encrypter = Encrypter(AES(key));
      _iv = IV.fromSecureRandom(16);
      
      // حفظ المفتاح الجديد في الإعدادات
      final settings = await DatabaseService.getSettings();
      if (settings != null) {
        settings.encryptionKey = newKey;
        await DatabaseService.saveSettings(settings);
      }
      
    } catch (e) {
      throw Exception('فشل في تحديث مفتاح التشفير: $e');
    }
  }

  /// إنشاء رقم تسلسلي مشفر للمستند
  static Future<String> generateSecureDocumentId(Document document) async {
    try {
      final data = {
        'outgoingNumber': document.outgoingNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'random': IV.fromSecureRandom(8).base64,
      };
      
      final jsonData = jsonEncode(data);
      final hash = generateHash(jsonData);
      
      return hash.substring(0, 16); // استخدام أول 16 حرف من الـ hash
      
    } catch (e) {
      throw Exception('فشل في توليد معرف آمن للمستند: $e');
    }
  }

  /// التحقق من سلامة المستند المشفر
  static Future<bool> verifyDocumentIntegrity(Document document) async {
    try {
      if (document.encryptedContent == null || !document.isEncrypted) {
        return false;
      }

      // فك تشفير المستند
      final decryptedData = await decryptDocument(document.encryptedContent!);
      
      // التحقق من البيانات الأساسية
      return decryptedData['outgoingNumber'] == document.outgoingNumber &&
             decryptedData['id'] == document.id;
             
    } catch (e) {
      return false;
    }
  }

  /// تصدير البيانات المشفرة لأغراض النسخ الاحتياطي
  static Future<String> exportEncryptedBackup(List<Document> documents) async {
    try {
      await _ensureInitialized();
      
      final backupData = {
        'version': '1.0',
        'createdAt': DateTime.now().toIso8601String(),
        'documentsCount': documents.length,
        'documents': documents.map((doc) => doc.toJson()).toList(),
      };

      final jsonString = jsonEncode(backupData);
      return await encryptText(jsonString);
      
    } catch (e) {
      throw Exception('فشل في تصدير النسخة الاحتياطية المشفرة: $e');
    }
  }

  /// استيراد البيانات المشفرة من النسخة الاحتياطية
  static Future<List<Document>> importEncryptedBackup(String encryptedBackup) async {
    try {
      final decryptedJson = await decryptText(encryptedBackup);
      final backupData = jsonDecode(decryptedJson) as Map<String, dynamic>;
      
      final documentsData = backupData['documents'] as List<dynamic>;
      
      return documentsData
          .map((data) => Document.fromJson(data as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      throw Exception('فشل في استيراد النسخة الاحتياطية المشفرة: $e');
    }
  }

  // Helper methods

  /// التأكد من تهيئة المشفر
  static Future<void> _ensureInitialized() async {
    if (_encrypter == null || _iv == null) {
      await initialize();
    }
  }

  /// تطبيع مفتاح التشفير ليكون بالطول المطلوب (32 حرف)
  static String _normalizeKey(String key) {
    if (key.length == 32) {
      return key;
    } else if (key.length > 32) {
      return key.substring(0, 32);
    } else {
      // إذا كان المفتاح أقل من 32 حرف، نكرره أو نضيف حشو
      final padding = '0' * (32 - key.length);
      return key + padding;
    }
  }

  /// تنظيف ذاكرة التشفير (للأمان)
  static void dispose() {
    _encrypter = null;
    _iv = null;
  }
}

/// فئة لإدارة أمان الطباعة
class PrintSecurityService {
  /// توليد توقيع رقمي للمستند
  static Future<String> generateDocumentSignature(Document document) async {
    final signatureData = {
      'outgoingNumber': document.outgoingNumber,
      'documentDate': document.documentDate?.toIso8601String(),
      'amount': document.amount,
      'documentDetails': document.documentDetails,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final jsonString = jsonEncode(signatureData);
    return EncryptionService.generateHash(jsonString);
  }

  /// التحقق من التوقيع الرقمي
  static Future<bool> verifyDocumentSignature(
    Document document,
    String signature,
  ) async {
    final expectedSignature = await generateDocumentSignature(document);
    return expectedSignature == signature;
  }

  /// إنشاء كود تحقق للطباعة الآمنة
  static Future<String> generatePrintVerificationCode(
    Document document,
    String printerInfo,
  ) async {
    final verificationData = {
      'documentId': document.id,
      'outgoingNumber': document.outgoingNumber,
      'printer': printerInfo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'security': await EncryptionService.generateSecureDocumentId(document),
    };

    final jsonString = jsonEncode(verificationData);
    final hash = EncryptionService.generateHash(jsonString);
    
    return hash.substring(0, 12); // رمز تحقق قصير
  }
}