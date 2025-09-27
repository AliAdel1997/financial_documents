import 'dart:io';
import 'dart:math';
import '../models/funding_models.dart';
import '../services/database_service.dart';
import '../services/funding_attachment_service.dart';

/// أمثلة وحالات اختبار لخدمة المرفقات
class FundingAttachmentExamples {

  /// تشغيل مثال شامل لإدارة المرفقات
  static Future<void> runCompleteExample() async {
    print('🚀 بدء تشغيل أمثلة المرفقات...');
    
    try {
      // تأكد من تهيئة قاعدة البيانات
      await DatabaseService.initialize();

      // إنشاء بيانات أساسية للتجربة
      await _createSampleData();

      // 1. إنشاء مرفقات تجريبية
      await _createSampleAttachments();

      // 2. عرض المرفقات
      await _displayAttachments();

      // 3. البحث في المرفقات
      await _searchAttachments();

      // 4. إحصائيات المرفقات
      await _showAttachmentsStats();

      // 5. تحديث وصف مرفق
      await _updateAttachmentExample();

      // 6. حذف مرفق
      await _deleteAttachmentExample();

      print('✅ تم تشغيل جميع أمثلة المرفقات بنجاح!');

    } catch (e) {
      print('❌ خطأ في تشغيل أمثلة المرفقات: $e');
      rethrow;
    }
  }

  /// إنشاء بيانات أساسية للتجربة
  static Future<void> _createSampleData() async {
    print('\n📋 إنشاء بيانات أساسية...');

    // إنشاء فئة تمويل
    final category = FundingCategory()
      ..name = 'التجهيزات الطبية'
      ..allocatedAmount = 1000000
      ..createdAt = DateTime.now();
    
    final savedCategoryId = await DatabaseService.addFundingCategory(category);
    print('تم إنشاء فئة التمويل: ${category.name} (ID: $savedCategoryId)');

    // إنشاء مؤسسة
    final institution = Institution()
      ..name = 'مستشفى الملك فهد'
      ..address = 'الرياض - المملكة العربية السعودية'
      ..code = 'KFH001';

    final savedInstitutionId = await DatabaseService.addInstitution(institution);
    print('تم إنشاء المؤسسة: ${institution.name} (ID: $savedInstitutionId)');

    // إنشاء تمويل للمؤسسة
    final funding = InstitutionFunding()
      ..institutionId = savedInstitutionId
      ..categoryId = savedCategoryId
      ..allocatedAmount = 500000
      ..spentAmount = 150000
      ..reservedAmount = 50000
      ..year = DateTime.now().year
      ..createdAt = DateTime.now();

    await DatabaseService.addInstitutionFunding(funding);
    print('تم إنشاء تمويل للمؤسسة بمبلغ: ${funding.allocatedAmount}');
  }

  /// إنشاء مرفقات تجريبية
  static Future<void> _createSampleAttachments() async {
    print('\n📎 إنشاء مرفقات تجريبية...');

    // الحصول على أول تمويل
    final fundings = await DatabaseService.getAllInstitutionFunding();
    if (fundings.isEmpty) {
      throw Exception('لم يتم العثور على تمويل للمرفقات');
    }

    final fundingId = fundings.first.id;

    // إنشاء مرفقات وهمية (ملفات غير موجودة فعلياً)
    final sampleAttachments = [
      {
        'fileName': 'عقد_شراء_التجهيزات.pdf',
        'fileType': 'PDF',
        'description': 'عقد شراء التجهيزات الطبية من الشركة الموردة',
        'filePath': '/documents/contracts/contract_001.pdf',
      },
      {
        'fileName': 'فاتورة_المعدات.xlsx',
        'fileType': 'Excel',
        'description': 'فاتورة تفصيلية للمعدات المشتراة',
        'filePath': '/documents/invoices/invoice_001.xlsx',
      },
      {
        'fileName': 'شهادة_الجودة.jpg',
        'fileType': 'JPEG',
        'description': 'شهادة جودة المعدات من الجهة المصنعة',
        'filePath': '/documents/certificates/quality_cert.jpg',
      },
      {
        'fileName': 'دليل_التشغيل.docx',
        'fileType': 'Word',
        'description': 'دليل التشغيل والصيانة للمعدات',
        'filePath': '/documents/manuals/operation_manual.docx',
      },
      {
        'fileName': 'تقرير_التسليم.pdf',
        'fileType': 'PDF',
        'description': 'تقرير تسليم واستلام المعدات',
        'filePath': '/documents/reports/delivery_report.pdf',
      },
    ];

    for (final attachmentData in sampleAttachments) {
      final attachment = FundingAttachment()
        ..fundingId = fundingId
        ..fileName = attachmentData['fileName'] as String
        ..filePath = attachmentData['filePath'] as String
        ..fileType = attachmentData['fileType'] as String
        ..description = attachmentData['description'] as String
        ..uploadedAt = DateTime.now().subtract(Duration(days: Random().nextInt(30)));

      final savedAttachment = await DatabaseService.addFundingAttachment(attachment);
      print('تم إنشاء مرفق: ${savedAttachment.fileName}');
    }
  }

  /// عرض جميع المرفقات
  static Future<void> _displayAttachments() async {
    print('\n📋 عرض جميع المرفقات:');

    final fundings = await DatabaseService.getAllInstitutionFunding();
    for (final funding in fundings) {
      final attachments = await FundingAttachmentService.getAttachments(funding.id);
      
      if (attachments.isNotEmpty) {
        print('\n--- مرفقات التمويل رقم ${funding.id} ---');
        for (final attachment in attachments) {
          print('📎 ${attachment.fileName} (${attachment.fileType})');
          print('   الوصف: ${attachment.description ?? 'لا يوجد وصف'}');
          print('   تاريخ الرفع: ${attachment.uploadedAt}');
          print('   المسار: ${attachment.filePath}');
        }
      }
    }
  }

