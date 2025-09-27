import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/documents_provider.dart';
import '../providers/organization_provider.dart';
import '../screens/add_document_screen.dart';
import '../screens/organization_settings_screen.dart';
import '../screens/organization_list_screen.dart';
import '../screens/reports_by_recipient_screen.dart';
import '../models/document.dart';
import '../services/printing_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تأخير تحميل البيانات حتى ما بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final documentsProvider = Provider.of<DocumentsProvider>(
      context,
      listen: false,
    );
    final organizationProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      documentsProvider.loadDocuments(),
      organizationProvider.loadOrganization(),
    ]);

    // إنشاء مؤسسة افتراضية إذا لم تكن موجودة
    if (mounted && !organizationProvider.hasOrganizationData) {
      await organizationProvider.createDefaultOrganization();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام طباعة وأرشفة المستندات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Consumer2<DocumentsProvider, OrganizationProvider>(
        builder: (context, documentsProvider, organizationProvider, child) {
          if (documentsProvider.isLoading || organizationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (documentsProvider.error != null) {
            return _buildErrorWidget(documentsProvider.error!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة معلومات المؤسسة
                _buildOrganizationCard(organizationProvider.organization),

                const SizedBox(height: 20),

                // إحصائيات سريعة
                _buildStatsCards(),

                const SizedBox(height: 20),

                // الأزرار الرئيسية
                _buildMainButtons(context, documentsProvider),

                const SizedBox(height: 20),

                // قائمة المستندات الأخيرة
                _buildRecentDocuments(documentsProvider.documents),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentDialog(context),
        label: const Text('إضافة مستند'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrganizationCard(organization) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  organization?.departmentName ?? 'غير محدد',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (organization?.directorName != null)
              Text('المدير: ${organization!.directorName}'),
            if (organization?.bankName != null)
              Text('المصرف: ${organization!.bankName}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<DocumentsProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<DocumentStatus, int>>(
          future: provider.getDocumentStatistics(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stats = snapshot.data!;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'المجموع',
                      stats.values.fold(0, (a, b) => a + b).toString(),
                      Colors.blue,
                      Icons.description,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'مطبوع',
                      (stats[DocumentStatus.printed] ?? 0).toString(),
                      Colors.green,
                      Icons.print,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'مرفوع',
                      (stats[DocumentStatus.uploaded] ?? 0).toString(),
                      Colors.orange,
                      Icons.cloud_upload,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(height: 80);
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, DocumentsProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPrintSingleDialog(context),
                icon: const Icon(Icons.print),
                label: const Text('طباعة مستند مفرد'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPrintMultipleDialog(context),
                icon: const Icon(Icons.print_outlined),
                label: const Text('طباعة متعددة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.importFromExcel,
                icon: const Icon(Icons.upload_file),
                label: const Text('استيراد من Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToExcel(provider),
                icon: const Icon(Icons.download),
                label: const Text('تصدير إلى Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // زر إنشاء قالب Excel
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _createExcelTemplate(),
                icon: const Icon(Icons.description),
                label: const Text('إنشاء قالب Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  foregroundColor: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // زر اختبار المعاينة
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _testPreviewBatch(context, provider),
            icon: const Icon(Icons.preview),
            label: const Text('اختبار معاينة الدفعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDocuments(List<Document> documents) {
    final recentDocs = documents.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المستندات الأخيرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (recentDocs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد مستندات'),
                ),
              )
            else
              ...recentDocs.map((doc) => _buildDocumentTile(doc)),
            if (documents.length > 5)
              TextButton(
                onPressed: () => _showAllDocuments(context),
                child: const Text('عرض جميع المستندات'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(Document document) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(document.status),
        child: Text(
          document.outgoingNumber?.toString() ?? '؟',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      title: Text(
        document.documentDetails ?? 'بدون عنوان',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        document.documentDate != null
            ? '${document.documentDate!.day}/${document.documentDate!.month}/${document.documentDate!.year}'
            : 'بدون تاريخ',
      ),
      trailing: Chip(
        label: Text(
          _getStatusText(document.status),
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: _getStatusColor(document.status).withOpacity(0.2),
      ),
      onTap: () => _showDocumentDetails(context, document),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Colors.grey;
      case DocumentStatus.printed:
        return Colors.green;
      case DocumentStatus.uploaded:
        return Colors.orange;
      case DocumentStatus.notUploaded:
        return Colors.red;
      case DocumentStatus.archived:
        return Colors.purple;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return 'مسودة';
      case DocumentStatus.printed:
        return 'مطبوع';
      case DocumentStatus.uploaded:
        return 'مرفوع';
      case DocumentStatus.notUploaded:
        return 'غير مرفوع';
      case DocumentStatus.archived:
        return 'مؤرشف';
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر السحب
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // عنوان القائمة
            Text(
              'الإعدادات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // قائمة الخيارات
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('إدارة المؤسسات'),
              subtitle: const Text('إضافة وتعديل بيانات المؤسسات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrganizationListScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('إعدادات المؤسسة الحالية'),
              subtitle: const Text('تعديل بيانات المؤسسة المحددة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrganizationSettingsScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول التطبيق'),
              subtitle: const Text('معلومات عن النظام'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'نظام طباعة وأرشفة المستندات',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.description,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text(
          'نظام متكامل لإدارة وطباعة وأرشفة المستندات المالية والإدارية',
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        const Text(
          'الميزات:',
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        const Text(
          '• إضافة وتعديل المستندات\n'
          '• طباعة فردية ومتعددة\n'
          '• تشفير وحماية البيانات\n'
          '• إدارة المؤسسات\n'
          '• تصدير التقارير',
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
    ).then((_) => _loadData());
  }

  void _showPrintSingleDialog(BuildContext context) async {
    final documentsProvider = Provider.of<DocumentsProvider>(context, listen: false);
    final readyDocuments = documentsProvider.documents.where(
      (doc) => doc.outgoingNumber != null && doc.status != DocumentStatus.draft
    ).toList();

    if (readyDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مستندات جاهزة للطباعة')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _PrintSingleDocumentDialog(documents: readyDocuments),
    );
  }

  void _showPrintMultipleDialog(BuildContext context) async {
    final documentsProvider = Provider.of<DocumentsProvider>(context, listen: false);
    final draftDocuments = documentsProvider.documents.where(
      (doc) => doc.status == DocumentStatus.draft || doc.outgoingNumber == null
    ).toList();

    if (draftDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مستندات متاحة للطباعة المتعددة')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _PrintMultipleDocumentsDialog(documents: draftDocuments),
    );
  }

  void _showAllDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsByRecipientScreen()),
    );
  }

  /// اختبار معاينة دفعة من المستندات
  Future<void> _testPreviewBatch(BuildContext context, DocumentsProvider provider) async {
    try {
      // أخذ عينة من المستندات للاختبار
      final testDocuments = provider.documents.take(3).toList();
      
      if (testDocuments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد مستندات للاختبار. يرجى إضافة بعض المستندات أولاً.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // عرض رسالة تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('جاري إنشاء المعاينة...'),
            ],
          ),
        ),
      );

      // استخدام الدالة الجديدة للمعاينة
      await PrintingService.previewMultipleDocuments(testDocuments);

      // إغلاق رسالة التحميل
      if (context.mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      // إغلاق رسالة التحميل في حالة الخطأ
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاينة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDocumentDetails(BuildContext context, Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentScreen(document: document),
      ),
    ).then((_) => _loadData());
  }

  /// إنشاء قالب Excel للاستيراد
  Future<void> _createExcelTemplate() async {
    try {
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
      final documentsProvider = Provider.of<DocumentsProvider>(context, listen: false);
      
      // الحصول على بيانات المؤسسة
      await organizationProvider.loadOrganization();
      final organization = organizationProvider.organization;
      
      final filePath = await documentsProvider.createExcelTemplate(
        organization: organization,
      );
      
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء قالب Excel بنجاح: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(documentsProvider.error ?? 'فشل في إنشاء القالب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء القالب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel(DocumentsProvider provider) async {
    final filePath = await provider.exportToExcel();
    if (filePath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تصدير الملف: $filePath')));
    }
  }
}

/// حوار طباعة مستند مفرد
class _PrintSingleDocumentDialog extends StatefulWidget {
  final List<Document> documents;

  const _PrintSingleDocumentDialog({required this.documents});

  @override
  State<_PrintSingleDocumentDialog> createState() => _PrintSingleDocumentDialogState();
}

class _PrintSingleDocumentDialogState extends State<_PrintSingleDocumentDialog> {
  Document? selectedDocument;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طباعة مستند مفرد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('اختر المستند للطباعة:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<Document>(
            value: selectedDocument,
            decoration: const InputDecoration(
              labelText: 'المستند',
              border: OutlineInputBorder(),
            ),
            items: widget.documents.map((doc) {
              return DropdownMenuItem(
                value: doc,
                child: Text('رقم ${doc.outgoingNumber} - ${doc.recipientAddress ?? 'غير محدد'}'),
              );
            }).toList(),
            onChanged: (doc) {
              setState(() {
                selectedDocument = doc;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _printDocument,
          child: isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('طباعة'),
        ),
      ],
    );
  }

  Future<void> _printDocument() async {
    if (selectedDocument == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final success = await PrintingService.printSingleDocument(
        selectedDocument!,
        context,
        showPreview: true,
        requireConfirmation: true,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم طباعة المستند بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الطباعة: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

/// حوار الطباعة المتعددة
class _PrintMultipleDocumentsDialog extends StatefulWidget {
  final List<Document> documents;

  const _PrintMultipleDocumentsDialog({required this.documents});

  @override
  State<_PrintMultipleDocumentsDialog> createState() => _PrintMultipleDocumentsDialogState();
}

class _PrintMultipleDocumentsDialogState extends State<_PrintMultipleDocumentsDialog> {
  final _startNumberController = TextEditingController();
  final _endNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Document> selectedDocuments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDocuments = List.from(widget.documents);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الطباعة المتعددة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('عدد المستندات المحددة: ${selectedDocuments.length}'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _startNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم البداية',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'رقم البداية مطلوب';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0) {
                  return 'أدخل رقماً صحيحاً';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _endNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم النهاية',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'رقم النهاية مطلوب';
                }
                final num = int.tryParse(value);
                final startNum = int.tryParse(_startNumberController.text);
                if (num == null || num <= 0) {
                  return 'أدخل رقماً صحيحاً';
                }
                if (startNum != null && num < startNum) {
                  return 'رقم النهاية يجب أن يكون أكبر من رقم البداية';
                }
                if (startNum != null && (num - startNum + 1) < selectedDocuments.length) {
                  return 'النطاق غير كافي لعدد المستندات';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _selectDocuments,
              child: const Text('اختيار المستندات'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _printDocuments,
          child: isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('طباعة الدفعة'),
        ),
      ],
    );
  }

  void _selectDocuments() {
    showDialog(
      context: context,
      builder: (context) => _DocumentSelectionDialog(
        availableDocuments: widget.documents,
        selectedDocuments: selectedDocuments,
        onSelectionChanged: (selected) {
          setState(() {
            selectedDocuments = selected;
          });
        },
      ),
    );
  }

  Future<void> _printDocuments() async {
    if (!_formKey.currentState!.validate() || selectedDocuments.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final startNumber = int.parse(_startNumberController.text);
      final endNumber = int.parse(_endNumberController.text);

      final result = await PrintingService.printMultipleDocuments(
        selectedDocuments,
        startingNumber: startNumber,
        endingNumber: endNumber,
        context: context,
        showPreview: true,
        requireConfirmation: true,
      );

      if (result.success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الطباعة: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

/// حوار اختيار المستندات
class _DocumentSelectionDialog extends StatefulWidget {
  final List<Document> availableDocuments;
  final List<Document> selectedDocuments;
  final Function(List<Document>) onSelectionChanged;

  const _DocumentSelectionDialog({
    required this.availableDocuments,
    required this.selectedDocuments,
    required this.onSelectionChanged,
  });

  @override
  State<_DocumentSelectionDialog> createState() => _DocumentSelectionDialogState();
}

class _DocumentSelectionDialogState extends State<_DocumentSelectionDialog> {
  late List<Document> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedDocuments);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختيار المستندات'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempSelected = List.from(widget.availableDocuments);
                    });
                  },
                  child: const Text('تحديد الكل'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempSelected.clear();
                    });
                  },
                  child: const Text('إلغاء التحديد'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.availableDocuments.length,
                itemBuilder: (context, index) {
                  final document = widget.availableDocuments[index];
                  final isSelected = tempSelected.contains(document);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          tempSelected.add(document);
                        } else {
                          tempSelected.remove(document);
                        }
                      });
                    },
                    title: Text('${document.recipientAddress ?? 'غير محدد'}'),
                    subtitle: Text('المبلغ: ${document.amount ?? 0} دينار'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSelectionChanged(List.from(tempSelected));
            Navigator.pop(context);
          },
          child: const Text('تم'),
        ),
      ],
    );
  }
}
