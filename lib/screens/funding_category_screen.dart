import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// شاشة إدارة الأبواب (رئيسية وفرعية) بشكل هرمي
class FundingCategoryScreen extends StatefulWidget {
  const FundingCategoryScreen({super.key});

  @override
  State<FundingCategoryScreen> createState() => _FundingCategoryScreenState();
}

class _FundingCategoryScreenState extends State<FundingCategoryScreen> {
  List<FundingCategory> _categories = [];
  Map<int, List<FundingCategory>> _categoryTree = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      _categories = await DatabaseService.getAllFundingCategories();
      _buildCategoryTreeData();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأبواب: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buildCategoryTreeData() {
    _categoryTree.clear();

    // إضافة الأبواب الرئيسية
    _categoryTree[0] = _categories.where((c) => c.parentId == null).toList();

    // إضافة الأبواب الفرعية
    for (final category in _categories.where((c) => c.parentId != null)) {
      final parentId = category.parentId!;
      _categoryTree[parentId] ??= [];
      _categoryTree[parentId]!.add(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأبواب'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
            tooltip: 'إضافة باب جديد',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? _buildEmptyState()
          : _buildCategoryTree(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد أبواب',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على + لإضافة باب جديد',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة باب جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTree() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // الأبواب الرئيسية
          ...(_categoryTree[0] ?? []).map(
            (category) => _buildCategoryTile(category, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(FundingCategory category, int level) {
    final hasChildren = _categoryTree[category.id]?.isNotEmpty ?? false;
    final isExpanded = true; // يمكن إضافة state لإدارة التوسع

    return Card(
      margin: EdgeInsets.only(left: level * 20.0, bottom: 8),
      elevation: level == 0 ? 4 : 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              level == 0 ? Icons.folder : Icons.subdirectory_arrow_right,
              color: level == 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: level == 0 ? FontWeight.bold : FontWeight.normal,
                fontSize: level == 0 ? 16 : 14,
              ),
            ),
            subtitle: category.description != null
                ? Text(category.description!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (level == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'رئيسي',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (level > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'فرعي',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCategoryDialog(category);
                        break;
                      case 'add_sub':
                        _showAddCategoryDialog(parentCategory: category);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(category);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('تعديل'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (level == 0)
                      const PopupMenuItem(
                        value: 'add_sub',
                        child: ListTile(
                          leading: Icon(Icons.add),
                          title: Text('إضافة باب فرعي'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('حذف', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // الأبواب الفرعية
          if (hasChildren && isExpanded)
            ...(_categoryTree[category.id] ?? []).map(
              (subCategory) => _buildCategoryTile(subCategory, level + 1),
            ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog({FundingCategory? parentCategory}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          parentCategory == null ? 'إضافة باب جديد' : 'إضافة باب فرعي',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (parentCategory != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الباب الرئيسي:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(parentCategory.name),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الباب *',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showErrorSnackBar('اسم الباب مطلوب');
                return;
              }

              try {
                final category = FundingCategory()
                  ..name = nameController.text.trim()
                  ..description = descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim()
                  ..parentId = parentCategory?.id
                  ..createdAt = DateTime.now()
                  ..updatedAt = DateTime.now();

                await DatabaseService.addFundingCategory(category);
                Navigator.pop(context);
                _showSuccessSnackBar('تم إضافة الباب بنجاح');
                _loadCategories();
              } catch (e) {
                _showErrorSnackBar('خطأ في إضافة الباب: $e');
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(FundingCategory category) {
    final nameController = TextEditingController(text: category.name);
    final descriptionController = TextEditingController(
      text: category.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الباب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الباب *',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                border: OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showErrorSnackBar('اسم الباب مطلوب');
                return;
              }

              try {
                category.name = nameController.text.trim();
                category.description = descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim();
                category.updatedAt = DateTime.now();

                await DatabaseService.updateFundingCategory(category);
                Navigator.pop(context);
                _showSuccessSnackBar('تم تحديث الباب بنجاح');
                _loadCategories();
              } catch (e) {
                _showErrorSnackBar('خطأ في تحديث الباب: $e');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(FundingCategory category) {
    final hasSubCategories = _categoryTree[category.id]?.isNotEmpty ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف الباب "${category.name}"؟'),
            if (hasSubCategories) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تحذير: هذا الباب يحتوي على أبواب فرعية. سيتم حذفها جميعاً.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseService.deleteFundingCategory(category.id);
                Navigator.pop(context);
                _showSuccessSnackBar('تم حذف الباب بنجاح');
                _loadCategories();
              } catch (e) {
                _showErrorSnackBar('خطأ في حذف الباب: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
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
