import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import '../models/funding_models.dart';
import '../models/organization.dart';
import '../providers/organization_provider.dart';
import '../services/database_service.dart';

class FundingAllocationScreen extends StatefulWidget {
  const FundingAllocationScreen({super.key});

  @override
  State<FundingAllocationScreen> createState() =>
      _FundingAllocationScreenState();
}

class _FundingAllocationScreenState extends State<FundingAllocationScreen> {
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  String _selectedFundingType = 'سنوي';
  FundingCategory? _selectedCategory;

  // متغيرات للتنقل الهرمي متعدد المستويات
  int _currentLevel =
      0; // المستوى الحالي (0 = رئيسي، 1 = فرعي، 2 = فرعي من الفرعي...)
  List<FundingCategory> _navigationPath = []; // مسار التنقل الحالي
  FundingCategory? _currentParent; // الباب الأعلى الحالي

  final _amountController = TextEditingController();

  List<FundingCategory> _categories = [];
  List<InstitutionFunding> _allocations = [];
  Organization? _mainInstitution;

  // متغيرات تحسين الأداء وتجربة المستخدم
  bool _isLoading = false;
  String? _lastError;
  final Map<int, List<FundingCategory>> _childrenCache = {};

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
    if (_isLoading) return; // منع التحميل المتكرر

    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      // إنشاء بيانات تجريبية إذا لم تكن موجودة
      await DatabaseService.createSampleFundingCategories();

      // تحميل المؤسسة الرئيسية
      final orgProvider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      _mainInstitution = orgProvider.organization;

      // تحميل جميع الفئات
      _categories = await DatabaseService.getAllFundingCategories();

      // تحميل التخصيصات حسب نوع التمويل
      if (_selectedFundingType == 'سنوي') {
        _allocations = await DatabaseService.getInstitutionFundingByYear(
          _selectedYear,
        );
      } else if (_selectedFundingType == 'شهري') {
        if (_selectedMonth != null) {
          _allocations = await DatabaseService.getInstitutionFundingByYearMonth(
            _selectedYear,
            _selectedMonth!,
          );
        } else {
          _allocations = []; // لم يتم اختيار الشهر بعد
        }
      }

