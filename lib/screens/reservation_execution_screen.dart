import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/funding_models.dart';
import '../models/active_period.dart';
import '../services/database_service.dart';
import '../services/active_period_service.dart';

class ReservationExecutionScreen extends StatefulWidget {
  @override
  _ReservationExecutionScreenState createState() =>
      _ReservationExecutionScreenState();
}

class _ReservationExecutionScreenState
    extends State<ReservationExecutionScreen> {
  List<FundingTransaction> transactions = [];
  List<InstitutionFunding> allocations = [];
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];

  // متغيرات الفترة النشطة
  ActivePeriod? _activePeriod;
  bool _isLoadingPeriod = true;

  // فلاتر البحث (بدون سنة وشهر لأنها ثابتة)
  String _selectedStatus = 'all'; // all, pending, executed, cancelled

  @override
  void initState() {
    super.initState();
    _loadActivePeriod();
  }

  Future<void> _loadActivePeriod() async {
    setState(() {
      _isLoadingPeriod = true;
    });

    try {
      final activePeriod = await ActivePeriodService.getCurrentActivePeriod();

      if (activePeriod == null) {
        // لا توجد فترة نشطة - اقتراح فتح فترة جديدة
        await _showOpenPeriodDialog();
      } else {
        setState(() {
          _activePeriod = activePeriod;
        });
        await _loadData();
      }
    } catch (e) {
      print('خطأ في تحميل الفترة النشطة: $e');
      _showErrorSnackBar('خطأ في تحميل الفترة النشطة');
    } finally {
      setState(() {
        _isLoadingPeriod = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_activePeriod == null) return;

    try {
      // تحميل المعاملات للفترة النشطة فقط
      final loadedTransactions = await DatabaseService.isar.fundingTransactions
          .filter()
          .yearEqualTo(_activePeriod!.activeYear)
          .and()
          .monthEqualTo(_activePeriod!.activeMonth)
          .findAll();

      // تحميل التخصيصات للفترة النشطة فقط
      final loadedAllocations = await DatabaseService.isar.institutionFundings
          .filter()
          .yearEqualTo(_activePeriod!.activeYear)
          .and()
          .monthEqualTo(_activePeriod!.activeMonth)
          .findAll();

      // تحميل الأبواب
      final loadedCategories = await DatabaseService.isar.fundingCategorys
          .where()
          .findAll();

      // تحميل المؤسسات
      final loadedInstitutions = await DatabaseService.isar.institutions
          .where()
          .findAll();

      setState(() {
        transactions = loadedTransactions;
        allocations = loadedAllocations;
        categories = loadedCategories;
        institutions = loadedInstitutions;
      });
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات')));
    }
  }

  List<FundingTransaction> get _filteredTransactions {
    return transactions.where((transaction) {
      if (_selectedStatus != 'all' &&
          transaction.status.toString().split('.').last != _selectedStatus)
        return false;
      return true;
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showOpenPeriodDialog() async {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('فتح فترة مالية جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('لا توجد فترة مالية نشطة. يرجى فتح فترة مالية للعمل عليها.'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(3, (index) {
                        final year = now.year - 1 + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMonth = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final success = await ActivePeriodService.openNewPeriod(
                  selectedYear,
                  selectedMonth,
                  'المستخدم',
                  notes: 'فتح تلقائي من شاشة الحجز والصرف',
                );

                if (success) {
                  Navigator.of(context).pop();
                  await _loadActivePeriod();
                } else {
                  _showErrorSnackBar('فشل في فتح الفترة المالية');
                }
              },
              child: Text('فتح الفترة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReservationRequestDialog() async {
    InstitutionFunding? selectedAllocation;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedPdfPath;
    String? selectedPdfName;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('طلب حجز جديد'),
          content: SizedBox(
            width: 400,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اختيار التخصيص
                  DropdownButtonFormField<InstitutionFunding>(
                    value: selectedAllocation,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      labelText: 'اختيار التخصيص',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 500,
                    items: allocations.map((allocation) {
                      final categoryName = _getCategoryName(
                        allocation.categoryId,
                      );
                      final institutionName = _getInstitutionName(
                        allocation.institutionId,
                      );
                      final availableAmount = allocation.remainingAmount;
                      final fundingTypeText = allocation.fundingType;
                      final monthText = allocation.month != null
                          ? ' - ${_getMonthName(allocation.month!)}'
                          : '';

                      return DropdownMenuItem(
                        value: allocation,
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$categoryName - $institutionName',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: allocation.fundingType == 'شهري'
                                          ? Colors.orange[100]
                                          : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$fundingTypeText ${allocation.year}$monthText',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: allocation.fundingType == 'شهري'
                                            ? Colors.orange[800]
                                            : Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'مخصص: ${allocation.allocatedAmount.toStringAsFixed(0)} د.ع',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'متاح: ${availableAmount.toStringAsFixed(0)} د.ع',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: availableAmount > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedAllocation = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // المبلغ المطلوب
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ المطلوب حجزه',
                      border: OutlineInputBorder(),
                      suffixText: 'د.ع',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  // الوصف
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'وصف الطلب',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  // تاريخ الطلب
                  ListTile(
                    title: Text('تاريخ الطلب'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  // رفع مرفق PDF
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedPdfName ?? 'لم يتم اختيار مرفق PDF',
                            style: TextStyle(
                              color: selectedPdfName != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                              allowMultiple: false,
                            );

                            if (result != null &&
                                result.files.single.path != null) {
                              setDialogState(() {
                                selectedPdfPath = result.files.single.path;
                                selectedPdfName = result.files.single.name;
                              });
                            }
                          },
                          icon: Icon(Icons.upload_file),
                          label: Text('اختيار'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAllocation == null ||
                    amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
                  );
                  return;
                }

                // التحقق من توفر الرصيد
                if (amount > selectedAllocation!.remainingAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('المبلغ المطلوب يتجاوز الرصيد المتاح!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // إنشاء طلب الحجز
                  final transaction = FundingTransaction()
                    ..fundingId = selectedAllocation!.id
                    ..institutionId = selectedAllocation!.institutionId
                    ..categoryId = selectedAllocation!.categoryId
                    ..status = ReservationStatus.reserved
                    ..requestedAmount = amount
                    ..requestDescription =
                        descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim()
                    ..reservationAttachmentPath = selectedPdfPath
                    ..requestDate = selectedDate
                    ..year = selectedAllocation!.year
                    ..month = selectedAllocation!.month ?? 0
                    ..createdAt = DateTime.now()
                    ..updatedAt = DateTime.now();

                  await DatabaseService.isar.writeTxn(() async {
                    await DatabaseService.isar.fundingTransactions.put(
                      transaction,
                    );

                    // تحديث المبلغ المحجوز في التخصيص
                    final updatedAllocation = selectedAllocation!.copyWith(
                      reservedAmount:
                          selectedAllocation!.reservedAmount + amount,
                      updatedAt: DateTime.now(),
                    );
                    await DatabaseService.isar.institutionFundings.put(
                      updatedAllocation,
                    );
                  });

                  Navigator.of(context).pop();
                  await _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم إنشاء طلب الحجز بنجاح')),
                  );
                } catch (e) {
                  print('خطأ في إنشاء طلب الحجز: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في إنشاء طلب الحجز')),
                  );
                }
              },
              child: Text('إنشاء طلب الحجز'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExecutionDialog(FundingTransaction transaction) async {
    final executedAmountController = TextEditingController(
      text: transaction.requestedAmount.toString(),
    );
    final executionDescriptionController = TextEditingController();
    String? selectedPdfPath;
    String? selectedPdfName;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('تنفيذ الصرف'),
          content: SizedBox(
            width: 400,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // معلومات الطلب
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معلومات الطلب:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'المبلغ المطلوب: ${transaction.requestedAmount.toStringAsFixed(0)} د.ع',
                        ),
                        Text(
                          'تاريخ الطلب: ${transaction.requestDate?.day}/${transaction.requestDate?.month}/${transaction.requestDate?.year}',
                        ),
                        if (transaction.requestDescription != null)
                          Text('الوصف: ${transaction.requestDescription}'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // المبلغ المنفذ
                  TextFormField(
                    controller: executedAmountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ المنفذ فعلياً',
                      border: OutlineInputBorder(),
                      suffixText: 'د.ع',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  // وصف التنفيذ
                  TextFormField(
                    controller: executionDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'وصف التنفيذ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  // تاريخ التنفيذ
                  ListTile(
                    title: Text('تاريخ التنفيذ'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            transaction.requestDate ??
                            DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  // رفع مرفق PDF للتنفيذ
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedPdfName ?? 'لم يتم اختيار مرفق التنفيذ',
                            style: TextStyle(
                              color: selectedPdfName != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                              allowMultiple: false,
                            );

                            if (result != null &&
                                result.files.single.path != null) {
                              setDialogState(() {
                                selectedPdfPath = result.files.single.path;
                                selectedPdfName = result.files.single.name;
                              });
                            }
                          },
                          icon: Icon(Icons.upload_file),
                          label: Text('اختيار'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final executedAmount = double.tryParse(
                  executedAmountController.text,
                );
                if (executedAmount == null || executedAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال مبلغ تنفيذ صحيح')),
                  );
                  return;
                }

                if (executedAmount > transaction.requestedAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'مبلغ التنفيذ لا يمكن أن يتجاوز المبلغ المطلوب!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final success = await DatabaseService.executeTransaction(
                    transaction.id,
                    executedAmount,
                    executionDescriptionController.text.trim().isEmpty
                        ? null
                        : executionDescriptionController.text.trim(),
                    selectedPdfPath,
                    selectedDate,
                  );

                  if (success) {
                    Navigator.of(context).pop();
                    await _loadData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تنفيذ الصرف بنجاح')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في تنفيذ الصرف')),
                    );
                  }
                } catch (e) {
                  print('خطأ في تنفيذ الصرف: $e');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('خطأ في تنفيذ الصرف')));
                }
              },
              child: Text('تنفيذ الصرف'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        await Process.start('explorer', [filePath], runInShell: true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('الملف غير موجود')));
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في فتح الملف')));
    }
  }

  String _getCategoryName(int categoryId) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => FundingCategory()..name = 'غير معروف',
    );
    return category.name;
  }

  String _getInstitutionName(int institutionId) {
    final institution = institutions.firstWhere(
      (inst) => inst.id == institutionId,
      orElse: () => Institution()..name = 'غير معروف',
    );
    return institution.name;
  }

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
    return months[month - 1];
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.reserved:
        return Colors.orange;
      case ReservationStatus.approved:
        return Colors.blue;
      case ReservationStatus.spent:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.reserved:
        return Icons.bookmark;
      case ReservationStatus.approved:
        return Icons.check_circle_outline;
      case ReservationStatus.spent:
        return Icons.check_circle;
      case ReservationStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPeriod) {
      return Scaffold(
        appBar: AppBar(
          title: Text('إدارة الحجز والصرف'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل الفترة المالية...'),
            ],
          ),
        ),
      );
    }

    if (_activePeriod == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('إدارة الحجز والصرف'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('لا توجد فترة مالية نشطة', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showOpenPeriodDialog(),
                icon: Icon(Icons.add),
                label: Text('فتح فترة مالية جديدة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الحجز والصرف'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // معلومات الفترة المالية النشطة
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              border: Border(bottom: BorderSide(color: Colors.indigo[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفترة المالية النشطة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _activePeriod!.periodText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('جميع الحالات'),
                      ),
                      DropdownMenuItem(
                        value: 'reserved',
                        child: Text('طلبات الحجز'),
                      ),
                      DropdownMenuItem(value: 'executed', child: Text('منفذة')),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('ملغية'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // إحصائيات سريعة
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'إجمالي المحجوز',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_filteredTransactions.where((t) => t.status == ReservationStatus.reserved).fold(0.0, (sum, t) => sum + t.requestedAmount).toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'إجمالي المنفذ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_filteredTransactions.where((t) => t.status == ReservationStatus.spent).fold(0.0, (sum, t) => sum + (t.executedAmount ?? 0)).toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'عدد المعاملات',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_filteredTransactions.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // قائمة المعاملات
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد معاملات',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final categoryName = _getCategoryName(
                        transaction.categoryId!,
                      );
                      final institutionName = _getInstitutionName(
                        transaction.institutionId!,
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(
                              transaction.status,
                            ),
                            child: Icon(
                              _getStatusIcon(transaction.status),
                              color: Colors.white,
                            ),
                          ),
                          title: Text('$categoryName - $institutionName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('الحالة: ${transaction.statusText}'),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: transaction.month > 0
                                          ? Colors.orange[100]
                                          : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      transaction.month > 0
                                          ? 'شهري ${transaction.year} - ${_getMonthName(transaction.month)}'
                                          : 'سنوي ${transaction.year}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: transaction.month > 0
                                            ? Colors.orange[800]
                                            : Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'المبلغ المطلوب: ${transaction.requestedAmount.toStringAsFixed(0)} د.ع',
                              ),
                              if (transaction.executedAmount != null)
                                Text(
                                  'المبلغ المنفذ: ${transaction.executedAmount!.toStringAsFixed(0)} د.ع',
                                ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // معلومات الطلب
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'معلومات طلب الحجز:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'تاريخ الطلب: ${transaction.requestDate?.day}/${transaction.requestDate?.month}/${transaction.requestDate?.year}',
                                        ),
                                        Text(
                                          'مصدر التمويل: ${transaction.month > 0 ? 'تمويل شهري ${_getMonthName(transaction.month)} ${transaction.year}' : 'تمويل سنوي ${transaction.year}'}',
                                        ),
                                        if (transaction.requestDescription !=
                                            null)
                                          Text(
                                            'وصف الطلب: ${transaction.requestDescription}',
                                          ),
                                        SizedBox(height: 8),
                                        if (transaction
                                                .reservationAttachmentPath !=
                                            null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'مرفق طلب الحجز',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.open_in_new,
                                                  size: 16,
                                                ),
                                                onPressed: () => _openPdfFile(
                                                  transaction
                                                      .reservationAttachmentPath!,
                                                ),
                                                tooltip: 'فتح مرفق الطلب',
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  // معلومات التنفيذ (إن وجدت)
                                  if (transaction.status == 'executed')
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'معلومات التنفيذ:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'تاريخ التنفيذ: ${transaction.executionDate?.day}/${transaction.executionDate?.month}/${transaction.executionDate?.year}',
                                          ),
                                          Text(
                                            'المبلغ المنفذ: ${transaction.executedAmount?.toStringAsFixed(0)} د.ع',
                                          ),
                                          if (transaction
                                                  .executionDescription !=
                                              null)
                                            Text(
                                              'وصف التنفيذ: ${transaction.executionDescription}',
                                            ),
                                          SizedBox(height: 8),
                                          if (transaction
                                                  .executionAttachmentPath !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.picture_as_pdf,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'مرفق التنفيذ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.open_in_new,
                                                    size: 16,
                                                  ),
                                                  onPressed: () => _openPdfFile(
                                                    transaction
                                                        .executionAttachmentPath!,
                                                  ),
                                                  tooltip: 'فتح مرفق التنفيذ',
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 12),
                                  // أزرار العمليات
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (transaction.status ==
                                          ReservationStatus.reserved)
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showExecutionDialog(transaction),
                                          icon: Icon(Icons.payment),
                                          label: Text('تنفيذ الصرف'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      if (transaction.status ==
                                          ReservationStatus.reserved)
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // TODO: إلغاء الطلب
                                          },
                                          icon: Icon(Icons.cancel),
                                          label: Text('إلغاء الطلب'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReservationRequestDialog,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'طلب حجز جديد',
      ),
    );
  }
}
