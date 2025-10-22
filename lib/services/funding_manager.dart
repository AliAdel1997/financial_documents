import '../models/funding_models.dart';
import 'database_service.dart';

/// مدير التمويل - كلاس متقدم لإدارة العمليات المالية والفئات
class FundingManager {
  /// إضافة باب تمويلي جديد (رئيسي أو فرعي)
  ///
  /// [name] اسم الباب الجديد
  /// [description] وصف الباب
  /// [parentId] معرف الباب الأعلى (null للباب الرئيسي)
  ///
  /// يرجع معرف الباب الجديد أو null في حالة الفشل
  static Future<int?> addFundingCategory(
    String name, {
    String? description,
    int? parentId,
  }) async {
    try {
      // التحقق من صحة البيانات
      if (name.trim().isEmpty) {
        throw ArgumentError('اسم الباب لا يمكن أن يكون فارغاً');
      }

      // التحقق من وجود الباب الأعلى إذا تم تحديده
      if (parentId != null) {
        final parentCategory = await DatabaseService.getFundingCategoryById(
          parentId,
        );
        if (parentCategory == null) {
          throw ArgumentError('الباب الأعلى غير موجود (ID: $parentId)');
        }
      }

      // التحقق من عدم تكرار الاسم في نفس المستوى
      final existingCategories = parentId == null
          ? await DatabaseService.getMainFundingCategories()
          : await DatabaseService.getSubFundingCategories(parentId);

      final nameExists = existingCategories.any(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );

      if (nameExists) {
        throw ArgumentError('يوجد باب بنفس الاسم في هذا المستوى');
      }

      // إنشاء الباب الجديد
      final newCategory = FundingCategory()
        ..name = name.trim()
        ..description = description?.trim()
        ..parentId = parentId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      return await DatabaseService.addFundingCategory(newCategory);
    } catch (e) {
      print('خطأ في إضافة الباب التمويلي: $e');
      return null;
    }
  }

  /// تحديث باب تمويلي موجود
  static Future<bool> updateFundingCategory(
    int categoryId,
    String name, {
    String? description,
  }) async {
    try {
      final category = await DatabaseService.getFundingCategoryById(categoryId);
      if (category == null) {
        throw ArgumentError('الباب غير موجود');
      }

      // التحقق من عدم تكرار الاسم في نفس المستوى
      final existingCategories = category.parentId == null
          ? await DatabaseService.getMainFundingCategories()
          : await DatabaseService.getSubFundingCategories(category.parentId!);

      final nameExists = existingCategories.any(
        (cat) =>
            cat.id != categoryId &&
            cat.name.toLowerCase() == name.toLowerCase(),
      );

      if (nameExists) {
        throw ArgumentError('يوجد باب بنفس الاسم في هذا المستوى');
      }

      // تحديث البيانات
      final updatedCategory = FundingCategory()
        ..id = category.id
        ..name = name.trim()
        ..description = description?.trim()
        ..parentId = category.parentId
        ..createdAt = category.createdAt
        ..updatedAt = DateTime.now();

      await DatabaseService.updateFundingCategory(updatedCategory);
      return true;
    } catch (e) {
      print('خطأ في تحديث الباب التمويلي: $e');
      return false;
    }
  }

  /// حذف باب تمويلي
  static Future<bool> deleteFundingCategory(int categoryId) async {
    try {
      // التحقق من وجود أبواب فرعية
      final subCategories = await DatabaseService.getSubFundingCategories(
        categoryId,
      );
      if (subCategories.isNotEmpty) {
        throw ArgumentError('لا يمكن حذف الباب لوجود أبواب فرعية تابعة له');
      }

      // التحقق من وجود تمويلات مرتبطة
      final linkedFundings =
          await DatabaseService.getInstitutionFundingByCategory(categoryId);
      if (linkedFundings.isNotEmpty) {
        throw ArgumentError('لا يمكن حذف الباب لوجود تمويلات مرتبطة به');
      }

      await DatabaseService.deleteFundingCategory(categoryId);
      return true;
    } catch (e) {
      print('خطأ في حذف الباب التمويلي: $e');
      return false;
    }
  }

  /// الحصول على الهيكل الهرمي للأبواب التمويلية
  static Future<List<CategoryHierarchy>> getCategoryHierarchy() async {
    final mainCategories = await DatabaseService.getMainFundingCategories();
    final List<CategoryHierarchy> hierarchy = [];

    for (final category in mainCategories) {
      final subCategories = await DatabaseService.getSubFundingCategories(
        category.id,
      );

      hierarchy.add(
        CategoryHierarchy(category: category, subCategories: subCategories),
      );
    }

    return hierarchy;
  }

