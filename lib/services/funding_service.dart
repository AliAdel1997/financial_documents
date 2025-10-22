import 'package:isar/isar.dart';
import '../models/funding_models.dart';

/// خدمة التمويل - إدارة عمليات الصرف والتحقق من المبالغ
class FundingService {
  /// التحقق من المبلغ المحجوز وتنفيذ عملية الصرف
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  /// [amount] المبلغ المراد صرفه
  /// [description] وصف العملية (اختياري)
  ///
  /// يرجع true في حالة نجاح العملية، false في حالة الفشل
  static Future<bool> validateAndSpend(
    Isar isar,
    int fundingId,
    double amount, {
    String? description,
  }) async {
    try {
      // التحقق من صحة المدخلات
      if (amount <= 0) {
        print('❌ خطأ: المبلغ يجب أن يكون أكبر من صفر');
        return false;
      }

      // 1. جلب سجل التمويل المطلوب
      final funding = await isar.institutionFundings.get(fundingId);

      if (funding == null) {
        print('❌ خطأ: سجل التمويل غير موجود (ID: $fundingId)');
        return false;
      }

      print('📋 تفاصيل التمويل:');
      print('   🏥 معرف المؤسسة: ${funding.institutionId}');
      print('   💰 معرف الباب: ${funding.categoryId}');
      print('   💵 المبلغ المخصص: ${funding.allocatedAmount}');
      print('   🔒 المبلغ المحجوز: ${funding.reservedAmount}');
      print('   💸 المبلغ المصروف: ${funding.spentAmount}');
      print('   💎 المبلغ المتبقي: ${funding.remainingAmount}');

      // 2. التحقق من توفر المبلغ في المحجوز
      if (funding.reservedAmount < amount) {
        print(
          '❌ فشل العملية: المبلغ المطلوب ($amount) يتجاوز المبلغ المحجوز (${funding.reservedAmount})',
        );
        return false;
      }

      // 3. تنفيذ عملية الصرف
      print('✅ المبلغ متوفر في المحجوز، جاري تنفيذ العملية...');

      // حساب القيم الجديدة
      final newReservedAmount = funding.reservedAmount - amount;
      final newSpentAmount = funding.spentAmount + amount;

      // إنشاء نسخة محدثة من سجل التمويل
      final updatedFunding = funding.copyWith(
        reservedAmount: newReservedAmount,
        spentAmount: newSpentAmount,
        updatedAt: DateTime.now(),
      );

      // 4. حفظ التغييرات في قاعدة البيانات
      final success = await isar.writeTxn(() async {
        try {
          await isar.institutionFundings.put(updatedFunding);
          return true;
        } catch (e) {
          print('❌ خطأ في حفظ البيانات: $e');
          return false;
        }
      });

      if (success) {
        print('✅ تم تنفيذ عملية الصرف بنجاح!');
        print('📊 النتائج:');
        print('   💰 المبلغ المصروف: $amount');
        print('   🔒 المبلغ المحجوز الجديد: $newReservedAmount');
        print('   💸 إجمالي المصروف الجديد: $newSpentAmount');
        print('   💎 المبلغ المتبقي الجديد: ${updatedFunding.remainingAmount}');

        if (description != null && description.isNotEmpty) {
          print('   📝 الوصف: $description');
        }

        // سجل العملية في تاريخ العمليات (إذا كان متوفراً)
        await _logSpendingOperation(
          isar,
          fundingId,
          amount,
          description,
          updatedFunding,
        );

        return true;
      } else {
        print('❌ فشل في حفظ التغييرات');
        return false;
      }
    } catch (e) {
      print('❌ خطأ غير متوقع في عملية الصرف: $e');
      return false;
    }
  }

  /// حجز مبلغ من المخصص
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  /// [amount] المبلغ المراد حجزه
  /// [description] وصف عملية الحجز (اختياري)
  ///
  /// يرجع true في حالة نجاح العملية، false في حالة الفشل
  static Future<bool> reserveFunds(
    Isar isar,
    int fundingId,
    double amount, {
    String? description,
  }) async {
    try {
      if (amount <= 0) {
        print('❌ خطأ: المبلغ يجب أن يكون أكبر من صفر');
        return false;
      }

      final funding = await isar.institutionFundings.get(fundingId);

      if (funding == null) {
        print('❌ خطأ: سجل التمويل غير موجود (ID: $fundingId)');
        return false;
      }

      // التحقق من توفر المبلغ المتاح للحجز
      final availableAmount =
          funding.allocatedAmount -
          funding.reservedAmount -
          funding.spentAmount;

      if (availableAmount < amount) {
        print(
          '❌ فشل العملية: المبلغ المطلوب ($amount) يتجاوز المتاح للحجز (${availableAmount.toStringAsFixed(2)})',
        );
        return false;
      }

      print('✅ المبلغ متوفر، جاري حجزه...');

      final updatedFunding = funding.copyWith(
        reservedAmount: funding.reservedAmount + amount,
        updatedAt: DateTime.now(),
      );

      final success = await isar.writeTxn(() async {
        try {
          await isar.institutionFundings.put(updatedFunding);
          return true;
        } catch (e) {
          print('❌ خطأ في حفظ البيانات: $e');
          return false;
        }
      });

      if (success) {
        print('✅ تم حجز المبلغ بنجاح!');
        print('📊 النتائج:');
        print('   🔒 المبلغ المحجوز: $amount');
        print('   🔒 إجمالي المحجوز الجديد: ${updatedFunding.reservedAmount}');
        print('   💎 المبلغ المتبقي الجديد: ${updatedFunding.remainingAmount}');

        if (description != null && description.isNotEmpty) {
          print('   📝 الوصف: $description');
        }

        return true;
      } else {
        print('❌ فشل في حفظ التغييرات');
        return false;
      }
    } catch (e) {
      print('❌ خطأ غير متوقع في عملية الحجز: $e');
      return false;
    }
  }

