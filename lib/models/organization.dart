import 'package:isar/isar.dart';

part 'organization.g.dart';

@collection
class Organization {
  Id id = Isar.autoIncrement;

  @Index()
  String? departmentName; // اسم الدائرة

  String? bankAccount; // الحساب المصرفي
  
  String? iban; // الايبان

  String? accountNumber; // رقم الحساب

  String? bankName; // اسم المصرف

  String? directorName; // اسم مدير المؤسسة

  String? jobTitle; // عنوانه الوظيفي

  String? assignedWork; // العمل المكلف به

  String? positionType; // مدير عام او مخول بالصلاحيات

  DateTime? createdAt;

  DateTime? updatedAt;

  Organization({
    this.departmentName,
    this.bankAccount,
    this.iban,
    this.accountNumber,
    this.bankName,
    this.directorName,
    this.jobTitle,
    this.assignedWork,
    this.positionType,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentName': departmentName,
      'bankAccount': bankAccount,
      'iban': iban,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'directorName': directorName,
      'jobTitle': jobTitle,
      'assignedWork': assignedWork,
      'positionType': positionType,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static Organization fromJson(Map<String, dynamic> json) {
    return Organization(
      departmentName: json['departmentName'],
      bankAccount: json['bankAccount'],
      iban: json['iban'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
      directorName: json['directorName'],
      jobTitle: json['jobTitle'],
      assignedWork: json['assignedWork'],
      positionType: json['positionType'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}