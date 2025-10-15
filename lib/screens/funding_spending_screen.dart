import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class FundingSpendingScreen extends StatefulWidget {
  @override
  _FundingSpendingScreenState createState() => _FundingSpendingScreenState();
}

class _FundingSpendingScreenState extends State<FundingSpendingScreen> {
  List<InstitutionFunding> allocations = [];
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];
  
  // فلاتر البحث
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  String _selectedFundingType = 'سنوي';
  
  // متغيرات الإدخال
  InstitutionFunding? _selectedAllocation;
  final _spentAmountController = TextEditingController();
  final _reservedAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _operationType = 'صرف'; // صرف أو حجز
  String? _selectedPdfPath; // مسار ملف PDF المحدد
  String? _selectedPdfName; // اسم ملف PDF المحدد
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _spentAmountController.dispose();
    _reservedAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
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

  List<InstitutionFunding> get _filteredAllocations {
    return allocations.where((allocation) {
      // فلترة حسب نوع التمويل والشهر
      if (allocation.fundingType != _selectedFundingType) return false;
      if (_selectedFundingType == 'شهري' && _selectedMonth != null && allocation.month != _selectedMonth) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _processSpending() async {
    if (_selectedAllocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار تخصيص للعمل عليه')),
      );
      return;
    }

    final amount = double.tryParse(
      _operationType == 'صرف' ? _spentAmountController.text : _reservedAmountController.text
    );
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    // التحقق من عدم تجاوز المبلغ المخصص
    final currentSpent = _selectedAllocation!.spentAmount;
    final currentReserved = _selectedAllocation!.reservedAmount;
    final allocated = _selectedAllocation!.allocatedAmount;
    
    double newSpent = currentSpent;
    double newReserved = currentReserved;
    
    if (_operationType == 'صرف') {
      newSpent = currentSpent + amount;
    } else {
      newReserved = currentReserved + amount;
    }
    
    if (newSpent + newReserved > allocated) {
      final remaining = allocated - currentSpent - currentReserved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المبلغ المطلوب يتجاوز المتبقي من التخصيص!\nالمتبقي: ${remaining.toStringAsFixed(0)} د.ع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final updatedAllocation = _selectedAllocation!.copyWith(
        spentAmount: newSpent,
        reservedAmount: newReserved,
        executionAttachmentPath: _operationType == 'صرف' ? _selectedPdfPath : _selectedAllocation!.executionAttachmentPath,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.institutionFundings.put(updatedAllocation);
        
        // إنشاء سجل في الأرشيف
        final archiveRecord = FundingArchive()
          ..fundingId = _selectedAllocation!.id
          ..institutionId = _selectedAllocation!.institutionId
          ..categoryId = _selectedAllocation!.categoryId
          ..operationType = _operationType
          ..amount = amount
          ..description = _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim()
          ..executionAttachmentPath = _selectedPdfPath
          ..year = _selectedAllocation!.year
          ..month = _selectedAllocation!.month ?? 0
          ..executedAt = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        await DatabaseService.isar.fundingArchives.put(archiveRecord);
      });

      _spentAmountController.clear();
      _reservedAmountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedAllocation = null;
        _selectedPdfPath = null;
        _selectedPdfName = null;
      });
      
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل ${_operationType} بنجاح')),
      );
    } catch (e) {
      print('خطأ في تسجيل ${_operationType}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تسجيل ${_operationType}')),
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

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPdfPath = result.files.single.path;
          _selectedPdfName = result.files.single.name;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم اختيار الملف: ${_selectedPdfName}')),
        );
      }
    } catch (e) {
      print('خطأ في اختيار الملف: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الملف')),
      );
    }
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        // فتح الملف باستخدام التطبيق الافتراضي
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الصرف والحجز'),
        backgroundColor: Colors.orange,
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
            child: Column(
              children: [
                Row(
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
                        value: _selectedFundingType,
                        decoration: InputDecoration(
                          labelText: 'نوع التمويل',
                          border: OutlineInputBorder(),
                        ),
                        items: ['سنوي', 'شهري'].map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFundingType = value!;
                            if (value == 'سنوي') _selectedMonth = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (_selectedFundingType == 'شهري')
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'الشهر',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(12, (index) {
                            final month = index + 1;
                            const monthNames = [
                              'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                              'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                            ];
                            return DropdownMenuItem(
                              value: month,
                              child: Text(monthNames[index]),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value;
                            });
                          },
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
              ],
            ),
          ),
          // نموذج الإدخال
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Column(
              children: [
                // اختيار نوع العملية
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('صرف'),
                        value: 'صرف',
                        groupValue: _operationType,
                        onChanged: (value) {
                          setState(() {
                            _operationType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('حجز'),
                        value: 'حجز',
                        groupValue: _operationType,
                        onChanged: (value) {
                          setState(() {
                            _operationType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // اختيار التخصيص
                DropdownButtonFormField<InstitutionFunding>(
                  value: _selectedAllocation,
                  decoration: InputDecoration(
                    labelText: 'اختيار التخصيص',
                    border: OutlineInputBorder(),
                  ),
                  items: _filteredAllocations.map((allocation) {
                    final categoryName = _getCategoryName(allocation.categoryId);
                    final institutionName = _getInstitutionName(allocation.institutionId);
                    final remainingAmount = allocation.remainingAmount;
                    
                    return DropdownMenuItem(
                      value: allocation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$categoryName - $institutionName'),
                          Text(
                            'المتبقي: ${remainingAmount.toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 12,
                              color: remainingAmount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAllocation = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                // إدخال المبلغ
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _operationType == 'صرف' 
                          ? _spentAmountController 
                          : _reservedAmountController,
                        decoration: InputDecoration(
                          labelText: 'مبلغ ${_operationType}',
                          border: OutlineInputBorder(),
                          suffixText: 'د.ع',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _processSpending,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _operationType == 'صرف' ? Colors.red : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text('تسجيل ${_operationType}'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // رفع مرفق PDF للصرف
                if (_operationType == 'صرف')
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
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
                                      _selectedPdfName ?? 'لم يتم اختيار مرفق PDF',
                                      style: TextStyle(
                                        color: _selectedPdfName != null ? Colors.black : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _pickPdfFile,
                            icon: Icon(Icons.upload_file),
                            label: Text('اختيار PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // حقل الوصف
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'وصف العملية (اختياري)',
                          border: OutlineInputBorder(),
                          hintText: 'أدخل وصفاً مختصراً للعملية...',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // قائمة التخصيصات
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAllocations.length,
              itemBuilder: (context, index) {
                final allocation = _filteredAllocations[index];
                final categoryName = _getCategoryName(allocation.categoryId);
                final institutionName = _getInstitutionName(allocation.institutionId);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text('$categoryName - $institutionName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('السنة: ${allocation.year} - الشهر: ${allocation.month}'),
                        Text('المخصص: ${allocation.allocatedAmount.toStringAsFixed(0)} د.ع'),
                        Text('المحجوز: ${allocation.reservedAmount.toStringAsFixed(0)} د.ع'),
                        Text('المصروف: ${allocation.spentAmount.toStringAsFixed(0)} د.ع'),
                        Text(
                          'المتبقي: ${allocation.remainingAmount.toStringAsFixed(0)} د.ع',
                          style: TextStyle(
                            color: allocation.remainingAmount >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // عرض حالة المرفق
                        if (allocation.executionAttachmentPath != null)
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'مرفق PDF متوفر',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.open_in_new, size: 16),
                                onPressed: () => _openPdfFile(allocation.executionAttachmentPath!),
                                tooltip: 'فتح المرفق',
                              ),
                            ],
                          ),
                        // شريط التقدم
                        LinearProgressIndicator(
                          value: allocation.allocatedAmount > 0 
                            ? (allocation.spentAmount + allocation.reservedAmount) / allocation.allocatedAmount
                            : 0,
                          backgroundColor: Colors.grey[300],
                          color: allocation.remainingAmount >= 0 ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAllocation = allocation;
                      });
                    },
                    selected: _selectedAllocation?.id == allocation.id,
                    selectedTileColor: Colors.blue[50],
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}