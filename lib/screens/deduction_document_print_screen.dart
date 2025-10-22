import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DeductionDocumentPrintScreen extends StatefulWidget {
  const DeductionDocumentPrintScreen({super.key});

  @override
  State<DeductionDocumentPrintScreen> createState() => _DeductionDocumentPrintScreenState();
}

class _DeductionDocumentPrintScreenState extends State<DeductionDocumentPrintScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _amountController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Data
  List<Map<String, dynamic>> _entities = [];
  Map<String, dynamic>? _selectedEntity;
  DateTime _documentDate = DateTime.now();
  String _documentNumber = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntities();
    _generateDocumentNumber();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _employeeNameController.dispose();
    _employeeNumberController.dispose();
    _departmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEntities() async {
    setState(() => _isLoading = true);
    
    try {
      final entities = await DatabaseService.getActiveDeductionEntities();
      setState(() {
        _entities = entities.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل جهات الاستقطاع: $e');
    }
  }

  void _generateDocumentNumber() {
    final now = DateTime.now();
    final docNumber = 'DED-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    setState(() {
      _documentNumber = docNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طباعة مستند استقطاع'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadEntities();
              _generateDocumentNumber();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات المستند الأساسية
                    _buildSectionTitle('معلومات المستند'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _documentNumber,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم المستند',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.numbers),
                                    ),
                                    onChanged: (value) => _documentNumber = value,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال رقم المستند';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'تاريخ المستند',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(_formatDate(_documentDate)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // جهة الاستقطاع
                    _buildSectionTitle('جهة الاستقطاع'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: _selectedEntity,
                              decoration: const InputDecoration(
                                labelText: 'اختر جهة الاستقطاع *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              items: _entities.map((entity) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: entity,
                                  child: SizedBox(
                                    width: 200,
                                    child: Text(
                                      entity['name'] ?? 'غير محدد',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEntity = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار جهة الاستقطاع';
                                }
                                return null;
                              },
                            ),
                            
                            if (_selectedEntity != null) ...[
                              const SizedBox(height: 16),
                              _buildEntityInfo(_selectedEntity!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // تفاصيل الاستقطاع
                    _buildSectionTitle('تفاصيل الاستقطاع'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'مبلغ الاستقطاع (د.ع) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                                suffixText: 'د.ع',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال المبلغ';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'يرجى إدخال مبلغ صحيح';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'يجب أن يكون المبلغ أكبر من صفر';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _employeeNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'اسم الموظف',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _employeeNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم الموظف',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.badge),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _departmentController,
                              decoration: const InputDecoration(
                                labelText: 'القسم',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.apartment),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'ملاحظات إضافية',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // أزرار العمليات
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _previewDocument,
                            icon: const Icon(Icons.preview),
                            label: const Text('معاينة المستند'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _printDocument,
                            icon: const Icon(Icons.print),
                            label: const Text('طباعة المستند'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildEntityInfo(Map<String, dynamic> entity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الجهة المحددة:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (entity['iban'] != null && entity['iban'].toString().isNotEmpty)
            _buildInfoRow('الإيبان:', entity['iban'], Icons.account_balance),
          if (entity['email'] != null && entity['email'].toString().isNotEmpty)
            _buildInfoRow('الإيميل:', entity['email'], Icons.email),
          if (entity['phone'] != null && entity['phone'].toString().isNotEmpty)
            _buildInfoRow('الهاتف:', entity['phone'], Icons.phone),
          if (entity['address'] != null && entity['address'].toString().isNotEmpty)
            _buildInfoRow('العنوان:', entity['address'], Icons.location_on),
          if (entity['notes'] != null && entity['notes'].toString().isNotEmpty)
            _buildInfoRow('ملاحظات:', entity['notes'], Icons.note),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _documentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _documentDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _previewDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final pdfBytes = await _generatePDF();
      
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('معاينة المستند'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printPDF(pdfBytes),
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
    } catch (e) {
      _showErrorSnackBar('خطأ في إنشاء المعاينة: $e');
    }
  }

  Future<void> _printDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final pdfBytes = await _generatePDF();
      await _printPDF(pdfBytes);
      
      _showSuccessSnackBar('تم إرسال المستند للطباعة بنجاح');
      
      // إعادة تعيين النموذج
      _resetForm();
    } catch (e) {
      _showErrorSnackBar('خطأ في طباعة المستند: $e');
    }
  }

  Future<List<int>> _generatePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس المستند
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(width: 2),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'مستند استقطاع',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'رقم المستند: $_documentNumber',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          'التاريخ: ${_formatDate(_documentDate)}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // معلومات جهة الاستقطاع
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  color: PdfColors.blue50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'معلومات جهة الاستقطاع:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('الاسم: ${_selectedEntity!['name']}', style: const pw.TextStyle(fontSize: 12)),
                    if (_selectedEntity!['iban'] != null && _selectedEntity!['iban'].toString().isNotEmpty)
                      pw.Text('الإيبان: ${_selectedEntity!['iban']}', style: const pw.TextStyle(fontSize: 12)),
                    if (_selectedEntity!['email'] != null && _selectedEntity!['email'].toString().isNotEmpty)
                      pw.Text('البريد الإلكتروني: ${_selectedEntity!['email']}', style: const pw.TextStyle(fontSize: 12)),
                    if (_selectedEntity!['phone'] != null && _selectedEntity!['phone'].toString().isNotEmpty)
                      pw.Text('رقم الهاتف: ${_selectedEntity!['phone']}', style: const pw.TextStyle(fontSize: 12)),
                    if (_selectedEntity!['address'] != null && _selectedEntity!['address'].toString().isNotEmpty)
                      pw.Text('العنوان: ${_selectedEntity!['address']}', style: const pw.TextStyle(fontSize: 12)),
                    if (_selectedEntity!['notes'] != null && _selectedEntity!['notes'].toString().isNotEmpty)
                      pw.Text('ملاحظات الجهة: ${_selectedEntity!['notes']}', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // تفاصيل الاستقطاع
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  color: PdfColors.green50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'تفاصيل الاستقطاع:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المبلغ المستقطع:', style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          '${_amountController.text} د.ع',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                    if (_employeeNameController.text.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text('اسم الموظف: ${_employeeNameController.text}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                    if (_employeeNumberController.text.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text('رقم الموظف: ${_employeeNumberController.text}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                    if (_departmentController.text.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text('القسم: ${_departmentController.text}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                    if (_notesController.text.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text('ملاحظات إضافية: ${_notesController.text}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // التوقيعات
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('توقيع المسؤول', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.black,
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('توقيع المحاسب', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.black,
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // معلومات إضافية
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(
                  'تم إنشاء هذا المستند تلقائياً بتاريخ ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printPDF(List<int> pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => Uint8List.fromList(pdfBytes),
        name: 'مستند_استقطاع_$_documentNumber',
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في الطباعة: $e');
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _employeeNameController.clear();
    _employeeNumberController.clear();
    _departmentController.clear();
    _notesController.clear();
    
    setState(() {
      _selectedEntity = null;
      _documentDate = DateTime.now();
    });
    
    _generateDocumentNumber();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}