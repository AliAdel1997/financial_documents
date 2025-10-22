import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/document_draft.dart';
import '../models/final_document.dart';
import '../services/database_service.dart';
import '../services/document_draft_excel_service.dart';
import '../services/arabic_number_to_words_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class DocumentDraftManagementScreen extends StatefulWidget {
  const DocumentDraftManagementScreen({super.key});

  @override
  State<DocumentDraftManagementScreen> createState() => _DocumentDraftManagementScreenState();
}

class _DocumentDraftManagementScreenState extends State<DocumentDraftManagementScreen> {
  List<DocumentDraft> _drafts = [];
  List<DocumentDraft> _filteredDrafts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedDocumentType;
  int? _selectedMonth;
  int? _selectedYear;
  DocumentDraftStatus? _selectedStatus;

  final List<String> _documentTypes = ['deductions', 'payments', 'transfers'];
  final List<int> _months = List.generate(12, (index) => index + 1);
  final List<int> _years = List.generate(5, (index) => DateTime.now().year - 2 + index);
  
  final DocumentDraftExcelService _excelService = DocumentDraftExcelService();

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    try {
      final drafts = await DatabaseService.getAllDocumentDrafts();
      setState(() {
        _drafts = drafts;
        _filteredDrafts = drafts;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل المسودات: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDrafts = _drafts.where((draft) {
        // فلتر البحث
        if (_searchQuery.isNotEmpty) {
          if (!draft.entityName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !draft.amount.toString().contains(_searchQuery)) {
            return false;
          }
        }

        // فلتر النوع
        if (_selectedDocumentType != null && draft.documentType != _selectedDocumentType) {
          return false;
        }

        // فلتر الشهر
        if (_selectedMonth != null && draft.month != _selectedMonth) {
          return false;
        }

        // فلتر السنة
        if (_selectedYear != null && draft.year != _selectedYear) {
          return false;
        }

        // فلتر الحالة
        if (_selectedStatus != null && draft.status != _selectedStatus) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة مسودات المستندات'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showImportDialog,
            tooltip: 'استيراد من Excel',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToExcel,
            tooltip: 'تصدير إلى Excel',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrafts,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          _buildStatsCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDrafts.isEmpty
                    ? _buildEmptyState()
                    : _buildDraftsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            decoration: const InputDecoration(
              hintText: 'البحث في المسودات...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          // الفلاتر
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع المستند',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedDocumentType,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ..._documentTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getDocumentTypeArabic(type)),
                        )),
                  ],
                  onChanged: (value) {
                    _selectedDocumentType = value;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'الشهر',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedMonth,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ..._months.map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthArabic(month)),
                        )),
                  ],
                  onChanged: (value) {
                    _selectedMonth = value;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'السنة',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedYear,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ..._years.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        )),
                  ],
                  onChanged: (value) {
                    _selectedYear = value;
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalDrafts = _drafts.length;
    final approvedDrafts = _drafts.where((d) => d.status == DocumentDraftStatus.approved).length;
    final printedDrafts = _drafts.where((d) => d.status == DocumentDraftStatus.printed).length;
    final totalAmount = _filteredDrafts.fold(0.0, (sum, draft) => sum + draft.amount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي المسودات', totalDrafts.toString(), Icons.description),
          _buildStatItem('معتمدة', approvedDrafts.toString(), Icons.check_circle),
          _buildStatItem('مطبوعة', printedDrafts.toString(), Icons.print),
          _buildStatItem('إجمالي المبلغ', '${totalAmount.toStringAsFixed(2)} ر.س', Icons.monetization_on),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مسودات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإنشاء مسودة جديدة أو استيراد البيانات من Excel',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showImportDialog,
            icon: const Icon(Icons.add),
            label: const Text('استيراد من Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDrafts.length,
      itemBuilder: (context, index) {
        final draft = _filteredDrafts[index];
        return _buildDraftCard(draft);
      },
    );
  }

  Widget _buildDraftCard(DocumentDraft draft) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.entityName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${draft.documentTypeArabic} - ${draft.monthNameArabic} ${draft.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${draft.amount.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(draft.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        draft.statusNameArabic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (draft.purpose != null && draft.purpose!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الغرض: ${draft.purpose}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (draft.status == DocumentDraftStatus.draft) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showPreviewDialog(draft),
                    icon: const Icon(Icons.preview, size: 16),
                    label: const Text('معاينة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _convertToFinalDocument(draft),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('اعتماد وطباعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ],
                if (draft.status == DocumentDraftStatus.printed && draft.finalDocumentId != null) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showFinalDocument(draft.finalDocumentId!),
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('عرض المستند'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteDraft(draft),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentDraftStatus status) {
    switch (status) {
      case DocumentDraftStatus.draft:
        return Colors.orange;
      case DocumentDraftStatus.reviewed:
        return Colors.blue;
      case DocumentDraftStatus.approved:
        return Colors.green;
      case DocumentDraftStatus.printed:
        return Colors.indigo;
      case DocumentDraftStatus.archived:
        return Colors.grey;
    }
  }

  Future<void> _showImportDialog() async {
    String documentType = 'deductions';
    int month = DateTime.now().month;
    int year = DateTime.now().year;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('استيراد من Excel'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شرح المطلوب
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تنسيق ملف Excel المطلوب:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• العمود الأول: اسم ${_getEntityTypeByDocumentType(documentType)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Text(
                        '• العمود الثاني: المبلغ (رقم)',
                        style: TextStyle(fontSize: 13),
                      ),
                      const Text(
                        '• العمود الثالث: الغرض (اختياري)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'نوع المستند'),
                  value: documentType,
                  items: _documentTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getDocumentTypeArabic(type)),
                      )).toList(),
                  onChanged: (value) => setState(() => documentType = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'الشهر'),
                        value: month,
                        items: _months.map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(_getMonthArabic(m)),
                            )).toList(),
                        onChanged: (value) => setState(() => month = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'السنة'),
                        value: year,
                        items: _years.map((y) => DropdownMenuItem(
                              value: y,
                              child: Text(y.toString()),
                            )).toList(),
                        onChanged: (value) => setState(() => year = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // خيارات إنشاء القالب أو الاستيراد
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إذا لم يكن لديك ملف Excel جاهز:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, 'template');
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('تحميل قالب Excel فارغ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade700,
                            side: BorderSide(color: Colors.amber.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'import'),
              child: const Text('استيراد ملف موجود'),
            ),
          ],
        ),
      ),
    );

    if (result == 'import') {
      _performImport(documentType, month, year, 'البنك الأهلي السعودي');
    } else if (result == 'template') {
      _createAndDownloadTemplate(documentType, month, year);
    }
  }

  Future<void> _performImport(String documentType, int month, int year, String organizationBankName) async {
    print('🚀 بدء عملية الاستيراد من screen...');
    print('📋 المعطيات المرسلة:');
    print('   - نوع المستند: $documentType');
    print('   - الشهر: $month');
    print('   - السنة: $year');
    print('   - اسم المصرف: $organizationBankName');
    
    try {
      _showLoadingDialog('جارٍ الاستيراد من Excel...');
      
      final service = DocumentDraftExcelService();
      print('📞 استدعاء خدمة الاستيراد...');
      
      final importResult = await service.importDraftsFromExcel(
        documentType: documentType,
        month: month,
        year: year,
        organizationBankName: organizationBankName,
      );

      print('📊 نتيجة الاستيراد:');
      print('   - نجحت العملية: ${importResult.success}');
      print('   - عدد المستوردة: ${importResult.importedCount}');
      print('   - عدد الأخطاء: ${importResult.errorCount}');
      print('   - الرسالة: ${importResult.message}');

      Navigator.pop(context); // إغلاق dialog التحميل

      if (importResult.success) {
        print('✅ تم الاستيراد بنجاح');
        _showSuccessSnackBar(importResult.message!);
        print('🔄 إعادة تحميل قائمة المسودات...');
        await _loadDrafts();
        print('✅ تم تحديث القائمة');
      } else {
        print('❌ فشل الاستيراد');
        _showErrorSnackBar(importResult.message!);
      }
    } catch (e, stackTrace) {
      print('❌ خطأ في عملية الاستيراد: $e');
      print('📍 Stack trace: $stackTrace');
      Navigator.pop(context); // إغلاق dialog التحميل في حالة الخطأ
      _showErrorSnackBar('خطأ في الاستيراد: $e');
    }
  }

  Future<void> _exportToExcel() async {
    try {
      _showLoadingDialog('جاري التصدير...');
      
      final service = DocumentDraftExcelService();
      final filePath = await service.exportDraftsToExcel(
        documentType: _selectedDocumentType,
        month: _selectedMonth,
        year: _selectedYear,
      );

      Navigator.pop(context);

      if (filePath != null) {
        _showSuccessSnackBar('تم تصدير الملف بنجاح');
      } else {
        _showErrorSnackBar('تم إلغاء عملية التصدير');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('خطأ في التصدير: $e');
    }
  }

  Future<void> _showPreviewDialog(DocumentDraft draft) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'معاينة المستند',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildPreviewContent(draft),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _convertToFinalDocument(draft);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('اعتماد وطباعة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(DocumentDraft draft) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مستند ${draft.documentTypeArabic}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildPreviewRow('اسم الجهة:', draft.entityName),
          _buildPreviewRow('المبلغ رقماً:', '${draft.amount.toStringAsFixed(2)} ر.س'),
          _buildPreviewRow('المبلغ كتابةً:', draft.amount.toArabicWords()),
          _buildPreviewRow('الشهر:', draft.monthNameArabic),
          _buildPreviewRow('السنة:', draft.year.toString()),
          if (draft.purpose != null) _buildPreviewRow('الغرض:', draft.purpose!),
          if (draft.entityIban != null) _buildPreviewRow('رقم الحساب:', draft.entityIban!),
          _buildPreviewRow('اسم المصرف:', draft.organizationBankName ?? ''),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'معاينة فقط - لن يحتوي على QR Code أو رقم صادر',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _convertToFinalDocument(DocumentDraft draft) async {
    try {
      _showLoadingDialog('جاري إنشاء المستند النهائي...');

      // توليد رقم المستند
      final documentNumber = await DatabaseService.generateDocumentNumber(
        documentType: draft.documentType,
        year: draft.year,
      );

      // تحويل المبلغ إلى كلمات
      final amountInWords = ArabicNumberToWordsService.convertForAccounting(draft.amount);

      // تحويل المسودة إلى مستند نهائي
      final finalDoc = await DatabaseService.convertDraftToFinalDocument(
        draft,
        documentNumber,
        amountInWords,
      );

      Navigator.pop(context); // إغلاق dialog التحميل

      if (finalDoc != null) {
        _showSuccessSnackBar('تم إنشاء المستند النهائي بنجاح');
        _loadDrafts();
        _showFinalDocumentPreview(finalDoc);
      } else {
        _showErrorSnackBar('خطأ في إنشاء المستند النهائي');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('خطأ في إنشاء المستند: $e');
    }
  }

  Future<void> _showFinalDocument(String documentNumber) async {
    try {
      final finalDoc = await DatabaseService.getFinalDocumentByNumber(documentNumber);
      if (finalDoc != null) {
        _showFinalDocumentPreview(finalDoc);
      } else {
        _showErrorSnackBar('لم يتم العثور على المستند');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في جلب المستند: $e');
    }
  }

  Future<void> _showFinalDocumentPreview(FinalDocument document) async {
    final pdfBytes = await _generateFinalDocumentPDF(document);
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('المستند النهائي - ${document.documentNumber}'),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () => _printFinalDocument(pdfBytes),
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => Uint8List.fromList(pdfBytes),
            canChangePageFormat: false,
            canDebug: false,
          ),
        ),
      ),
    );
  }

  Future<List<int>> _generateFinalDocumentPDF(FinalDocument document) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس المستند
              pw.Center(
                child: pw.Text(
                  document.documentTitle,
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // معلومات المستند
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${document.formattedDocumentNumber}'),
                  pw.Text('${document.formattedIssueDate}'),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // محتوى المستند
              pw.Text('اسم الجهة: ${document.entityName}', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('رقم الحساب: ${document.entityIban}', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('المبلغ رقماً: ${document.formattedAmount}', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('المبلغ كتابةً: ${document.amountInWords}', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('اسم المصرف: ${document.organizationBankName}', style: const pw.TextStyle(fontSize: 16)),
              if (document.purpose != null) ...[
                pw.SizedBox(height: 10),
                pw.Text('الغرض: ${document.purpose}', style: const pw.TextStyle(fontSize: 16)),
              ],
              
              pw.Spacer(),
              
              // QR Code
              pw.Center(
                child: pw.Text('QR Code: ${document.qrCodeData}'),
              ),
              
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('التوقيع الرقمي: ${document.verificationHash}'),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  Future<void> _printFinalDocument(List<int> pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
    );
  }

  Future<void> _deleteDraft(DocumentDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف مسودة "${draft.entityName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteDocumentDraft(draft.id);
        _showSuccessSnackBar('تم حذف المسودة بنجاح');
        _loadDrafts();
      } catch (e) {
        _showErrorSnackBar('خطأ في حذف المسودة: $e');
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getEntityTypeByDocumentType(String documentType) {
    switch (documentType) {
      case 'deductions':
        return 'الموظف';
      case 'payments':
        return 'المورد / الجهة';
      case 'transfers':
        return 'البنك / الجهة';
      default:
        return 'الجهة';
    }
  }

  Future<void> _createAndDownloadTemplate(String documentType, int month, int year) async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('جارٍ إنشاء القالب...'),
          duration: Duration(seconds: 2),
        ),
      );

      await _excelService.createTemplate(
        documentType: documentType,
        month: month,
        year: year,
      );
      
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء وتحميل القالب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء القالب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDocumentTypeArabic(String type) {
    switch (type.toLowerCase()) {
      case 'deductions':
        return 'استقطاعات';
      case 'payments':
        return 'مدفوعات';
      case 'transfers':
        return 'تحويلات';
      default:
        return type;
    }
  }

  String _getMonthArabic(int month) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month >= 1 && month <= 12 ? arabicMonths[month - 1] : 'غير محدد';
  }
}