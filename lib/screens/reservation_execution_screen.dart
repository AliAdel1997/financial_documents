import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class ReservationExecutionScreen extends StatefulWidget {
  @override
  _ReservationExecutionScreenState createState() => _ReservationExecutionScreenState();
}

class _ReservationExecutionScreenState extends State<ReservationExecutionScreen> {
  List<FundingTransaction> transactions = [];
  List<InstitutionFunding> allocations = [];
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];
  
  // فلاتر البحث
  int _selectedYear = DateTime.now().year;
  String _selectedStatus = 'all'; // all, pending, executed, cancelled
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // تحميل المعاملات
      final loadedTransactions = await DatabaseService.getAllFundingTransactions();
      
      // تحميل التخصيصات
      final loadedAllocations = await DatabaseService.isar.institutionFundings
          .filter()
          .yearEqualTo(_selectedYear)
          .findAll();
      
      // تحميل الأبواب
      final loadedCategories = await DatabaseService.isar.fundingCategorys.where().findAll();
      
      // تحميل المؤسسات
      final loadedInstitutions = await DatabaseService.isar.institutions.where().findAll();
      
      setState(() {
        transactions = loadedTransactions;
        allocations = loadedAllocations;
        categories = loadedCategories;
        institutions = loadedInstitutions;
      });
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات')),
      );
    }
  }

  List<FundingTransaction> get _filteredTransactions {
    return transactions.where((transaction) {
      if (transaction.year != _selectedYear) return false;
      if (_selectedStatus != 'all' && transaction.status != _selectedStatus) return false;
      return true;
    }).toList();
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اختيار التخصيص
                DropdownButtonFormField<InstitutionFunding>(
                  value: selectedAllocation,
                  decoration: InputDecoration(
                    labelText: 'اختيار التخصيص',
                    border: OutlineInputBorder(),
                  ),
                  items: allocations.map((allocation) {
                    final categoryName = _getCategoryName(allocation.categoryId);
                    final institutionName = _getInstitutionName(allocation.institutionId);
                    final availableAmount = allocation.remainingAmount;
                    
                    return DropdownMenuItem(
                      value: allocation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$categoryName - $institutionName'),
                          Text(
                            'المتاح: ${availableAmount.toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 12,
                              color: availableAmount > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
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
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
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
                            color: selectedPdfName != null ? Colors.black : Colors.grey[600],
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

                          if (result != null && result.files.single.path != null) {
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAllocation == null || amountController.text.isEmpty) {
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
                    ..status = 'pending'
                    ..requestedAmount = amount
                    ..requestDescription = descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim()
                    ..reservationAttachmentPath = selectedPdfPath
                    ..requestDate = selectedDate
                    ..year = selectedAllocation!.year
                    ..month = selectedAllocation!.month
                    ..createdAt = DateTime.now()
                    ..updatedAt = DateTime.now();

                  await DatabaseService.isar.writeTxn(() async {
                    await DatabaseService.isar.fundingTransactions.put(transaction);
                    
                    // تحديث المبلغ المحجوز في التخصيص
                    final updatedAllocation = selectedAllocation!.copyWith(
                      reservedAmount: selectedAllocation!.reservedAmount + amount,
                      updatedAt: DateTime.now(),
                    );
                    await DatabaseService.isar.institutionFundings.put(updatedAllocation);
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
      text: transaction.requestedAmount.toString()
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
          content: SingleChildScrollView(
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
                      Text('معلومات الطلب:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('المبلغ المطلوب: ${transaction.requestedAmount.toStringAsFixed(0)} د.ع'),
                      Text('تاريخ الطلب: ${transaction.requestDate?.day}/${transaction.requestDate?.month}/${transaction.requestDate?.year}'),
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
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: transaction.requestDate ?? DateTime.now().subtract(Duration(days: 365)),
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
                            color: selectedPdfName != null ? Colors.black : Colors.grey[600],
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

                          if (result != null && result.files.single.path != null) {
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final executedAmount = double.tryParse(executedAmountController.text);
                if (executedAmount == null || executedAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال مبلغ تنفيذ صحيح')),
                  );
                  return;
                }

                if (executedAmount > transaction.requestedAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('مبلغ التنفيذ لا يمكن أن يتجاوز المبلغ المطلوب!'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في تنفيذ الصرف')),
                  );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الملف غير موجود')),
        );
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح الملف')),
      );
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
      (i) => i.id == institutionId,
      orElse: () => Institution()..name = 'غير معروف',
    );
    return institution.name;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'executed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الحجز والصرف'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط الفلاتر
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'السنة',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                        _loadData();
                      });
                    },
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
                      DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                      DropdownMenuItem(value: 'pending', child: Text('طلبات الحجز')),
                      DropdownMenuItem(value: 'executed', child: Text('منفذة')),
                      DropdownMenuItem(value: 'cancelled', child: Text('ملغية')),
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
          // قائمة المعاملات
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد معاملات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final categoryName = _getCategoryName(transaction.categoryId!);
                      final institutionName = _getInstitutionName(transaction.institutionId!);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(transaction.status),
                            child: Icon(
                              transaction.status == 'pending' 
                                ? Icons.pending 
                                : transaction.status == 'executed'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('$categoryName - $institutionName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الحالة: ${transaction.statusText}'),
                              Text('المبلغ المطلوب: ${transaction.requestedAmount.toStringAsFixed(0)} د.ع'),
                              if (transaction.executedAmount != null)
                                Text('المبلغ المنفذ: ${transaction.executedAmount!.toStringAsFixed(0)} د.ع'),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('معلومات طلب الحجز:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Text('تاريخ الطلب: ${transaction.requestDate?.day}/${transaction.requestDate?.month}/${transaction.requestDate?.year}'),
                                        if (transaction.requestDescription != null)
                                          Text('وصف الطلب: ${transaction.requestDescription}'),
                                        SizedBox(height: 8),
                                        if (transaction.reservationAttachmentPath != null)
                                          Row(
                                            children: [
                                              Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'مرفق طلب الحجز',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.open_in_new, size: 16),
                                                onPressed: () => _openPdfFile(transaction.reservationAttachmentPath!),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('معلومات التنفيذ:', style: TextStyle(fontWeight: FontWeight.bold)),
                                          SizedBox(height: 8),
                                          Text('تاريخ التنفيذ: ${transaction.executionDate?.day}/${transaction.executionDate?.month}/${transaction.executionDate?.year}'),
                                          Text('المبلغ المنفذ: ${transaction.executedAmount?.toStringAsFixed(0)} د.ع'),
                                          if (transaction.executionDescription != null)
                                            Text('وصف التنفيذ: ${transaction.executionDescription}'),
                                          SizedBox(height: 8),
                                          if (transaction.executionAttachmentPath != null)
                                            Row(
                                              children: [
                                                Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'مرفق التنفيذ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.open_in_new, size: 16),
                                                  onPressed: () => _openPdfFile(transaction.executionAttachmentPath!),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (transaction.status == 'pending')
                                        ElevatedButton.icon(
                                          onPressed: () => _showExecutionDialog(transaction),
                                          icon: Icon(Icons.payment),
                                          label: Text('تنفيذ الصرف'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      if (transaction.status == 'pending')
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