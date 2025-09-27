import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class FundingAllocationScreen extends StatefulWidget {
  @override
  _FundingAllocationScreenState createState() => _FundingAllocationScreenState();
}

class _FundingAllocationScreenState extends State<FundingAllocationScreen> {
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];
  List<InstitutionFunding> allocations = [];
  
  // فلاتر البحث
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  String _selectedFundingType = 'سنوي';
  FundingCategory? _selectedCategory;
  Institution? _selectedInstitution;
  
  final _amountController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // تحميل الأبواب
      final loadedCategories = await DatabaseService.isar.fundingCategorys.where().findAll();
      
      // تحميل المؤسسات
      final loadedInstitutions = await DatabaseService.isar.institutions.where().findAll();
      
      // تحميل التخصيصات الحالية
      final loadedAllocations = await DatabaseService.isar.institutionFundings
          .filter()
          .yearEqualTo(_selectedYear)
          .findAll();
      
      setState(() {
        categories = loadedCategories;
        institutions = loadedInstitutions;
        allocations = loadedAllocations;
      });
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات')),
      );
    }
  }

  List<FundingCategory> get _filteredCategories {
    return categories.where((category) {
      // فلترة حسب نوع التمويل والسنة والشهر
      if (category.fundingType != _selectedFundingType) return false;
      if (category.year != _selectedYear) return false;
      if (_selectedFundingType == 'شهري' && _selectedMonth != null && category.month != _selectedMonth) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _allocateFunding() async {
    if (_selectedCategory == null || _selectedInstitution == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    try {
      // التحقق من التخصيص الموجود
      final existingAllocation = await DatabaseService.isar.institutionFundings
          .filter()
          .institutionIdEqualTo(_selectedInstitution!.id)
          .and()
          .categoryIdEqualTo(_selectedCategory!.id)
          .and()
          .yearEqualTo(_selectedYear)
          .and()
          .monthEqualTo(_selectedMonth ?? 1)
          .findFirst();

      if (existingAllocation != null) {
        // تحديث التخصيص الموجود
        final updatedAllocation = existingAllocation.copyWith(
          allocatedAmount: amount,
          updatedAt: DateTime.now(),
        );
        
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.institutionFundings.put(updatedAllocation);
        });
      } else {
        // إنشاء تخصيص جديد
        final newAllocation = InstitutionFunding()
          ..institutionId = _selectedInstitution!.id
          ..categoryId = _selectedCategory!.id
          ..allocatedAmount = amount
          ..reservedAmount = 0
          ..spentAmount = 0
          ..year = _selectedYear
          ..month = _selectedMonth ?? 1
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.institutionFundings.put(newAllocation);
        });
      }

      _amountController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedInstitution = null;
      });
      
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تخصيص التمويل بنجاح')),
      );
    } catch (e) {
      print('خطأ في تخصيص التمويل: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تخصيص التمويل')),
      );
    }
  }

  Future<void> _deleteAllocation(InstitutionFunding allocation) async {
    // التحقق من عدم وجود صرف أو حجز
    if (allocation.spentAmount > 0 || allocation.reservedAmount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يمكن حذف التخصيص لأنه يحتوي على مبالغ مصروفة أو محجوزة')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا التخصيص؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.institutionFundings.delete(allocation.id);
        });
        
        await _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف التخصيص بنجاح')),
        );
      } catch (e) {
        print('خطأ في حذف التخصيص: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حذف التخصيص')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تخصيص التمويل'),
        backgroundColor: Colors.blue,
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
                // الصف الأول: السنة ونوع التمويل
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
                // الصف الثاني: الشهر (إذا كان شهري)
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
                SizedBox(height: 16),
                // الصف الثالث: اختيار الباب والمؤسسة
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<FundingCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'الباب',
                          border: OutlineInputBorder(),
                        ),
                        items: _filteredCategories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<Institution>(
                        value: _selectedInstitution,
                        decoration: InputDecoration(
                          labelText: 'المؤسسة',
                          border: OutlineInputBorder(),
                        ),
                        items: institutions.map((institution) => DropdownMenuItem(
                          value: institution,
                          child: Text(institution.name),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedInstitution = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // الصف الرابع: المبلغ وزر التخصيص
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'المبلغ المخصص',
                          border: OutlineInputBorder(),
                          suffixText: 'د.ع',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _allocateFunding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text('تخصيص'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // قائمة التخصيصات الحالية
          Expanded(
            child: ListView.builder(
              itemCount: allocations.length,
              itemBuilder: (context, index) {
                final allocation = allocations[index];
                final category = categories.firstWhere(
                  (c) => c.id == allocation.categoryId,
                  orElse: () => FundingCategory()..name = 'غير معروف',
                );
                final institution = institutions.firstWhere(
                  (i) => i.id == allocation.institutionId,
                  orElse: () => Institution()..name = 'غير معروف',
                );

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text('${category.name} - ${institution.name}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('السنة: ${allocation.year} - الشهر: ${allocation.month}'),
                        Text('المخصص: ${allocation.allocatedAmount.toStringAsFixed(0)} د.ع'),
                        Text('المحجوز: ${allocation.reservedAmount.toStringAsFixed(0)} د.ع'),
                        Text('المصروف: ${allocation.spentAmount.toStringAsFixed(0)} د.ع'),
                        Text('المتبقي: ${allocation.remainingAmount.toStringAsFixed(0)} د.ع',
                          style: TextStyle(
                            color: allocation.remainingAmount >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAllocation(allocation),
                    ),
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