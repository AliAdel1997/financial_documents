import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// شاشة تنفيذ المصروفات
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  // متغيرات النموذج
  List<FundingTransaction> _pendingReservations = [];
  FundingTransaction? _selectedReservation;
  final TextEditingController _executedAmountController =
      TextEditingController();
  final TextEditingController _executionDescriptionController =
      TextEditingController();
  final TextEditingController _beneficiaryController = TextEditingController();

  // متغيرات الملفات
  List<PlatformFile> _attachedFiles = [];

  // متغيرات الحالة
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<FundingTransaction> _executedTransactions = [];

  // متحكمات التنسيق
  final intl.NumberFormat _currencyFormat = intl.NumberFormat('#,##0', 'ar');
  final intl.DateFormat _dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _executedAmountController.dispose();
    _executionDescriptionController.dispose();
    _beneficiaryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadPendingReservations();
      await _loadExecutedTransactions();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPendingReservations() async {
    try {
      // تحميل الحجوزات المعتمدة (الجاهزة للصرف)
      _pendingReservations = await DatabaseService.getApprovedReservations();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الحجوزات المعلقة: $e');
    }
  }

  Future<void> _loadExecutedTransactions() async {
    try {
      _executedTransactions = await DatabaseService.getExecutedTransactions();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل المعاملات المنفذة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المصروفات'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'الحجوزات المعلقة'),
              Tab(icon: Icon(Icons.check_circle), text: 'المعاملات المنفذة'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPendingReservationsTab(),
                  _buildExecutedTransactionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildPendingReservationsTab() {
    return Column(
      children: [
        // نموذج تنفيذ المصروف
        if (_pendingReservations.isNotEmpty)
          Flexible(child: _buildExpenseExecutionForm()),

        // قائمة الحجوزات المعلقة
        Expanded(child: _buildPendingReservationsList()),
      ],
    );
  }

  Widget _buildExecutedTransactionsTab() {
    return _buildExecutedTransactionsList();
  }

  Widget _buildExpenseExecutionForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'تنفيذ مصروف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // اختيار الحجز
                _buildReservationDropdown(),
                const SizedBox(height: 16),

                // عرض تفاصيل الحجز المختار
                if (_selectedReservation != null) _buildReservationDetails(),
                const SizedBox(height: 16),

                // المبلغ المنفذ
                _buildExecutedAmountField(),
                const SizedBox(height: 16),

                // وصف التنفيذ
                _buildExecutionDescriptionField(),
                const SizedBox(height: 16),

                // المستفيد الفعلي
                _buildBeneficiaryField(),
                const SizedBox(height: 16),

                // المرفقات
                _buildAttachmentsSection(),
                const SizedBox(height: 24),

                // أزرار التنفيذ
                _buildExecutionActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationDropdown() {
    return DropdownButtonFormField<FundingTransaction>(
      value: _selectedReservation,
      decoration: const InputDecoration(
        labelText: 'اختيار الحجز المراد تنفيذه',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.bookmark),
        helperText: 'اختر من الحجوزات المعتمدة',
      ),
      items: _pendingReservations.map((reservation) {
        return DropdownMenuItem(
          value: reservation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200, // Fixed width to prevent overflow
                      child: Text(
                        reservation.requestDescription ?? 'لا يوجد وصف',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currencyFormat.format(reservation.requestedAmount)} د.ع',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'السنة: ${reservation.year}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    if (reservation.month > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          _getMonthName(reservation.month),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _dateFormat.format(
                        reservation.requestDate ?? DateTime.now(),
                      ),
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (reservation) {
        setState(() {
          _selectedReservation = reservation;
          if (reservation != null) {
            _executedAmountController.text = _currencyFormat.format(
              reservation.requestedAmount,
            );
            _executionDescriptionController.text =
                reservation.requestDescription ?? '';
          }
        });
      },
      validator: (value) => value == null ? 'يجب اختيار الحجز' : null,
    );
  }

  /// الحصول على اسم الشهر بالعربية
  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return month > 0 && month <= 12 ? months[month - 1] : 'غير محدد';
  }

  Widget _buildReservationDetails() {
    final reservation = _selectedReservation!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 18),
              const SizedBox(width: 4),
              const Text(
                'تفاصيل الحجز المختار:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // المبلغ المحجوز
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.green[700],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text('المبلغ المحجوز:'),
                  ],
                ),
                Text(
                  '${_currencyFormat.format(reservation.requestedAmount)} د.ع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // الفترة الزمنية
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
              const SizedBox(width: 4),
              Text(
                'الفترة: السنة ${reservation.year}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (reservation.month > 0) ...[
                const Text(' - ', style: TextStyle(color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getMonthName(reservation.month),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // تاريخ الحجز
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 4),
                  const Text('تاريخ طلب الحجز:'),
                ],
              ),
              Text(
                _dateFormat.format(reservation.requestDate ?? DateTime.now()),
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),

          if (reservation.requestDescription?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'وصف الحجز:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation.requestDescription!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExecutedAmountField() {
    return TextFormField(
      controller: _executedAmountController,
      decoration: const InputDecoration(
        labelText: 'المبلغ المنفذ (دينار عراقي)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'د.ع',
        helperText: 'يمكن أن يكون أقل من المبلغ المحجوز',
      ),
      keyboardType: TextInputType.number,
      textDirection: TextDirection.rtl,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final number = int.tryParse(newValue.text);
          if (number == null) return oldValue;
          final formatted = _currencyFormat.format(number);
          return TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يجب إدخال المبلغ المنفذ';
        }
        final numericValue = value.replaceAll(',', '');
        final amount = double.tryParse(numericValue);
        if (amount == null || amount <= 0) {
          return 'يجب إدخال مبلغ صحيح';
        }
        if (_selectedReservation != null &&
            amount > _selectedReservation!.requestedAmount) {
          return 'المبلغ المنفذ لا يمكن أن يتجاوز المبلغ المحجوز';
        }
        return null;
      },
    );
  }

  Widget _buildExecutionDescriptionField() {
    return TextFormField(
      controller: _executionDescriptionController,
      decoration: const InputDecoration(
        labelText: 'وصف التنفيذ',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        helperText: 'تفاصيل إضافية حول عملية الصرف',
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يجب إدخال وصف التنفيذ';
        }
        return null;
      },
    );
  }

  Widget _buildBeneficiaryField() {
    return TextFormField(
      controller: _beneficiaryController,
      decoration: const InputDecoration(
        labelText: 'المستفيد الفعلي',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        helperText: 'اسم الشخص أو الجهة التي تم صرف المبلغ لها',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يجب إدخال اسم المستفيد';
        }
        return null;
      },
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.attach_file, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'مرفقات التنفيذ (PDF)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // زر إضافة ملف
        OutlinedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.add),
          label: const Text('إضافة ملف PDF'),
        ),

        // قائمة الملفات المرفقة
        if (_attachedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...(_attachedFiles.map((file) => _buildAttachmentItem(file))),
        ],
      ],
    );
  }

  Widget _buildAttachmentItem(PlatformFile file) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(file.name),
        subtitle: Text('${(file.size / 1024).ceil()} KB'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _attachedFiles.remove(file);
            });
          },
        ),
      ),
    );
  }

  Widget _buildExecutionActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearForm,
              child: const Text('مسح'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _executeExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تنفيذ المصروف'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReservationsList() {
    if (_pendingReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد حجوزات معلقة',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text('جميع الحجوزات تم تنفيذها'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingReservations.length,
      itemBuilder: (context, index) {
        final reservation = _pendingReservations[index];
        return _buildPendingReservationCard(reservation);
      },
    );
  }

  Widget _buildPendingReservationCard(FundingTransaction reservation) {
    // تحديد عمر الحجز
    final daysSinceReservation = DateTime.now()
        .difference(reservation.requestDate ?? DateTime.now())
        .inDays;
    final isOld = daysSinceReservation > 30;

    return Card(
      color: isOld ? Colors.red[50] : null,
      child: ListTile(
        title: Text(reservation.requestDescription ?? 'لا يوجد وصف'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبلغ المحجوز: ${_currencyFormat.format(reservation.requestedAmount)} د.ع',
            ),
            Text(
              'تاريخ الحجز: ${_dateFormat.format(reservation.requestDate ?? DateTime.now())}',
            ),
            if (isOld)
              Text(
                'تحذير: الحجز عمره $daysSinceReservation يوم',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          onPressed: () {
            setState(() {
              _selectedReservation = reservation;
              _executedAmountController.text = _currencyFormat.format(
                reservation.requestedAmount,
              );
              _executionDescriptionController.text =
                  reservation.requestDescription ?? '';
            });
          },
          tooltip: 'تنفيذ هذا الحجز',
        ),
      ),
    );
  }

  Widget _buildExecutedTransactionsList() {
    if (_executedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات منفذة',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _executedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _executedTransactions[index];
        return _buildExecutedTransactionCard(transaction);
      },
    );
  }

  Widget _buildExecutedTransactionCard(FundingTransaction transaction) {
    return Card(
      child: ListTile(
        title: Text(
          transaction.executionDescription ??
              transaction.requestDescription ??
              'لا يوجد وصف',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبلغ المحجوز: ${_currencyFormat.format(transaction.requestedAmount)} د.ع',
            ),
            Text(
              'المبلغ المنفذ: ${_currencyFormat.format(transaction.executedAmount ?? 0)} د.ع',
            ),
            Text(
              'تاريخ التنفيذ: ${_dateFormat.format(transaction.executionDate ?? DateTime.now())}',
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            Text(
              'منفذ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الملفات: $e');
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _executedAmountController.clear();
    _executionDescriptionController.clear();
    _beneficiaryController.clear();
    setState(() {
      _selectedReservation = null;
      _attachedFiles.clear();
    });
  }

  Future<void> _executeExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReservation == null) return;

    setState(() => _isSubmitting = true);

    try {
      final executedAmountText = _executedAmountController.text.replaceAll(
        ',',
        '',
      );

      if (executedAmountText.isEmpty) {
        _showErrorSnackBar('يجب إدخال المبلغ المنفذ');
        return;
      }

      final executedAmount = double.tryParse(executedAmountText);
      if (executedAmount == null || executedAmount <= 0) {
        _showErrorSnackBar('يجب إدخال مبلغ صحيح');
        return;
      }

      if (executedAmount > _selectedReservation!.requestedAmount) {
        _showErrorSnackBar('المبلغ المنفذ لا يمكن أن يتجاوز المبلغ المحجوز');
        return;
      }

      // تنفيذ المعاملة
      final success = await DatabaseService.executeTransaction(
        _selectedReservation!.id,
        executedAmount,
        _executionDescriptionController.text.trim(),
        _attachedFiles.isNotEmpty ? _attachedFiles.first.path : null,
        DateTime.now(),
      );

      if (success) {
        // حفظ المرفقات الإضافية
        if (_selectedReservation!.fundingId != null) {
          for (final file in _attachedFiles) {
            final attachment = FundingAttachment()
              ..fundingId = _selectedReservation!.fundingId
              ..fileName = file.name
              ..filePath = file.path ?? ''
              ..fileType = file.extension
              ..uploadedAt = DateTime.now()
              ..description = 'مرفق تنفيذ المصروف';

            await DatabaseService.addFundingAttachment(attachment);
          }
        }

        _showSuccessSnackBar('تم تنفيذ المصروف بنجاح');
        _clearForm();
        await _loadData();
      } else {
        _showErrorSnackBar(
          'فشل في تنفيذ المصروف - تحقق من البيانات والحجز المختار',
        );
      }
    } catch (e) {
      print('خطأ تفصيلي في تنفيذ المصروف: $e');
      _showErrorSnackBar('خطأ في تنفيذ المصروف: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showTransactionDetails(FundingTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل المعاملة'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'الوصف الأصلي:',
                transaction.requestDescription ?? 'لا يوجد',
              ),
              _buildDetailRow(
                'وصف التنفيذ:',
                transaction.executionDescription ?? 'لا يوجد',
              ),
              _buildDetailRow(
                'المبلغ المحجوز:',
                '${_currencyFormat.format(transaction.requestedAmount)} د.ع',
              ),
              _buildDetailRow(
                'المبلغ المنفذ:',
                '${_currencyFormat.format(transaction.executedAmount ?? 0)} د.ع',
              ),
              _buildDetailRow(
                'تاريخ الحجز:',
                _dateFormat.format(transaction.requestDate ?? DateTime.now()),
              ),
              _buildDetailRow(
                'تاريخ التنفيذ:',
                _dateFormat.format(transaction.executionDate ?? DateTime.now()),
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
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
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
