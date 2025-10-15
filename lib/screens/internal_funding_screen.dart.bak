import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// الشاشة الرئيسية لإدارة التمويل الداخلي
class InternalFundingScreen extends StatefulWidget {
  @override
  _InternalFundingScreenState createState() => _InternalFundingScreenState();
}

class _InternalFundingScreenState extends State<InternalFundingScreen> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.initialize();
    } catch (e) {
      _showErrorSnackBar('خطأ في تهيئة قاعدة البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة التمويل الداخلي'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(Icons.account_tree),
              text: 'الأبواب التمويلية',
            ),
            Tab(
              icon: Icon(Icons.payment),
              text: 'الحجز والصرف',
            ),
            Tab(
              icon: Icon(Icons.attach_file),
              text: 'المرفقات',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'التقارير',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo),
                  SizedBox(height: 16),
                  Text('جاري تحميل البيانات...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                FundingCategoriesTab(
                  onMessage: (message, isError) {
                    if (isError) {
                      _showErrorSnackBar(message);
                    } else {
                      _showSuccessSnackBar(message);
                    }
                  },
                ),
                ReservationSpendingTab(
                  onMessage: (message, isError) {
                    if (isError) {
                      _showErrorSnackBar(message);
                    } else {
                      _showSuccessSnackBar(message);
                    }
                  },
                ),
                AttachmentsTab(
                  onMessage: (message, isError) {
                    if (isError) {
                      _showErrorSnackBar(message);
                    } else {
                      _showSuccessSnackBar(message);
                    }
                  },
                ),
                ReportsTab(
                  onMessage: (message, isError) {
                    if (isError) {
                      _showErrorSnackBar(message);
                    } else {
                      _showSuccessSnackBar(message);
                    }
                  },
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// التبويب الأول: الأبواب التمويلية (Hierarchical Multi-Level)
class FundingCategoriesTab extends StatefulWidget {
  final Function(String message, bool isError) onMessage;

  const FundingCategoriesTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  _FundingCategoriesTabState createState() => _FundingCategoriesTabState();
}

class _FundingCategoriesTabState extends State<FundingCategoriesTab> {
  List<FundingCategory> _categories = [];
  List<FundingCategory> _hierarchicalCategories = [];
  List<FundingCategory> _allCategories = []; // القائمة الكاملة للتصفية
  List<InstitutionFunding> _fundings = [];
  Map<int, bool> _expansionStates = {};
  bool _isLoading = false;

  // متغيرات التصفية
  String _selectedFilterType = 'الكل';
  int _selectedFilterYear = 0; // 0 يعني جميع السنوات
  int _selectedFilterMonth = 0; // 0 يعني جميع الشهور

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await DatabaseService.getAllFundingCategories();
      final fundings = await DatabaseService.getAllInstitutionFunding();
      
      setState(() {
        _allCategories = categories; // حفظ القائمة الكاملة
        _fundings = fundings;
        _applyFilters(); // تطبيق المرشحات
      });
    } catch (e) {
      widget.onMessage('خطأ في تحميل الأبواب التمويلية: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<FundingCategory> filteredCategories = _allCategories.where((category) {
      // فلترة حسب النوع
      if (_selectedFilterType != 'الكل' && category.fundingType != _selectedFilterType) {
        return false;
      }
      
      // فلترة حسب السنة
      if (_selectedFilterYear != 0 && category.year != _selectedFilterYear) {
        return false;
      }
      
      // فلترة حسب الشهر
      if (_selectedFilterMonth != 0 && category.month != _selectedFilterMonth) {
        return false;
      }
      
      return true;
    }).toList();

    setState(() {
      _categories = filteredCategories;
      _hierarchicalCategories = _buildHierarchy(filteredCategories);
    });
  }

  /// بناء الهيكل الهرمي من القائمة المسطحة
  List<FundingCategory> _buildHierarchy(List<FundingCategory> flatCategories) {
    Map<int, List<FundingCategory>> childrenMap = {};
    List<FundingCategory> rootCategories = [];

    // تجميع الفئات حسب parentId
    for (final category in flatCategories) {
      if (category.parentId == null) {
        rootCategories.add(category);
      } else {
        childrenMap.putIfAbsent(category.parentId!, () => []).add(category);
      }
    }

    // بناء الهيكل الهرمي بشكل تكراري
    void buildChildren(FundingCategory category) {
      if (childrenMap.containsKey(category.id)) {
        // إنشاء قائمة الأطفال إذا لم تكن موجودة
        final children = childrenMap[category.id]!;
        for (final child in children) {
          buildChildren(child); // استدعاء تكراري للأطفال
        }
      }
    }

    for (final root in rootCategories) {
      buildChildren(root);
    }

    return rootCategories;
  }

  /// حساب المجاميع الإجمالية
  Map<String, double> _calculateTotalSummary() {
    double totalAllocated = 0;
    double totalSpent = 0;
    double totalReserved = 0;

    // حساب مجموع جميع الأبواب التمويلية
    for (final category in _categories) {
      totalAllocated += category.allocatedAmount;
    }

    // حساب المصروف والمحجوز من بيانات التمويل
    for (final funding in _fundings) {
      totalSpent += funding.spentAmount;
      totalReserved += funding.reservedAmount;
    }

    return {
      'allocated': totalAllocated,
      'spent': totalSpent,
      'reserved': totalReserved,
      'remaining': totalAllocated - totalSpent - totalReserved,
    };
  }

  /// حساب مجاميع فئة معينة وجميع أطفالها
  Map<String, double> _calculateCategorySummary(FundingCategory category) {
    double allocated = 0;
    double spent = 0;
    double reserved = 0;

    // حساب المبلغ للفئة الحالية
    allocated += category.allocatedAmount;
    
    // البحث عن بيانات التمويل المرتبطة بهذه الفئة
    final funding = _fundings.where((f) => f.categoryId == category.id).firstOrNull;
    if (funding != null) {
      spent += funding.spentAmount;
      reserved += funding.reservedAmount;
    }

    // الحصول على جميع الفئات الفرعية وحساب مجاميعها
    final children = _categories.where((c) => c.parentId == category.id).toList();
    for (final child in children) {
      final childSummary = _calculateCategorySummary(child);
      allocated += childSummary['allocated']!;
      spent += childSummary['spent']!;
      reserved += childSummary['reserved']!;
    }

    return {
      'allocated': allocated,
      'spent': spent,
      'reserved': reserved,
      'remaining': allocated - spent - reserved,
    };
  }

  Future<void> _showAddCategoryDialog([FundingCategory? parentCategory]) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    FundingCategory? selectedParent = parentCategory;
    String selectedFundingType = 'سنوي'; // القيمة الافتراضية
    int selectedYear = DateTime.now().year; // السنة الحالية
    int? selectedMonth; // null افتراضياً

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(parentCategory != null 
                  ? 'إضافة باب فرعي تحت "${parentCategory.name}"'
                  : 'إضافة باب تمويلي جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الباب',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Dropdown للباب الأب مع عرض هرمي
                    DropdownButtonFormField<FundingCategory>(
                      value: selectedParent,
                      decoration: InputDecoration(
                        labelText: 'الباب الأب (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_tree),
                      ),
                      items: [
                        DropdownMenuItem<FundingCategory>(
                          value: null,
                          child: Text('باب رئيسي'),
                        ),
                        ..._buildHierarchicalDropdownItems(_hierarchicalCategories, 0),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedParent = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // نوع التمويل
                    DropdownButtonFormField<String>(
                      value: selectedFundingType,
                      decoration: InputDecoration(
                        labelText: 'نوع التمويل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      items: [
                        DropdownMenuItem(value: 'سنوي', child: Text('سنوي')),
                        DropdownMenuItem(value: 'شهري', child: Text('شهري')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFundingType = value!;
                          if (selectedFundingType == 'سنوي') {
                            selectedMonth = null; // إزالة الشهر للتمويل السنوي
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // السنة
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _generateYearsList().map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // الشهر (يظهر فقط للتمويل الشهري)
                    if (selectedFundingType == 'شهري')
                      DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'الشهر',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        items: _generateMonthsList().map((month) {
                          return DropdownMenuItem<int>(
                            value: month['value'] as int,
                            child: Text(month['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMonth = value;
                          });
                        },
                      ),
                    
                    if (selectedFundingType == 'شهري')
                      SizedBox(height: 16),
                    
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ المخصص',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
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
                    if (nameController.text.isNotEmpty && 
                        amountController.text.isNotEmpty &&
                        (selectedFundingType == 'سنوي' || selectedMonth != null)) {
                      Navigator.of(context).pop();
                      await _addCategory(
                        nameController.text,
                        selectedParent?.id,
                        double.tryParse(amountController.text) ?? 0,
                        selectedFundingType,
                        selectedYear,
                        selectedMonth,
                      );
                    } else {
                      // عرض رسالة خطأ
                      String errorMessage = 'يرجى ملء جميع الحقول المطلوبة';
                      if (selectedFundingType == 'شهري' && selectedMonth == null) {
                        errorMessage = 'يرجى اختيار الشهر للتمويل الشهري';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// إنشاء قائمة السنوات (من 2020 إلى 2030)
  List<int> _generateYearsList() {
    final currentYear = DateTime.now().year;
    return List.generate(11, (index) => currentYear - 5 + index);
  }

  /// إنشاء قائمة الشهور
  List<Map<String, dynamic>> _generateMonthsList() {
    return [
      {'value': 1, 'name': 'يناير'},
      {'value': 2, 'name': 'فبراير'},
      {'value': 3, 'name': 'مارس'},
      {'value': 4, 'name': 'أبريل'},
      {'value': 5, 'name': 'مايو'},
      {'value': 6, 'name': 'يونيو'},
      {'value': 7, 'name': 'يوليو'},
      {'value': 8, 'name': 'أغسطس'},
      {'value': 9, 'name': 'سبتمبر'},
      {'value': 10, 'name': 'أكتوبر'},
      {'value': 11, 'name': 'نوفمبر'},
      {'value': 12, 'name': 'ديسمبر'},
    ];
  }

  /// بناء عناصر القائمة المنسدلة بشكل هرمي
  List<DropdownMenuItem<FundingCategory>> _buildHierarchicalDropdownItems(
    List<FundingCategory> categories, 
    int depth
  ) {
    List<DropdownMenuItem<FundingCategory>> items = [];
    
    for (final category in categories) {
      final indent = '  ' * depth;
      items.add(
        DropdownMenuItem<FundingCategory>(
          value: category,
          child: Text('$indent${category.name}'),
        ),
      );
      
      // إضافة الأطفال
      final children = _categories.where((c) => c.parentId == category.id).toList();
      if (children.isNotEmpty) {
        items.addAll(_buildHierarchicalDropdownItems(children, depth + 1));
      }
    }
    
    return items;
  }

  Future<void> _addCategory(String name, int? parentId, double amount, 
      String fundingType, int year, int? month) async {
    try {
      final category = FundingCategory()
        ..name = name
        ..parentId = parentId
        ..allocatedAmount = amount
        ..fundingType = fundingType
        ..year = year
        ..month = month
        ..createdAt = DateTime.now();

      final categoryId = await DatabaseService.addFundingCategory(category);
      
      // إنشاء سجل تمويل افتراضي للباب الجديد
      await _createDefaultFundingRecord(categoryId, amount);
      
      await _loadCategories();
      widget.onMessage('تم إضافة الباب التمويلي بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في إضافة الباب التمويلي: $e', true);
    }
  }

  Future<void> _createDefaultFundingRecord(int categoryId, double allocatedAmount) async {
    try {
      // البحث عن مؤسسة موجودة أو إنشاء واحدة افتراضية
      final institutions = await DatabaseService.getAllInstitutions();
      int institutionId;
      
      if (institutions.isEmpty) {
        // إنشاء مؤسسة افتراضية
        final defaultInstitution = Institution()
          ..name = 'المؤسسة الافتراضية'
          ..code = 'DEFAULT'
          ..address = 'العنوان الافتراضي';
        
        institutionId = await DatabaseService.addInstitution(defaultInstitution);
      } else {
        institutionId = institutions.first.id;
      }

      // إنشاء سجل تمويل للباب الجديد
      final currentDate = DateTime.now();
      final funding = InstitutionFunding()
        ..institutionId = institutionId
        ..categoryId = categoryId
        ..allocatedAmount = allocatedAmount
        ..reservedAmount = 0
        ..spentAmount = 0
        ..year = currentDate.year
        ..month = currentDate.month
        ..createdAt = currentDate;

      await DatabaseService.addInstitutionFunding(funding);
    } catch (e) {
      // تسجيل الخطأ ولكن عدم إيقاف العملية
      print('خطأ في إنشاء سجل التمويل الافتراضي: $e');
    }
  }

  Future<void> _createSampleData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // إنشاء الأبواب التمويلية التجريبية
      final currentYear = DateTime.now().year;
      await _addCategory('خدمات طبية', null, 100000, 'سنوي', currentYear, null);
      await _addCategory('رواتب ومكافآت', null, 200000, 'سنوي', currentYear, null);
      await _addCategory('مشتريات وتجهيزات', null, 50000, 'شهري', currentYear, 1);
      
      // انتظار قليل للحصول على IDs الصحيحة
      await Future.delayed(Duration(milliseconds: 500));
      await _loadCategories();
      
      // إضافة أبواب فرعية
      final categories = await DatabaseService.getAllFundingCategories();
      final medicalCategory = categories.where((c) => c.name == 'خدمات طبية').firstOrNull;
      final salariesCategory = categories.where((c) => c.name == 'رواتب ومكافآت').firstOrNull;
      final purchasesCategory = categories.where((c) => c.name == 'مشتريات وتجهيزات').firstOrNull;

      if (medicalCategory != null) {
        await _addCategory('أدوية', medicalCategory.id, 30000, 'سنوي', currentYear, null);
        await _addCategory('مختبرات', medicalCategory.id, 25000, 'شهري', currentYear, 2);
        await _addCategory('أشعة', medicalCategory.id, 45000, 'سنوي', currentYear, null);
      }

      if (salariesCategory != null) {
        await _addCategory('رواتب أساسية', salariesCategory.id, 150000, 'سنوي', currentYear, null);
        await _addCategory('مكافآت', salariesCategory.id, 50000, 'شهري', currentYear, 3);
      }

      if (purchasesCategory != null) {
        await _addCategory('أجهزة طبية', purchasesCategory.id, 30000, 'سنوي', currentYear, null);
        await _addCategory('أثاث ومكتبية', purchasesCategory.id, 20000, 'شهري', currentYear, 4);
      }

      // إضافة بعض البيانات المصروفة والمحجوزة
      await _addSampleSpentAndReservedData();

      widget.onMessage('تم إنشاء البيانات التجريبية بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في إنشاء البيانات التجريبية: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSampleSpentAndReservedData() async {
    try {
      final fundings = await DatabaseService.getAllInstitutionFunding();
      
      for (int i = 0; i < fundings.length && i < 5; i++) {
        final funding = fundings[i];
        final allocatedAmount = funding.allocatedAmount;
        
        // إضافة مبالغ عشوائية للمصروف والمحجوز
        final spentAmount = allocatedAmount * 0.3; // 30% مصروف
        final reservedAmount = allocatedAmount * 0.2; // 20% محجوز
        
        final updatedFunding = funding.copyWith(
          spentAmount: spentAmount,
          reservedAmount: reservedAmount,
          updatedAt: DateTime.now(),
        );
        
        await DatabaseService.updateInstitutionFunding(updatedFunding);
      }
    } catch (e) {
      print('خطأ في إضافة البيانات المصروفة والمحجوزة: $e');
    }
  }

  Future<void> _showEditCategoryDialog(FundingCategory category) async {
    final nameController = TextEditingController(text: category.name);
    final amountController = TextEditingController(text: category.allocatedAmount.toString());
    String selectedFundingType = category.fundingType;
    int selectedYear = category.year;
    int? selectedMonth = category.month;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('تعديل الباب التمويلي'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الباب',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    SizedBox(height: 16),

                    // نوع التمويل
                    DropdownButtonFormField<String>(
                      value: selectedFundingType,
                      decoration: InputDecoration(
                        labelText: 'نوع التمويل',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      items: [
                        DropdownMenuItem(value: 'سنوي', child: Text('سنوي')),
                        DropdownMenuItem(value: 'شهري', child: Text('شهري')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFundingType = value!;
                          if (selectedFundingType == 'سنوي') {
                            selectedMonth = null;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // السنة
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _generateYearsList().map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // الشهر (يظهر فقط للتمويل الشهري)
                    if (selectedFundingType == 'شهري')
                      DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: 'الشهر',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        items: _generateMonthsList().map((month) {
                          return DropdownMenuItem<int>(
                            value: month['value'] as int,
                            child: Text(month['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMonth = value;
                          });
                        },
                      ),
                    
                    if (selectedFundingType == 'شهري')
                      SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ المخصص',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
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
                    if (nameController.text.isNotEmpty && 
                        amountController.text.isNotEmpty &&
                        (selectedFundingType == 'سنوي' || selectedMonth != null)) {
                      Navigator.of(context).pop();
                      await _updateCategory(
                        category,
                        nameController.text,
                        double.tryParse(amountController.text) ?? 0,
                        selectedFundingType,
                        selectedYear,
                        selectedMonth,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateCategory(FundingCategory category, String name, double amount,
      String fundingType, int year, int? month) async {
    try {
      final updatedCategory = category.copyWith(
        name: name,
        allocatedAmount: amount,
        fundingType: fundingType,
        year: year,
        month: month,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateFundingCategory(updatedCategory);
      await _loadCategories();
      widget.onMessage('تم تحديث الباب التمويلي بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في تحديث الباب التمويلي: $e', true);
    }
  }

  Future<void> _deleteCategory(FundingCategory category) async {
    final childrenCount = _categories.where((c) => c.parentId == category.id).length;
    final confirmMessage = childrenCount > 0
        ? 'هل أنت متأكد من حذف "${category.name}"؟\nسيتم حذف $childrenCount باب فرعي أيضاً.'
        : 'هل أنت متأكد من حذف "${category.name}"؟';

    final confirmed = await _showConfirmDialog(
      'حذف الباب التمويلي',
      confirmMessage,
    );

    if (confirmed == true) {
      try {
        await _deleteCategoryAndChildren(category);
        await _loadCategories();
        widget.onMessage('تم حذف الباب التمويلي وجميع الأبواب الفرعية بنجاح', false);
      } catch (e) {
        widget.onMessage('خطأ في حذف الباب التمويلي: $e', true);
      }
    }
  }

  /// حذف الفئة وجميع أطفالها بشكل تكراري (Cascade Delete)
  Future<void> _deleteCategoryAndChildren(FundingCategory category) async {
    // حذف الأطفال أولاً
    final children = _categories.where((c) => c.parentId == category.id).toList();
    for (final child in children) {
      await _deleteCategoryAndChildren(child);
    }
    
    // حذف الفئة نفسها
    await DatabaseService.deleteFundingCategory(category.id);
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final totalSummary = _calculateTotalSummary();

    return Column(
      children: [
        // بطاقة الملخص العام
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملخص العام',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryColumn(
                      'إجمالي التمويل',
                      totalSummary['allocated']!,
                      Colors.indigo,
                    ),
                    _buildSummaryColumn(
                      'المصروف',
                      totalSummary['spent']!,
                      Colors.red,
                    ),
                    _buildSummaryColumn(
                      'المحجوز',
                      totalSummary['reserved']!,
                      Colors.orange,
                    ),
                    _buildSummaryColumn(
                      'المتبقي',
                      totalSummary['remaining']!,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // شريط المرشحات
        Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تصفية الأبواب التمويلية (${_categories.length} من ${_allCategories.length})',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilterType,
                          decoration: InputDecoration(
                            labelText: 'النوع',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                            DropdownMenuItem(value: 'سنوي', child: Text('سنوي')),
                            DropdownMenuItem(value: 'شهري', child: Text('شهري')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilterType = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedFilterYear,
                          decoration: InputDecoration(
                            labelText: 'السنة',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem(value: 0, child: Text('جميع السنوات')),
                            ..._generateYearsList().map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilterYear = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedFilterMonth,
                          decoration: InputDecoration(
                            labelText: 'الشهر',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem(value: 0, child: Text('جميع الشهور')),
                            ..._generateMonthsList().map((month) {
                              return DropdownMenuItem<int>(
                                value: month['value'] as int,
                                child: Text(month['name'] as String),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilterMonth = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // شريط الأزرار
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(),
                icon: Icon(Icons.add),
                label: Text('إضافة باب جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _loadCategories,
                icon: Icon(Icons.refresh),
                label: Text('تحديث'),
              ),
              SizedBox(width: 12),
              if (_categories.isEmpty) // عرض الزر فقط إذا لم توجد بيانات
                ElevatedButton.icon(
                  onPressed: _createSampleData,
                  icon: Icon(Icons.data_usage),
                  label: Text('إنشاء بيانات تجريبية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // قائمة الأبواب الهرمية
        Expanded(
          child: _hierarchicalCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد أبواب تمويلية', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _hierarchicalCategories.length,
                  itemBuilder: (context, index) {
                    return _buildHierarchicalCategoryTile(_hierarchicalCategories[index], 0);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryColumn(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// بناء العنصر الهرمي بشكل تكراري
  Widget _buildHierarchicalCategoryTile(FundingCategory category, int depth) {
    final children = _categories.where((c) => c.parentId == category.id).toList();
    final hasChildren = children.isNotEmpty;
    final summary = _calculateCategorySummary(category);
    final isExpanded = _expansionStates[category.id] ?? false;

    return Container(
      margin: EdgeInsets.only(left: depth * 24.0, bottom: 8),
      child: Card(
        elevation: hasChildren ? 2 : 1,
        child: hasChildren
            ? ExpansionTile(
                key: Key('category_${category.id}'),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expansionStates[category.id] = expanded;
                  });
                },
                leading: Icon(
                  hasChildren ? Icons.folder : Icons.description,
                  color: hasChildren ? Colors.indigo : Colors.grey,
                ),
                title: Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: hasChildren ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.fundingPeriodText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4),
                    _buildCategorySummaryRow(summary),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _showAddCategoryDialog(category),
                      tooltip: 'إضافة باب فرعي',
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditCategoryDialog(category),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(category),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
                children: children
                    .map((child) => _buildHierarchicalCategoryTile(child, depth + 1))
                    .toList(),
              )
            : ListTile(
                leading: Icon(Icons.description, color: Colors.grey),
                title: Text(category.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.fundingPeriodText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4),
                    _buildCategorySummaryRow(summary),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _showAddCategoryDialog(category),
                      tooltip: 'إضافة باب فرعي',
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditCategoryDialog(category),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(category),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategorySummaryRow(Map<String, double> summary) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _buildSmallChip('مخصص', summary['allocated']!, Colors.indigo),
          SizedBox(width: 8),
          _buildSmallChip('مصروف', summary['spent']!, Colors.red),
          SizedBox(width: 8),
          _buildSmallChip('متبقي', summary['remaining']!, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// التبويب الثاني: إدارة الحجز والصرف
class ReservationSpendingTab extends StatefulWidget {
  final Function(String message, bool isError) onMessage;

  const ReservationSpendingTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  _ReservationSpendingTabState createState() => _ReservationSpendingTabState();
}

class _ReservationSpendingTabState extends State<ReservationSpendingTab> {
  List<FundingCategory> _categories = [];
  List<InstitutionFunding> _fundings = [];
  List<InstitutionFunding> _recentOperations = [];
  
  FundingCategory? _selectedCategory;
  InstitutionFunding? _selectedFunding;
  
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await DatabaseService.getAllFundingCategories();
      final fundings = await DatabaseService.getAllInstitutionFunding();
      
      setState(() {
        _categories = categories;
        _fundings = fundings;
        _recentOperations = fundings.take(10).toList();
      });
    } catch (e) {
      widget.onMessage('خطأ في تحميل البيانات: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createFundingForCategory(FundingCategory category) async {
    try {
      // إنشاء تمويل جديد للفئة إذا لم يكن موجوداً
      final existingFunding = _fundings.where((f) => f.categoryId == category.id).firstOrNull;
      
      if (existingFunding == null) {
        final newFunding = InstitutionFunding()
          ..institutionId = 1 // المؤسسة الافتراضية (المؤسسة الداخلية)
          ..categoryId = category.id
          ..allocatedAmount = category.allocatedAmount
          ..reservedAmount = 0
          ..spentAmount = 0
          ..year = DateTime.now().year
          ..month = DateTime.now().month
          ..createdAt = DateTime.now();

        await DatabaseService.addInstitutionFunding(newFunding);
        await _loadData();
        
        // تحديد التمويل الجديد
        final updatedFundings = await DatabaseService.getAllInstitutionFunding();
        final createdFunding = updatedFundings.where((f) => f.categoryId == category.id).firstOrNull;
        setState(() {
          _selectedFunding = createdFunding;
        });
      } else {
        setState(() {
          _selectedFunding = existingFunding;
        });
      }
    } catch (e) {
      widget.onMessage('خطأ في إنشاء التمويل: $e', true);
    }
  }

  Future<void> _reserveAmount() async {
    if (_selectedFunding == null || _amountController.text.isEmpty) {
      widget.onMessage('يرجى اختيار التمويل وإدخال المبلغ', true);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      widget.onMessage('يرجى إدخال مبلغ صحيح', true);
      return;
    }

    try {
      // المتاح = المخصص - المحجوز - المصروف
      final available = _selectedFunding!.allocatedAmount - _selectedFunding!.reservedAmount - _selectedFunding!.spentAmount;
      
      if (amount > available) {
        widget.onMessage('المبلغ المطلوب للحجز (${amount.toStringAsFixed(0)}) أكبر من المتاح (${available.toStringAsFixed(0)})', true);
        return;
      }

      final updatedFunding = _selectedFunding!.copyWith(
        reservedAmount: _selectedFunding!.reservedAmount + amount,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateInstitutionFunding(updatedFunding);
      await _loadData();
      
      // تحديث التمويل المحدد
      final refreshedFunding = _fundings.where((f) => f.id == _selectedFunding!.id).firstOrNull;
      setState(() {
        _selectedFunding = refreshedFunding;
        _amountController.clear();
      });

      widget.onMessage('تم حجز المبلغ بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في حجز المبلغ: $e', true);
    }
  }

  Future<void> _spendAmount() async {
    if (_selectedFunding == null || _amountController.text.isEmpty) {
      widget.onMessage('يرجى اختيار التمويل وإدخال المبلغ', true);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      widget.onMessage('يرجى إدخال مبلغ صحيح', true);
      return;
    }

    try {
      // المتاح = المخصص - المصروف - المحجوز
      final available = _selectedFunding!.allocatedAmount - _selectedFunding!.spentAmount - _selectedFunding!.reservedAmount;
      
      if (amount > available) {
        widget.onMessage('المبلغ المطلوب (${amount.toStringAsFixed(0)}) أكبر من المتاح (${available.toStringAsFixed(0)})', true);
        return;
      }

      final updatedFunding = _selectedFunding!.copyWith(
        spentAmount: _selectedFunding!.spentAmount + amount,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateInstitutionFunding(updatedFunding);
      await _loadData();
      
      // تحديث التمويل المحدد
      final refreshedFunding = _fundings.where((f) => f.id == _selectedFunding!.id).firstOrNull;
      setState(() {
        _selectedFunding = refreshedFunding;
        _amountController.clear();
      });

      widget.onMessage('تم صرف المبلغ بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في صرف المبلغ: $e', true);
    }
  }

  Future<void> _showAdjustDialog(String type) async {
    if (_selectedFunding == null) {
      widget.onMessage('يرجى اختيار التمويل أولاً', true);
      return;
    }

    final adjustController = TextEditingController();
    final currentAmount = type == 'reserved' 
        ? _selectedFunding!.reservedAmount 
        : _selectedFunding!.spentAmount;
    
    adjustController.text = currentAmount.toString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type == 'reserved' ? 'تعديل المبلغ المحجوز' : 'تعديل المبلغ المصروف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'المبلغ الحالي: ${currentAmount.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: adjustController,
                decoration: InputDecoration(
                  labelText: 'المبلغ الجديد',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newAmount = double.tryParse(adjustController.text);
                if (newAmount != null && newAmount >= 0) {
                  Navigator.of(context).pop();
                  await _adjustAmount(type, newAmount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: type == 'reserved' ? Colors.orange : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _adjustAmount(String type, double newAmount) async {
    try {
      if (type == 'reserved') {
        // التحقق من أن المبلغ المحجوز + المصروف لا يتجاوز المخصص
        final totalUsed = newAmount + _selectedFunding!.spentAmount;
        if (totalUsed > _selectedFunding!.allocatedAmount) {
          widget.onMessage('المجموع (محجوز + مصروف) يتجاوز المبلغ المخصص', true);
          return;
        }
        
        final updatedFunding = _selectedFunding!.copyWith(
          reservedAmount: newAmount,
          updatedAt: DateTime.now(),
        );
        await DatabaseService.updateInstitutionFunding(updatedFunding);
        widget.onMessage('تم تعديل المبلغ المحجوز بنجاح', false);
      } else {
        // التحقق من أن المبلغ المصروف + المحجوز لا يتجاوز المخصص
        final totalUsed = newAmount + _selectedFunding!.reservedAmount;
        if (totalUsed > _selectedFunding!.allocatedAmount) {
          widget.onMessage('المجموع (مصروف + محجوز) يتجاوز المبلغ المخصص', true);
          return;
        }
        
        final updatedFunding = _selectedFunding!.copyWith(
          spentAmount: newAmount,
          updatedAt: DateTime.now(),
        );
        await DatabaseService.updateInstitutionFunding(updatedFunding);
        widget.onMessage('تم تعديل المبلغ المصروف بنجاح', false);
      }

      await _loadData();
      
      // تحديث التمويل المحدد
      final refreshedFunding = _fundings.where((f) => f.id == _selectedFunding!.id).firstOrNull;
      setState(() {
        _selectedFunding = refreshedFunding;
      });
    } catch (e) {
      widget.onMessage('خطأ في تعديل المبلغ: $e', true);
    }
  }

  /// بناء قائمة منسدلة هرمية للفئات
  List<DropdownMenuItem<FundingCategory>> _buildHierarchicalCategoryDropdown(
    List<FundingCategory> categories
  ) {
    List<DropdownMenuItem<FundingCategory>> items = [];
    
    // تصفية الفئات الجذر (بدون أب)
    final rootCategories = categories.where((c) => c.parentId == null).toList();
    
    for (final category in rootCategories) {
      items.addAll(_buildCategoryItemsRecursive(category, categories, 0));
    }
    
    return items;
  }

  /// بناء عناصر الفئة بشكل تكراري
  List<DropdownMenuItem<FundingCategory>> _buildCategoryItemsRecursive(
    FundingCategory category,
    List<FundingCategory> allCategories,
    int depth
  ) {
    List<DropdownMenuItem<FundingCategory>> items = [];
    
    // إضافة الفئة الحالية
    final indent = '  ' * depth;
    final icon = depth == 0 ? '📁 ' : '  └─ ';
    
    items.add(
      DropdownMenuItem<FundingCategory>(
        value: category,
        child: Text('$indent$icon${category.name}'),
      ),
    );
    
    // البحث عن الأطفال وإضافتهم بشكل تكراري
    final children = allCategories.where((c) => c.parentId == category.id).toList();
    for (final child in children) {
      items.addAll(_buildCategoryItemsRecursive(child, allCategories, depth + 1));
    }
    
    return items;
  }

  Widget _buildFundingInfo() {
    if (_selectedFunding == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'اختر باباً تمويلياً لعرض التفاصيل',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final funding = _selectedFunding!;
    final remaining = funding.remainingAmount;
    final utilization = funding.allocatedAmount > 0 
        ? (funding.spentAmount / funding.allocatedAmount) * 100 
        : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تحذير في حالة تجاوز المبلغ المخصص
            if (remaining < 0)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تحذير: تم تجاوز المبلغ المخصص بمقدار ${(-remaining).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            Text(
              'معلومات التمويل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    'المخصص',
                    funding.allocatedAmount,
                    Colors.blue,
                    Icons.account_balance,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildAmountCard(
                    'المحجوز',
                    funding.reservedAmount,
                    Colors.orange,
                    Icons.lock,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    'المصروف',
                    funding.spentAmount,
                    Colors.red,
                    Icons.payments,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildAmountCard(
                    'المتبقي',
                    remaining,
                    remaining > 0 ? Colors.green : (remaining < 0 ? Colors.red : Colors.grey),
                    remaining > 0 ? Icons.savings : Icons.warning,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // شريط التقدم
            Text(
              'نسبة الاستغلال: ${utilization.toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: utilization / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                utilization < 50 ? Colors.green :
                utilization < 80 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            amount.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اختيار الباب التمويلي
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختيار الباب التمويلي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<FundingCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'اختر الباب التمويلي',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_tree),
                    ),
                    items: _buildHierarchicalCategoryDropdown(_categories),
                    onChanged: (value) async {
                      setState(() {
                        _selectedCategory = value;
                      });
                      if (value != null) {
                        await _createFundingForCategory(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // معلومات التمويل
          _buildFundingInfo(),
          
          SizedBox(height: 16),
          
          // عمليات الحجز والصرف
          if (_selectedFunding != null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عمليات الحجز والصرف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _reserveAmount,
                            icon: Icon(Icons.lock),
                            label: Text('حجز المبلغ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _spendAmount,
                            icon: Icon(Icons.payments),
                            label: Text('صرف المبلغ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // أزرار التصحيح
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAdjustDialog('reserved'),
                            icon: Icon(Icons.edit, size: 16),
                            label: Text('تعديل المحجوز'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.orange),
                              padding: EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAdjustDialog('spent'),
                            icon: Icon(Icons.edit, size: 16),
                            label: Text('تعديل المصروف'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // آخر العمليات
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آخر العمليات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    if (_recentOperations.isEmpty)
                      Text('لا توجد عمليات', style: TextStyle(color: Colors.grey))
                    else
                      ...(_recentOperations.map((funding) {
                        final category = _categories.where((c) => c.id == funding.categoryId).firstOrNull;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.account_balance, color: Colors.white),
                          ),
                          title: Text(category?.name ?? 'غير محدد'),
                          subtitle: Text(
                            'مصروف: ${funding.spentAmount.toStringAsFixed(0)} - محجوز: ${funding.reservedAmount.toStringAsFixed(0)}',
                          ),
                          trailing: Text(
                            '${funding.updatedAt?.toString().split(' ')[0] ?? ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      }).toList()),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

/// التبويب الثالث: المرفقات
class AttachmentsTab extends StatefulWidget {
  final Function(String message, bool isError) onMessage;

  const AttachmentsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  _AttachmentsTabState createState() => _AttachmentsTabState();
}

class _AttachmentsTabState extends State<AttachmentsTab> {
  List<FundingCategory> _categories = [];
  List<InstitutionFunding> _fundings = [];
  List<FundingAttachment> _attachments = [];
  List<FundingAttachment> _filteredAttachments = [];
  
  FundingCategory? _selectedCategory;
  InstitutionFunding? _selectedFunding;
  
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await DatabaseService.getAllFundingCategories();
      final fundings = await DatabaseService.getAllInstitutionFunding();
      
      setState(() {
        _categories = categories;
        _fundings = fundings;
      });
    } catch (e) {
      widget.onMessage('خطأ في تحميل البيانات: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAttachments() async {
    if (_selectedFunding == null) return;

    try {
      final attachments = await DatabaseService.getAttachmentsByFunding(_selectedFunding!.id);
      setState(() {
        _attachments = attachments;
        _applySearch();
      });
    } catch (e) {
      widget.onMessage('خطأ في تحميل المرفقات: $e', true);
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredAttachments = List.from(_attachments);
    } else {
      _filteredAttachments = _attachments.where((attachment) {
        return attachment.fileName?.toLowerCase().contains(query) == true ||
               attachment.fileType?.toLowerCase().contains(query) == true ||
               attachment.description?.toLowerCase().contains(query) == true;
      }).toList();
    }
  }

  Future<void> _showAddAttachmentDialog() async {
    if (_selectedFunding == null) {
      widget.onMessage('يرجى اختيار باب تمويلي أولاً', true);
      return;
    }

    final fileNameController = TextEditingController();
    final filePathController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedFileType = 'PDF';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('إضافة مرفق جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fileNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الملف',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    TextField(
                      controller: filePathController,
                      decoration: InputDecoration(
                        labelText: 'مسار الملف',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      value: selectedFileType,
                      decoration: InputDecoration(
                        labelText: 'نوع الملف',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ['PDF', 'Word', 'Excel', 'JPEG', 'PNG', 'Other']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFileType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'الوصف (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
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
                    if (fileNameController.text.isNotEmpty && filePathController.text.isNotEmpty) {
                      Navigator.of(context).pop();
                      await _addAttachment(
                        fileNameController.text,
                        filePathController.text,
                        selectedFileType,
                        descriptionController.text,
                      );
                    }
                  },
                  child: Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addAttachment(String fileName, String filePath, String fileType, String description) async {
    try {
      final attachment = FundingAttachment()
        ..fundingId = _selectedFunding!.id
        ..fileName = fileName
        ..filePath = filePath
        ..fileType = fileType
        ..description = description.isEmpty ? null : description
        ..uploadedAt = DateTime.now();

      await DatabaseService.addFundingAttachment(attachment);
      await _loadAttachments();
      widget.onMessage('تم إضافة المرفق بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في إضافة المرفق: $e', true);
    }
  }

  Future<void> _deleteAttachment(FundingAttachment attachment) async {
    final confirmed = await _showConfirmDialog(
      'حذف المرفق',
      'هل أنت متأكد من حذف "${attachment.fileName}"؟',
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteFundingAttachment(attachment.id);
        await _loadAttachments();
        widget.onMessage('تم حذف المرفق بنجاح', false);
      } catch (e) {
        widget.onMessage('خطأ في حذف المرفق: $e', true);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  Color _getFileTypeColor(String? fileType) {
    switch (fileType?.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'WORD':
        return Colors.blue;
      case 'EXCEL':
        return Colors.green;
      case 'JPEG':
      case 'PNG':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  IconData _getFileTypeIcon(String? fileType) {
    switch (fileType?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'WORD':
        return Icons.description;
      case 'EXCEL':
        return Icons.table_chart;
      case 'JPEG':
      case 'PNG':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  /// بناء قائمة منسدلة هرمية للفئات
  List<DropdownMenuItem<FundingCategory>> _buildHierarchicalCategoryDropdown(
    List<FundingCategory> categories
  ) {
    List<DropdownMenuItem<FundingCategory>> items = [];
    
    // تصفية الفئات الجذر (بدون أب)
    final rootCategories = categories.where((c) => c.parentId == null).toList();
    
    for (final category in rootCategories) {
      items.addAll(_buildCategoryItemsRecursive(category, categories, 0));
    }
    
    return items;
  }

  /// بناء عناصر الفئة بشكل تكراري
  List<DropdownMenuItem<FundingCategory>> _buildCategoryItemsRecursive(
    FundingCategory category,
    List<FundingCategory> allCategories,
    int depth
  ) {
    List<DropdownMenuItem<FundingCategory>> items = [];
    
    // إضافة الفئة الحالية
    final indent = '  ' * depth;
    final icon = depth == 0 ? '📁 ' : '  └─ ';
    
    items.add(
      DropdownMenuItem<FundingCategory>(
        value: category,
        child: Text('$indent$icon${category.name}'),
      ),
    );
    
    // البحث عن الأطفال وإضافتهم بشكل تكراري
    final children = allCategories.where((c) => c.parentId == category.id).toList();
    for (final child in children) {
      items.addAll(_buildCategoryItemsRecursive(child, allCategories, depth + 1));
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // منطقة التحكم
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              // اختيار الباب التمويلي
              DropdownButtonFormField<FundingCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'اختر الباب التمويلي',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_tree),
                ),
                items: _buildHierarchicalCategoryDropdown(_categories),
                onChanged: (value) async {
                  setState(() {
                    _selectedCategory = value;
                    if (value != null) {
                      _selectedFunding = _fundings.where((f) => f.categoryId == value.id).firstOrNull;
                    } else {
                      _selectedFunding = null;
                    }
                  });
                  await _loadAttachments();
                },
              ),
              
              SizedBox(height: 12),
              
              // شريط البحث
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'البحث في المرفقات...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _applySearch();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _applySearch();
                  });
                },
              ),
              
              SizedBox(height: 12),
              
              // زر إضافة مرفق
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedFunding != null ? _showAddAttachmentDialog : null,
                  icon: Icon(Icons.add),
                  label: Text('إضافة مرفق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // قائمة المرفقات
        Expanded(
          child: _selectedFunding == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_file_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'اختر باباً تمويلياً لعرض مرفقاته',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredAttachments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _attachments.isEmpty ? 'لا توجد مرفقات' : 'لا توجد نتائج للبحث',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredAttachments.length,
                      itemBuilder: (context, index) {
                        final attachment = _filteredAttachments[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getFileTypeColor(attachment.fileType),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getFileTypeIcon(attachment.fileType),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              attachment.fileName ?? 'ملف غير معروف',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (attachment.description != null) ...[
                                  Text(
                                    attachment.description!,
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                ],
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                                    SizedBox(width: 4),
                                    Text(
                                      attachment.uploadedAt?.toString().split('.')[0] ?? 'غير محدد',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                switch (value) {
                                  case 'delete':
                                    await _deleteAttachment(attachment);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                                    title: Text('حذف', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// التبويب الرابع: التقارير
class ReportsTab extends StatefulWidget {
  final Function(String message, bool isError) onMessage;

  const ReportsTab({Key? key, required this.onMessage}) : super(key: key);

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  List<FundingCategory> _categories = [];
  List<InstitutionFunding> _fundings = [];
  List<ReportNode> _reportNodes = [];
  
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  bool _isLoading = false;
  bool _showOnlyWithFunding = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await DatabaseService.getAllFundingCategories();
      final fundings = await DatabaseService.getAllInstitutionFunding();
      
      setState(() {
        _categories = categories;
        _fundings = fundings;
      });
      
      await _generateReport();
    } catch (e) {
      widget.onMessage('خطأ في تحميل البيانات: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // بناء التقرير الهرمي
      final rootCategories = _categories.where((c) => c.parentId == null).toList();
      final reportNodes = <ReportNode>[];

      for (final category in rootCategories) {
        final node = await _buildReportNode(category);
        if (!_showOnlyWithFunding || node.totalAllocated > 0) {
          reportNodes.add(node);
        }
      }

      setState(() {
        _reportNodes = reportNodes;
      });

      widget.onMessage('تم توليد التقرير بنجاح', false);
    } catch (e) {
      widget.onMessage('خطأ في توليد التقرير: $e', true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ReportNode> _buildReportNode(FundingCategory category) async {
    // البحث عن التمويل الخاص بهذه الفئة
    final funding = _fundings.where((f) => 
        f.categoryId == category.id && 
        f.year == _selectedYear &&
        (_selectedMonth == null || f.month == _selectedMonth)
    ).firstOrNull;

    // بناء العقد الفرعية
    final childCategories = _categories.where((c) => c.parentId == category.id).toList();
    final children = <ReportNode>[];
    
    for (final child in childCategories) {
      final childNode = await _buildReportNode(child);
      children.add(childNode);
    }

    return ReportNode(
      categoryId: category.id,
      categoryName: category.name,
      allocated: funding?.allocatedAmount ?? category.allocatedAmount,
      reserved: funding?.reservedAmount ?? 0,
      spent: funding?.spentAmount ?? 0,
      children: children,
    );
  }

  Widget _buildReportNodeWidget(ReportNode node, int depth) {
    final indent = depth * 20.0;
    final hasChildren = node.children.isNotEmpty;
    final utilizationRate = node.allocated > 0 ? (node.spent / node.allocated) * 100 : 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: hasChildren
          ? ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16 + indent, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getUtilizationColor(utilizationRate.toDouble()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.folder, color: Colors.white),
              ),
              title: Text(
                node.categoryName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مخصص: ${node.totalAllocated.toStringAsFixed(0)}'),
                  Text('مصروف: ${node.totalSpent.toStringAsFixed(0)} (${utilizationRate.toStringAsFixed(1)}%)'),
                ],
              ),
              children: node.children.map((child) => _buildReportNodeWidget(child, depth + 1)).toList(),
            )
          : ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16 + indent, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getUtilizationColor(utilizationRate.toDouble()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description, color: Colors.white),
              ),
              title: Text(node.categoryName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildAmountChip('مخصص', node.allocated, Colors.blue),
                      SizedBox(width: 8),
                      _buildAmountChip('محجوز', node.reserved, Colors.orange),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildAmountChip('مصروف', node.spent, Colors.red),
                      SizedBox(width: 8),
                      _buildAmountChip('متبقي', node.remaining, Colors.green),
                    ],
                  ),
                  if (utilizationRate > 0) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'نسبة الاستغلال: ${utilizationRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAmountChip(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getUtilizationColor(double utilizationRate) {
    if (utilizationRate >= 80) return Colors.red;
    if (utilizationRate >= 50) return Colors.orange;
    if (utilizationRate >= 20) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // منطقة التحكم
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إعدادات التقرير',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'الشهر (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('جميع الأشهر'),
                        ),
                        ...List.generate(12, (index) {
                          final month = index + 1;
                          return DropdownMenuItem<int?>(
                            value: month,
                            child: Text('$month'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              CheckboxListTile(
                title: Text('إظهار الأبواب التي لها تمويل فقط'),
                value: _showOnlyWithFunding,
                onChanged: (value) {
                  setState(() {
                    _showOnlyWithFunding = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              
              SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: Icon(Icons.analytics),
                  label: Text('توليد التقرير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // منطقة التقرير
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _reportNodes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد بيانات للتقرير',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'جرب تغيير فلاتر التقرير أو إضافة بيانات تمويل',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _reportNodes.length,
                      itemBuilder: (context, index) {
                        return _buildReportNodeWidget(_reportNodes[index], 0);
                      },
                    ),
        ),
      ],
    );
  }
}

/// كلاس مساعد لعقد التقرير
class ReportNode {
  final int categoryId;
  final String categoryName;
  final double allocated;
  final double reserved;
  final double spent;
  final List<ReportNode> children;

  ReportNode({
    required this.categoryId,
    required this.categoryName,
    required this.allocated,
    required this.reserved,
    required this.spent,
    required this.children,
  });

  double get remaining => allocated - reserved - spent;
  
  double get totalAllocated {
    return allocated + children.fold(0.0, (sum, child) => sum + child.totalAllocated);
  }
  
  double get totalSpent {
    return spent + children.fold(0.0, (sum, child) => sum + child.totalSpent);
  }
  
  double get totalReserved {
    return reserved + children.fold(0.0, (sum, child) => sum + child.totalReserved);
  }
}