import 'package:isar/isar.dart';

part 'deduction_entity.g.dart';

@collection
class DeductionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? iban; // ايبان الجهة
  String? email; // البريد الالكتروني
  String? address; // عنوان الجهة
  String? phone; // رقم الهاتف
  String? notes; // ملاحظات
  
  double totalDeductions = 0.0;
  
  bool isActive = true;
  
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;

  DeductionEntity({
    this.id = Isar.autoIncrement,
    required this.name,
    this.iban,
    this.email,
    this.address,
    this.phone,
    this.notes,
    this.totalDeductions = 0.0,
    this.isActive = true,
    this.updatedAt,
  });

  // تحويل إلى JSON للتصدير
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iban': iban,
      'email': email,
      'address': address,
      'phone': phone,
      'notes': notes,
      'totalDeductions': totalDeductions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // تحويل من JSON للاستيراد
  factory DeductionEntity.fromJson(Map<String, dynamic> json) {
    return DeductionEntity(
      id: json['id'] ?? Isar.autoIncrement,
      name: json['name'] ?? '',
      iban: json['iban'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
      notes: json['notes'],
      totalDeductions: (json['totalDeductions'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    )..createdAt = json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now();
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeductionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}