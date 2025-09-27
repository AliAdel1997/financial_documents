import '../services/funding_service.dart';
import '../services/database_service.dart';
import '../models/funding_models.dart';

/// أمثلة عملية لاستخدام FundingService
class FundingServiceExamples {
  
  /// مثال شامل على استخدام جميع وظائف FundingService
  static Future<void> runCompleteExample() async {
    print('🚀 بدء تشغيل أمثلة FundingService...\n');

    // تهيئة قاعدة البيانات
    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    // إنشاء بيانات تجريبية
    await _setupTestData();
    
    // أمثلة على عمليات الحجز والصرف
    await _demonstrateReservationAndSpending(isar);
    
    // أمثلة على التقارير المفصلة
    await _demonstrateReporting(isar);
    
    // اختبار حالات الخطأ
    await _testErrorCases(isar);
    
    print('✅ تم الانتهاء من جميع أمثلة FundingService!');
  }

  /// إعداد بيانات تجريبية للاختبار
  static Future<void> _setupTestData() async {
    print('📋 إعداد البيانات التجريبية...');
    
    // إنشاء مؤسسة تجريبية
    final testInstitution = Institution()
      ..name = 'مستشفى الاختبار'
      ..address = 'بغداد - الكرادة'
      ..code = 'TEST001';

    final institutionId = await DatabaseService.addInstitution(testInstitution);
    print('✅ تم إنشاء مؤسسة تجريبية بالمعرف: $institutionId');

    // إنشاء باب تمويلي تجريبي
    final testCategory = FundingCategory()
      ..name = 'باب اختبار الخدمات'
      ..allocatedAmount = 500000.0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final categoryId = await DatabaseService.addFundingCategory(testCategory);
    print('✅ تم إنشاء باب تمويلي تجريبي بالمعرف: $categoryId');

    // إنشاء سجل تمويل تجريبي
    final testFunding = InstitutionFunding()
      ..institutionId = institutionId
      ..categoryId = categoryId
      ..allocatedAmount = 300000.0
      ..reservedAmount = 0.0
      ..spentAmount = 0.0
      ..year = DateTime.now().year
      ..month = DateTime.now().month
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final fundingId = await DatabaseService.addInstitutionFunding(testFunding);
    print('✅ تم إنشاء سجل تمويل تجريبي بالمعرف: $fundingId');
    
    print('✅ تم الانتهاء من إعداد البيانات التجريبية\n');
  }

  /// أمثلة على عمليات الحجز والصرف
  static Future<void> _demonstrateReservationAndSpending(isar) async {
    print('💰 أمثلة على عمليات الحجز والصرف:');
    print('═══════════════════════════════════════════════');

    // الحصول على أول سجل تمويل للاختبار
    final fundings = await DatabaseService.getAllInstitutionFunding();
    if (fundings.isEmpty) {
      print('❌ لا توجد سجلات تمويل للاختبار');
      return;
    }

    final testFundingId = fundings.last.id; // استخدام آخر سجل تم إنشاؤه
    
    print('\n📊 حالة التمويل قبل العمليات:');
    await FundingService.printFundingReport(isar, testFundingId);

    // 1. حجز مبلغ 150,000
    print('\n🔒 حجز مبلغ 150,000:');
    final reserveSuccess1 = await FundingService.reserveFunds(
      isar,
      testFundingId,
      150000.0,
      description: 'حجز لمشتريات طبية',
    );
    
    if (reserveSuccess1) {
      print('✅ تم حجز المبلغ الأول بنجاح');
    }

    // 2. حجز مبلغ إضافي 100,000
    print('\n🔒 حجز مبلغ إضافي 100,000:');
    final reserveSuccess2 = await FundingService.reserveFunds(
      isar,
      testFundingId,
      100000.0,
      description: 'حجز لصيانة الأجهزة',
    );
    
    if (reserveSuccess2) {
      print('✅ تم حجز المبلغ الثاني بنجاح');
    }

    print('\n📊 حالة التمويل بعد الحجز:');
    await FundingService.printFundingReport(isar, testFundingId);

    // 3. صرف مبلغ 80,000 من المحجوز الأول
    print('\n💸 صرف مبلغ 80,000 من المحجوز:');
    final spendSuccess1 = await FundingService.validateAndSpend(
      isar,
      testFundingId,
      80000.0,
      description: 'شراء أدوية ومستلزمات',
    );
    
    if (spendSuccess1) {
      print('✅ تم صرف المبلغ الأول بنجاح');
    }

    // 4. صرف مبلغ إضافي 120,000
    print('\n💸 صرف مبلغ إضافي 120,000:');
    final spendSuccess2 = await FundingService.validateAndSpend(
      isar,
      testFundingId,
      120000.0,
      description: 'دفع فواتير الصيانة',
    );
    
    if (spendSuccess2) {
      print('✅ تم صرف المبلغ الثاني بنجاح');
    }

    print('\n📊 حالة التمويل بعد الصرف:');
    await FundingService.printFundingReport(isar, testFundingId);

    // 5. إلغاء حجز جزء من المبلغ المحجوز
    print('\n🔓 إلغاء حجز مبلغ 30,000:');
    final unreserveSuccess = await FundingService.unreserveFunds(
      isar,
      testFundingId,
      30000.0,
      description: 'إلغاء حجز - تغيير في الخطة',
    );
    
    if (unreserveSuccess) {
      print('✅ تم إلغاء حجز المبلغ بنجاح');
    }

    print('\n📊 حالة التمويل النهائية:');
    await FundingService.printFundingReport(isar, testFundingId);

    print('\n✅ تم الانتهاء من أمثلة الحجز والصرف\n');
  }

