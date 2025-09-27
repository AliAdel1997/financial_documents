import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import 'organization_form_screen.dart';

class OrganizationListScreen extends StatefulWidget {
  const OrganizationListScreen({super.key});

  @override
  State<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends State<OrganizationListScreen> {
  List<Organization> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final organizations = await DatabaseService.getAllOrganizations();
      setState(() {
        _organizations = organizations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المؤسسات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrganizations,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewOrganization,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مؤسسة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _organizations.isEmpty
              ? _buildEmptyState()
              : _buildOrganizationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مؤسسات مسجلة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على الزر أدناه لإضافة مؤسسة جديدة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewOrganization,
            icon: const Icon(Icons.add),
            label: const Text('إضافة مؤسسة جديدة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationsList() {
    return RefreshIndicator(
      onRefresh: _loadOrganizations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _organizations.length,
        itemBuilder: (context, index) {
          final organization = _organizations[index];
          return _buildOrganizationCard(organization);
        },
      ),
    );
  }

  Widget _buildOrganizationCard(Organization organization) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editOrganization(organization),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          organization.departmentName ?? 'غير محدد',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        if (organization.directorName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'المدير: ${organization.directorName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, organization),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
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
              
              const SizedBox(height: 16),
              
              // معلومات المؤسسة
              _buildInfoRow(
                icon: Icons.work,
                label: 'المنصب',
                value: organization.jobTitle ?? 'غير محدد',
              ),
              
              if (organization.bankName != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.account_balance,
                  label: 'المصرف',
                  value: organization.bankName!,
                ),
              ],
              
              if (organization.iban != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.account_box,
                  label: 'الآيبان',
                  value: organization.iban!,
                  isMonospace: true,
                ),
              ],
              
              if (organization.positionType != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.business_center,
                  label: 'نوع المنصب',
                  value: organization.positionType!,
                ),
              ],
              
              // تاريخ الإنشاء والتحديث
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (organization.createdAt != null)
                    Text(
                      'أنشئت: ${_formatDate(organization.createdAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  if (organization.updatedAt != null)
                    Text(
                      'آخر تحديث: ${_formatDate(organization.updatedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: isMonospace ? 'monospace' : null,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addNewOrganization() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const OrganizationFormScreen(),
      ),
    );

    if (result == true) {
      _loadOrganizations();
    }
  }

  Future<void> _editOrganization(Organization organization) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => OrganizationFormScreen(organization: organization),
      ),
    );

    if (result == true) {
      _loadOrganizations();
    }
  }

  void _handleMenuAction(String action, Organization organization) {
    switch (action) {
      case 'edit':
        _editOrganization(organization);
        break;
      case 'delete':
        _showDeleteConfirmation(organization);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(Organization organization) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من حذف هذه المؤسسة؟'),
            const SizedBox(height: 8),
            Text(
              'المؤسسة: ${organization.departmentName ?? 'غير محدد'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(color: Colors.red),
            ),
          ],
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

    if (confirmed == true) {
      await _deleteOrganization(organization);
    }
  }

  Future<void> _deleteOrganization(Organization organization) async {
    try {
      await DatabaseService.deleteOrganization(organization.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المؤسسة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrganizations();
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
    }
  }
}