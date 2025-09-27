import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// Provider لإدارة حالة البيانات التمويلية
class FundingProvider with ChangeNotifier {
  // قوائم البيانات
  List<FundingCategory> _fundingCategories = [];
  List<Institution> _institutions = [];
  List<InstitutionFunding> _institutionFundings = [];

  // حالة التحميل
  bool _isLoading = false;
  String? _errorMessage;

  // المتغيرات المؤقتة للتصفية
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedInstitutionId;
  int? _selectedCategoryId;

  // Getters للبيانات
  List<FundingCategory> get fundingCategories => _fundingCategories;
  List<Institution> get institutions => _institutions;
  List<InstitutionFunding> get institutionFundings => _institutionFundings;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  int? get selectedInstitutionId => _selectedInstitutionId;
  int? get selectedCategoryId => _selectedCategoryId;

  /// الأبواب التمويلية الرئيسية فقط
  List<FundingCategory> get mainFundingCategories =>
      _fundingCategories.where((category) => category.parentId == null).toList();

  /// الأبواب التمويلية الفرعية لباب معين
  List<FundingCategory> getSubCategories(int parentId) =>
      _fundingCategories.where((category) => category.parentId == parentId).toList();

  /// تحديث حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تحديث رسالة الخطأ
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // =============================================
  // دوال تحميل البيانات
  // =============================================

