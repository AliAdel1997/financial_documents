import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../models/document.dart';
import '../providers/documents_provider.dart';
import '../services/database_service.dart';

class AddDocumentScreen extends StatefulWidget {
  final Document? document; // للتعديل

  const AddDocumentScreen({Key? key, this.document}) : super(key: key);

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers للنصوص
  final _amountController = TextEditingController();
  final _amountInWordsController = TextEditingController();
  final _departmentIbanController = TextEditingController();
  final _recipientIbanController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _documentDetailsController = TextEditingController();
  final _bankNotificationNumberController = TextEditingController();

  // متغيرات التاريخ
  DateTime _documentDate = DateTime.now();
  DateTime? _uploadDate;

  // متغيرات الحالة
  DocumentStatus _status = DocumentStatus.draft;
  bool _isUploaded = false;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.document != null;
    if (_isEditing) {
      _loadDocumentData();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountInWordsController.dispose();
    _departmentIbanController.dispose();
    _recipientIbanController.dispose();
    _recipientAddressController.dispose();
    _documentDetailsController.dispose();
    _bankNotificationNumberController.dispose();
    super.dispose();
  }

  void _loadDocumentData() {
    final doc = widget.document!;
    _amountController.text = doc.amount?.toString() ?? '';
    _amountInWordsController.text = doc.amountInWords ?? '';
    _departmentIbanController.text = doc.departmentIban ?? '';
    _recipientIbanController.text = doc.recipientIban ?? '';
    _recipientAddressController.text = doc.recipientAddress ?? '';
    _documentDetailsController.text = doc.documentDetails ?? '';
    _bankNotificationNumberController.text = doc.bankNotificationNumber ?? '';
    _documentDate = doc.documentDate ?? DateTime.now();
    _uploadDate = doc.uploadDate;
    _status = doc.status;
    _isUploaded = doc.uploadDate != null;
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<DocumentsProvider>(context, listen: false);

      // تحديد رقم الصادر التلقائي إذا لم يكن موجوداً
      int? outgoingNumber;
      if (_isEditing) {
        outgoingNumber = widget.document!.outgoingNumber;
      } else {
        outgoingNumber = await DatabaseService.getNextOutgoingNumber();
      }

      final document = Document(
        outgoingNumber: outgoingNumber,
        documentDate: _documentDate,
        amount: double.tryParse(_amountController.text),
        amountInWords: _amountInWordsController.text.trim(),
        departmentIban: _departmentIbanController.text.trim(),
        recipientIban: _recipientIbanController.text.trim(),
        recipientAddress: _recipientAddressController.text.trim(),
        documentDetails: _documentDetailsController.text.trim(),
        bankNotificationNumber: _bankNotificationNumberController.text.trim(),
        uploadDate: _uploadDate,
        status: _status,
        createdAt: _isEditing ? widget.document!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // نسخ الـ ID إذا كان تعديل
      if (_isEditing) {
        document.id = widget.document!.id;
      }

      if (_isEditing) {
        await provider.updateDocument(document);
        _showSuccessSnackBar('تم تحديث المستند بنجاح');
      } else {
        await provider.addDocument(document);
        _showSuccessSnackBar(
          'تم إضافة المستند بنجاح - رقم الصادر: $outgoingNumber',
        );
      }

      Navigator.pop(context, document);
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ المستند: $e');
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

  Future<void> _selectDate(BuildContext context, bool isDocumentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDocumentDate
          ? _documentDate
          : (_uploadDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        if (isDocumentDate) {
          _documentDate = picked;
        } else {
          _uploadDate = picked;
        }
      });
    }
  }

