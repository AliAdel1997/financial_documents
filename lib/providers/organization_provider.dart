import 'package:flutter/foundation.dart';
import '../models/organization.dart';
import '../services/database_service.dart';

class OrganizationProvider with ChangeNotifier {
  Organization? _organization;
  bool _isLoading = false;
  String? _error;

  Organization? get organization => _organization;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل بيانات المؤسسة
  Future<void> loadOrganization() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organization = await DatabaseService.getMainOrganization();
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المؤسسة: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ أو تحديث بيانات المؤسسة
  Future<void> saveOrganization(Organization organization) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.saveOrganization(organization);
      _organization = organization;
    } catch (e) {
      _error = 'خطأ في حفظ بيانات المؤسسة: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث اسم الدائرة
  Future<void> updateDepartmentName(String departmentName) async {
    if (_organization != null) {
      _organization!.departmentName = departmentName;
      await _saveCurrentOrganization();
    }
  }

  /// تحديث معلومات المصرف
  Future<void> updateBankInfo({
    String? bankName,
    String? bankAccount,
    String? iban,
    String? accountNumber,
  }) async {
    if (_organization != null) {
      if (bankName != null) _organization!.bankName = bankName;
      if (bankAccount != null) _organization!.bankAccount = bankAccount;
      if (iban != null) _organization!.iban = iban;
      if (accountNumber != null) _organization!.accountNumber = accountNumber;

      await _saveCurrentOrganization();
    }
  }

  /// تحديث معلومات المدير
  Future<void> updateDirectorInfo({
    String? directorName,
    String? jobTitle,
    String? assignedWork,
    String? positionType,
  }) async {
    if (_organization != null) {
      if (directorName != null) _organization!.directorName = directorName;
      if (jobTitle != null) _organization!.jobTitle = jobTitle;
      if (assignedWork != null) _organization!.assignedWork = assignedWork;
      if (positionType != null) _organization!.positionType = positionType;

      await _saveCurrentOrganization();
    }
  }

  /// إنشاء مؤسسة جديدة بقيم افتراضية
  Future<void> createDefaultOrganization() async {
    final defaultOrg = Organization(
      departmentName: 'اسم الدائرة',
      bankName: 'اسم المصرف',
      directorName: 'اسم المدير',
      jobTitle: 'المنصب',
      assignedWork: 'الأعمال المكلف بها',
      positionType: 'مدير عام',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveOrganization(defaultOrg);
  }

  /// التحقق من وجود بيانات المؤسسة
  bool get hasOrganizationData => _organization != null;

  /// التحقق من اكتمال البيانات الأساسية
  bool get isDataComplete {
    if (_organization == null) return false;

    return _organization!.departmentName != null &&
        _organization!.departmentName!.isNotEmpty &&
        _organization!.directorName != null &&
        _organization!.directorName!.isNotEmpty &&
        _organization!.bankName != null &&
        _organization!.bankName!.isNotEmpty;
  }

  /// حفظ المؤسسة الحالية
  Future<void> _saveCurrentOrganization() async {
    if (_organization != null) {
      try {
        await DatabaseService.saveOrganization(_organization!);
        notifyListeners();
      } catch (e) {
        _error = 'خطأ في حفظ البيانات: $e';
        notifyListeners();
      }
    }
  }

  /// إزالة الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadOrganization();
  }

  /// تصدير بيانات المؤسسة
  Map<String, dynamic> exportData() {
    return _organization?.toJson() ?? {};
  }

  /// استيراد بيانات المؤسسة
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      final organization = Organization.fromJson(data);
      await saveOrganization(organization);
    } catch (e) {
      _error = 'خطأ في استيراد البيانات: $e';
      notifyListeners();
    }
  }
}