  /// تحميل جميع الأبواب التمويلية
  Future<void> loadFundingCategories() async {
    try {
      _setLoading(true);
      _setError(null);
      _fundingCategories = await DatabaseService.getAllFundingCategories();
      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل الأبواب التمويلية: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل جميع المؤسسات
  Future<void> loadInstitutions() async {
    try {
      _setLoading(true);
      _setError(null);
      _institutions = await DatabaseService.getAllInstitutions();
      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل المؤسسات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل جميع بيانات التمويل
  Future<void> loadInstitutionFundings() async {
    try {
      _setLoading(true);
      _setError(null);
      _institutionFundings = await DatabaseService.getAllInstitutionFunding();
      notifyListeners();
    } catch (e) {
      _setError('خطأ في تحميل بيانات التمويل: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل جميع البيانات
  Future<void> loadAllData() async {
    await Future.wait([
      loadFundingCategories(),
      loadInstitutions(),
      loadInstitutionFundings(),
    ]);
  }

  // =============================================
  // دوال إدارة الأبواب التمويلية
  // =============================================

  /// إضافة باب تمويلي جديد
  Future<bool> addFundingCategory(FundingCategory category) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final id = await DatabaseService.addFundingCategory(category);
      category.id = id;
      _fundingCategories.add(category);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في إضافة الباب التمويلي: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث باب تمويلي
  Future<bool> updateFundingCategory(FundingCategory category) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await DatabaseService.updateFundingCategory(category);
      
      final index = _fundingCategories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _fundingCategories[index] = category;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تحديث الباب التمويلي: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف باب تمويلي
  Future<bool> deleteFundingCategory(int id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final success = await DatabaseService.deleteFundingCategory(id);
      if (success) {
        _fundingCategories.removeWhere((category) => category.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('خطأ في حذف الباب التمويلي: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================
  // دوال إدارة المؤسسات
  // =============================================

  /// إضافة مؤسسة جديدة
  Future<bool> addInstitution(Institution institution) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final id = await DatabaseService.addInstitution(institution);
      institution.id = id;
      _institutions.add(institution);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في إضافة المؤسسة: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث مؤسسة
  Future<bool> updateInstitution(Institution institution) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await DatabaseService.updateInstitution(institution);
      
      final index = _institutions.indexWhere((i) => i.id == institution.id);
      if (index != -1) {
        _institutions[index] = institution;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تحديث المؤسسة: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف مؤسسة
  Future<bool> deleteInstitution(int id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final success = await DatabaseService.deleteInstitution(id);
      if (success) {
        _institutions.removeWhere((institution) => institution.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('خطأ في حذف المؤسسة: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================
  // دوال إدارة تمويل المؤسسات
  // =============================================

  /// إضافة تمويل مؤسسة جديد
  Future<bool> addInstitutionFunding(InstitutionFunding funding) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final id = await DatabaseService.addInstitutionFunding(funding);
      funding.id = id;
      _institutionFundings.add(funding);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في إضافة التمويل: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث تمويل مؤسسة
  Future<bool> updateInstitutionFunding(InstitutionFunding funding) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await DatabaseService.updateInstitutionFunding(funding);
      
      final index = _institutionFundings.indexWhere((f) => f.id == funding.id);
      if (index != -1) {
        _institutionFundings[index] = funding;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تحديث التمويل: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف تمويل مؤسسة
  Future<bool> deleteInstitutionFunding(int id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final success = await DatabaseService.deleteInstitutionFunding(id);
      if (success) {
        _institutionFundings.removeWhere((funding) => funding.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('خطأ في حذف التمويل: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================================
  // دوال التصفية
  // =============================================

  /// تحديد السنة المختارة
  void setSelectedYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  /// تحديد الشهر المختار
  void setSelectedMonth(int? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  /// تحديد المؤسسة المختارة
  void setSelectedInstitution(int? institutionId) {
    _selectedInstitutionId = institutionId;
    notifyListeners();
  }

  /// تحديد الباب المختار
  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// مسح جميع المرشحات
  void clearFilters() {
    _selectedYear = null;
    _selectedMonth = null;
    _selectedInstitutionId = null;
    _selectedCategoryId = null;
    notifyListeners();
  }

  /// الحصول على التمويلات المفلترة
  List<InstitutionFunding> get filteredFundings {
    List<InstitutionFunding> filtered = List.from(_institutionFundings);

    if (_selectedYear != null) {
      filtered = filtered.where((f) => f.year == _selectedYear).toList();
    }

    if (_selectedMonth != null) {
      filtered = filtered.where((f) => f.month == _selectedMonth).toList();
    }

    if (_selectedInstitutionId != null) {
      filtered = filtered.where((f) => f.institutionId == _selectedInstitutionId).toList();
    }

    if (_selectedCategoryId != null) {
      filtered = filtered.where((f) => f.categoryId == _selectedCategoryId).toList();
    }

    return filtered;
  }

  // =============================================
  // دوال الحسابات والتقارير
  // =============================================

  /// حساب إجمالي المبالغ المخصصة
  double getTotalAllocatedAmount([List<InstitutionFunding>? fundings]) {
    final list = fundings ?? filteredFundings;
    return list.fold(0.0, (total, funding) => total + funding.allocatedAmount);
  }

  /// حساب إجمالي المبالغ المحجوزة
  double getTotalReservedAmount([List<InstitutionFunding>? fundings]) {
    final list = fundings ?? filteredFundings;
    return list.fold(0.0, (total, funding) => total + funding.reservedAmount);
  }

  /// حساب إجمالي المبالغ المصروفة
  double getTotalSpentAmount([List<InstitutionFunding>? fundings]) {
    final list = fundings ?? filteredFundings;
    return list.fold(0.0, (total, funding) => total + funding.spentAmount);
  }

  /// حساب إجمالي المبالغ المتبقية
  double getTotalRemainingAmount([List<InstitutionFunding>? fundings]) {
    final list = fundings ?? filteredFundings;
    return list.fold(0.0, (total, funding) => total + funding.remainingAmount);
  }

  /// الحصول على اسم المؤسسة بالمعرف
  String getInstitutionName(int institutionId) {
    final institution = _institutions.firstWhere(
      (i) => i.id == institutionId,
      orElse: () => Institution()..name = 'غير معروف',
    );
    return institution.name;
  }

  /// الحصول على اسم الباب التمويلي بالمعرف
  String getCategoryName(int categoryId) {
    final category = _fundingCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => FundingCategory()..name = 'غير معروف',
    );
    return category.name;
  }

  /// البحث في المؤسسات
  Future<List<Institution>> searchInstitutions(String searchTerm) async {
    if (searchTerm.isEmpty) return _institutions;
    return await DatabaseService.searchInstitutions(searchTerm);
  }

  /// البحث في الأبواب التمويلية
  Future<List<FundingCategory>> searchFundingCategories(String searchTerm) async {
    if (searchTerm.isEmpty) return _fundingCategories;
    return await DatabaseService.searchFundingCategories(searchTerm);
  }
}