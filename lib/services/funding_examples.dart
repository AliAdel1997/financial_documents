import '../models/funding_models.dart';
import '../services/database_service.dart';

/// كلاس مساعد يحتوي على أمثلة لاستخدام نماذج التمويل
class FundingExamples {
  /// إنشاء بيانات تجريبية للأبواب التمويلية
  static Future<void> createSampleFundingCategories() async {
    // إنشاء الأبواب الرئيسية
    final mainCategories = [
      FundingCategory()
        ..name = 'باب الرواتب والأجور'
        ..description = 'باب خاص برواتب الموظفين والأجور'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      FundingCategory()
        ..name = 'باب المستلزمات الطبية'
        ..description = 'باب خاص بالمعدات والمستلزمات الطبية'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      FundingCategory()
        ..name = 'باب الصيانة والتشغيل'
        ..description = 'باب خاص بصيانة المعدات والتشغيل'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    ];

    // إضافة الأبواب الرئيسية
    for (final category in mainCategories) {
      final id = await DatabaseService.addFundingCategory(category);
      print('تم إضافة الباب الرئيسي: ${category.name} بالمعرف: $id');
    }

    // الحصول على الباب الأول لإنشاء أبواب فرعية له
    final mainCategoryId = 1; // افتراض أن هذا هو معرف الباب الأول

    // إنشاء الأبواب الفرعية
    final subCategories = [
      FundingCategory()
        ..name = 'رواتب الأطباء'
        ..description = 'باب فرعي لرواتب الأطباء'
        ..parentId = mainCategoryId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      FundingCategory()
        ..name = 'رواتب الممرضين'
        ..description = 'باب فرعي لرواتب الممرضين'
        ..parentId = mainCategoryId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    ];

    // إضافة الأبواب الفرعية
    for (final category in subCategories) {
      final id = await DatabaseService.addFundingCategory(category);
      print('تم إضافة الباب الفرعي: ${category.name} بالمعرف: $id');
    }
  }

  /// إنشاء بيانات تجريبية للمؤسسات
  static Future<void> createSampleInstitutions() async {
    final institutions = [
      Institution()
        ..name = 'مستشفى بغداد التعليمي'
        ..address = 'بغداد - الرصافة'
        ..code = 'BGH001',

      Institution()
        ..name = 'مستشفى الكرخ العام'
        ..address = 'بغداد - الكرخ'
        ..code = 'KRK002',

      Institution()
        ..name = 'مستشفى الأطفال المركزي'
        ..address = 'بغداد - الكاظمية'
        ..code = 'CHD003',

      Institution()
        ..name = 'مستشفى البصرة العام'
        ..address = 'البصرة - الحي العسكري'
        ..code = 'BSR004',
    ];

    for (final institution in institutions) {
      final id = await DatabaseService.addInstitution(institution);
      print('تم إضافة المؤسسة: ${institution.name} بالمعرف: $id');
    }
  }

  /// إنشاء بيانات تجريبية لتمويل المؤسسات
  static Future<void> createSampleInstitutionFunding() async {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    final fundings = [
      // تمويل مستشفى بغداد التعليمي
      InstitutionFunding()
        ..institutionId = 1
        ..categoryId = 1
        ..allocatedAmount = 200000.0
        ..reservedAmount = 50000.0
        ..spentAmount = 100000.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      InstitutionFunding()
        ..institutionId = 1
        ..categoryId = 2
        ..allocatedAmount = 150000.0
        ..reservedAmount = 30000.0
        ..spentAmount = 80000.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      // تمويل مستشفى الكرخ العام
      InstitutionFunding()
        ..institutionId = 2
        ..categoryId = 1
        ..allocatedAmount = 180000.0
        ..reservedAmount = 40000.0
        ..spentAmount = 90000.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),

      InstitutionFunding()
        ..institutionId = 2
        ..categoryId = 2
        ..allocatedAmount = 120000.0
        ..reservedAmount = 25000.0
        ..spentAmount = 60000.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    ];

