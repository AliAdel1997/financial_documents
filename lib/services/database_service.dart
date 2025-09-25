import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../models/organization.dart';

class DatabaseService {
  static late Isar isar;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      DocumentSchema,
      PrintBatchSchema,
      PrintSettingsSchema,
      OrganizationSchema,
    ], directory: dir.path);

    // إنشاء إعدادات افتراضية إذا لم تكن موجودة
    await _initializeDefaultSettings();
    _isInitialized = true;
  }

  static Future<void> _initializeDefaultSettings() async {
    final existingSettings = await isar.printSettings.where().findFirst();
    if (existingSettings == null) {
      final defaultSettings = PrintSettings()
        ..currentOutgoingNumber = 1
        ..departmentName = 'اسم الدائرة'
        ..bankName = 'اسم المصرف'
        ..directorName = 'اسم مدير المؤسسة'
        ..jobTitle = 'العنوان الوظيفي'
        ..assignedWork = 'العمل المكلف به'
        ..positionType = 'مدير عام'
        ..requirePreview = true
        ..autoIncrement = true
        ..copiesCount = 2
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.printSettings.put(defaultSettings);
      });
    }
  }

  // Document operations
  static Future<List<Document>> getAllDocuments() async {
    return await isar.documents.where().findAll();
  }

  static Future<Document?> getDocumentById(int id) async {
    return await isar.documents.get(id);
  }

  static Future<Document?> getDocumentByOutgoingNumber(
    int outgoingNumber,
  ) async {
    return await isar.documents
        .filter()
        .outgoingNumberEqualTo(outgoingNumber)
        .findFirst();
  }

  static Future<List<Document>> getDocumentsByStatus(
    DocumentStatus status,
  ) async {
    return await isar.documents.filter().statusEqualTo(status).findAll();
  }

  static Future<void> saveDocument(Document document) async {
    await isar.writeTxn(() async {
      document.updatedAt = DateTime.now();
      if (document.createdAt == null) {
        document.createdAt = DateTime.now();
      }
      await isar.documents.put(document);
    });
  }

  static Future<void> saveDocuments(List<Document> documents) async {
    await isar.writeTxn(() async {
      final now = DateTime.now();
      for (var document in documents) {
        document.updatedAt = now;
        if (document.createdAt == null) {
          document.createdAt = now;
        }
      }
      await isar.documents.putAll(documents);
    });
  }

  static Future<void> deleteDocument(int id) async {
    await isar.writeTxn(() async {
      await isar.documents.delete(id);
    });
  }

  static Future<void> updateDocumentStatus(
    int id,
    DocumentStatus status, {
    String? bankNotificationNumber,
    DateTime? uploadedDate,
  }) async {
    await isar.writeTxn(() async {
      final document = await isar.documents.get(id);
      if (document != null) {
        document.status = status;
        document.updatedAt = DateTime.now();

        if (status == DocumentStatus.uploaded) {
          document.bankNotificationNumber = bankNotificationNumber;
          document.uploadDate = uploadedDate ?? DateTime.now();
        }

        await isar.documents.put(document);
      }
    });
  }

  // PrintBatch operations
  static Future<List<PrintBatch>> getAllPrintBatches() async {
    return await isar.printBatchs.where().findAll();
  }

  static Future<PrintBatch?> getPrintBatchById(int id) async {
    return await isar.printBatchs.get(id);
  }

  static Future<void> savePrintBatch(PrintBatch batch) async {
    await isar.writeTxn(() async {
      await isar.printBatchs.put(batch);
    });
  }

  static Future<void> updatePrintBatchStatus(
    int id,
    PrintBatchStatus status,
  ) async {
    await isar.writeTxn(() async {
      final batch = await isar.printBatchs.get(id);
      if (batch != null) {
        batch.status = status;
        if (status == PrintBatchStatus.completed) {
          batch.completedDate = DateTime.now();
        }
        await isar.printBatchs.put(batch);
      }
    });
  }

  // PrintSettings operations
  static Future<PrintSettings?> getSettings() async {
    return await isar.printSettings.where().findFirst();
  }

  static Future<void> saveSettings(PrintSettings settings) async {
    await isar.writeTxn(() async {
      settings.updatedAt = DateTime.now();
      await isar.printSettings.put(settings);
    });
  }

  static Future<int> getNextOutgoingNumber() async {
    final settings = await getSettings();
    if (settings != null) {
      final nextNumber = settings.currentOutgoingNumber + 1;
      settings.currentOutgoingNumber = nextNumber;
      await saveSettings(settings);
      return nextNumber;
    }
    return 1;
  }

  static Future<void> updateCurrentOutgoingNumber(int number) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.currentOutgoingNumber = number;
      await saveSettings(settings);
    }
  }

  // Search operations
  static Future<List<Document>> searchDocuments(String query) async {
    return await isar.documents
        .filter()
        .group(
          (q) => q
              .documentDetailsContains(query, caseSensitive: false)
              .or()
              .amountInWordsContains(query, caseSensitive: false)
              .or()
              .recipientAddressContains(query, caseSensitive: false),
        )
        .findAll();
  }

  static Future<List<Document>> getDocumentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await isar.documents
        .filter()
        .documentDateBetween(start, end)
        .findAll();
  }

  // Statistics
  static Future<Map<DocumentStatus, int>> getDocumentStatusCounts() async {
    final counts = <DocumentStatus, int>{};

    for (final status in DocumentStatus.values) {
      final count = await isar.documents.filter().statusEqualTo(status).count();
      counts[status] = count;
    }

    return counts;
  }

  static Future<int> getTotalDocumentsCount() async {
    return await isar.documents.count();
  }

  // Organization operations
  static Future<List<Organization>> getAllOrganizations() async {
    return await isar.organizations.where().findAll();
  }

  static Future<Organization?> getOrganizationById(int id) async {
    return await isar.organizations.get(id);
  }

  static Future<Organization?> getMainOrganization() async {
    final orgs = await isar.organizations.where().findAll();
    return orgs.isNotEmpty ? orgs.first : null;
  }

  static Future<void> saveOrganization(Organization organization) async {
    await isar.writeTxn(() async {
      organization.updatedAt = DateTime.now();
      if (organization.createdAt == null) {
        organization.createdAt = DateTime.now();
      }
      await isar.organizations.put(organization);
    });
  }

  static Future<void> deleteOrganization(int id) async {
    await isar.writeTxn(() async {
      await isar.organizations.delete(id);
    });
  }

  // Additional utility functions
  static Future<double> getTotalAmountByStatus(DocumentStatus status) async {
    final documents = await getDocumentsByStatus(status);
    double total = 0;
    for (var doc in documents) {
      if (doc.amount != null) {
        total += doc.amount!;
      }
    }
    return total;
  }

  static Future<List<Document>> getDocumentsByBatch(String batchId) async {
    return await isar.documents.filter().batchIdEqualTo(batchId).findAll();
  }

  static Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await isar.close();
      _isInitialized = false;
    }
  }
}
