import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../services/database_service.dart';

class OrganizationFormScreen extends StatefulWidget {
  final Organization? organization; // null للإضافة، غير null للتعديل

  const OrganizationFormScreen({super.key, this.organization});

  @override
  State<OrganizationFormScreen> createState() => _OrganizationFormScreenState();
}

class _OrganizationFormScreenState extends State<OrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers for form fields
  late final TextEditingController _departmentNameController;
  late final TextEditingController _bankAccountController;
  late final TextEditingController _ibanController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _directorNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _assignedWorkController;
  late final TextEditingController _positionTypeController;

  bool _isLoading = false;
  bool get _isEditing => widget.organization != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final org = widget.organization;

    _departmentNameController = TextEditingController(
      text: org?.departmentName ?? '',
    );
    _bankAccountController = TextEditingController(
      text: org?.bankAccount ?? '',
    );
    _ibanController = TextEditingController(text: org?.iban ?? '');
    _accountNumberController = TextEditingController(
      text: org?.accountNumber ?? '',
    );
    _bankNameController = TextEditingController(text: org?.bankName ?? '');
    _directorNameController = TextEditingController(
      text: org?.directorName ?? '',
    );
    _jobTitleController = TextEditingController(text: org?.jobTitle ?? '');
    _assignedWorkController = TextEditingController(
      text: org?.assignedWork ?? '',
    );
    _positionTypeController = TextEditingController(
      text: org?.positionType ?? '',
    );
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    _bankAccountController.dispose();
    _ibanController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _directorNameController.dispose();
    _jobTitleController.dispose();
    _assignedWorkController.dispose();
    _positionTypeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل بيانات المؤسسة' : 'إضافة مؤسسة جديدة'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
              tooltip: 'حذف المؤسسة',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // معلومات المؤسسة الأساسية
                _buildSectionCard(
                  title: 'المعلومات الأساسية',
                  icon: Icons.business,
                  children: [
                    _buildTextField(
                      controller: _departmentNameController,
                      label: 'اسم الدائرة',
                      hint: 'مثال: مدينة مرجان الطبية',
                      icon: Icons.business_center,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _directorNameController,
                      label: 'اسم مدير المؤسسة',
                      hint: 'الاسم الثلاثي للمدير',
                      icon: Icons.person,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _jobTitleController,
                      label: 'العنوان الوظيفي',
                      hint: 'مثال: مدير عام',
                      icon: Icons.work,
                      isRequired: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // المعلومات المصرفية
                _buildSectionCard(
                  title: 'المعلومات المصرفية',
                  icon: Icons.account_balance,
                  children: [
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'اسم المصرف',
                      hint: 'مثال: مصرف الرافدين',
                      icon: Icons.account_balance,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bankAccountController,
                      label: 'الحساب المصرفي',
                      hint: 'رقم الحساب المصرفي',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'رقم الحساب',
                      hint: 'رقم الحساب الإضافي',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ibanController,
                      label: 'رقم الآيبان (IBAN)',
                      hint: 'IQ00 XXXX XXXX XXXX XXXX XX',
                      icon: Icons.account_box,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      isRequired: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // معلومات إضافية
                _buildSectionCard(
                  title: 'معلومات إضافية',
                  icon: Icons.info,
                  children: [
                    _buildTextField(
                      controller: _assignedWorkController,
                      label: 'العمل المكلف به',
                      hint: 'وصف العمل أو المهام المكلف بها',
                      icon: Icons.assignment,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      controller: _positionTypeController,
                      label: 'نوع المنصب',
                      hint: 'اختر نوع المنصب',
                      icon: Icons.business_center,
                      items: const [
                        'مدير عام',
                        'مخول بصلاحيات المدير العام',
                        'معاون المدير العام',
                        'مدير قسم الامورالمالية والادارية',
                        'مدير الحسابات',
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // أزرار الحفظ والإلغاء
                _buildActionButtons(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, textDirection: TextDirection.rtl),
            ),
          )
          .toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إلغاء'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveOrganization,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'حفظ التغييرات' : 'إضافة المؤسسة'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveOrganization() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final organization = Organization(
        departmentName: _departmentNameController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        iban: _ibanController.text.trim().toUpperCase(),
        accountNumber: _accountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        directorName: _directorNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        assignedWork: _assignedWorkController.text.trim(),
        positionType: _positionTypeController.text.trim(),
        createdAt: widget.organization?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        organization.id = widget.organization!.id;
      }

      await DatabaseService.saveOrganization(organization);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'تم حفظ التغييرات بنجاح' : 'تم إضافة المؤسسة بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذه المؤسسة؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteOrganization();
    }
  }

  Future<void> _deleteOrganization() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.deleteOrganization(widget.organization!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المؤسسة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المؤسسة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