  void _convertNumberToWords() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      final words = _convertAmountToArabicWords(amount);
      _amountInWordsController.text = words;
    }
  }

  String _convertAmountToArabicWords(double amount) {
    // تحويل بسيط للمبلغ إلى كلمات عربية
    // يمكن تطوير هذا ليصبح أكثر دقة
    final formatter = intl.NumberFormat('#,##0.00', 'ar');
    final formattedAmount = formatter.format(amount);
    return '$formattedAmount دينار عراقي';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'تعديل المستند' : 'إضافة مستند جديد'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveDocument,
                tooltip: 'حفظ',
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (_isEditing) _buildInfoCard(),

                      _buildSectionCard(
                        title: 'بيانات المستند الأساسية',
                        icon: Icons.description,
                        children: [
                          _buildDateField(
                            label: 'تاريخ المستند',
                            date: _documentDate,
                            onTap: () => _selectDate(context, true),
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _documentDetailsController,
                            label: 'تفاصيل الكتاب/المستند',
                            hint: 'اكتب تفاصيل المستند هنا...',
                            maxLines: 4,
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'تفاصيل المستند مطلوبة'
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'المبلغ المالي',
                        icon: Icons.attach_money,
                        children: [
                          _buildTextFormField(
                            controller: _amountController,
                            label: 'المبلغ (رقماً)',
                            hint: '0.00',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value?.trim().isEmpty == true) {
                                return 'المبلغ مطلوب';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'أدخل مبلغاً صحيحاً';
                              }
                              return null;
                            },
                            onChanged: (value) => _convertNumberToWords(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _convertNumberToWords,
                              tooltip: 'تحويل إلى كلمات',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _amountInWordsController,
                            label: 'المبلغ (كتابة)',
                            hint: 'سيتم تحويله تلقائياً من الرقم',
                            maxLines: 2,
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'المبلغ كتابة مطلوب'
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'معلومات الحسابات',
                        icon: Icons.account_balance,
                        children: [
                          _buildTextFormField(
                            controller: _departmentIbanController,
                            label: 'إيبان الدائرة',
                            hint: 'IQ##XXXX################',
                            validator: _validateIban,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _recipientIbanController,
                            label: 'إيبان الجهة المراد التحويل إليها',
                            hint: 'IQ##XXXX################',
                            validator: _validateIban,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _recipientAddressController,
                            label: 'عنوان الجهة',
                            hint: 'العنوان الكامل للجهة المستفيدة',
                            maxLines: 2,
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'عنوان الجهة مطلوب'
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'حالة المستند',
                        icon: Icons.info,
                        children: [
                          _buildStatusDropdown(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _isUploaded,
                                onChanged: (value) {
                                  setState(() {
                                    _isUploaded = value ?? false;
                                    if (_isUploaded && _uploadDate == null) {
                                      _uploadDate = DateTime.now();
                                    } else if (!_isUploaded) {
                                      _uploadDate = null;
                                      _bankNotificationNumberController.clear();
                                    }
                                  });
                                },
                              ),
                              const Text('تم الرفع للبنك'),
                            ],
                          ),
                          if (_isUploaded) ...[
                            const SizedBox(height: 16),
                            _buildDateField(
                              label: 'تاريخ الرفع',
                              date: _uploadDate,
                              onTap: () => _selectDate(context, false),
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              controller: _bankNotificationNumberController,
                              label: 'رقم الإشعار البنكي',
                              hint: 'رقم الإشعار المستلم من البنك',
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              'رقم الصادر: ${widget.document!.outgoingNumber ?? 'غير محدد'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? intl.DateFormat('yyyy/MM/dd', 'ar').format(date)
              : 'اختر التاريخ',
          style: TextStyle(color: date != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<DocumentStatus>(
      value: _status,
      decoration: const InputDecoration(
        labelText: 'حالة المستند',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: DocumentStatus.values.map((status) {
        return DropdownMenuItem<DocumentStatus>(
          value: status,
          child: Text(_getStatusText(status)),
        );
      }).toList(),
      onChanged: (DocumentStatus? newValue) {
        if (newValue != null) {
          setState(() {
            _status = newValue;
          });
        }
      },
    );
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

  String? _validateIban(String? value) {
    if (value?.trim().isEmpty == true) {
      return 'رقم الآيبان مطلوب';
    }

    final iban = value!.trim().toUpperCase();

    if (iban.length != 23) {
      return 'رقم الآيبان يجب أن يكون 23 رقم';
    }

    if (!iban.startsWith('IQ')) {
      return 'رقم الآيبان يجب أن يبدأ بـ IQ';
    }

    return null;
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveDocument,
            icon: const Icon(Icons.save),
            label: Text(_isEditing ? 'حفظ التغييرات' : 'حفظ المستند'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
