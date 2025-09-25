import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../models/document.dart';
import '../providers/documents_provider.dart';
import '../services/excel_service.dart';
import '../screens/add_document_screen.dart';

class ReportsByRecipientScreen extends StatefulWidget {
  const ReportsByRecipientScreen({Key? key}) : super(key: key);

  @override
  State<ReportsByRecipientScreen> createState() =>
      _ReportsByRecipientScreenState();
}

class _ReportsByRecipientScreenState extends State<ReportsByRecipientScreen> {
  String? _selectedRecipient;
  DateTime? _startDate;
  DateTime? _endDate;
  DocumentStatus? _selectedStatus;
  bool _isLoading = false;

  List<Document> _filteredDocuments = [];
  Map<String, List<Document>> _documentsByRecipient = {};
  Map<String, double> _totalAmountsByRecipient = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<DocumentsProvider>(context, listen: false);
      await provider.loadDocuments();
      _applyFilters();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final provider = Provider.of<DocumentsProvider>(context, listen: false);
    List<Document> documents = List.from(provider.documents);

    // تطبيق فلتر التاريخ
    if (_startDate != null) {
      documents = documents.where((doc) {
        return doc.documentDate != null &&
            doc.documentDate!.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            );
      }).toList();
    }

    if (_endDate != null) {
      documents = documents.where((doc) {
        return doc.documentDate != null &&
            doc.documentDate!.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // تطبيق فلتر الحالة
    if (_selectedStatus != null) {
      documents = documents
          .where((doc) => doc.status == _selectedStatus)
          .toList();
    }

    // تطبيق فلتر الجهة
    if (_selectedRecipient != null) {
      documents = documents.where((doc) {
        return doc.recipientAddress?.contains(_selectedRecipient!) == true;
      }).toList();
    }

    // تجميع المستندات حسب الجهة
    _documentsByRecipient.clear();
    _totalAmountsByRecipient.clear();

    for (var doc in documents) {
      final recipient = doc.recipientAddress ?? 'غير محدد';

      if (_documentsByRecipient.containsKey(recipient)) {
        _documentsByRecipient[recipient]!.add(doc);
      } else {
        _documentsByRecipient[recipient] = [doc];
      }

      // حساب المجموع
      final amount = doc.amount ?? 0.0;
      _totalAmountsByRecipient[recipient] =
          (_totalAmountsByRecipient[recipient] ?? 0.0) + amount;
    }

    setState(() {
      _filteredDocuments = documents;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  Future<void> _exportToExcel() async {
    if (_filteredDocuments.isEmpty) {
      _showErrorSnackBar('لا توجد بيانات للتصدير');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ExcelService.exportDocumentsToExcel(_filteredDocuments);

      _showSuccessSnackBar('تم تصدير التقرير بنجاح');
    } catch (e) {
      _showErrorSnackBar('خطأ في تصدير التقرير: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير حسب الجهة'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _isLoading ? null : _exportToExcel,
            tooltip: 'تصدير إلى Excel',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersCard(),
                _buildSummaryCard(),
                Expanded(child: _buildReportsList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'إضافة مستند جديد',
      ),
    );
  }

  Widget _buildFiltersCard() {
    final provider = Provider.of<DocumentsProvider>(context);
    final recipients =
        provider.documents
            .map((doc) => doc.recipientAddress ?? 'غير محدد')
            .toSet()
            .toList()
          ..sort();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'فلاتر البحث',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // فلتر الجهة
            DropdownButtonFormField<String>(
              value: _selectedRecipient,
              decoration: const InputDecoration(
                labelText: 'الجهة',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('جميع الجهات'),
                ),
                ...recipients.map(
                  (recipient) => DropdownMenuItem<String>(
                    value: recipient,
                    child: Text(recipient),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedRecipient = value);
                _applyFilters();
              },
            ),

            const SizedBox(height: 16),

            // فلاتر التاريخ
            Row(
              children: [
                Expanded(child: _buildDateFilter('من تاريخ', _startDate, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDateFilter('إلى تاريخ', _endDate, false)),
              ],
            ),

            const SizedBox(height: 16),

            // فلتر الحالة
            DropdownButtonFormField<DocumentStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'حالة المستند',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem<DocumentStatus>(
                  value: null,
                  child: Text('جميع الحالات'),
                ),
                ...DocumentStatus.values.map(
                  (status) => DropdownMenuItem<DocumentStatus>(
                    value: status,
                    child: Text(_getStatusText(status)),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(String label, DateTime? date, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          date != null
              ? intl.DateFormat('yyyy/MM/dd').format(date)
              : 'اختر التاريخ',
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_filteredDocuments.isEmpty) return const SizedBox();

    final totalCount = _filteredDocuments.length;
    final totalAmount = _filteredDocuments
        .map((doc) => doc.amount ?? 0.0)
        .reduce((a, b) => a + b);
    final recipientCount = _documentsByRecipient.keys.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'عدد المستندات',
              totalCount.toString(),
              Icons.description,
            ),
            _buildSummaryItem(
              'عدد الجهات',
              recipientCount.toString(),
              Icons.business,
            ),
            _buildSummaryItem(
              'المجموع الكلي',
              '${intl.NumberFormat('#,##0.00').format(totalAmount)} د.ع',
              Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsList() {
    if (_documentsByRecipient.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد مستندات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documentsByRecipient.keys.length,
      itemBuilder: (context, index) {
        final recipient = _documentsByRecipient.keys.elementAt(index);
        final documents = _documentsByRecipient[recipient]!;
        final totalAmount = _totalAmountsByRecipient[recipient]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              recipient,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'عدد المستندات: ${documents.length} - المجموع: ${intl.NumberFormat('#,##0.00').format(totalAmount)} د.ع',
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: Text(
                '${documents.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: documents.map((doc) => _buildDocumentTile(doc)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDocumentTile(Document document) {
    return ListTile(
      title: Text('رقم الصادر: ${document.outgoingNumber ?? 'غير محدد'}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التاريخ: ${_formatDate(document.documentDate)}'),
          Text(
            'المبلغ: ${intl.NumberFormat('#,##0.00').format(document.amount ?? 0)} د.ع',
          ),
          Text('الحالة: ${_getStatusText(document.status)}'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'edit':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDocumentScreen(document: document),
                ),
              ).then((_) => _loadData());
              break;
            case 'details':
              _showDocumentDetails(document);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'details',
            child: Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 8),
                Text('التفاصيل'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [Icon(Icons.edit), SizedBox(width: 8), Text('تعديل')],
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المستند ${document.outgoingNumber ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'رقم الصادر',
                '${document.outgoingNumber ?? 'غير محدد'}',
              ),
              _buildDetailRow(
                'تاريخ المستند',
                _formatDate(document.documentDate),
              ),
              _buildDetailRow(
                'المبلغ رقماً',
                '${intl.NumberFormat('#,##0.00').format(document.amount ?? 0)} د.ع',
              ),
              _buildDetailRow(
                'المبلغ كتابة',
                document.amountInWords ?? 'غير محدد',
              ),
              _buildDetailRow(
                'إيبان الدائرة',
                document.departmentIban ?? 'غير محدد',
              ),
              _buildDetailRow(
                'إيبان المستفيد',
                document.recipientIban ?? 'غير محدد',
              ),
              _buildDetailRow(
                'عنوان الجهة',
                document.recipientAddress ?? 'غير محدد',
              ),
              _buildDetailRow(
                'تفاصيل المستند',
                document.documentDetails ?? 'غير محدد',
              ),
              _buildDetailRow('الحالة', _getStatusText(document.status)),
              if (document.uploadDate != null)
                _buildDetailRow(
                  'تاريخ الرفع',
                  _formatDate(document.uploadDate),
                ),
              if (document.bankNotificationNumber?.isNotEmpty == true)
                _buildDetailRow(
                  'رقم الإشعار البنكي',
                  document.bankNotificationNumber!,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return intl.DateFormat('yyyy/MM/dd').format(date);
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
}