    for (final funding in fundings) {
      final id = await DatabaseService.addInstitutionFunding(funding);
      print(
        'تم إضافة التمويل للمؤسسة ${funding.institutionId} في الباب ${funding.categoryId} بالمعرف: $id',
      );
      print('المبلغ المتبقي: ${funding.remainingAmount}');
    }
  }

  /// إنشاء جميع البيانات التجريبية
  static Future<void> createAllSampleData() async {
    print('بدء إنشاء البيانات التجريبية...');

    await createSampleFundingCategories();
    print('✅ تم إنشاء الأبواب التمويلية');

    await createSampleInstitutions();
    print('✅ تم إنشاء المؤسسات');

    await createSampleInstitutionFunding();
    print('✅ تم إنشاء بيانات التمويل');

    print('✅ تم الانتهاء من إنشاء جميع البيانات التجريبية');
  }

  /// عرض تقرير بسيط عن البيانات
  static Future<void> displayDataSummary() async {
    print('\n📊 ملخص البيانات:');

    // عدد الأبواب التمويلية
    final categories = await DatabaseService.getAllFundingCategories();
    print('عدد الأبواب التمويلية: ${categories.length}');

    // عدد المؤسسات
    final institutions = await DatabaseService.getAllInstitutions();
    print('عدد المؤسسات: ${institutions.length}');

    // عدد بيانات التمويل
    final fundings = await DatabaseService.getAllInstitutionFunding();
    print('عدد بيانات التمويل: ${fundings.length}');

    print('\n🏥 المؤسسات:');
    for (final institution in institutions) {
      print('- ${institution.name} (${institution.code})');
    }

    print('\n💰 الأبواب التمويلية الرئيسية:');
    final mainCategories = await DatabaseService.getMainFundingCategories();
    for (final category in mainCategories) {
      print(
        '- ${category.name} - الوصف: ${category.description ?? 'لا يوجد وصف'}',
      );

      // عرض الأبواب الفرعية
      final subCategories = await DatabaseService.getSubFundingCategories(
        category.id,
      );
      for (final subCategory in subCategories) {
        print(
          '  └─ ${subCategory.name} - الوصف: ${subCategory.description ?? 'لا يوجد وصف'}',
        );
      }
    }

    print('\n📈 تقرير التمويل للسنة الحالية:');
    final currentYear = DateTime.now().year;

    for (final institution in institutions) {
      final totalAllocated =
          await DatabaseService.getTotalAllocatedAmountForInstitution(
            institution.id,
            currentYear,
          );
      final totalSpent =
          await DatabaseService.getTotalSpentAmountForInstitution(
            institution.id,
            currentYear,
          );
      final totalRemaining =
          await DatabaseService.getTotalRemainingAmountForInstitution(
            institution.id,
            currentYear,
          );

      if (totalAllocated > 0) {
        print('🏥 ${institution.name}:');
        print('  - المخصص: $totalAllocated');
        print('  - المصروف: $totalSpent');
        print('  - المتبقي: $totalRemaining');
        print(
          '  - نسبة الإنفاق: ${((totalSpent / totalAllocated) * 100).toStringAsFixed(1)}%',
        );
      }
    }
  }

  /// مثال على البحث والتصفية
  static Future<void> searchAndFilterExample() async {
    print('\n🔍 أمثلة على البحث والتصفية:');

    // البحث في المؤسسات
    final hospitalResults = await DatabaseService.searchInstitutions('مستشفى');
    print('المؤسسات التي تحتوي على كلمة "مستشفى": ${hospitalResults.length}');

    // البحث في الأبواب التمويلية
    final salaryResults = await DatabaseService.searchFundingCategories(
      'رواتب',
    );
    print('الأبواب التي تحتوي على كلمة "رواتب": ${salaryResults.length}');

    // الحصول على تمويلات السنة الحالية
    final currentYear = DateTime.now().year;
    final yearFundings = await DatabaseService.getInstitutionFundingByYear(
      currentYear,
    );
    print('عدد التمويلات للسنة $currentYear: ${yearFundings.length}');

    // الحصول على تمويلات الشهر الحالي
    final currentMonth = DateTime.now().month;
    final monthFundings =
        await DatabaseService.getInstitutionFundingByYearMonth(
          currentYear,
          currentMonth,
        );
    print(
      'عدد التمويلات للشهر $currentMonth/$currentYear: ${monthFundings.length}',
    );
  }
}