      // مسح التخزين المؤقت عند تحميل بيانات جديدة
      _childrenCache.clear();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _lastError = 'خطأ في تحميل البيانات: $e';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_lastError!)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // دوال مساعدة للتنقل الهرمي

  /// الحصول على الأطفال المباشرين لفئة محددة مع التخزين المؤقت
  List<FundingCategory> _getDirectChildren(FundingCategory? parent) {
    final parentId = parent?.id ?? 0;

    // التحقق من التخزين المؤقت أولاً
    if (_childrenCache.containsKey(parentId)) {
      return _childrenCache[parentId]!;
    }

    List<FundingCategory> children;
    if (parent == null) {
      // إرجاع الفئات الرئيسية
      children = _categories
          .where((category) => category.parentId == null)
          .toList();
    } else {
      // إرجاع الأطفال المباشرين
      children = _categories
          .where((category) => category.parentId == parent.id)
          .toList();
    }

    // حفظ في التخزين المؤقت
    _childrenCache[parentId] = children;
    return children;
  }

  /// الحصول على فئات المستوى الحالي
  List<FundingCategory> _getCurrentLevelCategories() {
    if (_currentLevel == 0) {
      // في المستوى الرئيسي - اعرض دائماً الفئات الرئيسية فقط
      return _getDirectChildren(null);
    } else {
      // في المستويات الفرعية - اعرض الأطفال المباشرين
      return _getDirectChildren(_currentParent);
    }
  }

  /// حساب إجمالي التخصيصات للأبواب الفرعية
  Future<double> _getSubCategoriesAllocatedTotal(
    FundingCategory parentCategory,
  ) async {
    final children = _getDirectChildren(parentCategory);
    double total = 0;

    for (final child in children) {
      final allocation = _allocations.firstWhere(
        (alloc) => alloc.categoryId == child.id,
        orElse: () => InstitutionFunding()..allocatedAmount = 0,
      );
      total += allocation.allocatedAmount;
    }

    return total;
  }

  /// حساب المبلغ المتاح للتوزيع من الباب الأعلى
  Future<double> _getAvailableAmountForDistribution(
    FundingCategory parentCategory,
  ) async {
    final parentAllocation = _allocations.firstWhere(
      (alloc) => alloc.categoryId == parentCategory.id,
      orElse: () => InstitutionFunding()..allocatedAmount = 0,
    );

    final subCategoriesTotal = await _getSubCategoriesAllocatedTotal(
      parentCategory,
    );
    return parentAllocation.allocatedAmount - subCategoriesTotal;
  }

  // دوال التخصيص
  Future<void> _allocateFunding() async {
    if (_selectedCategory == null) {
      _showSnackBar('يرجى اختيار الفئة');
      return;
    }

    if (_amountController.text.isEmpty) {
      _showSnackBar('يرجى إدخال المبلغ');
      return;
    }

    if (_selectedFundingType.isEmpty) {
      _showSnackBar('يرجى اختيار نوع التمويل');
      return;
    }

    if (_selectedFundingType == 'شهري' && _selectedMonth == null) {
      _showSnackBar('يرجى اختيار الشهر للتمويل الشهري');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('يرجى إدخال مبلغ صحيح');
      return;
    }

    try {
      // ✅ التحقق من المبلغ المتاح
      if (_currentLevel > 0 && _currentParent != null) {
        final availableAmount = await _getAvailableAmountForDistribution(
          _currentParent!,
        );

        var query = DatabaseService.isar.institutionFundings
            .filter()
            .categoryIdEqualTo(_selectedCategory!.id)
            .fundingTypeEqualTo(_selectedFundingType)
            .yearEqualTo(_selectedYear);

        if (_selectedFundingType == 'شهري') {
          query = query.monthEqualTo(_selectedMonth!);
        }

        final existingAlloc = await query.findFirst();

        final existingAmount = existingAlloc?.allocatedAmount ?? 0;
        final additionalAmount = amount - existingAmount;

        if (additionalAmount > availableAmount) {
          _showSnackBar(
            'المبلغ المطلوب يتجاوز المتاح للتوزيع. المتاح: ${availableAmount.toStringAsFixed(0)} د.ع',
          );
          return;
        }
      }

      var existingQuery = DatabaseService.isar.institutionFundings
          .filter()
          .categoryIdEqualTo(_selectedCategory!.id)
          .fundingTypeEqualTo(_selectedFundingType)
          .yearEqualTo(_selectedYear);

      if (_selectedFundingType == 'شهري') {
        existingQuery = existingQuery.monthEqualTo(_selectedMonth!);
      }

      final existingAllocation = await existingQuery.findFirst();

      if (existingAllocation != null) {
        // ✅ تحديث الموجود
        existingAllocation
          ..allocatedAmount = amount
          ..updatedAt = DateTime.now();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.institutionFundings.put(
            existingAllocation,
          );
        });

        print("✅ تم تحديث التخصيص الموجود بنجاح ID: ${existingAllocation.id}");
      } else {
        // ✅ إنشاء تخصيص جديد
        final newAllocation = InstitutionFunding()
          ..institutionId = _mainInstitution!.id
          ..categoryId = _selectedCategory!.id
          ..fundingType = _selectedFundingType
          ..allocatedAmount = amount
          ..reservedAmount = 0
          ..spentAmount = 0
          ..year = _selectedYear
          ..month = _selectedFundingType == 'شهري' ? _selectedMonth : null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.institutionFundings.put(newAllocation);
        });

        print("✅ تم إنشاء تخصيص جديد ID: ${newAllocation.id}");
      }

      // ✅ إعادة تحميل البيانات بعد الإضافة
      print("🔄 إعادة تحميل البيانات...");
      await _loadData();

      // ✅ إعادة تعيين الحقول بعد التحديث
      setState(() {
        _amountController.clear();
        _selectedCategory = null;
      });

      _showSnackBar(
        'تم ${_currentLevel == 0 ? 'تخصيص' : 'توزيع'} التمويل بنجاح',
      );
    } catch (e) {
      _showSnackBar(
        '❌ خطأ في ${_currentLevel == 0 ? 'تخصيص' : 'توزيع'} التمويل: $e',
      );
    }
  }

  Future<void> _deleteAllocation(InstitutionFunding allocation) async {
    if (allocation.spentAmount > 0 || allocation.reservedAmount > 0) {
      _showSnackBar(
        'لا يمكن حذف التخصيص لأنه يحتوي على مبالغ مصروفة أو محجوزة',
      );
      return;
    }

    try {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.institutionFundings.delete(allocation.id);
      });

      await _loadData();
      _showSnackBar('تم حذف التخصيص بنجاح');
    } catch (e) {
      _showSnackBar('خطأ في حذف التخصيص');
    }
  }

  // دوال الواجهة

  String _getCurrentLevelName() {
    switch (_currentLevel) {
      case 0:
        return 'الأبواب الرئيسية';
      case 1:
        return 'الأبواب الفرعية';
      case 2:
        return 'الأبواب الفرعية من الدرجة الثانية';
      default:
        return 'المستوى ${_currentLevel + 1}';
    }
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// بناء شريط التنقل (Breadcrumb)
  Widget _buildNavigationBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // الرئيسية
            GestureDetector(
              onTap: () {
                setState(() {
                  _navigationPath.clear();
                  _currentLevel = 0;
                  _currentParent = null;
                  _selectedCategory = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentLevel == 0
                      ? Colors.blue[600]
                      : Colors.blue[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'الرئيسية',
                  style: TextStyle(
                    color: _currentLevel == 0 ? Colors.white : Colors.blue[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // مسار التنقل
            ..._navigationPath.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isLast = index == _navigationPath.length - 1;

              return Row(
                children: [
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _navigationPath = _navigationPath.sublist(0, index + 1);
                        _currentLevel = index + 1;
                        _currentParent = category;
                        _selectedCategory = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLast ? Colors.blue[600] : Colors.blue[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isLast ? Colors.white : Colors.blue[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// بناء نموذج التخصيص
  Widget _buildAllocationForm() {
    final currentCategories = _getCurrentLevelCategories();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // عرض المبلغ المتاح إذا كنا في مستوى فرعي
            if (_currentLevel > 0 && _currentParent != null)
              FutureBuilder<double>(
                future: _getAvailableAmountForDistribution(_currentParent!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ المتاح للتوزيع:'),
                        Text(
                          '${snapshot.data!.toStringAsFixed(0)} د.ع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // نموذج الإدخال
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // اختيار نوع التمويل (فقط في المستوى الرئيسي)
                if (_currentLevel == 0)
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: _selectedFundingType,
                      decoration: const InputDecoration(
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
                          if (value == 'سنوي') _selectedMonth = null;
                          _selectedCategory = null;
                          _loadData();
                        });
                      },
                    ),
                  ),

                // اختيار الشهر (فقط للتمويل الشهري في المستوى الرئيسي)
                if (_currentLevel == 0 && _selectedFundingType == 'شهري')
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_getMonthName(index + 1)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                          _selectedCategory = null;
                          _loadData();
                        });
                      },
                    ),
                  ),

                // اختيار الفئة
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<FundingCategory>(
                    value: currentCategories.contains(_selectedCategory)
                        ? _selectedCategory
                        : null,
                    decoration: InputDecoration(
                      labelText: _getCurrentLevelName(),
                      border: const OutlineInputBorder(),
                    ),
                    items: currentCategories.isEmpty
                        ? [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'لا توجد فئات متاحة',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ]
                        : currentCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                    onChanged: currentCategories.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                  ),
                ),

                // مبلغ التخصيص
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ المخصص',
                      border: OutlineInputBorder(),
                      suffixText: 'د.ع',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // زر التخصيص
                ElevatedButton(
                  onPressed: _allocateFunding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentLevel == 0
                        ? Colors.green
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_currentLevel == 0 ? 'تخصيص' : 'توزيع'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة التخصيص
  Widget _buildAllocationCard(
    InstitutionFunding allocation,
    FundingCategory category,
  ) {
    final hasChildren = _getDirectChildren(category).isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: hasChildren
          ? _buildExpandableAllocationCard(allocation, category)
          : _buildSimpleAllocationCard(allocation, category),
    );
  }

  /// بناء بطاقة تخصيص قابلة للتوسيع (للفئات التي لها أطفال)
  Widget _buildExpandableAllocationCard(
    InstitutionFunding allocation,
    FundingCategory category,
  ) {
    return FutureBuilder<double>(
      future: _getSubCategoriesAllocatedTotal(category),
      builder: (context, subTotalSnapshot) {
        final subTotal = subTotalSnapshot.data ?? 0;
        final remaining = allocation.allocatedAmount - subTotal;

        return ExpansionTile(
          title: Text(category.name),
          subtitle: Text(
            'النوع: ${allocation.fundingType} - السنة: ${allocation.year}',
          ),
          trailing: SizedBox(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${allocation.allocatedAmount.toStringAsFixed(0)} د.ع',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
                if (subTotal > 0)
                  Text(
                    'موزع: ${subTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                Text(
                  'متبقي: ${remaining.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: remaining > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          children: [
            // أزرار التنقل والتحكم
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _navigationPath.add(category);
                        _currentLevel++;
                        _currentParent = category;
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.subdirectory_arrow_right),
                    label: const Text('الدخول للأبواب الفرعية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _deleteAllocation(allocation),
                    icon: const Icon(Icons.delete),
                    label: const Text('حذف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// بناء بطاقة تخصيص بسيطة (للفئات التي ليس لها أطفال)
  Widget _buildSimpleAllocationCard(
    InstitutionFunding allocation,
    FundingCategory category,
  ) {
    return ListTile(
      title: Text(category.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentLevel > 0 && _currentParent != null)
            Text('الباب الأعلى: ${_currentParent!.name}'),
          Text('النوع: ${allocation.fundingType} - السنة: ${allocation.year}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${allocation.allocatedAmount.toStringAsFixed(0)} د.ع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentLevel == 0 ? Colors.green : Colors.orange,
                  fontSize: 11,
                ),
              ),
              if (allocation.spentAmount > 0)
                Text(
                  'مصروف: ${allocation.spentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
              if (allocation.reservedAmount > 0)
                Text(
                  'محجوز: ${allocation.reservedAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteAllocation(allocation),
          ),
        ],
      ),
    );
  }

  /// بناء قائمة المستوى الحالي
  Widget _buildCurrentLevelList() {
    final currentLevelAllocations = _allocations.where((allocation) {
      final category = _categories.firstWhere(
        (c) => c.id == allocation.categoryId,
        orElse: () => FundingCategory(),
      );

      if (_currentLevel == 0) {
        return category.parentId == null;
      } else {
        return category.parentId == _currentParent?.id;
      }
    }).toList();

    if (currentLevelAllocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد تخصيصات في ${_getCurrentLevelName()}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: currentLevelAllocations.length,
      itemBuilder: (context, index) {
        final allocation = currentLevelAllocations[index];
        final category = _categories.firstWhere(
          (c) => c.id == allocation.categoryId,
          orElse: () => FundingCategory()..name = 'غير معروف',
        );

        return _buildAllocationCard(allocation, category);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تخصيص التمويل الهرمي متعدد المستويات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل البيانات...'),
                ],
              ),
            )
          : Column(
              children: [
                // شريط المعلومات ومسار التنقل
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // مسار التنقل (Breadcrumb)
                        if (_navigationPath.isNotEmpty)
                          _buildNavigationBreadcrumb(),

                        if (_navigationPath.isNotEmpty)
                          const SizedBox(height: 8),

                        // معلومات أساسية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المؤسسة: ${_mainInstitution?.departmentName ?? 'غير محدد'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'السنة: $_selectedYear | المستوى: ${_getCurrentLevelName()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // نموذج التخصيص
                _buildAllocationForm(),

                // قائمة التخصيصات الحالية
                Expanded(child: _buildCurrentLevelList()),
              ],
            ),
    );
  }
}
