import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class FundingCategoryManagementScreen extends StatefulWidget {
  @override
  _FundingCategoryManagementScreenState createState() => _FundingCategoryManagementScreenState();
}

class _FundingCategoryManagementScreenState extends State<FundingCategoryManagementScreen> {
  List<FundingCategory> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await DatabaseService.isar.fundingCategorys.where().findAll();
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print('خطأ في تحميل الأبواب: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الأبواب')),
      );
    }
  }

  Future<void> _showAddCategoryDialog() async {
    await _showCategoryDialog();
  }

  Future<void> _showEditCategoryDialog(FundingCategory category) async {
    await _showCategoryDialog(category: category);
  }

  Future<void> _showCategoryDialog({FundingCategory? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    FundingCategory? selectedParent;
    String selectedFundingType = category?.fundingType ?? 'سنوي';
    int selectedYear = category?.year ?? DateTime.now().year;
    int? selectedMonth = category?.month;

    // للتعديل، البحث عن الباب الأب
    if (isEditing && category.parentId != null) {
      selectedParent = categories.firstWhere(
        (c) => c.id == category.parentId,
        orElse: () => FundingCategory()..name = 'غير موجود',
      );
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'تعديل الباب' : 'إضافة باب جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الباب',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<FundingCategory?>(
                  value: selectedParent,
                  decoration: InputDecoration(
                    labelText: 'الباب الأب (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<FundingCategory?>(
                      value: null,
                      child: Text('لا يوجد (باب رئيسي)'),
                    ),
                    ...categories
                        .where((c) => isEditing ? c.id != category.id : true)
                        .map((c) => DropdownMenuItem<FundingCategory?>(
                              value: c,
                              child: Text(c.name),
                            )),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedParent = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFundingType,
                  decoration: InputDecoration(
                    labelText: 'نوع التمويل',
                    border: OutlineInputBorder(),
                  ),
                  items: ['سنوي', 'شهري'].map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFundingType = value!;
                      if (value == 'سنوي') selectedMonth = null;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedYear,
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
                    setDialogState(() {
                      selectedYear = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                if (selectedFundingType == 'شهري')
                  DropdownButtonFormField<int>(
                    value: selectedMonth,
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
                      setDialogState(() {
                        selectedMonth = value;
                      });
                    },
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
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال اسم الباب')),
                  );
                  return;
                }

                try {
                  if (isEditing) {
                    // تعديل الباب
                    final updatedCategory = category.copyWith(
                      name: nameController.text.trim(),
                      parentId: selectedParent?.id,
                      fundingType: selectedFundingType,
                      year: selectedYear,
                      month: selectedMonth,
                      updatedAt: DateTime.now(),
                    );

                    await DatabaseService.isar.writeTxn(() async {
                      await DatabaseService.isar.fundingCategorys.put(updatedCategory);
                    });
                  } else {
                    // إضافة باب جديد
                    final newCategory = FundingCategory()
                      ..name = nameController.text.trim()
                      ..parentId = selectedParent?.id
                      ..fundingType = selectedFundingType
                      ..year = selectedYear
                      ..month = selectedMonth
                      ..allocatedAmount = 0
                      ..createdAt = DateTime.now()
                      ..updatedAt = DateTime.now();

                    await DatabaseService.isar.writeTxn(() async {
                      await DatabaseService.isar.fundingCategorys.put(newCategory);
                    });
                  }

                  Navigator.of(context).pop();
                  await _loadCategories();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'تم تعديل الباب بنجاح' : 'تم إضافة الباب بنجاح')),
                  );
                } catch (e) {
                  print('خطأ في ${isEditing ? 'تعديل' : 'إضافة'} الباب: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في ${isEditing ? 'تعديل' : 'إضافة'} الباب')),
                  );
                }
              },
              child: Text(isEditing ? 'تعديل' : 'إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(FundingCategory category) async {
    // التحقق من وجود تمويل مرتبط بهذا الباب
    try {
      final linkedFunding = await DatabaseService.isar.institutionFundings
          .filter()
          .categoryIdEqualTo(category.id)
          .findFirst();

      if (linkedFunding != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تحذير'),
            content: Text('لا يمكن حذف هذا الباب لأنه مرتبط بتمويل موجود.\nيجب حذف جميع التمويلات المرتبطة أولاً.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('موافق'),
              ),
            ],
          ),
        );
        return;
      }

      // التحقق من وجود أبواب فرعية
      final subCategories = await DatabaseService.isar.fundingCategorys
          .filter()
          .parentIdEqualTo(category.id)
          .findAll();

      if (subCategories.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تحذير'),
            content: Text('لا يمكن حذف هذا الباب لأنه يحتوي على أبواب فرعية.\nيجب حذف الأبواب الفرعية أولاً.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('موافق'),
              ),
            ],
          ),
        );
        return;
      }

      // إظهار تأكيد الحذف
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف الباب "${category.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('حذف'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.fundingCategorys.delete(category.id);
        });

        await _loadCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الباب بنجاح')),
        );
      }
    } catch (e) {
      print('خطأ في حذف الباب: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف الباب')),
      );
    }
  }

  String _getParentName(int? parentId) {
    if (parentId == null) return 'باب رئيسي';
    final parent = categories.firstWhere(
      (c) => c.id == parentId,
      orElse: () => FundingCategory()..name = 'غير معروف',
    );
    return parent.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الأبواب'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد أبواب محددة', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: Icon(Icons.add),
                    label: Text('إضافة أول باب'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_getParentName(category.parentId)}'),
                        Text('${category.fundingPeriodText}'),
                        Text('المخصص: ${category.allocatedAmount.toStringAsFixed(0)} د.ع'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'إضافة باب جديد',
      ),
    );
  }
}