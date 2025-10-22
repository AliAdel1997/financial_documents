import 'package:isar/isar.dart';

import '../models/active_period.dart';
import '../services/database_service.dart';

class ActivePeriodService {
  /// الحصول على الفترة النشطة الحالية
  static Future<ActivePeriod?> getCurrentActivePeriod() async {
    return await DatabaseService.isar.activePeriods
        .filter()
        .isActiveEqualTo(true)
        .findFirst();
  }

  /// فتح فترة مالية جديدة
  static Future<bool> openNewPeriod(
    int year,
    int month,
    String openedBy, {
    String? notes,
  }) async {
    try {
      // التحقق من عدم وجود فترة نشطة أخرى
      final existingActivePeriod = await getCurrentActivePeriod();
      if (existingActivePeriod != null) {
        throw Exception(
          'يوجد فترة مالية نشطة بالفعل: ${existingActivePeriod.periodText}',
        );
      }

      // التحقق من عدم وجود فترة بنفس السنة والشهر
      final existingPeriod = await DatabaseService.isar.activePeriods
          .filter()
          .activeYearEqualTo(year)
          .and()
          .activeMonthEqualTo(month)
          .findFirst();

      if (existingPeriod != null) {
        throw Exception(
          'تم فتح هذه الفترة مسبقاً: ${existingPeriod.periodText}',
        );
      }

      // إنشاء فترة جديدة
      final newPeriod = ActivePeriod()
        ..activeYear = year
        ..activeMonth = month
        ..isActive = true
        ..openedAt = DateTime.now()
        ..openedBy = openedBy
        ..notes = notes
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.activePeriods.put(newPeriod);
      });

      print('✅ تم فتح الفترة المالية: ${newPeriod.periodText}');
      return true;
    } catch (e) {
      print('❌ خطأ في فتح الفترة المالية: $e');
      return false;
    }
  }

  /// إغلاق الفترة النشطة الحالية
  static Future<bool> closeCurrentPeriod(
    String closedBy, {
    String? notes,
  }) async {
    try {
      final activePeriod = await getCurrentActivePeriod();
      if (activePeriod == null) {
        throw Exception('لا توجد فترة مالية نشطة للإغلاق');
      }

      // تحديث الفترة لتصبح مغلقة
      activePeriod.isActive = false;
      activePeriod.closedAt = DateTime.now();
      activePeriod.closedBy = closedBy;
      if (notes != null) {
        activePeriod.notes =
            (activePeriod.notes ?? '') + '\nملاحظات الإغلاق: $notes';
      }
      activePeriod.updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.activePeriods.put(activePeriod);
      });

      print('✅ تم إغلاق الفترة المالية: ${activePeriod.periodText}');
      return true;
    } catch (e) {
      print('❌ خطأ في إغلاق الفترة المالية: $e');
      return false;
    }
  }

  /// الحصول على معلومات الفترة النشطة
  static Future<Map<String, dynamic>?> getActivePeriodInfo() async {
    final activePeriod = await getCurrentActivePeriod();
    if (activePeriod == null) return null;

    return {
      'year': activePeriod.activeYear,
      'month': activePeriod.activeMonth,
      'periodText': activePeriod.periodText,
      'openedAt': activePeriod.openedAt,
      'openedBy': activePeriod.openedBy,
      'notes': activePeriod.notes,
    };
  }

  /// الحصول على جميع الفترات المالية
  static Future<List<ActivePeriod>> getAllPeriods() async {
    return await DatabaseService.isar.activePeriods
        .where()
        .sortByActiveYearDesc()
        .thenByActiveMonthDesc()
        .findAll();
  }

  /// فتح الفترة التالية تلقائياً
  static Future<bool> openNextPeriod(String openedBy, {String? notes}) async {
    final currentPeriod = await getCurrentActivePeriod();
    if (currentPeriod != null) {
      // إغلاق الفترة الحالية أولاً
      await closeCurrentPeriod(openedBy, notes: 'فتح الفترة التالية');
    }

    // حساب الفترة التالية
    final now = DateTime.now();
    int nextYear = now.year;
    int nextMonth = now.month;

    // فتح الفترة التالية
    return await openNewPeriod(nextYear, nextMonth, openedBy, notes: notes);
  }
}
