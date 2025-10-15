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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      categories = await DatabaseService.getAllFundingCategories();
    } catch (e) {
      print('خطأ في تحميل الفئات: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الأبواب المالية'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إدارة الأبواب المالية',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(),
                        icon: Icon(Icons.add),
                        label: Text('إضافة باب جديد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('لا توجد أبواب مالية', style: TextStyle(fontSize: 18, color: Colors.grey)),
                              SizedBox(height: 8),
                              Text('اضغط على "إضافة باب جديد" لإنشاء أول باب مالي'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _buildCategoryCard(category);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(FundingCategory category) {
    final isRootCategory = category.parentId == null;
    final children = categories.where((c) => c.parentId == category.id).toList();
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          isRootCategory ? Icons.folder : Icons.subdirectory_arrow_right,
          color: isRootCategory ? Colors.blue : Colors.green,
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isRootCategory ? 16 : 14,
          ),
        ),
        subtitle: category.description != null 
            ? Text(category.description!, style: TextStyle(color: Colors.grey[600]))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (children.isNotEmpty)
              Chip(
                label: Text('${children.length}'),
                backgroundColor: Colors.blue[100],
                labelStyle: TextStyle(fontSize: 12),
              ),
            SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showCategoryDialog(category: category);
                    break;
                  case 'delete':
                    _deleteCategory(category);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('تعديل')])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('حذف')])),
              ],
            ),
          ],
        ),
        children: children.map((child) => _buildSubCategoryTile(child)).toList(),
      ),
    );
  }

  Widget _buildSubCategoryTile(FundingCategory category) {
    return ListTile(
      leading: Icon(Icons.label, color: Colors.orange, size: 20),
      title: Text(category.name),
      subtitle: category.description != null 
          ? Text(category.description!, style: TextStyle(color: Colors.grey[600]))
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showCategoryDialog(category: category);
              break;
            case 'delete':
              _deleteCategory(category);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('تعديل')])),
          PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete), SizedBox(width: 8), Text('حذف')])),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog({FundingCategory? category}) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    FundingCategory? selectedParent;

    // للتعديل، البحث عن الباب الأب
    if (isEditing && category.parentId != null) {
      selectedParent = categories.firstWhere(
        (c) => c.id == category.parentId,
        orElse: () => FundingCategory(),
      );
      if (selectedParent.id == 0) selectedParent = null;
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
                    labelText: 'اسم الباب *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف الباب (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                    // تعديل الباب الموجود
                    final updatedCategory = category.copyWith(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isEmpty 
                          ? null 
                          : descriptionController.text.trim(),
                      parentId: selectedParent?.id,
                      updatedAt: DateTime.now(),
                    );

                    await DatabaseService.isar.writeTxn(() async {
                      await DatabaseService.isar.fundingCategorys.put(updatedCategory);
                    });
                  } else {
                    // إضافة باب جديد
                    final newCategory = FundingCategory()
                      ..name = nameController.text.trim()
                      ..description = descriptionController.text.trim().isEmpty 
                          ? null 
                          : descriptionController.text.trim()
                      ..parentId = selectedParent?.id
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
      final linkedFundings = await DatabaseService.isar.institutionFundings
          .filter()
          .categoryIdEqualTo(category.id)
          .findAll();

      if (linkedFundings.isNotEmpty) {
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
      final children = categories.where((c) => c.parentId == category.id).toList();
      if (children.isNotEmpty) {
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

      // تأكيد الحذف
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('حذف', style: TextStyle(color: Colors.white)),
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
}