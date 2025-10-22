import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// شاشة الحجوزات - للأبواب الفرعية فقط
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  // متغيرات النموذج
  List<FundingCategory> _subCategories = [];
  FundingCategory? _selectedSubCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _beneficiaryController = TextEditingController();

  // متغيرات الملفات
  List<PlatformFile> _attachedFiles = [];

  // متغيرات الحالة
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<FundingTransaction> _reservations = [];
  InstitutionFunding? _currentFunding;

  // متحكمات التنسيق
  final intl.NumberFormat _currencyFormat = intl.NumberFormat('#,##0', 'ar');
  final intl.DateFormat _dateFormat = intl.DateFormat('yyyy/MM/dd', 'ar');

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _beneficiaryController.dispose();
    super.dispose();
  }

  /// الحصول على لون الحالة
  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.reserved:
        return Colors.orange;
      case ReservationStatus.approved:
        return Colors.blue;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.spent:
        return Colors.green;
    }
  }

  /// تحديث حالة الحجز
  Future<void> _updateReservationStatus(
    FundingTransaction reservation,
    ReservationStatus newStatus,
  ) async {
    try {
      // تحديث الحجز
      final updatedReservation = reservation.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        executionDate: newStatus == ReservationStatus.spent
            ? DateTime.now()
            : reservation.executionDate,
      );

      await DatabaseService.updateFundingTransaction(updatedReservation);

      // إعادة تحميل البيانات
      await _loadReservations();

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث حالة الحجز إلى: ${newStatus.displayName}'),
            backgroundColor: _getStatusColor(newStatus),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحالة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSubCategories() async {
    setState(() => _isLoading = true);
    try {
      final allCategories = await DatabaseService.getAllFundingCategories();
      // فقط الأبواب الفرعية (التي لها parentId)
      _subCategories = allCategories.where((c) => c.parentId != null).toList();
      await _loadReservations();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأبواب: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReservations() async {
    try {
      _reservations = await DatabaseService.getPendingReservations();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الحجوزات: $e');
    }
  }

  Future<void> _loadCategoryFunding(FundingCategory category) async {
    try {
      final fundings = await DatabaseService.getInstitutionFundingByCategory(
        category.id,
      );
      if (fundings.isNotEmpty) {
        _currentFunding = fundings.first;
      } else {
        _currentFunding = null;
      }
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل بيانات التمويل: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showReservationHistory(),
            tooltip: 'تاريخ الحجوزات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subCategories.isEmpty
          ? _buildEmptyState()
          : _buildReservationInterface(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد أبواب فرعية',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            'يجب إنشاء أبواب فرعية وتخصيص تمويل لها أولاً',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('العودة'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationInterface() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // نموذج إنشاء الحجز - بارتفاع محدد
            SizedBox(
              height: 400, // ارتفاع ثابت للنموذج
              child: SingleChildScrollView(child: _buildReservationForm()),
            ),

            // قائمة الحجوزات الحالية - باقي المساحة المتاحة
            SizedBox(
              height: constraints.maxHeight - 400,
              child: _buildReservationsList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReservationForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_add, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'إنشاء حجز جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // اختيار الباب الفرعي
              _buildSubCategoryDropdown(),
              const SizedBox(height: 16),

              // عرض معلومات التمويل المتاح
              if (_currentFunding != null) _buildFundingInfo(),
              const SizedBox(height: 16),

              // مبلغ الحجز
              _buildAmountField(),
              const SizedBox(height: 16),

              // وصف الحجز
              _buildDescriptionField(),
              const SizedBox(height: 16),

              // المستفيد
              _buildBeneficiaryField(),
              const SizedBox(height: 16),

              // المرفقات
              _buildAttachmentsSection(),
              const SizedBox(height: 24),

              // أزرار الحفظ
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryDropdown() {
    return DropdownButtonFormField<FundingCategory>(
      value: _selectedSubCategory,
      decoration: const InputDecoration(
        labelText: 'الباب الفرعي',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_tree),
      ),
      items: _subCategories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category.name));
      }).toList(),
      onChanged: (category) {
        setState(() {
          _selectedSubCategory = category;
          _currentFunding = null;
        });
        if (category != null) {
          _loadCategoryFunding(category);
        }
      },
      validator: (value) => value == null ? 'يجب اختيار الباب الفرعي' : null,
    );
  }

  Widget _buildFundingInfo() {
    final funding = _currentFunding!;
    final availableAmount =
        funding.allocatedAmount - funding.reservedAmount - funding.spentAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: availableAmount > 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: availableAmount > 0 ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المبلغ المخصص:'),
              Text(
                '${_currencyFormat.format(funding.allocatedAmount)} د.ع',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المحجوز:'),
              Text(
                '${_currencyFormat.format(funding.reservedAmount)} د.ع',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المصروف:'),
              Text(
                '${_currencyFormat.format(funding.spentAmount)} د.ع',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المتاح للحجز:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_currencyFormat.format(availableAmount)} د.ع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: availableAmount > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'مبلغ الحجز (دينار عراقي)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'د.ع',
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
          return 'يجب إدخال المبلغ';
        }
        final numericValue = value.replaceAll(',', '');
        final amount = double.tryParse(numericValue);
        if (amount == null || amount <= 0) {
          return 'يجب إدخال مبلغ صحيح';
        }
        if (_currentFunding != null) {
          final available =
              _currentFunding!.allocatedAmount -
              _currentFunding!.reservedAmount -
              _currentFunding!.spentAmount;
          if (amount > available) {
            return 'المبلغ يتجاوز المتاح (${_currencyFormat.format(available)} د.ع)';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'وصف الحجز',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يجب إدخال وصف الحجز';
        }
        return null;
      },
    );
  }

  Widget _buildBeneficiaryField() {
    return TextFormField(
      controller: _beneficiaryController,
      decoration: const InputDecoration(
        labelText: 'المستفيد',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
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
              'المرفقات (PDF)',
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

  Widget _buildActionButtons() {
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
              onPressed: _isSubmitting ? null : _submitReservation,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ الحجز'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد حجوزات',
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
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return _buildReservationCard(reservation);
      },
    );
  }

  Widget _buildReservationCard(FundingTransaction reservation) {
    final category = _subCategories.firstWhere(
      (c) => c.id == reservation.categoryId,
      orElse: () => FundingCategory()..name = 'غير معروف',
    );

    // تحديد عمر الحجز
    final daysSinceReservation = DateTime.now()
        .difference(reservation.createdAt ?? DateTime.now())
        .inDays;
    final isOld = daysSinceReservation > 30;

    return Card(
      color: isOld ? Colors.red[50] : null,
      child: ListTile(
        title: Text(reservation.requestDescription ?? 'لا يوجد وصف'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الباب: ${category.name}'),
            Text(
              'المبلغ المطلوب: ${_currencyFormat.format(reservation.requestedAmount)} د.ع',
            ),
            Text(
              'تاريخ الحجز: ${_dateFormat.format(reservation.createdAt ?? DateTime.now())}',
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_currencyFormat.format(reservation.requestedAmount)} د.ع',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              reservation.statusText,
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(reservation.status),
              ),
            ),
          ],
        ),
        onTap: () => _showReservationDetails(reservation),
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
    _amountController.clear();
    _descriptionController.clear();
    _beneficiaryController.clear();
    setState(() {
      _selectedSubCategory = null;
      _currentFunding = null;
      _attachedFiles.clear();
    });
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amountText = _amountController.text.replaceAll(',', '');
      final amount = double.parse(amountText);

      // إنشاء الحجز
      final reservation = FundingTransaction()
        ..categoryId = _selectedSubCategory!.id
        ..requestedAmount = amount
        ..requestDescription = _descriptionController.text.trim()
        ..status = ReservationStatus.reserved
        ..year = DateTime.now().year
        ..month = DateTime.now().month
        ..requestDate = DateTime.now()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await DatabaseService.saveFundingTransaction(reservation);

      // حفظ المرفقات
      for (final file in _attachedFiles) {
        final attachment = FundingAttachment()
          ..fundingId = _currentFunding?.id
          ..fileName = file.name
          ..filePath = file.path ?? ''
          ..fileType = file.extension
          ..uploadedAt = DateTime.now();

        await DatabaseService.addFundingAttachment(attachment);
      }

      // تحديث المبلغ المحجوز
      if (_currentFunding != null) {
        _currentFunding!.reservedAmount += amount;
        await DatabaseService.updateInstitutionFunding(_currentFunding!);
      }

      _showSuccessSnackBar('تم حفظ الحجز بنجاح');
      _clearForm();
      await _loadReservations();
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ الحجز: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showReservationDetails(FundingTransaction reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفاصيل الحجز'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'الوصف:',
                reservation.requestDescription ?? 'لا يوجد وصف',
              ),
              _buildDetailRow(
                'المبلغ المطلوب:',
                '${_currencyFormat.format(reservation.requestedAmount)} د.ع',
              ),
              _buildDetailRow('الحالة:', reservation.statusText),
              _buildDetailRow(
                'تاريخ الإنشاء:',
                _dateFormat.format(reservation.createdAt ?? DateTime.now()),
              ),
              // TODO: عرض المرفقات
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          // أزرار تغيير الحالة
          if (reservation.status == ReservationStatus.reserved) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateReservationStatus(
                  reservation,
                  ReservationStatus.approved,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('اعتماد'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateReservationStatus(
                  reservation,
                  ReservationStatus.cancelled,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('إلغاء'),
            ),
          ],
          if (reservation.status == ReservationStatus.approved)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateReservationStatus(reservation, ReservationStatus.spent);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('صرف'),
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
            width: 80,
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

  void _showReservationHistory() {
    // TODO: تنفيذ شاشة تاريخ الحجوزات
    _showErrorSnackBar('قريباً: شاشة تاريخ الحجوزات');
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