  /// أمثلة على التقارير المفصلة
  static Future<void> _demonstrateReporting(isar) async {
    print('📊 أمثلة على التقارير والتحليل:');
    print('═══════════════════════════════════════════════');

    final fundings = await DatabaseService.getAllInstitutionFunding();
    
    for (final funding in fundings) {
      print('\n📋 تفاصيل التمويل ${funding.id}:');
      
      // جلب التفاصيل المحسوبة
      final details = await FundingService.getFundingDetails(isar, funding.id);
      
      if (details != null) {
        print('🏥 المؤسسة: ${details.institutionName}');
        print('💰 الباب: ${details.categoryName}');
        print('💵 المخصص: ${details.funding.allocatedAmount}');
        print('🔒 المحجوز: ${details.funding.reservedAmount}');
        print('💸 المصروف: ${details.funding.spentAmount}');
        print('🟢 المتاح: ${details.availableAmount}');
        print('📊 نسبة الاستغلال: ${details.utilizationRate.toStringAsFixed(1)}%');
        print('🔒 نسبة الحجز: ${details.reservationRate.toStringAsFixed(1)}%');
        
        // اختبار إمكانية العمليات
        final canSpend50k = await FundingService.canSpend(isar, funding.id, 50000.0);
        final canReserve50k = await FundingService.canReserve(isar, funding.id, 50000.0);
        
        print('💸 يمكن صرف 50,000: ${canSpend50k ? "نعم" : "لا"}');
        print('🔒 يمكن حجز 50,000: ${canReserve50k ? "نعم" : "لا"}');
      }
      
      print('─' * 50);
    }

    print('\n✅ تم الانتهاء من أمثلة التقارير\n');
  }

  /// اختبار حالات الخطأ
  static Future<void> _testErrorCases(isar) async {
    print('🧪 اختبار حالات الخطأ:');
    print('═══════════════════════════════════════════════');

    final fundings = await DatabaseService.getAllInstitutionFunding();
    if (fundings.isEmpty) return;
    
    final testFundingId = fundings.first.id;

    // 1. محاولة صرف مبلغ أكبر من المحجوز
    print('\n❌ محاولة صرف مبلغ أكبر من المحجوز:');
    await FundingService.validateAndSpend(
      isar,
      testFundingId,
      999999.0, // مبلغ كبير جداً
      description: 'محاولة صرف مبلغ مفرط',
    );

    // 2. محاولة حجز مبلغ أكبر من المتاح
    print('\n❌ محاولة حجز مبلغ أكبر من المتاح:');
    await FundingService.reserveFunds(
      isar,
      testFundingId,
      999999.0, // مبلغ كبير جداً
      description: 'محاولة حجز مبلغ مفرط',
    );

    // 3. محاولة العمل مع سجل غير موجود
    print('\n❌ محاولة العمل مع سجل غير موجود:');
    await FundingService.validateAndSpend(
      isar,
      99999, // معرف غير موجود
      1000.0,
      description: 'محاولة صرف من سجل غير موجود',
    );

    // 4. محاولة صرف/حجز مبلغ سالب أو صفر
    print('\n❌ محاولة صرف مبلغ سالب:');
    await FundingService.validateAndSpend(
      isar,
      testFundingId,
      -1000.0, // مبلغ سالب
      description: 'محاولة صرف مبلغ سالب',
    );

    print('\n❌ محاولة حجز مبلغ صفر:');
    await FundingService.reserveFunds(
      isar,
      testFundingId,
      0.0, // مبلغ صفر
      description: 'محاولة حجز مبلغ صفر',
    );

    // 5. محاولة إلغاء حجز مبلغ أكبر من المحجوز
    print('\n❌ محاولة إلغاء حجز مبلغ أكبر من المحجوز:');
    await FundingService.unreserveFunds(
      isar,
      testFundingId,
      999999.0, // مبلغ كبير جداً
      description: 'محاولة إلغاء حجز مبلغ مفرط',
    );

    print('\n✅ تم الانتهاء من اختبار حالات الخطأ\n');
  }