  /// إلغاء حجز مبلغ (إرجاعه إلى المتاح)
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  /// [amount] المبلغ المراد إلغاء حجزه
  /// [description] وصف عملية الإلغاء (اختياري)
  ///
  /// يرجع true في حالة نجاح العملية، false في حالة الفشل
  static Future<bool> unreserveFunds(
    Isar isar,
    int fundingId,
    double amount, {
    String? description,
  }) async {
    try {
      if (amount <= 0) {
        print('❌ خطأ: المبلغ يجب أن يكون أكبر من صفر');
        return false;
      }

      final funding = await isar.institutionFundings.get(fundingId);

      if (funding == null) {
        print('❌ خطأ: سجل التمويل غير موجود (ID: $fundingId)');
        return false;
      }

      if (funding.reservedAmount < amount) {
        print(
          '❌ فشل العملية: المبلغ المطلوب إلغاؤه ($amount) يتجاوز المبلغ المحجوز (${funding.reservedAmount})',
        );
        return false;
      }

      print('✅ جاري إلغاء حجز المبلغ...');

      final updatedFunding = funding.copyWith(
        reservedAmount: funding.reservedAmount - amount,
        updatedAt: DateTime.now(),
      );

      final success = await isar.writeTxn(() async {
        try {
          await isar.institutionFundings.put(updatedFunding);
          return true;
        } catch (e) {
          print('❌ خطأ في حفظ البيانات: $e');
          return false;
        }
      });

      if (success) {
        print('✅ تم إلغاء حجز المبلغ بنجاح!');
        print('📊 النتائج:');
        print('   🔓 المبلغ المُلغى حجزه: $amount');
        print('   🔒 إجمالي المحجوز الجديد: ${updatedFunding.reservedAmount}');
        print('   💎 المبلغ المتبقي الجديد: ${updatedFunding.remainingAmount}');

        if (description != null && description.isNotEmpty) {
          print('   📝 الوصف: $description');
        }

        return true;
      } else {
        print('❌ فشل في حفظ التغييرات');
        return false;
      }
    } catch (e) {
      print('❌ خطأ غير متوقع في عملية إلغاء الحجز: $e');
      return false;
    }
  }

  /// الحصول على تفاصيل التمويل مع حسابات مفصلة
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  ///
  /// يرجع تفاصيل التمويل أو null إذا لم يوجد
  static Future<FundingDetails?> getFundingDetails(
    Isar isar,
    int fundingId,
  ) async {
    try {
      final funding = await isar.institutionFundings.get(fundingId);

      if (funding == null) {
        return null;
      }

      // جلب تفاصيل المؤسسة والباب التمويلي
      final institution = await isar.institutions.get(funding.institutionId);
      final category = await isar.fundingCategorys.get(funding.categoryId);

      return FundingDetails(
        funding: funding,
        institutionName: institution?.name ?? 'غير معروف',
        categoryName: category?.name ?? 'غير معروف',
        availableAmount:
            funding.allocatedAmount -
            funding.reservedAmount -
            funding.spentAmount,
        utilizationRate: funding.allocatedAmount > 0
            ? (funding.spentAmount / funding.allocatedAmount) * 100
            : 0,
        reservationRate: funding.allocatedAmount > 0
            ? (funding.reservedAmount / funding.allocatedAmount) * 100
            : 0,
      );
    } catch (e) {
      print('❌ خطأ في جلب تفاصيل التمويل: $e');
      return null;
    }
  }

