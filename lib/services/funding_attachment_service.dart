import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// خدمة إدارة مرفقات التمويل
class FundingAttachmentService {
  
  /// رفع مرفق جديد
  static Future<FundingAttachment> uploadAttachment({
    required int fundingId,
    required String fileName,
    required String localFilePath,
    String? description,
  }) async {
    try {
      // التحقق من وجود الملف
      final file = File(localFilePath);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $localFilePath');
      }

      // تحديد نوع الملف
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileType = _getFileType(fileExtension);

      // إنشاء سجل المرفق
      final attachment = FundingAttachment()
        ..fundingId = fundingId
        ..fileName = fileName
        ..filePath = localFilePath
        ..fileType = fileType
        ..uploadedAt = DateTime.now()
        ..description = description;

      // حفظ في قاعدة البيانات
      final savedAttachment = await DatabaseService.addFundingAttachment(attachment);
      
      print('تم رفع المرفق بنجاح: ${savedAttachment.fileName}');
      return savedAttachment;

    } catch (e) {
      print('خطأ في رفع المرفق: $e');
      rethrow;
    }
  }

  /// الحصول على مرفقات تمويل محدد
  static Future<List<FundingAttachment>> getAttachments(int fundingId) async {
    return await DatabaseService.getAttachmentsByFunding(fundingId);
  }

  /// حذف مرفق مع حذف الملف من النظام
  static Future<bool> deleteAttachment(int attachmentId, {bool deleteFile = false}) async {
    try {
      // الحصول على المرفق أولاً
      final attachment = await DatabaseService.getFundingAttachment(attachmentId);
      if (attachment == null) {
        throw Exception('المرفق غير موجود');
      }

      // حذف الملف من النظام إذا طُلب ذلك
      if (deleteFile && attachment.filePath != null) {
        final file = File(attachment.filePath!);
        if (await file.exists()) {
          await file.delete();
          print('تم حذف الملف: ${attachment.filePath}');
        }
      }

      // حذف السجل من قاعدة البيانات
      final deleted = await DatabaseService.deleteFundingAttachment(attachmentId);
      
      if (deleted) {
        print('تم حذف المرفق بنجاح: ${attachment.fileName}');
      }
      
      return deleted;

    } catch (e) {
      print('خطأ في حذف المرفق: $e');
      return false;
    }
  }

  /// تحديث وصف المرفق
  static Future<FundingAttachment?> updateAttachmentDescription(
    int attachmentId, 
    String newDescription
  ) async {
    try {
      final attachment = await DatabaseService.getFundingAttachment(attachmentId);
      if (attachment == null) return null;

      final updatedAttachment = attachment.copyWith(
        description: newDescription,
      );

      return await DatabaseService.updateFundingAttachment(updatedAttachment);
    } catch (e) {
      print('خطأ في تحديث وصف المرفق: $e');
      return null;
    }
  }

  /// البحث في المرفقات
  static Future<List<FundingAttachment>> searchAttachments(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return await DatabaseService.searchAttachments(query);
  }

  /// تحديد نوع الملف بناءً على الامتداد
  static String _getFileType(String extension) {
    switch (extension) {
      case '.pdf':
        return 'PDF';
      case '.doc':
      case '.docx':
        return 'Word';
      case '.xls':
      case '.xlsx':
        return 'Excel';
      case '.jpg':
      case '.jpeg':
        return 'JPEG';
      case '.png':
        return 'PNG';
      case '.gif':
        return 'GIF';
      case '.txt':
        return 'Text';
      case '.zip':
      case '.rar':
        return 'Archive';
      default:
        return 'Other';
    }
  }

  /// الحصول على أحدث المرفقات  
  static Future<List<FundingAttachment>> getRecentAttachments({int limit = 10}) async {
    final attachments = await DatabaseService.isar.fundingAttachments
        .filter()
        .uploadedAtIsNotNull()
        .sortByUploadedAtDesc()
        .findAll();
    
    return attachments.take(limit).toList();
  }
}