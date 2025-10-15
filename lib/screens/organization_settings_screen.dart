import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../providers/organization_provider.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers للنصوص
  final _departmentNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ibanController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _assignedWorkController = TextEditingController();

  // متغيرات الاختيار
  String _selectedPositionType = 'مدير عام';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تأجيل تحميل البيانات حتى بعد انتهاء مرحلة البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationData();
    });
  }

  @override
  void dispose() {
    // تنظيف الـ Controllers
    _departmentNameController.dispose();
    _bankAccountController.dispose();
    _ibanController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _directorNameController.dispose();
    _jobTitleController.dispose();
    _assignedWorkController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizationData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      await provider.loadOrganization();

      final org = provider.organization;
      if (org != null) {
        _departmentNameController.text = org.departmentName ?? '';
        _bankAccountController.text = org.bankAccount ?? '';
        _ibanController.text = org.iban ?? '';
        _accountNumberController.text = org.accountNumber ?? '';
        _bankNameController.text = org.bankName ?? '';
        _directorNameController.text = org.directorName ?? '';
        _jobTitleController.text = org.jobTitle ?? '';
        _assignedWorkController.text = org.assignedWork ?? '';
        _selectedPositionType = org.positionType ?? 'مدير عام';
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل بيانات المؤسسة: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrganizationData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );

      final organization = Organization(
        departmentName: _departmentNameController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        iban: _ibanController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        directorName: _directorNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        assignedWork: _assignedWorkController.text.trim(),
        positionType: _selectedPositionType,
        updatedAt: DateTime.now(),
      );

      // إذا كانت هناك منظمة موجودة، احتفظ بالـ ID والـ createdAt
      final existingOrg = provider.organization;
      if (existingOrg != null) {
        organization.id = existingOrg.id;
        organization.createdAt = existingOrg.createdAt;
      } else {
        organization.createdAt = DateTime.now();
      }

      await provider.saveOrganization(organization);

      _showSuccessSnackBar('تم حفظ بيانات المؤسسة بنجاح');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ بيانات المؤسسة: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات المؤسسة'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveOrganizationData,
                tooltip: 'حفظ',
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildSectionCard(
                        title: 'معلومات الدائرة',
                        icon: Icons.business,
                        children: [
                          _buildTextFormField(
                            controller: _departmentNameController,
                            label: 'اسم الدائرة',
                            hint: 'مثال: دائرة المالية',
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'اسم الدائرة مطلوب'
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'معلومات البنك',
                        icon: Icons.account_balance,
                        children: [
                          _buildTextFormField(
                            controller: _bankNameController,
                            label: 'اسم البنك',
                            hint: 'مثال: بنك الرافدين',
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'اسم البنك مطلوب'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _bankAccountController,
                            label: 'رقم الحساب المصرفي',
                            hint: 'أدخل رقم الحساب المصرفي',
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'رقم الحساب مطلوب'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _accountNumberController,
                            label: 'رقم الحساب',
                            hint: 'رقم الحساب المختصر',
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _ibanController,
                            label: 'رقم الآيبان (IBAN)',
                            hint: 'IQ##XXXX################',
                            validator: _validateIban,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'معلومات المدير',
                        icon: Icons.person,
                        children: [
                          _buildTextFormField(
                            controller: _directorNameController,
                            label: 'اسم المدير',
                            hint: 'الاسم الثلاثي للمدير',
                            validator: (value) => value?.trim().isEmpty == true
                                ? 'اسم المدير مطلوب'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _jobTitleController,
                            label: 'العنوان الوظيفي',
                            hint: 'مثال: مدير عام',
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _assignedWorkController,
                            label: 'العمل المكلف به',
                            hint: 'وصف المهام والصلاحيات',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildPositionTypeDropdown(),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPositionTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPositionType,
      decoration: const InputDecoration(
        labelText: 'نوع المنصب',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: ['مدير عام', 'مخول بالصلاحيات'].map((type) {
        return DropdownMenuItem<String>(value: type, child: Text(type));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedPositionType = newValue;
          });
        }
      },
    );
  }

  String? _validateIban(String? value) {
    if (value?.trim().isEmpty == true) {
      return 'رقم الآيبان مطلوب';
    }

    final iban = value!.trim().toUpperCase();

    // التحقق من الطول (العراق 23 رقم)
    if (iban.length != 23) {
      return 'رقم الآيبان يجب أن يكون 23 رقم';
    }

    // التحقق من بداية رقم الآيبان العراقي
    if (!iban.startsWith('IQ')) {
      return 'رقم الآيبان يجب أن يبدأ بـ IQ';
    }

    return null;
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveOrganizationData,
            icon: const Icon(Icons.save),
            label: const Text('حفظ البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