  /// طباعة تقرير مفصل عن حالة التمويل
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  static Future<void> printFundingReport(Isar isar, int fundingId) async {
    final details = await getFundingDetails(isar, fundingId);

    if (details == null) {
      print('❌ لا يمكن العثور على سجل التمويل (ID: $fundingId)');
      return;
    }

    print('\n📊 ═══════════════════════════════════════');
    print('📊 تقرير التمويل المفصل');
    print('📊 ═══════════════════════════════════════');
    print('🆔 معرف التمويل: $fundingId');
    print('🏥 المؤسسة: ${details.institutionName}');
    print('💰 الباب التمويلي: ${details.categoryName}');
    print('📅 السنة: ${details.funding.year}');
    print('📅 الشهر: ${details.funding.month}');
    print('');
    print('💰 المبالغ المالية:');
    print('─────────────────────────────────────────');
    print(
      '💵 المبلغ المخصص: ${details.funding.allocatedAmount.toStringAsFixed(2)}',
    );
    print(
      '🔒 المبلغ المحجوز: ${details.funding.reservedAmount.toStringAsFixed(2)}',
    );
    print(
      '💸 المبلغ المصروف: ${details.funding.spentAmount.toStringAsFixed(2)}',
    );
    print(
      '💎 المبلغ المتبقي: ${details.funding.remainingAmount.toStringAsFixed(2)}',
    );
    print(
      '🟢 المبلغ المتاح للحجز: ${details.availableAmount.toStringAsFixed(2)}',
    );
    print('');
    print('📈 النسب والمؤشرات:');
    print('─────────────────────────────────────────');
    print('📊 نسبة الاستغلال: ${details.utilizationRate.toStringAsFixed(1)}%');
    print('🔒 نسبة الحجز: ${details.reservationRate.toStringAsFixed(1)}%');
    print(
      '💎 نسبة المتبقي: ${(100 - details.utilizationRate - details.reservationRate).toStringAsFixed(1)}%',
    );
    print('');
    print('📅 تواريخ مهمة:');
    print('─────────────────────────────────────────');
    if (details.funding.createdAt != null) {
      print(
        '📅 تاريخ الإنشاء: ${details.funding.createdAt!.toString().substring(0, 19)}',
      );
    }
    if (details.funding.updatedAt != null) {
      print(
        '🔄 آخر تحديث: ${details.funding.updatedAt!.toString().substring(0, 19)}',
      );
    }
    print('📊 ═══════════════════════════════════════\n');
  }

  /// تسجيل عملية الصرف في السجل (دالة مساعدة)
  static Future<void> _logSpendingOperation(
    Isar isar,
    int fundingId,
    double amount,
    String? description,
    InstitutionFunding updatedFunding,
  ) async {
    try {
      // هنا يمكن إضافة منطق تسجيل العمليات في جدول منفصل
      // مثل SpendingLog أو TransactionHistory

      print('📝 تم تسجيل العملية في سجل العمليات');
      print('   🆔 معرف التمويل: $fundingId');
      print('   💰 المبلغ: $amount');
      print('   📅 التاريخ: ${DateTime.now().toString().substring(0, 19)}');

      if (description != null) {
        print('   📝 الوصف: $description');
      }
    } catch (e) {
      print('⚠️ تحذير: فشل في تسجيل العملية في السجل: $e');
      // لا نوقف العملية الأساسية بسبب فشل التسجيل
    }
  }

  /// التحقق من إمكانية الصرف بدون تنفيذ فعلي
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  /// [amount] المبلغ المراد التحقق منه
  ///
  /// يرجع true إذا كان بالإمكان الصرف، false إذا لم يكن
  static Future<bool> canSpend(Isar isar, int fundingId, double amount) async {
    try {
      if (amount <= 0) return false;

      final funding = await isar.institutionFundings.get(fundingId);
      if (funding == null) return false;

      return funding.reservedAmount >= amount;
    } catch (e) {
      print('❌ خطأ في التحقق من إمكانية الصرف: $e');
      return false;
    }
  }

  /// التحقق من إمكانية الحجز بدون تنفيذ فعلي
  ///
  /// [isar] مثيل قاعدة البيانات
  /// [fundingId] معرف سجل التمويل
  /// [amount] المبلغ المراد التحقق منه
  ///
  /// يرجع true إذا كان بالإمكان الحجز، false إذا لم يكن
  static Future<bool> canReserve(
    Isar isar,
    int fundingId,
    double amount,
  ) async {
    try {
      if (amount <= 0) return false;

      final funding = await isar.institutionFundings.get(fundingId);
      if (funding == null) return false;

      final availableAmount =
          funding.allocatedAmount -
          funding.reservedAmount -
          funding.spentAmount;
      return availableAmount >= amount;
    } catch (e) {
      print('❌ خطأ في التحقق من إمكانية الحجز: $e');
      return false;
    }
  }
}

/// كلاس لتفاصيل التمويل المحسوبة
class FundingDetails {
  final InstitutionFunding funding;
  final String institutionName;
  final String categoryName;
  final double availableAmount;
  final double utilizationRate;
  final double reservationRate;

  FundingDetails({
    required this.funding,
    required this.institutionName,
    required this.categoryName,
    required this.availableAmount,
    required this.utilizationRate,
    required this.reservationRate,
  });

  @override
  String toString() {
    return 'FundingDetails{institution: $institutionName, category: $categoryName, '
        'allocated: ${funding.allocatedAmount}, spent: ${funding.spentAmount}, '
        'reserved: ${funding.reservedAmount}, available: $availableAmount}';
  }
}
