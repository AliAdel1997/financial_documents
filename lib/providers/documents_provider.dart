import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import '../services/excel_service.dart';

class DocumentsProvider with ChangeNotifier {
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;
  DocumentStatus? _statusFilter;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DocumentStatus? get statusFilter => _statusFilter;

  /// تحميل جميع المستندات
  Future<void> loadDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await DatabaseService.getAllDocuments();
      _applyStatusFilter();
    } catch (e) {
      _error = 'خطأ في تحميل المستندات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل المستندات حسب الحالة
  Future<void> loadDocumentsByStatus(DocumentStatus status) async {
    _isLoading = true;
    _error = null;
    _statusFilter = status;
    notifyListeners();

    try {
      _documents = await DatabaseService.getDocumentsByStatus(status);
    } catch (e) {
      _error = 'خطأ في تحميل المستندات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة مستند جديد
  Future<void> addDocument(Document document) async {
    try {
      // تعيين رقم صادر تلقائي إذا لم يكن محدد
      if (document.outgoingNumber == null) {
        document.outgoingNumber = await DatabaseService.getNextOutgoingNumber();
      }

      await DatabaseService.saveDocument(document);

      // إضافة المستند إلى القائمة إذا كان يطابق الفلتر الحالي
      if (_shouldIncludeDocument(document)) {
        _documents.insert(0, document); // إضافة في البداية
      }
      notifyListeners();
    } catch (e) {
      _error = 'خطأ في إضافة المستند: $e';
      notifyListeners();
    }
  }

  /// تحديث مستند
  Future<void> updateDocument(Document document) async {
    try {
      await DatabaseService.saveDocument(document);

      // تحديث المستند في القائمة
      final index = _documents.indexWhere((doc) => doc.id == document.id);
      if (index >= 0) {
        _documents[index] = document;
        notifyListeners();
      }
    } catch (e) {
      _error = 'خطأ في تحديث المستند: $e';
      notifyListeners();
    }
  }

  /// حذف مستند
  Future<void> deleteDocument(int documentId) async {
    try {
      await DatabaseService.deleteDocument(documentId);

      // حذف المستند من القائمة
      _documents.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
    } catch (e) {
      _error = 'خطأ في حذف المستند: $e';
      notifyListeners();
    }
  }

  /// تحديث حالة مستند
  Future<void> updateDocumentStatus(
    int documentId,
    DocumentStatus status, {
    String? bankNotificationNumber,
    DateTime? uploadDate,
  }) async {
    try {
      await DatabaseService.updateDocumentStatus(
        documentId,
        status,
        bankNotificationNumber: bankNotificationNumber,
        uploadedDate: uploadDate,
      );

      // تحديث المستند في القائمة
      final index = _documents.indexWhere((doc) => doc.id == documentId);
      if (index >= 0) {
        _documents[index].status = status;
        if (status == DocumentStatus.uploaded) {
          _documents[index].bankNotificationNumber = bankNotificationNumber;
          _documents[index].uploadDate = uploadDate ?? DateTime.now();
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'خطأ في تحديث حالة المستند: $e';
      notifyListeners();
    }
  }

  /// البحث في المستندات
  Future<void> searchDocuments(String query) async {
    if (query.trim().isEmpty) {
      await loadDocuments();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await DatabaseService.searchDocuments(query);
    } catch (e) {
      _error = 'خطأ في البحث: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل المستندات حسب نطاق التاريخ
  Future<void> loadDocumentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await DatabaseService.getDocumentsByDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      _error = 'خطأ في تحميل المستندات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// استيراد المستندات من Excel
  Future<void> importFromExcel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final importedDocuments = await ExcelService.readDocumentsFromExcel();

      if (importedDocuments.isNotEmpty) {
        // حفظ المستندات في قاعدة البيانات
        await DatabaseService.saveDocuments(importedDocuments);

        // إعادة تحميل القائمة
        await loadDocuments();
      }
    } catch (e) {
      _error = 'خطأ في استيراد ملف Excel: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تصدير المستندات إلى Excel
  Future<String?> exportToExcel({String? fileName}) async {
    try {
      if (_documents.isEmpty) {
        _error = 'لا توجد مستندات للتصدير';
        notifyListeners();
        return null;
      }

      final filePath = await ExcelService.exportDocumentsToExcel(
        _documents,
        fileName: fileName,
      );

      return filePath;
    } catch (e) {
      _error = 'خطأ في تصدير ملف Excel: $e';
      notifyListeners();
      return null;
    }
  }

  /// إنشاء قالب Excel للاستيراد
  Future<String?> createExcelTemplate({
    String? fileName,
    Organization? organization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filePath = await ExcelService.createImportTemplate(
        fileName: fileName,
        organization: organization,
      );

      return filePath;
    } catch (e) {
      _error = 'خطأ في إنشاء قالب Excel: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تطبيق فلتر الحالة
  void _applyStatusFilter() {
    if (_statusFilter != null) {
      _documents = _documents
          .where((doc) => doc.status == _statusFilter)
          .toList();
    }
  }

  /// التحقق من أن المستند يطابق الفلتر الحالي
  bool _shouldIncludeDocument(Document document) {
    return _statusFilter == null || document.status == _statusFilter;
  }

  /// إزالة الفلتر
  void clearFilter() {
    _statusFilter = null;
    loadDocuments();
  }

  /// تطبيق فلتر حالة جديد
  void setStatusFilter(DocumentStatus? status) {
    _statusFilter = status;
    if (status != null) {
      loadDocumentsByStatus(status);
    } else {
      loadDocuments();
    }
  }

  /// الحصول على إحصائيات المستندات
  Future<Map<DocumentStatus, int>> getDocumentStatistics() async {
    try {
      return await DatabaseService.getDocumentStatusCounts();
    } catch (e) {
      _error = 'خطأ في تحميل الإحصائيات: $e';
      notifyListeners();
      return {};
    }
  }

  /// إزالة الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    if (_statusFilter != null) {
      await loadDocumentsByStatus(_statusFilter!);
    } else {
      await loadDocuments();
    }
  }
}
