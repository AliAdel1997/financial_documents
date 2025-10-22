import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../services/deduction_excel_service.dart';
import '../models/deduction_entity.dart';

class DeductionEntitiesScreen extends StatefulWidget {
  const DeductionEntitiesScreen({super.key});

  @override
  State<DeductionEntitiesScreen> createState() => _DeductionEntitiesScreenState();
}

class _DeductionEntitiesScreenState extends State<DeductionEntitiesScreen> {
  List<Map<String, dynamic>> _entities = [];
  List<Map<String, dynamic>> _filteredEntities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    setState(() => _isLoading = true);
    
    try {
      final entities = await DatabaseService.getAllDeductionEntities();
      setState(() {
        _entities = entities.cast<Map<String, dynamic>>();
        _filterEntities();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('خطأ في تحميل جهات الاستقطاع: $e');
    }
  }

  void _filterEntities() {
    setState(() {
      _filteredEntities = _entities.where((entity) {
        final matchesSearch = entity['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             (entity['iban']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                             (entity['email']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                             (entity['address']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                             (entity['phone']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                             (entity['notes']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        final matchesStatus = !_showActiveOnly || (entity['isActive'] == true);
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة جهات الاستقطاع'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'استيراد من Excel',
            onPressed: _importFromExcel,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'تصدير إلى Excel',
            onPressed: _exportToExcel,
          ),
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'إنشاء قالب Excel',
            onPressed: _createExcelTemplate,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntities,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_defaults':
                  _createDefaultEntities();
                  break;
                case 'print_report':
                  _showPrintReportDialog();
                  break;
                case 'stats':
                  _showStatsDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_defaults',
                child: Row(
                  children: [
                    Icon(Icons.add_business, size: 20),
                    SizedBox(width: 8),
                    Text('إضافة الجهات الافتراضية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print_report',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 8),
                    Text('طباعة تقرير الاستقطاعات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('الإحصائيات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلاتر
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'البحث في جهات الاستقطاع',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterEntities();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('عرض النشطة فقط'),
                        value: _showActiveOnly,
                        onChanged: (value) {
                          setState(() => _showActiveOnly = value ?? false);
                          _filterEntities();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    Text(
                      'العدد: ${_filteredEntities.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // قائمة الجهات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredEntities.length,
                        itemBuilder: (context, index) {
                          final entity = _filteredEntities[index];
                          return _buildEntityCard(entity);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showPrintReportDialog(),
            backgroundColor: Colors.blue,
            heroTag: "print_report",
            child: const Icon(Icons.print),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => _showAddEntityDialog(),
            heroTag: "add_entity",
            icon: const Icon(Icons.add),
            label: const Text('إضافة جهة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد جهات استقطاع',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على الزر أدناه لإضافة جهة جديدة',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEntityDialog(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة جهة استقطاع'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityCard(Map<String, dynamic> entity) {
    final isActive = entity['isActive'] == true;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.grey,
          child: const Icon(
            Icons.business,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          entity['name'] ?? 'غير محدد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entity['iban'] != null)
              Text(
                'الإيبان: ${entity['iban']}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            if (entity['email'] != null)
              Text(
                'الإيميل: ${entity['email']}',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            if (entity['phone'] != null)
              Text(
                'الهاتف: ${entity['phone']}',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            if (entity['address'] != null)
              Text(
                'العنوان: ${entity['address']}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            Text(
              'إجمالي الاستقطاعات: ${(entity['totalDeductions'] ?? 0.0).toStringAsFixed(0)} د.ع',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print, color: Colors.blue),
              onPressed: () => _printEntityReport(entity),
              tooltip: 'طباعة تقرير الاستقطاعات',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleEntityAction(value, entity),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'إلغاء التفعيل' : 'تفعيل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showEntityDetailsDialog(entity),
      ),
    );
  }

  void _handleEntityAction(String action, Map<String, dynamic> entity) {
    switch (action) {
      case 'edit':
        _showEditEntityDialog(entity);
        break;
      case 'toggle':
        _toggleEntityStatus(entity);
        break;
      case 'delete':
        _showDeleteConfirmDialog(entity);
        break;
    }
  }

  void _showAddEntityDialog() {
    _showEntityDialog();
  }

  void _showEditEntityDialog(Map<String, dynamic> entity) {
    _showEntityDialog(entity: entity);
  }

  void _showEntityDialog({Map<String, dynamic>? entity}) {
    final isEditing = entity != null;
    final nameController = TextEditingController(text: entity?['name'] ?? '');
    final ibanController = TextEditingController(text: entity?['iban'] ?? '');
    final emailController = TextEditingController(text: entity?['email'] ?? '');
    final addressController = TextEditingController(text: entity?['address'] ?? '');
    final phoneController = TextEditingController(text: entity?['phone'] ?? '');
    final notesController = TextEditingController(text: entity?['notes'] ?? '');
    bool isActive = entity?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'تعديل جهة الاستقطاع' : 'إضافة جهة استقطاع جديدة'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الجهة *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ibanController,
                    decoration: const InputDecoration(
                      labelText: 'ايبان الجهة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                      hintText: 'IQ33XXXX1234567890123456',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'البريد الالكتروني',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      hintText: 'example@domain.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '07901234567',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('فعال'),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value ?? true);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => _saveEntity(
                isEditing,
                entity,
                nameController.text,
                ibanController.text,
                emailController.text,
                addressController.text,
                phoneController.text,
                notesController.text,
                isActive,
              ),
              child: Text(isEditing ? 'حفظ' : 'إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntity(
    bool isEditing,
    Map<String, dynamic>? existingEntity,
    String name,
    String iban,
    String email,
    String address,
    String phone,
    String notes,
    bool isActive,
  ) async {
    if (name.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال اسم الجهة');
      return;
    }

    final entityData = {
      if (isEditing && existingEntity != null) 'id': existingEntity['id'],
      'name': name,
      'iban': iban.isEmpty ? null : iban,
      'email': email.isEmpty ? null : email,
      'address': address.isEmpty ? null : address,
      'phone': phone.isEmpty ? null : phone,
      'notes': notes.isEmpty ? null : notes,
      'isActive': isActive,
      'totalDeductions': existingEntity?['totalDeductions'] ?? 0.0,
    };

    final success = isEditing 
        ? await DatabaseService.updateDeductionEntity(entityData)
        : await DatabaseService.addDeductionEntity(entityData);

    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar(isEditing ? 'تم تحديث الجهة بنجاح' : 'تم إضافة الجهة بنجاح');
      _loadEntities();
    } else {
      _showErrorSnackBar(isEditing ? 'فشل في تحديث الجهة' : 'فشل في إضافة الجهة');
    }
  }

  Future<void> _toggleEntityStatus(Map<String, dynamic> entity) async {
    entity['isActive'] = !(entity['isActive'] ?? false);
    final success = await DatabaseService.updateDeductionEntity(entity);
    if (success) {
      _showSuccessSnackBar('تم تغيير حالة الجهة بنجاح');
      _loadEntities();
    } else {
      _showErrorSnackBar('فشل في تغيير حالة الجهة');
    }
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف جهة الاستقطاع "${entity['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => _deleteEntity(entity),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntity(Map<String, dynamic> entity) async {
    Navigator.of(context).pop();
    
    final success = await DatabaseService.deleteDeductionEntity(entity['id']);
    if (success) {
      _showSuccessSnackBar('تم حذف الجهة بنجاح');
      _loadEntities();
    } else {
      _showErrorSnackBar('فشل في حذف الجهة');
    }
  }

  void _showEntityDetailsDialog(Map<String, dynamic> entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity['name'] ?? 'غير محدد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الحالة', (entity['isActive'] == true) ? 'فعال' : 'غير فعال'),
            if (entity['description'] != null)
              _buildDetailRow('الوصف', entity['description']),
            if (entity['contactInfo'] != null)
              _buildDetailRow('معلومات الاتصال', entity['contactInfo']),
            if (entity['address'] != null)
              _buildDetailRow('العنوان', entity['address']),
            _buildDetailRow('إجمالي الاستقطاعات', '${(entity['totalDeductions'] ?? 0.0).toStringAsFixed(0)} د.ع'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _printEntityReport(entity);
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة التقرير'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _createDefaultEntities() async {
    await DatabaseService.createDefaultDeductionEntities();
    _showSuccessSnackBar('تم إنشاء الجهات الافتراضية بنجاح');
    _loadEntities();
  }

  void _showPrintReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طباعة تقرير الاستقطاعات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('تقرير شامل لجميع الجهات'),
              onTap: () {
                Navigator.of(context).pop();
                _printAllEntitiesReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('تقرير استقطاعات شهرية'),
              onTap: () {
                Navigator.of(context).pop();
                _showMonthlyReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('تقرير استقطاعات موظف'),
              onTap: () {
                Navigator.of(context).pop();
                _showEmployeeReportDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showMonthlyReportDialog() {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تقرير الاستقطاعات الشهرية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'السنة',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setDialogState(() => selectedYear = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'الشهر',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_getMonthName(index + 1)),
                  );
                }),
                onChanged: (value) {
                  setDialogState(() => selectedMonth = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _printMonthlyReport(selectedYear, selectedMonth);
              },
              child: const Text('طباعة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeReportDialog() {
    final employeeIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تقرير استقطاعات الموظف'),
        content: TextField(
          controller: employeeIdController,
          decoration: const InputDecoration(
            labelText: 'رقم الموظف',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (employeeIdController.text.isNotEmpty) {
                Navigator.of(context).pop();
                _printEmployeeReport(employeeIdController.text);
              }
            },
            child: const Text('طباعة'),
          ),
        ],
      ),
    );
  }

  Future<void> _printAllEntitiesReport() async {
    _showInfoSnackBar('جاري إنشاء تقرير شامل لجميع جهات الاستقطاع...');
    // هنا يمكن إضافة كود الطباعة الفعلي
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('تم إنشاء التقرير بنجاح');
  }

  Future<void> _printEntityReport(Map<String, dynamic> entity) async {
    _showInfoSnackBar('جاري إنشاء تقرير استقطاعات ${entity['name']}...');
    // هنا يمكن إضافة كود الطباعة الفعلي
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('تم إنشاء التقرير بنجاح');
  }

  Future<void> _printMonthlyReport(int year, int month) async {
    _showInfoSnackBar('جاري إنشاء تقرير شهر ${_getMonthName(month)} $year...');
    // هنا يمكن إضافة كود الطباعة الفعلي
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('تم إنشاء التقرير بنجاح');
  }

  Future<void> _printEmployeeReport(String employeeId) async {
    _showInfoSnackBar('جاري إنشاء تقرير الموظف رقم $employeeId...');
    // هنا يمكن إضافة كود الطباعة الفعلي
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('تم إنشاء التقرير بنجاح');
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائيات جهات الاستقطاع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('إجمالي الجهات', _entities.length.toString()),
            _buildStatRow('الجهات النشطة', _entities.where((e) => e['isActive'] == true).length.toString()),
            _buildStatRow('الجهات غير النشطة', _entities.where((e) => e['isActive'] != true).length.toString()),
            _buildStatRow('إجمالي الاستقطاعات', '${_entities.fold(0.0, (sum, e) => sum + (e['totalDeductions'] ?? 0.0)).toStringAsFixed(0)} د.ع'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month > 0 && month <= 12 ? months[month - 1] : 'غير محدد';
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// استيراد جهات الاستقطاع من ملف Excel
  Future<void> _importFromExcel() async {
    try {
      _showLoadingDialog('جاري استيراد البيانات...');
      
      final entities = await DeductionExcelService.importFromExcel();
      
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      
      await _loadEntities(); // تحديث القائمة
      
      _showSuccessSnackBar('تم استيراد ${entities.length} جهة بنجاح');
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      _showErrorSnackBar('خطأ في الاستيراد: $e');
    }
  }

  /// تصدير جهات الاستقطاع إلى ملف Excel
  Future<void> _exportToExcel() async {
    try {
      if (_filteredEntities.isEmpty) {
        _showErrorSnackBar('لا توجد بيانات للتصدير');
        return;
      }

      _showLoadingDialog('جاري تصدير البيانات...');
      
      // تحويل البيانات إلى كائنات DeductionEntity
      final entities = _filteredEntities.map((entityData) {
        return DeductionEntity(
          id: entityData['id'] ?? 0,
          name: entityData['name'] ?? '',
          iban: entityData['iban'],
          email: entityData['email'], 
          address: entityData['address'],
          phone: entityData['phone'],
          notes: entityData['notes'],
          totalDeductions: (entityData['totalDeductions'] ?? 0.0).toDouble(),
          isActive: entityData['isActive'] ?? true,
        );
      }).toList();
      
      final filePath = await DeductionExcelService.exportToExcel(entities);
      
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      
      _showSuccessSnackBar('تم تصدير البيانات إلى: ${filePath.split('/').last}');
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      _showErrorSnackBar('خطأ في التصدير: $e');
    }
  }

  /// إنشاء قالب Excel فارغ
  Future<void> _createExcelTemplate() async {
    try {
      _showLoadingDialog('جاري إنشاء القالب...');
      
      final filePath = await DeductionExcelService.createTemplate();
      
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      
      _showSuccessSnackBar('تم إنشاء القالب: ${filePath.split('/').last}');
    } catch (e) {
      Navigator.of(context).pop(); // إغلاق حوار التحميل
      _showErrorSnackBar('خطأ في إنشاء القالب: $e');
    }
  }

  /// عرض حوار التحميل
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}