  /// إنشاء تخصيص مالي جديد
  static Future<bool> createFundingAllocation({
    required int institutionId,
    required int categoryId,
    required double amount,
    required String fundingType,
    required int year,
    int? month,
    String? description,
  }) async {
    try {
      print('محاولة إنشاء تخصيص مالي...');
      print('institutionId: $institutionId');
      print('categoryId: $categoryId');
      print('amount: $amount');
      print('fundingType: $fundingType');
      print('year: $year');
      print('month: $month');

      if (amount <= 0) {
        throw ArgumentError('المبلغ يجب أن يكون أكبر من صفر');
      }

      // التحقق من وجود المؤسسة والفئة
      print('التحقق من وجود المؤسسة...');
      final institution = await DatabaseService.getInstitutionById(
        institutionId,
      );
      if (institution == null) {
        print('المؤسسة غير موجودة: $institutionId');
        throw ArgumentError('المؤسسة غير موجودة');
      }
      print('المؤسسة موجودة: ${institution.name}');

      print('التحقق من وجود الفئة...');
      final category = await DatabaseService.getFundingCategoryById(categoryId);
      if (category == null) {
        print('الباب التمويلي غير موجود: $categoryId');
        throw ArgumentError('الباب التمويلي غير موجود');
      }
      print('الباب التمويلي موجود: ${category.name}');

      // إنشاء التخصيص الجديد
      print('إنشاء كائن التخصيص...');
      final funding = InstitutionFunding();
      funding.institutionId = institutionId;
      funding.categoryId = categoryId;
      funding.allocatedAmount = amount;
      funding.reservedAmount = 0.0;
      funding.spentAmount = 0.0;
      funding.fundingType = fundingType;
      funding.year = year;
      funding.month = month;
      funding.createdAt = DateTime.now();
      funding.updatedAt = DateTime.now();

      print('حفظ التخصيص في قاعدة البيانات...');
      final id = await DatabaseService.addInstitutionFunding(funding);
      print('تم إنشاء التخصيص بنجاح بالمعرف: $id');
      return true;
    } catch (e) {
      print('خطأ في إنشاء التخصيص المالي: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// الحصول على إجمالي التخصيصات لفئة معينة
  static Future<double> getTotalAllocatedForCategory(
    int categoryId, {
    int? year,
  }) async {
    final fundings = await DatabaseService.getInstitutionFundingByCategory(
      categoryId,
    );

    double total = 0.0;
    for (final funding in fundings) {
      if (year == null || funding.year == year) {
        total += funding.allocatedAmount;
      }
    }

    return total;
  }

  /// الحصول على إجمالي المصروف لفئة معينة
  static Future<double> getTotalSpentForCategory(
    int categoryId, {
    int? year,
  }) async {
    final fundings = await DatabaseService.getInstitutionFundingByCategory(
      categoryId,
    );

    double total = 0.0;
    for (final funding in fundings) {
      if (year == null || funding.year == year) {
        total += funding.spentAmount;
      }
    }

    return total;
  }

  /// الحصول على المتبقي لفئة معينة
  static Future<double> getRemainingForCategory(
    int categoryId, {
    int? year,
  }) async {
    final allocated = await getTotalAllocatedForCategory(
      categoryId,
      year: year,
    );
    final spent = await getTotalSpentForCategory(categoryId, year: year);
    return allocated - spent;
  }

  /// إنشاء تقرير ملخص للفئة
  static Future<CategorySummary> getCategorySummary(
    int categoryId, {
    int? year,
  }) async {
    final category = await DatabaseService.getFundingCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('الفئة غير موجودة');
    }

    final totalAllocated = await getTotalAllocatedForCategory(
      categoryId,
      year: year,
    );
    final totalSpent = await getTotalSpentForCategory(categoryId, year: year);
    final fundings = await DatabaseService.getInstitutionFundingByCategory(
      categoryId,
    );

    return CategorySummary(
      category: category,
      totalAllocated: totalAllocated,
      totalSpent: totalSpent,
      remainingAmount: totalAllocated - totalSpent,
      fundingCount: fundings.length,
      fundings: fundings,
    );
  }
}

/// كلاس لتمثيل الهيكل الهرمي للفئات
class CategoryHierarchy {
  final FundingCategory category;
  final List<FundingCategory> subCategories;

  CategoryHierarchy({required this.category, required this.subCategories});
}

/// كلاس لتمثيل ملخص الفئة
class CategorySummary {
  final FundingCategory category;
  final double totalAllocated;
  final double totalSpent;
  final double remainingAmount;
  final int fundingCount;
  final List<InstitutionFunding> fundings;

  CategorySummary({
    required this.category,
    required this.totalAllocated,
    required this.totalSpent,
    required this.remainingAmount,
    required this.fundingCount,
    required this.fundings,
  });

  double get spentPercentage =>
      totalAllocated > 0 ? (totalSpent / totalAllocated) * 100 : 0;

  double get remainingPercentage =>
      totalAllocated > 0 ? (remainingAmount / totalAllocated) * 100 : 0;
}