  /// مثال سريع لاستخدام أساسي
  static Future<void> quickExample() async {
    print('⚡ مثال سريع على FundingService:\n');

    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    // البحث عن سجل تمويل موجود
    final fundings = await DatabaseService.getAllInstitutionFunding();
    
    if (fundings.isEmpty) {
      print('❌ لا توجد سجلات تمويل. قم بإنشاء البيانات التجريبية أولاً.');
      return;
    }

    final fundingId = fundings.first.id;

    print('📊 التقرير الأولي:');
    await FundingService.printFundingReport(isar, fundingId);

    // حجز مبلغ
    print('🔒 حجز مبلغ 50,000:');
    final reserved = await FundingService.reserveFunds(
      isar,
      fundingId,
      50000.0,
      description: 'حجز تجريبي سريع',
    );

    if (reserved) {
      // صرف من المحجوز
      print('\n💸 صرف مبلغ 30,000:');
      await FundingService.validateAndSpend(
        isar,
        fundingId,
        30000.0,
        description: 'صرف تجريبي سريع',
      );

      print('\n📊 التقرير النهائي:');
      await FundingService.printFundingReport(isar, fundingId);
    }

    print('✅ تم تنفيذ المثال السريع بنجاح!');
  }

  /// مثال على سيناريو واقعي لمستشفى
  static Future<void> hospitalScenarioExample() async {
    print('🏥 سيناريو واقعي: إدارة ميزانية مستشفى\n');

    await DatabaseService.initialize();
    final isar = DatabaseService.isar;

    // إنشاء سيناريو مستشفى واقعي
    await _createHospitalScenario();

    final fundings = await DatabaseService.getAllInstitutionFunding();
    if (fundings.isEmpty) return;

    final fundingId = fundings.last.id;

    print('🏥 سيناريو: مستشفى يحتاج لشراء أجهزة طبية وأدوية');
    print('─────────────────────────────────────────────────────────────');

    // الخطوة 1: حجز للأجهزة الطبية
    print('\n📱 الخطوة 1: حجز ميزانية للأجهزة الطبية');
    await FundingService.reserveFunds(
      isar,
      fundingId,
      200000.0,
      description: 'حجز لشراء جهاز أشعة مقطعية',
    );

    // الخطوة 2: حجز للأدوية
    print('\n💊 الخطوة 2: حجز ميزانية للأدوية');
    await FundingService.reserveFunds(
      isar,
      fundingId,
      100000.0,
      description: 'حجز لشراء أدوية الطوارئ',
    );

    // الخطوة 3: صرف جزئي للأجهزة (دفعة أولى)
    print('\n💰 الخطوة 3: دفع الدفعة الأولى للأجهزة');
    await FundingService.validateAndSpend(
      isar,
      fundingId,
      150000.0,
      description: 'الدفعة الأولى لجهاز الأشعة المقطعية',
    );

    // الخطوة 4: صرف للأدوية
    print('\n💉 الخطوة 4: شراء الأدوية');
    await FundingService.validateAndSpend(
      isar,
      fundingId,
      80000.0,
      description: 'شراء أدوية الطوارئ والعناية المركزة',
    );

    // الخطوة 5: إلغاء حجز جزء من ميزانية الأجهزة
    print('\n🔄 الخطوة 5: تعديل الحجز (توفير في السعر)');
    await FundingService.unreserveFunds(
      isar,
      fundingId,
      30000.0,
      description: 'توفير في سعر الجهاز - إلغاء جزء من الحجز',
    );

    // الخطوة 6: صرف المبلغ المتبقي للأجهزة
    print('\n✅ الخطوة 6: دفع المبلغ المتبقي للأجهزة');
    await FundingService.validateAndSpend(
      isar,
      fundingId,
      20000.0,
      description: 'المبلغ المتبقي لجهاز الأشعة المقطعية',
    );

    print('\n📊 التقرير النهائي للسيناريو:');
    await FundingService.printFundingReport(isar, fundingId);

    print('\n🎉 تم إنجاز السيناريو بنجاح! المستشفى حصل على:');
    print('   📱 جهاز أشعة مقطعية جديد');
    print('   💊 مخزون أدوية الطوارئ');
    print('   💰 توفير 30,000 في الميزانية');
  }

  /// إنشاء سيناريو مستشفى واقعي
  static Future<void> _createHospitalScenario() async {
    final hospital = Institution()
      ..name = 'مستشفى الأمل التخصصي'
      ..address = 'بغداد - المنصور'
      ..code = 'HOPE001';

    final hospitalId = await DatabaseService.addInstitution(hospital);

    final medicalEquipment = FundingCategory()
      ..name = 'الأجهزة والمعدات الطبية'
      ..allocatedAmount = 800000.0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final categoryId = await DatabaseService.addFundingCategory(medicalEquipment);

    final funding = InstitutionFunding()
      ..institutionId = hospitalId
      ..categoryId = categoryId
      ..allocatedAmount = 400000.0
      ..reservedAmount = 0.0
      ..spentAmount = 0.0
      ..year = DateTime.now().year
      ..month = DateTime.now().month
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await DatabaseService.addInstitutionFunding(funding);
    print('✅ تم إعداد سيناريو المستشفى');
  }
}