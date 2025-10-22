import 'package:isar/isar.dart';

part 'active_period.g.dart';

@collection
class ActivePeriod {
  Id id = Isar.autoIncrement;

  @Index()
  late int activeYear; // السنة النشطة

  @Index()
  late int activeMonth; // الشهر النشط

  bool isActive = true; // هل هذه الفترة نشطة

  DateTime? openedAt; // تاريخ فتح الفترة
  DateTime? closedAt; // تاريخ إغلاق الفترة

  String? openedBy; // من فتح الفترة
  String? closedBy; // من أغلق الفترة

  String? notes; // ملاحظات

  DateTime? createdAt;
  DateTime? updatedAt;

  ActivePeriod();

  /// الحصول على نص الفترة
  String get periodText {
    const monthNames = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${monthNames[activeMonth]} $activeYear';
  }
}
