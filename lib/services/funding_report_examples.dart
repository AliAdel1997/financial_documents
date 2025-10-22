// TODO: يحتاج هذا الملف لإعادة كتابة بعد تحديث النماذج
// تم تعطيله مؤقتاً

/*
import '../models/funding_models.dart';

/// أمثلة عملية لاستخدام خدمة التقارير الهرمية
class FundingReportExamples {
  
  /// مثال شامل على توليد التقارير الهرمية
  static Future<void> runCompleteExample() async {
    print('🚀 بدء تشغيل أمثلة التقارير الهرمية...\n');

    // تهيئة قاعدة البيانات
    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    // إنشاء بيانات تجريبية متقدمة
    await _setupAdvancedTestData();
    
    // أمثلة على التقارير المختلفة
    await _demonstrateBasicReports(isar);
    await _demonstrateFilteredReports(isar);
    await _demonstrateSearchAndAnalysis(isar);
    await _demonstrateJsonExport(isar);
    
    print('✅ تم الانتهاء من جميع أمثلة التقارير الهرمية!');
  }

  /// إعداد بيانات تجريبية متقدمة
  static Future<void> _setupAdvancedTestData() async {
    print('🏗️ إعداد بيانات تجريبية متقدمة...');
    
    // إنشاء هيكل هرمي معقد للأبواب التمويلية
    
    // الباب الرئيسي الأول: الرواتب والأجور
    final salariesCategoryId = await FundingManager.addFundingCategory(
      'الرواتب والأجور',
      allocatedAmount: 5000000.0,
    );

    if (salariesCategoryId != null) {
      // أبواب فرعية للرواتب
      final doctorSalariesId = await FundingManager.addFundingCategory(
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

      // أبواب فرعية من المستوى الثاني (تحت رواتب الأطباء)
      if (doctorSalariesId != null) {
        await FundingManager.addFundingCategory(
          'رواتب الأطباء المختصين',
          parentId: doctorSalariesId,
          allocatedAmount: 2000000.0,
        );
        
        await FundingManager.addFundingCategory(
          'رواتب الأطباء المقيمين',
          parentId: doctorSalariesId,
          allocatedAmount: 1000000.0,
        );
      }
    }

    // الباب الرئيسي الثاني: المستلزمات الطبية
    final suppliesCategoryId = await FundingManager.addFundingCategory(
      'المستلزمات الطبية',
      allocatedAmount: 3000000.0,
    );

    if (suppliesCategoryId != null) {
      await FundingManager.addFundingCategory(
        'الأدوية والعقاقير',
        parentId: suppliesCategoryId,
        allocatedAmount: 2000000.0,
      );
      
      await FundingManager.addFundingCategory(
        'الأجهزة الطبية',
        parentId: suppliesCategoryId,
        allocatedAmount: 800000.0,
      );
      
      await FundingManager.addFundingCategory(
        'المواد الاستهلاكية',
        parentId: suppliesCategoryId,
        allocatedAmount: 200000.0,
      );
    }

    // الباب الرئيسي الثالث: التطوير والصيانة
    final developmentCategoryId = await FundingManager.addFundingCategory(
      'التطوير والصيانة',
      allocatedAmount: 2000000.0,
    );

    if (developmentCategoryId != null) {
      await FundingManager.addFundingCategory(
        'صيانة الأجهزة',
        parentId: developmentCategoryId,
        allocatedAmount: 1200000.0,
      );
      
      await FundingManager.addFundingCategory(
        'تطوير البنية التحتية',
        parentId: developmentCategoryId,
        allocatedAmount: 800000.0,
      );
    }

    // إنشاء مؤسسات متعددة
    final institutions = [
      {'name': 'مستشفى الأمل التخصصي', 'code': 'HOPE001'},
      {'name': 'مستشفى النور العام', 'code': 'NOOR002'},
      {'name': 'مركز الأطفال الطبي', 'code': 'CHILD003'},
    ];

    for (final inst in institutions) {
      final institution = Institution()
        ..name = inst['name']!
        ..address = 'بغداد'
        ..code = inst['code'];
      
      await DatabaseService.addInstitution(institution);
    }

    // إنشاء تمويلات متنوعة
    await _createDiverseFundings();

    print('✅ تم إعداد البيانات التجريبية المتقدمة');
    print('   🏥 3 مؤسسات');
    print('   💰 3 أبواب رئيسية');
    print('   📂 عدة أبواب فرعية بمستويات مختلفة');
    print('   💼 تمويلات متنوعة مع عمليات مختلفة\n');
  }

  /// إنشاء تمويلات متنوعة مع عمليات مختلفة
  static Future<void> _createDiverseFundings() async {
    final isar = DatabaseService.isar;
    final institutions = await DatabaseService.getAllInstitutions();
    final categories = await DatabaseService.getAllFundingCategories();
    
    if (institutions.isEmpty || categories.isEmpty) return;

    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    // تمويلات لمستشفى الأمل
    final hopeHospital = institutions.first;
    final salariesCategory = categories.firstWhere(
      (cat) => cat.name.contains('رواتب') && cat.parentId == null,
      orElse: () => categories.first,
    );

    // تمويل الرواتب مع عمليات متنوعة
    final funding1 = InstitutionFunding()
      ..institutionId = hopeHospital.id
      ..categoryId = salariesCategory.id
      ..allocatedAmount = 800000.0
      ..reservedAmount = 0.0
      ..spentAmount = 0.0
      ..year = currentYear
      ..month = currentMonth
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final fundingId1 = await DatabaseService.addInstitutionFunding(funding1);

    // تنفيذ عمليات متنوعة على التمويل الأول
    await FundingService.reserveFunds(isar, fundingId1, 400000.0, description: 'حجز رواتب الأطباء');
    await FundingService.reserveFunds(isar, fundingId1, 200000.0, description: 'حجز رواتب الممرضين');
    await FundingService.validateAndSpend(isar, fundingId1, 300000.0, description: 'صرف رواتب شهر سابق');
    await FundingService.validateAndSpend(isar, fundingId1, 150000.0, description: 'صرف حوافز');

    // تمويلات إضافية للمؤسسات الأخرى
    if (institutions.length > 1) {
      final noorHospital = institutions[1];
      final suppliesCategory = categories.firstWhere(
        (cat) => cat.name.contains('مستلزمات'),
        orElse: () => categories.length > 1 ? categories[1] : categories.first,
      );

      final funding2 = InstitutionFunding()
        ..institutionId = noorHospital.id
        ..categoryId = suppliesCategory.id
        ..allocatedAmount = 500000.0
        ..reservedAmount = 0.0
        ..spentAmount = 0.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final fundingId2 = await DatabaseService.addInstitutionFunding(funding2);

      // عمليات على التمويل الثاني
      await FundingService.reserveFunds(isar, fundingId2, 250000.0, description: 'حجز للأدوية');
      await FundingService.validateAndSpend(isar, fundingId2, 200000.0, description: 'شراء أدوية طوارئ');
    }

    // إضافة تمويلات لفئات فرعية
    final subCategories = categories.where((cat) => cat.parentId != null).toList();
    if (subCategories.isNotEmpty && institutions.length > 2) {
      final childCenter = institutions[2];
      final subCategory = subCategories.first;

      final funding3 = InstitutionFunding()
        ..institutionId = childCenter.id
        ..categoryId = subCategory.id
        ..allocatedAmount = 300000.0
        ..reservedAmount = 100000.0
        ..spentAmount = 150000.0
        ..year = currentYear
        ..month = currentMonth
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await DatabaseService.addInstitutionFunding(funding3);
    }
  }

  /// أمثلة على التقارير الأساسية
  static Future<void> _demonstrateBasicReports(isar) async {
    print('📊 أمثلة على التقارير الأساسية:');
    print('═══════════════════════════════════════════════');

    // تقرير شامل لجميع البيانات
    print('\n🌍 التقرير الشامل (جميع المؤسسات والسنوات):');
    final allReport = await generateFundingReport(isar);
    printDetailedFundingReport(allReport);

    // تقرير مقيد بسنة معينة
    final currentYear = DateTime.now().year;
    print('\n📅 التقرير لسنة $currentYear:');
    final yearReport = await generateFundingReport(isar, year: currentYear);
    printDetailedFundingReport(yearReport);

    // تقرير مقيد بمؤسسة معينة
    final institutions = await DatabaseService.getAllInstitutions();
    if (institutions.isNotEmpty) {
      final firstInstitution = institutions.first;
      print('\n🏥 التقرير لمؤسسة ${firstInstitution.name}:');
      final institutionReport = await generateFundingReport(
        isar,
        institutionId: firstInstitution.id,
      );
      printDetailedFundingReport(institutionReport);
    }

    print('\n✅ تم الانتهاء من التقارير الأساسية\n');
  }

  /// أمثلة على التقارير المفلترة
  static Future<void> _demonstrateFilteredReports(isar) async {
    print('🔍 أمثلة على التقارير المفلترة:');
    print('═══════════════════════════════════════════════');

    final allReport = await generateFundingReport(isar);

    // فلتر: الفئات ذات المخصصات الكبيرة
    print('\n💰 الفئات ذات المخصصات أكبر من 500,000:');
    final highBudgetReport = filterReport(
      allReport,
      minAllocated: 500000.0,
    );
    printDetailedFundingReport(highBudgetReport);

    // فلتر: الفئات ذات نسبة استغلال عالية
    print('\n📈 الفئات ذات نسبة استغلال أكبر من 30%:');
    final highUtilizationReport = filterReport(
      allReport,
      minUtilizationRate: 30.0,
    );
    printDetailedFundingReport(highUtilizationReport);

    // فلتر: الفئات التي لها تمويل فعلي فقط
    print('\n✅ الفئات التي لها تمويل فعلي فقط:');
    final activeFundingReport = filterReport(
      allReport,
      showOnlyWithFunding: true,
    );
    printDetailedFundingReport(activeFundingReport);

    print('\n✅ تم الانتهاء من التقارير المفلترة\n');
  }

  /// أمثلة على البحث والتحليل
  static Future<void> _demonstrateSearchAndAnalysis(isar) async {
    print('🔍 أمثلة على البحث والتحليل:');
    print('═══════════════════════════════════════════════');

    final allReport = await generateFundingReport(isar);

    // البحث عن فئة معينة
    print('\n🔎 البحث عن فئات تحتوي على كلمة "رواتب":');
    final salariesNode = findNodeInReport(allReport, 'رواتب');
    
    if (salariesNode != null) {
      print('✅ تم العثور على الفئة: ${salariesNode.categoryName}');
      print('   💰 المخصص: ${salariesNode.allocated.toStringAsFixed(2)}');
      print('   💸 المصروف: ${salariesNode.spent.toStringAsFixed(2)}');
      print('   📊 نسبة الاستغلال: ${salariesNode.utilizationRate.toStringAsFixed(1)}%');
      print('   👥 عدد الأطفال: ${salariesNode.childrenCount}');
      
      if (salariesNode.hasChildren) {
        print('   📂 الفئات الفرعية:');
        for (final child in salariesNode.children) {
          print('      - ${child.categoryName}: ${child.allocated.toStringAsFixed(2)}');
        }
      }
    } else {
      print('❌ لم يتم العثور على فئة تحتوي على "رواتب"');
    }

    // تحليل الأداء
    print('\n📈 تحليل الأداء:');
    _analyzePerformance(allReport);

    print('\n✅ تم الانتهاء من البحث والتحليل\n');
  }

  /// تحليل الأداء للتقرير
  static void _analyzePerformance(List<FundingReportNode> report) {
    if (report.isEmpty) {
      print('❌ لا توجد بيانات للتحليل');
      return;
    }

    // العثور على أعلى فئة في المخصصات
    FundingReportNode? highestAllocated;
    FundingReportNode? highestUtilization;
    FundingReportNode? lowestUtilization;

    for (final node in report) {
      _analyzeNodeRecursive(node, (current) {
        // أعلى مخصصات
        if (highestAllocated == null || current.allocated > highestAllocated!.allocated) {
          highestAllocated = current;
        }

        // أعلى نسبة استغلال (للفئات التي لها مخصصات)
        if (current.allocated > 0) {
          if (highestUtilization == null || current.utilizationRate > highestUtilization!.utilizationRate) {
            highestUtilization = current;
          }

          if (lowestUtilization == null || current.utilizationRate < lowestUtilization!.utilizationRate) {
            lowestUtilization = current;
          }
        }
      });
    }

    if (highestAllocated != null) {
      print('🏆 أعلى فئة في المخصصات:');
      print('   📊 ${highestAllocated!.categoryName}: ${highestAllocated!.allocated.toStringAsFixed(2)}');
    }

    if (highestUtilization != null) {
      print('🎯 أعلى نسبة استغلال:');
      print('   📈 ${highestUtilization!.categoryName}: ${highestUtilization!.utilizationRate.toStringAsFixed(1)}%');
    }

    if (lowestUtilization != null) {
      print('⚠️ أقل نسبة استغلال:');
      print('   📉 ${lowestUtilization!.categoryName}: ${lowestUtilization!.utilizationRate.toStringAsFixed(1)}%');
    }

    // إحصائيات عامة
    int totalNodes = 0;
    int nodesWithFunding = 0;
    double averageUtilization = 0;

    for (final node in report) {
      _analyzeNodeRecursive(node, (current) {
        totalNodes++;
        if (current.allocated > 0) {
          nodesWithFunding++;
          averageUtilization += current.utilizationRate;
        }
      });
    }

    if (nodesWithFunding > 0) {
      averageUtilization /= nodesWithFunding;
      print('📊 متوسط نسبة الاستغلال: ${averageUtilization.toStringAsFixed(1)}%');
    }

    print('📈 إجمالي الفئات: $totalNodes');
    print('💰 الفئات التي لها تمويل: $nodesWithFunding');
  }

  /// دالة مساعدة للتحليل التكراري
  static void _analyzeNodeRecursive(FundingReportNode node, Function(FundingReportNode) analyzer) {
    analyzer(node);
    for (final child in node.children) {
      _analyzeNodeRecursive(child, analyzer);
    }
  }

  /// أمثلة على تصدير JSON
  static Future<void> _demonstrateJsonExport(isar) async {
    print('📤 أمثلة على تصدير JSON:');
    print('═══════════════════════════════════════════════');

    final report = await generateFundingReport(isar);
    
    if (report.isNotEmpty) {
      final jsonData = exportReportToJson(report);
      
      print('📊 تم تصدير التقرير إلى JSON:');
      print('   📅 تاريخ التوليد: ${jsonData['reportGeneratedAt']}');
      print('   🌳 عدد الفئات الجذرية: ${jsonData['totalRootNodes']}');
      print('   📊 إجمالي العقد: ${jsonData['totalNodes']}');
      
      final summary = jsonData['summary'] as Map<String, dynamic>;
      print('   💰 إجمالي المخصص: ${summary['totalAllocated']}');
      print('   💸 إجمالي المصروف: ${summary['totalSpent']}');
      
      // طباعة عينة من البيانات المصدرة
      print('\n📋 عينة من البيانات المصدرة:');
      final categories = jsonData['categories'] as List;
      if (categories.isNotEmpty) {
        final firstCategory = categories.first as Map<String, dynamic>;
        print('   📂 الفئة الأولى: ${firstCategory['categoryName']}');
        print('   🆔 المعرف: ${firstCategory['categoryId']}');
        print('   📊 المستوى: ${firstCategory['level']}');
        print('   👥 عدد الأطفال: ${firstCategory['childrenCount']}');
      }
      
      print('✅ تم تصدير التقرير بنجاح');
    } else {
      print('❌ لا توجد بيانات للتصدير');
    }

    print('\n✅ تم الانتهاء من أمثلة التصدير\n');
  }

  /// مثال سريع للاستخدام الأساسي
  static Future<void> quickExample() async {
    print('⚡ مثال سريع على التقارير الهرمية:\n');

    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    // توليد تقرير أساسي
    print('📊 توليد التقرير الأساسي...');
    final report = await generateFundingReport(isar);

    if (report.isNotEmpty) {
      print('✅ تم توليد التقرير بنجاح!');
      print('🌳 عدد الفئات الجذرية: ${report.length}');
      
      // عرض الفئة الأولى كمثال
      final firstCategory = report.first;
      print('\n📂 مثال على فئة:');
      print('   📊 الاسم: ${firstCategory.categoryName}');
      print('   💰 المخصص: ${firstCategory.allocated.toStringAsFixed(2)}');
      print('   💸 المصروف: ${firstCategory.spent.toStringAsFixed(2)}');
      print('   📈 نسبة الاستغلال: ${firstCategory.utilizationRate.toStringAsFixed(1)}%');
      print('   👥 عدد الأطفال: ${firstCategory.childrenCount}');
      
      // عرض شجري مبسط
      print('\n🌳 الهيكل الشجري:');
      print(firstCategory.toTreeString());
      
    } else {
      print('❌ لا توجد بيانات للتقرير');
      print('💡 تلميح: قم بإنشاء بيانات تجريبية أولاً');
    }

    print('✅ تم تنفيذ المثال السريع بنجاح!');
  }

  /// مثال على مقارنة التقارير بين فترات مختلفة
  static Future<void> compareReportsExample() async {
    print('🔄 مثال على مقارنة التقارير:\n');

    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    final currentYear = DateTime.now().year;
    final lastYear = currentYear - 1;

    // تقرير السنة الحالية
    print('📊 تقرير السنة الحالية ($currentYear):');
    final currentReport = await generateFundingReport(isar, year: currentYear);
    
    // تقرير السنة الماضية
    print('\n📊 تقرير السنة الماضية ($lastYear):');
    final lastReport = await generateFundingReport(isar, year: lastYear);

    // مقارنة النتائج
    print('\n📈 مقارنة النتائج:');
    print('─────────────────────────────────────────');
    
    final currentTotal = currentReport.fold(0.0, (sum, node) => sum + node.allocated);
    final lastTotal = lastReport.fold(0.0, (sum, node) => sum + node.allocated);
    
    print('💰 إجمالي مخصصات $currentYear: ${currentTotal.toStringAsFixed(2)}');
    print('💰 إجمالي مخصصات $lastYear: ${lastTotal.toStringAsFixed(2)}');
    
    if (lastTotal > 0) {
      final growthRate = ((currentTotal - lastTotal) / lastTotal) * 100;
      print('📈 معدل النمو: ${growthRate.toStringAsFixed(1)}%');
    }

    print('✅ تم إنجاز مثال المقارنة');
  }
}*/
