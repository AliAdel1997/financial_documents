// TODO: يحتاج هذا الملف لإعادة كتابة كاملة بعد تحديث FundingManager
// تم تعطيله مؤقتاً حتى يتم تحديث الطرق المستخدمة

/*
import '../services/funding_manager.dart';
import '../services/funding_examples.dart';
import '../services/database_service.dart';

/// أمثلة عملية لاستخدام FundingManager
class FundingManagerExamples {
  
  /// مثال شامل على استخدام جميع وظائف FundingManager
  static Future<void> runCompleteExample() async {
    print('🚀 بدء تشغيل أمثلة FundingManager...\n');

    // 1. إنشاء البيانات الأساسية
    await _setupInitialData();
    
    // 2. أمثلة على إضافة الأبواب التمويلية
    await _demonstrateAddingCategories();
    
    // 3. أمثلة على تخصيص الأموال للمؤسسات
    await _demonstrateFundAllocation();
    
    // 4. أمثلة على التوزيع الهرمي
    await _demonstrateHierarchicalDistribution();
    
    // 5. توليد التقارير
    await _generateReports();
    
    print('✅ تم الانتهاء من جميع الأمثلة!');
  }

  /// إعداد البيانات الأساسية
  static Future<void> _setupInitialData() async {
    print('📋 إعداد البيانات الأساسية...');
    
    // إنشاء البيانات التجريبية الأساسية
    await FundingExamples.createSampleInstitutions();
    
    print('✅ تم إعداد البيانات الأساسية\n');
  }

  /// أمثلة على إضافة الأبواب التمويلية
  static Future<void> _demonstrateAddingCategories() async {
    print('💼 أمثلة على إضافة الأبواب التمويلية:');
    print('═══════════════════════════════════════════════');

    // إضافة الأبواب الرئيسية
    print('\n📁 إضافة الأبواب الرئيسية:');
    
    final salariesCategoryId = await FundingManager.addFundingCategory(
      'باب الرواتب والأجور',
      allocatedAmount: 5000000.0,
    );
    
    final suppliesCategoryId = await FundingManager.addFundingCategory(
      'باب المستلزمات الطبية',
      allocatedAmount: 3000000.0,
    );
    
    await FundingManager.addFundingCategory(
      'باب الصيانة والتطوير',
      allocatedAmount: 2000000.0,
    );

    // إضافة الأبواب الفرعية للرواتب
    if (salariesCategoryId != null) {
      print('\n📂 إضافة الأبواب الفرعية لباب الرواتب:');
      
      await FundingManager.addFundingCategory(
        'رواتب الأطباء',
        parentId: salariesCategoryId,
        allocatedAmount: 3000000.0,
      );
      
      await FundingManager.addFundingCategory(
        'رواتب الممرضين',
        parentId: salariesCategoryId,
        allocatedAmount: 1500000.0,
      );
      
      await FundingManager.addFundingCategory(
        'رواتب الإداريين',
        parentId: salariesCategoryId,
        allocatedAmount: 500000.0,
      );
    }

    // إضافة الأبواب الفرعية للمستلزمات
    if (suppliesCategoryId != null) {
      print('\n📂 إضافة الأبواب الفرعية لباب المستلزمات:');
      
      await FundingManager.addFundingCategory(
        'أدوية ومواد طبية',
        parentId: suppliesCategoryId,
        allocatedAmount: 2000000.0,
      );
      
      await FundingManager.addFundingCategory(
        'أجهزة طبية',
        parentId: suppliesCategoryId,
        allocatedAmount: 1000000.0,
      );
    }

    print('\n✅ تم الانتهاء من إضافة الأبواب التمويلية\n');
  }

  /// أمثلة على تخصيص الأموال للمؤسسات
  static Future<void> _demonstrateFundAllocation() async {
    print('💰 أمثلة على تخصيص الأموال للمؤسسات:');
    print('═══════════════════════════════════════════════');

    // الحصول على المؤسسات والأبواب
    final institutions = await DatabaseService.getAllInstitutions();
    final categories = await DatabaseService.getAllFundingCategories();
    
    if (institutions.isEmpty || categories.isEmpty) {
      print('❌ لا توجد مؤسسات أو أبواب تمويلية للعمل معها');
      return;
    }

    print('\n💼 تخصيص الأموال للمؤسسات:');

    // تخصيص أموال لمستشفى بغداد التعليمي
    final baghdadHospital = institutions.firstWhere(
      (inst) => inst.name.contains('بغداد'),
      orElse: () => institutions.first,
    );
    
    // البحث عن باب الرواتب
    final salariesCategory = categories.firstWhere(
      (cat) => cat.name.contains('رواتب') && cat.parentId == null,
      orElse: () => categories.first,
    );

    // تخصيص 800,000 لمستشفى بغداد من باب الرواتب
    await FundingManager.allocateFundsToInstitution(
      baghdadHospital.id,
      salariesCategory.id,
      800000.0,
    );

    // تخصيص أموال لمستشفى الكرخ
    final karkhHospital = institutions.firstWhere(
      (inst) => inst.name.contains('الكرخ'),
      orElse: () => institutions.length > 1 ? institutions[1] : institutions.first,
    );

    await FundingManager.allocateFundsToInstitution(
      karkhHospital.id,
      salariesCategory.id,
      600000.0,
    );

    // تخصيص من باب المستلزمات
    final suppliesCategory = categories.firstWhere(
      (cat) => cat.name.contains('مستلزمات'),
      orElse: () => categories.length > 1 ? categories[1] : categories.first,
    );

    await FundingManager.allocateFundsToInstitution(
      baghdadHospital.id,
      suppliesCategory.id,
      500000.0,
    );

    await FundingManager.allocateFundsToInstitution(
      karkhHospital.id,
      suppliesCategory.id,
      400000.0,
    );

    // تخصيص أموال إضافية (اختبار التراكم)
    print('\n🔄 اختبار التخصيص التراكمي:');
    await FundingManager.allocateFundsToInstitution(
      baghdadHospital.id,
      salariesCategory.id,
      200000.0, // مبلغ إضافي
    );

    print('\n✅ تم الانتهاء من تخصيص الأموال\n');
  }

  /// أمثلة على التوزيع الهرمي
  static Future<void> _demonstrateHierarchicalDistribution() async {
    print('🌳 أمثلة على التوزيع الهرمي:');
    print('═══════════════════════════════════════════════');

    final categories = await DatabaseService.getMainFundingCategories();
    
    for (final mainCategory in categories) {
      final subCategories = await DatabaseService.getSubFundingCategories(mainCategory.id);
      
      if (subCategories.isNotEmpty) {
        print('\n📊 توزيع أموال الباب: ${mainCategory.name}');
        print('المبلغ الإجمالي: ${mainCategory.allocatedAmount}');
        print('عدد الأبواب الفرعية: ${subCategories.length}');
        
        // التوزيع بالتساوي
        print('\n🟰 التوزيع بالتساوي:');
        final equalDistribution = await FundingManager.distributeFundsHierarchically(
          mainCategory.id,
          distributionType: DistributionType.equal,
          totalAmount: mainCategory.allocatedAmount * 0.8, // 80% من المبلغ
        );
        
        if (equalDistribution != null) {
          for (final entry in equalDistribution.entries) {
            final subCat = subCategories.firstWhere((cat) => cat.id == entry.key);
            print('   ${subCat.name}: ${entry.value.toStringAsFixed(2)}');
          }
        }

        // إعادة تعيين المبالغ للاختبار التالي
        await _resetCategoryAmounts(subCategories);

        // التوزيع النسبي
        print('\n📊 التوزيع النسبي:');
        final proportionalDistribution = await FundingManager.distributeFundsHierarchically(
          mainCategory.id,
          distributionType: DistributionType.proportional,
          totalAmount: mainCategory.allocatedAmount * 0.9, // 90% من المبلغ
        );
        
        if (proportionalDistribution != null) {
          for (final entry in proportionalDistribution.entries) {
            final subCat = subCategories.firstWhere((cat) => cat.id == entry.key);
            print('   ${subCat.name}: ${entry.value.toStringAsFixed(2)}');
          }
        }

        // التوزيع حسب الأولوية
        print('\n🎯 التوزيع حسب الأولوية:');
        final priorityDistribution = await FundingManager.distributeFundsHierarchically(
          mainCategory.id,
          distributionType: DistributionType.priority,
          totalAmount: mainCategory.allocatedAmount,
        );
        
        if (priorityDistribution != null) {
          for (final entry in priorityDistribution.entries) {
            final subCat = subCategories.firstWhere((cat) => cat.id == entry.key);
            print('   ${subCat.name}: ${entry.value.toStringAsFixed(2)}');
          }
        }
        
        print('\n' + '─' * 50);
      }
    }

    print('\n✅ تم الانتهاء من أمثلة التوزيع الهرمي\n');
  }

  /// إعادة تعيين مبالغ الأبواب الفرعية لأغراض الاختبار
  static Future<void> _resetCategoryAmounts(List categories) async {
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      // إعطاء مبالغ مختلفة للاختبار
      final amounts = [100000.0, 250000.0, 500000.0, 750000.0];
      final newAmount = amounts[i % amounts.length];
      
      final updatedCategory = category.copyWith(
        allocatedAmount: newAmount,
        updatedAt: DateTime.now(),
      );
      await DatabaseService.updateFundingCategory(updatedCategory);
    }
  }

  /// توليد التقارير
  static Future<void> _generateReports() async {
    print('📊 توليد التقارير:');
    print('═══════════════════════════════════════════════');

    final currentYear = DateTime.now().year;

    // تقرير شامل
    await FundingManager.generateComprehensiveReport(year: currentYear);

    // تقارير مفصلة للمؤسسات
    print('\n📋 تقارير مفصلة للمؤسسات:');
    print('─────────────────────────────────────────');
    
    final institutions = await DatabaseService.getAllInstitutions();
    for (final institution in institutions) {
      final summary = await FundingManager.getInstitutionFundingSummary(
        institution.id, 
        currentYear
      );
      
      if (summary.totalAllocated > 0) {
        print('\n🏥 تقرير مفصل للمؤسسة: ${summary.institutionName}');
        print('   📅 السنة: ${summary.year}');
        print('   💰 إجمالي المخصص: ${summary.totalAllocated.toStringAsFixed(2)}');
        print('   🔒 إجمالي المحجوز: ${summary.totalReserved.toStringAsFixed(2)}');
        print('   💸 إجمالي المصروف: ${summary.totalSpent.toStringAsFixed(2)}');
        print('   💵 إجمالي المتبقي: ${summary.totalRemaining.toStringAsFixed(2)}');
        print('   📈 نسبة الاستغلال: ${summary.utilizationRate.toStringAsFixed(2)}%');
        print('   📋 عدد التمويلات: ${summary.fundingCount}');
      }
    }

    // تقارير مفصلة للأبواب التمويلية
    print('\n💰 تقارير مفصلة للأبواب التمويلية:');
    print('─────────────────────────────────────────');
    
    final categories = await DatabaseService.getMainFundingCategories();
    for (final category in categories) {
      final summary = await FundingManager.getCategoryFundingSummary(
        category.id, 
        currentYear
      );
      
      print('\n💰 تقرير مفصل للباب: ${summary.categoryName}');
      print('   📅 السنة: ${summary.year}');
      print('   🎯 الميزانية الكلية: ${summary.totalBudget.toStringAsFixed(2)}');
      print('   💰 إجمالي المخصص: ${summary.totalAllocated.toStringAsFixed(2)}');
      print('   💸 إجمالي المصروف: ${summary.totalSpent.toStringAsFixed(2)}');
      print('   💵 المتبقي من الميزانية: ${summary.remainingBudget.toStringAsFixed(2)}');
      print('   📈 نسبة الاستغلال: ${summary.utilizationRate.toStringAsFixed(2)}%');
      print('   🏥 عدد المؤسسات المستفيدة: ${summary.institutionCount}');
    }

    print('\n✅ تم الانتهاء من توليد التقارير\n');
  }

  /// مثال مبسط لاستخدام سريع
  static Future<void> quickExample() async {
    print('⚡ مثال سريع على FundingManager:\n');

    // إنشاء باب رئيسي
    final categoryId = await FundingManager.addFundingCategory(
      'باب اختبار سريع',
      allocatedAmount: 1000000.0,
    );

    if (categoryId != null) {
      // إنشاء باب فرعي
      await FundingManager.addFundingCategory(
        'فرع اختبار',
        parentId: categoryId,
        allocatedAmount: 500000.0,
      );

      // توزيع الأموال على الأبواب الفرعية
      await FundingManager.distributeFundsHierarchically(
        categoryId,
        distributionType: DistributionType.equal,
      );

      print('✅ تم تنفيذ المثال السريع بنجاح!');
    } else {
      print('❌ فشل في إنشاء الباب الرئيسي');
    }
  }

  /// اختبار حالات الخطأ
  static Future<void> testErrorCases() async {
    print('🧪 اختبار حالات الخطأ:\n');

    // محاولة إضافة باب بدون اسم
    print('❌ اختبار إضافة باب بدون اسم:');
    await FundingManager.addFundingCategory('');

    // محاولة إضافة باب بمبلغ سالب
    print('\n❌ اختبار إضافة باب بمبلغ سالب:');
    await FundingManager.addFundingCategory(
      'باب خاطئ',
      allocatedAmount: -1000.0,
    );

    // محاولة تخصيص مبلغ لمؤسسة غير موجودة
    print('\n❌ اختبار تخصيص مبلغ لمؤسسة غير موجودة:');
    await FundingManager.allocateFundsToInstitution(
      99999, // مؤسسة غير موجودة
      1,     // باب افتراضي
      50000.0,
    );

    // محاولة توزيع أموال على باب بدون أبواب فرعية
    print('\n❌ اختبار توزيع أموال على باب بدون أبواب فرعية:');
    await FundingManager.distributeFundsHierarchically(99999);

    print('\n✅ تم الانتهاء من اختبار حالات الخطأ');
  }
}*/
