import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';
import '../services/funding_manager.dart';

/// الشاشة الرئيسية لإدارة التخصيصات المالية
class InternalFundingScreen extends StatefulWidget {
  @override
  _InternalFundingScreenState createState() => _InternalFundingScreenState();
}

class _InternalFundingScreenState extends State<InternalFundingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // قوائم البيانات
  List<FundingCategory> _categories = [];
  List<Institution> _institutions = [];
  List<InstitutionFunding> _fundings = [];

  // المرشحات
  String _selectedFilterType = 'الكل';
  int _selectedFilterYear = DateTime.now().year;
  int _selectedFilterMonth = 0;
  int? _selectedCategoryId;
  int? _selectedInstitutionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.initialize();
      await _loadData();
    } catch (e) {
      print('خطأ في تهيئة البيانات: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    final categories = await DatabaseService.getAllFundingCategories();
    final institutions = await DatabaseService.getAllInstitutions();
    final fundings = await DatabaseService.getAllInstitutionFunding();

    print('تم تحميل البيانات:');
    print('عدد الفئات: ${categories.length}');
    print('عدد المؤسسات: ${institutions.length}');
    print('عدد التخصيصات: ${fundings.length}');

    // إنشاء بيانات تجريبية إذا لم تكن موجودة
    if (categories.isEmpty) {
      print('إنشاء فئات تجريبية...');
      await _createSampleCategories();
    }

    if (institutions.isEmpty) {
      print('إنشاء مؤسسات تجريبية...');
      await _createSampleInstitutions();
    }

    // إعادة تحميل البيانات بعد الإنشاء
    final updatedCategories = await DatabaseService.getAllFundingCategories();
    final updatedInstitutions = await DatabaseService.getAllInstitutions();
    final updatedFundings = await DatabaseService.getAllInstitutionFunding();

    setState(() {
      _categories = updatedCategories;
      _institutions = updatedInstitutions;
      _fundings = updatedFundings;
    });
  }

  Future<void> _createSampleCategories() async {
    final sampleCategories = [
      FundingCategory()
        ..name = 'الرواتب والأجور'
        ..description = 'باب خاص برواتب الموظفين والأجور'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
      FundingCategory()
        ..name = 'المستلزمات الطبية'
        ..description = 'باب خاص بالمعدات والمستلزمات الطبية'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
      FundingCategory()
        ..name = 'الصيانة والتشغيل'
        ..description = 'باب خاص بصيانة المعدات والتشغيل'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    ];

    for (final category in sampleCategories) {
      await DatabaseService.addFundingCategory(category);
    }
  }

  Future<void> _createSampleInstitutions() async {
    final sampleInstitutions = [
      Institution()
        ..name = 'دائرة صحة بابل'
        ..code = 'HDB001'
        ..address = 'بابل - الحلة',
      Institution()
        ..name = 'مستشفى الحلة العام'
        ..code = 'HGH001'
        ..address = 'بابل - الحلة المركز',
      Institution()
        ..name = 'مستشفى المسيب العام'
        ..code = 'MGH001'
        ..address = 'بابل - المسيب',
    ];

    for (final institution in sampleInstitutions) {
      await DatabaseService.addInstitution(institution);
    }
  }

  List<InstitutionFunding> get _filteredFundings {
    return _fundings.where((funding) {
      // تصفية بنوع التمويل
      if (_selectedFilterType != 'الكل' &&
          funding.fundingType != _selectedFilterType) {
        return false;
      }

      // تصفية بالسنة
      if (funding.year != _selectedFilterYear) {
        return false;
      }

      // تصفية بالشهر
      if (_selectedFilterMonth != 0 && funding.month != _selectedFilterMonth) {
        return false;
      }

      // تصفية بالفئة
      if (_selectedCategoryId != null &&
          funding.categoryId != _selectedCategoryId) {
        return false;
      }

      // تصفية بالمؤسسة
      if (_selectedInstitutionId != null &&
          funding.institutionId != _selectedInstitutionId) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة التخصيصات المالية'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          tabs: [
            Tab(text: 'التخصيصات', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'التقارير', icon: Icon(Icons.analytics)),
            Tab(text: 'الإعدادات', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllocationsTab(),
                _buildReportsTab(),
                _buildSettingsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddAllocationDialog,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue[700],
            )
          : null,
    );
  }

  Widget _buildAllocationsTab() {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildAllocationsList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilterType,
                  decoration: InputDecoration(
                    labelText: 'نوع التمويل',
                    border: OutlineInputBorder(),
                  ),
                  items: ['الكل', 'سنوي', 'شهري']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilterType = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedFilterYear,
                  decoration: InputDecoration(
                    labelText: 'السنة',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      List.generate(5, (index) => DateTime.now().year - index)
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilterYear = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'الباب التمويلي',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('جميع الأبواب'),
                    ),
                    ..._categories.map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedInstitutionId,
                  decoration: InputDecoration(
                    labelText: 'المؤسسة',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('جميع المؤسسات'),
                    ),
                    ..._institutions.map(
                      (institution) => DropdownMenuItem(
                        value: institution.id,
                        child: Text(institution.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedInstitutionId = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationsList() {
    final filteredFundings = _filteredFundings;

    if (filteredFundings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            Text('لا توجد تخصيصات مالية'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddAllocationDialog,
              child: Text('إضافة تخصيص جديد'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredFundings.length,
      itemBuilder: (context, index) {
        final funding = filteredFundings[index];
        return _buildFundingCard(funding);
      },
    );
  }

  Widget _buildFundingCard(InstitutionFunding funding) {
    final category = _categories.firstWhere(
      (cat) => cat.id == funding.categoryId,
      orElse: () => FundingCategory()..name = 'غير محدد',
    );

    final institution = _institutions.firstWhere(
      (inst) => inst.id == funding.institutionId,
      orElse: () => Institution()..name = 'غير محدد',
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAllocationDialog(funding);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(funding);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                    PopupMenuItem(value: 'delete', child: Text('حذف')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('المؤسسة: ${institution.name}'),
            Text('نوع التمويل: ${funding.fundingPeriodText}'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    'المخصص',
                    funding.allocatedAmount,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    'المصروف',
                    funding.spentAmount,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildAmountInfo(
                    'المتبقي',
                    funding.remainingAmount,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          '${amount.toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return Center(child: Text('تبويب التقارير - قيد التطوير'));
  }

  Widget _buildSettingsTab() {
    return Center(child: Text('تبويب الإعدادات - قيد التطوير'));
  }

  void _showAddAllocationDialog() {
    showDialog(
      context: context,
      builder: (context) => _AllocationDialog(
        categories: _categories,
        institutions: _institutions,
        onSave: (allocation) async {
          final success = await FundingManager.createFundingAllocation(
            institutionId: allocation['institutionId'],
            categoryId: allocation['categoryId'],
            amount: allocation['amount'],
            fundingType: allocation['fundingType'],
            year: allocation['year'],
            month: allocation['month'],
          );

          if (success) {
            await _loadData();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('تم إضافة التخصيص بنجاح')));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('خطأ في إضافة التخصيص')));
          }
        },
      ),
    );
  }

  void _showEditAllocationDialog(InstitutionFunding funding) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ميزة التعديل قيد التطوير')));
  }

  void _showDeleteConfirmation(InstitutionFunding funding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا التخصيص؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.deleteInstitutionFunding(funding.id);
              await _loadData();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('تم حذف التخصيص بنجاح')));
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _AllocationDialog extends StatefulWidget {
  final List<FundingCategory> categories;
  final List<Institution> institutions;
  final Function(Map<String, dynamic>) onSave;

  _AllocationDialog({
    required this.categories,
    required this.institutions,
    required this.onSave,
  });

  @override
  _AllocationDialogState createState() => _AllocationDialogState();
}

class _AllocationDialogState extends State<_AllocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedInstitutionId;
  String _selectedFundingType = 'سنوي';
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('إضافة تخصيص مالي جديد'),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedInstitutionId,
                decoration: InputDecoration(
                  labelText: 'المؤسسة',
                  border: OutlineInputBorder(),
                ),
                items: widget.institutions
                    .map(
                      (institution) => DropdownMenuItem(
                        value: institution.id,
                        child: Text(institution.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInstitutionId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'يرجى اختيار المؤسسة' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'الباب التمويلي',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'يرجى اختيار الباب التمويلي' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'المبلغ المخصص',
                  border: OutlineInputBorder(),
                  suffixText: 'ر.س',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFundingType,
                      decoration: InputDecoration(
                        labelText: 'نوع التمويل',
                        border: OutlineInputBorder(),
                      ),
                      items: ['سنوي', 'شهري']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFundingType = value!;
                          if (value == 'سنوي') {
                            _selectedMonth = null;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          List.generate(
                                5,
                                (index) => DateTime.now().year + index,
                              )
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedFundingType == 'شهري') ...[
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'الشهر',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) => index + 1)
                      .map(
                        (month) => DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthName(month)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  validator: (value) =>
                      _selectedFundingType == 'شهري' && value == null
                      ? 'يرجى اختيار الشهر'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _save, child: Text('حفظ')),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
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
    return monthNames[month];
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      widget.onSave({
        'institutionId': _selectedInstitutionId!,
        'categoryId': _selectedCategoryId!,
        'amount': amount,
        'fundingType': _selectedFundingType,
        'year': _selectedYear,
        'month': _selectedMonth,
      });

      Navigator.pop(context);
    }
  }
}