  /// البحث في المرفقات
  static Future<void> _searchAttachments() async {
    print('\n🔍 اختبار البحث في المرفقات:');

    final searchQueries = ['عقد', 'فاتورة', 'PDF', 'تقرير'];

    for (final query in searchQueries) {
      final results = await FundingAttachmentService.searchAttachments(query);
      print('\n--- نتائج البحث عن "$query" ---');
      if (results.isNotEmpty) {
        for (final result in results) {
          print('✓ ${result.fileName} - ${result.description}');
        }
      } else {
        print('لا توجد نتائج');
      }
    }
  }

  /// عرض إحصائيات المرفقات
  static Future<void> _showAttachmentsStats() async {
    print('\n📊 إحصائيات المرفقات:');

    final stats = await DatabaseService.getAttachmentsStats();
    
    print('إجمالي المرفقات: ${stats['totalAttachments']}');
    print('المرفقات الحديثة (آخر 30 يوم): ${stats['recentCount']}');
    
    final typeStats = stats['typeStats'] as Map<String, int>;
    if (typeStats.isNotEmpty) {
      print('\nتوزيع المرفقات حسب النوع:');
      typeStats.forEach((type, count) {
        print('  $type: $count مرفق');
      });
    }
  }

  /// مثال على تحديث وصف مرفق
  static Future<void> _updateAttachmentExample() async {
    print('\n✏️ اختبار تحديث وصف مرفق:');

    // البحث عن أول مرفق
    final searchResults = await FundingAttachmentService.searchAttachments('عقد');
    if (searchResults.isNotEmpty) {
      final attachment = searchResults.first;
      print('الوصف القديم: ${attachment.description}');

      // تحديث الوصف
      final newDescription = '${attachment.description} - تم التحديث في ${DateTime.now()}';
      final updatedAttachment = await FundingAttachmentService.updateAttachmentDescription(
        attachment.id,
        newDescription,
      );

      if (updatedAttachment != null) {
        print('الوصف الجديد: ${updatedAttachment.description}');
        print('✅ تم تحديث الوصف بنجاح');
      } else {
        print('❌ فشل في تحديث الوصف');
      }
    }
  }

  /// مثال على حذف مرفق
  static Future<void> _deleteAttachmentExample() async {
    print('\n🗑️ اختبار حذف مرفق:');

    // البحث عن آخر مرفق
    final recentAttachments = await FundingAttachmentService.getRecentAttachments(limit: 1);
    if (recentAttachments.isNotEmpty) {
      final attachment = recentAttachments.first;
      print('سيتم حذف المرفق: ${attachment.fileName}');

      // حذف المرفق (بدون حذف الملف الفعلي لأنه وهمي)
      final deleted = await FundingAttachmentService.deleteAttachment(
        attachment.id,
        deleteFile: false,
      );

      if (deleted) {
        print('✅ تم حذف المرفق بنجاح');
      } else {
        print('❌ فشل في حذف المرفق');
      }
    }
  }

  /// مثال متقدم: رفع مرفق حقيقي
  static Future<void> uploadRealFileExample(String filePath) async {
    print('\n📤 مثال رفع ملف حقيقي:');

    try {
      // التحقق من وجود الملف
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ الملف غير موجود: $filePath');
        return;
      }

      // الحصول على أول تمويل
      final fundings = await DatabaseService.getAllInstitutionFunding();
      if (fundings.isEmpty) {
        print('❌ لا توجد تمويلات للربط بالمرفق');
        return;
      }

      final fundingId = fundings.first.id;
      final fileName = file.path.split(Platform.pathSeparator).last;

      // رفع المرفق
      final attachment = await FundingAttachmentService.uploadAttachment(
        fundingId: fundingId,
        fileName: fileName,
        localFilePath: filePath,
        description: 'مرفق تم رفعه من خلال المثال',
      );

      print('✅ تم رفع المرفق بنجاح:');
      print('   الاسم: ${attachment.fileName}');
      print('   النوع: ${attachment.fileType}');
      print('   المعرف: ${attachment.id}');

    } catch (e) {
      print('❌ خطأ في رفع الملف: $e');
    }
  }

  /// تنظيف البيانات التجريبية
  static Future<void> cleanupSampleData() async {
    print('\n🧹 تنظيف البيانات التجريبية...');

    try {
      // حذف جميع المرفقات (سنحذفها عبر التمويلات)
      int deletedAttachments = 0;
      final fundings = await DatabaseService.getAllInstitutionFunding();
      for (final funding in fundings) {
        final count = await DatabaseService.deleteAttachmentsByFunding(funding.id);
        deletedAttachments += count;
      }
      print('تم حذف $deletedAttachments مرفق');

      // حذف التمويلات
      final allFundings = await DatabaseService.getAllInstitutionFunding();
      for (final funding in allFundings) {
        await DatabaseService.deleteInstitutionFunding(funding.id);
      }
      print('تم حذف ${allFundings.length} تمويل');

      // حذف المؤسسات
      final allInstitutions = await DatabaseService.getAllInstitutions();
      for (final institution in allInstitutions) {
        await DatabaseService.deleteInstitution(institution.id);
      }
      print('تم حذف ${allInstitutions.length} مؤسسة');

      // حذف فئات التمويل
      final allCategories = await DatabaseService.getAllFundingCategories();
      for (final category in allCategories) {
        await DatabaseService.deleteFundingCategory(category.id);
      }
      print('تم حذف ${allCategories.length} فئة تمويل');

      print('✅ تم تنظيف جميع البيانات التجريبية');

    } catch (e) {
      print('❌ خطأ في تنظيف البيانات: $e');
    }
  }
}