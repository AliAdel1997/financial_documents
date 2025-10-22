import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/documents_provider.dart';
import '../providers/organization_provider.dart';
import '../screens/add_document_screen.dart';
import '../screens/organization_settings_screen.dart';
import '../screens/organization_list_screen.dart';
import '../screens/reports_by_recipient_screen.dart';

import '../screens/overdue_reservations_screen.dart';
import '../screens/deduction_document_print_screen.dart';
import '../screens/document_draft_management_screen.dart';

// النظام الهرمي الجديد للتمويل
import '../screens/funding_category_screen.dart';
import '../screens/reservation_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/hierarchical_funding_main_screen.dart';
import '../screens/deduction_entities_screen.dart';

import '../models/document.dart';
import '../models/funding_models.dart';
import '../models/active_period.dart';
import '../services/printing_service.dart';
import '../services/notification_service.dart';
import '../services/active_period_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FundingTransaction> _overdueReservations = [];
  bool _showOverdueBanner = false;

  // متغيرات الفترة النشطة
  ActivePeriod? _activePeriod;
  bool _isLoadingPeriod = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivePeriod();
      _loadData();
    });
  }

  Future<void> _loadActivePeriod() async {
    try {
      final activePeriod = await ActivePeriodService.getCurrentActivePeriod();
      setState(() {
        _activePeriod = activePeriod;
        _isLoadingPeriod = false;
      });
    } catch (e) {
      print('خطأ في تحميل الفترة النشطة: $e');
      setState(() {
        _isLoadingPeriod = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final documentsProvider = Provider.of<DocumentsProvider>(
      context,
      listen: false,
    );
    final organizationProvider = Provider.of<OrganizationProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      documentsProvider.loadDocuments(),
      organizationProvider.loadOrganization(),
    ]);

    if (mounted && !organizationProvider.hasOrganizationData) {
      await organizationProvider.createDefaultOrganization();
    }

    _checkOverdueReservations();
  }

  Future<void> _checkOverdueReservations() async {
    try {
      final overdueReservations =
          await NotificationService.getOverdueReservations();
      if (mounted) {
        setState(() {
          _overdueReservations = overdueReservations;
          _showOverdueBanner = overdueReservations.isNotEmpty;
        });

        if (overdueReservations.isNotEmpty) {
          NotificationService.showOverdueReservationsSnackBar(
            context,
            overdueReservations,
            () => _showOverdueReservationsDialog(overdueReservations),
          );
        }
      }
    } catch (e) {
      print('خطأ في فحص الحجوزات المتأخرة: $e');
    }
  }

  void _showOverdueReservationsDialog(
    List<FundingTransaction> overdueReservations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('حجوزات متأخرة'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: overdueReservations.length,
            itemBuilder: (context, index) {
              final reservation = overdueReservations[index];
              return NotificationService.buildOverdueReservationCard(
                reservation,
                'الباب ${reservation.categoryId}',
                'المؤسسة ${reservation.institutionId}',
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OverdueReservationsScreen(),
                ),
              );
            },
            child: Text('إدارة الحجوزات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام طباعة وأرشفة المستندات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Consumer2<DocumentsProvider, OrganizationProvider>(
        builder: (context, documentsProvider, organizationProvider, child) {
          if (documentsProvider.isLoading || organizationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (documentsProvider.error != null) {
            return _buildErrorWidget(documentsProvider.error!);
          }

          return Column(
            children: [
              if (_showOverdueBanner) _buildOverdueBanner(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildOrganizationCard(organizationProvider.organization),
                      const SizedBox(height: 16),
                      _buildActivePeriodCard(),
                      const SizedBox(height: 20),
                      _buildDocumentManagementSection(
                        context,
                        documentsProvider,
                      ),
                      const SizedBox(height: 20),
                      _buildHierarchicalFundingSection(context),
                      const SizedBox(height: 30),
                      // _buildFundingManagementSection(context),
                      // const SizedBox(height: 20),
                      _buildRecentDocuments(documentsProvider.documents),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentDialog(context),
        label: const Text('إضافة مستند'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrganizationCard(organization) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  organization?.departmentName ?? 'غير محدد',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (organization?.directorName != null)
              Text('المدير: ${organization!.directorName}'),
            if (organization?.bankName != null)
              Text('المصرف: ${organization!.bankName}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePeriodCard() {
    if (_isLoadingPeriod) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _activePeriod != null
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: _activePeriod != null
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفترة المالية النشطة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _activePeriod != null
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                      if (_activePeriod != null)
                        Text(
                          _activePeriod!.periodText,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_activePeriod == null)
              Column(
                children: [
                  Text(
                    'لا توجد فترة مالية نشطة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showOpenPeriodDialog,
                    icon: Icon(Icons.add_circle),
                    label: Text('فتح فترة مالية جديدة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الفتح: ${_formatDate(_activePeriod!.openedAt)}',
                        ),
                        Text(
                          'فتحت بواسطة: ${_activePeriod!.openedBy ?? "غير محدد"}',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'close':
                          await _showClosePeriodDialog();
                          break;
                        case 'open_next':
                          await _showOpenNextPeriodDialog();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'close',
                        child: Row(
                          children: [
                            Icon(Icons.lock, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('إغلاق الفترة'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'open_next',
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text('فتح الفترة التالية'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _showOpenPeriodDialog() async {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('فتح فترة مالية جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('اختر الفترة المالية التي تريد فتحها:'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(3, (index) {
                        final year = now.year - 1 + index;
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
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        final month = index + 1;
                        return DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMonth = value!;
                        });
                      },
                    ),
                  ),
                ],
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
                Navigator.of(context).pop();
                final success = await ActivePeriodService.openNewPeriod(
                  selectedYear,
                  selectedMonth,
                  'المستخدم',
                  notes: 'فتح من الصفحة الرئيسية',
                );

                if (success) {
                  await _loadActivePeriod();
                  _showSuccessSnackBar('تم فتح الفترة المالية بنجاح');
                } else {
                  _showErrorSnackBar('فشل في فتح الفترة المالية');
                }
              },
              child: Text('فتح الفترة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClosePeriodDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إغلاق الفترة المالية'),
        content: Text(
          'هل أنت متأكد من إغلاق الفترة المالية: ${_activePeriod!.periodText}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ActivePeriodService.closeCurrentPeriod(
                'المستخدم',
              );

              if (success) {
                await _loadActivePeriod();
                _showSuccessSnackBar('تم إغلاق الفترة المالية بنجاح');
              } else {
                _showErrorSnackBar('فشل في إغلاق الفترة المالية');
              }
            },
            child: Text('إغلاق'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _showOpenNextPeriodDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('فتح الفترة التالية'),
        content: Text(
          'سيتم إغلاق الفترة الحالية وفتح الفترة التالية تلقائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ActivePeriodService.openNextPeriod(
                'المستخدم',
              );

              if (success) {
                await _loadActivePeriod();
                _showSuccessSnackBar('تم فتح الفترة التالية بنجاح');
              } else {
                _showErrorSnackBar('فشل في فتح الفترة التالية');
              }
            },
            child: Text('فتح الفترة التالية'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDocumentManagementSection(
    BuildContext context,
    DocumentsProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.library_books,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'نظام طباعة وأرشفة المستندات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDocumentStats(provider),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPrintSingleDialog(context),
                    icon: const Icon(Icons.print, size: 20),
                    label: const Text('طباعة مستند مفرد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPrintMultipleDialog(context),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text('طباعة متعددة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.importFromExcel,
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: const Text('استيراد من Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportToExcel(provider),
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text('تصدير إلى Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _createExcelTemplate(),
                    icon: const Icon(Icons.description, size: 20),
                    label: const Text('إنشاء قالب Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      side: const BorderSide(color: Colors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DeductionEntitiesScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.business, size: 20),
                    label: const Text('جهات الاستقطاع'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            
            // زر طباعة مستند الاستقطاع  
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeductionDocumentPrintScreen(),
                  ),
                ),
                icon: const Icon(Icons.print, size: 20),
                label: const Text('طباعة مستند الاستقطاع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            
            // زر إدارة مسودات المستندات  
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DocumentDraftManagementScreen(),
                  ),
                ),
                icon: const Icon(Icons.folder_copy, size: 20),
                label: const Text('نظام المطبوعات والمسودات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStats(DocumentsProvider provider) {
    return FutureBuilder<Map<DocumentStatus, int>>(
      future: provider.getDocumentStatistics(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final stats = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'إجمالي المستندات',
                  '${provider.documents.length}',
                  Icons.description,
                  Colors.blue,
                ),
                _buildStatItem(
                  'تم الطباعة',
                  '${stats[DocumentStatus.printed] ?? 0}',
                  Icons.print_outlined,
                  Colors.green,
                ),
                _buildStatItem(
                  'مسودة',
                  '${stats[DocumentStatus.draft] ?? 0}',
                  Icons.schedule,
                  Colors.orange,
                ),
              ],
            ),
          );
        }
        return Container(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHierarchicalFundingSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_tree,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النظام الهرمي للتمويل',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إدارة شاملة للتمويل بنظام هرمي متقدم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'جديد: TreeView • PDF • تحذيرات التقادم • تقارير متقدمة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // زر النظام الكامل
              Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const HierarchicalFundingMainScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.dashboard, size: 24),
                  label: const Text(
                    'الدخول للنظام الهرمي الكامل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const Divider(),
              const SizedBox(height: 16),

              // الوصول السريع للشاشات الفرعية
              Text(
                'الوصول السريع:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      'إدارة الأبواب',
                      Icons.folder_special,
                      Colors.green,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FundingCategoryScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      'الحجوزات',
                      Icons.bookmark,
                      Colors.orange,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReservationScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      'المصروفات',
                      Icons.payment,
                      Colors.purple,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExpenseScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAccessButton(
                      context,
                      'التقارير',
                      Icons.analytics,
                      Colors.indigo,
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReportsScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
    );
  }

  // Widget _buildFundingManagementSection(BuildContext context) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: Colors.green.shade100,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Icon(
  //                   Icons.account_balance,
  //                   color: Colors.green.shade700,
  //                   size: 24,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'إدارة التمويل التقليدية',
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.green.shade800,
  //                     ),
  //                   ),
  //                   Text(
  //                     'النظام التقليدي (قيد الاستبدال)',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.green.shade600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 20),
  //           Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'التقارير الهرمية',
  //                       Icons.analytics,
  //                       Colors.indigo,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => FundingReportScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'التقارير الموسعة',
  //                       Icons.assessment,
  //                       Colors.deepPurple,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => FundingReportsScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'أرشيف العمليات',
  //                       Icons.archive,
  //                       Colors.brown,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => FundingArchiveScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'الحجوزات المتأخرة',
  //                       Icons.warning_amber,
  //                       Colors.deepOrange,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) =>
  //                               const OverdueReservationsScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'إدارة الأبواب',
  //                       Icons.category,
  //                       Colors.teal,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) =>
  //                               FundingCategoryManagementScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'تخصيص التمويل',
  //                       Icons.account_balance_wallet,
  //                       Colors.blue,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => FundingAllocationScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'إدارة الحجز والصرف',
  //                       Icons.swap_horiz,
  //                       Colors.purple,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => ReservationExecutionScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: _buildFundingButton(
  //                       context,
  //                       'الصرف المباشر',
  //                       Icons.payments,
  //                       Colors.orange,
  //                       () => Navigator.of(context).push(
  //                         MaterialPageRoute(
  //                           builder: (context) => FundingSpendingScreen(),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Widget _buildRecentDocuments(List<Document> documents) {
    final recentDocs = documents.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'المستندات الأخيرة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportsByRecipientScreen(),
                    ),
                  ),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentDocs.isEmpty)
              const Center(
                child: Text(
                  'لا توجد مستندات',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentDocs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = recentDocs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(doc.status),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(doc.recipientAddress ?? 'غير محدد'),
                    subtitle: Text('المبلغ: ${doc.amount ?? 0} دينار'),
                    trailing: Icon(
                      _getStatusIcon(doc.status),
                      color: _getStatusColor(doc.status),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.printed:
        return Colors.green;
      case DocumentStatus.uploaded:
        return Colors.blue;
      case DocumentStatus.draft:
        return Colors.orange;
      case DocumentStatus.archived:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.printed:
        return Icons.print;
      case DocumentStatus.uploaded:
        return Icons.cloud_upload;
      case DocumentStatus.draft:
        return Icons.edit;
      case DocumentStatus.archived:
        return Icons.archive;
      default:
        return Icons.description;
    }
  }

  Widget _buildOverdueBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade800, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه: حجوزات متأخرة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  NotificationService.getOverdueMessage(
                    _overdueReservations.length,
                  ),
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () =>
                _showOverdueReservationsDialog(_overdueReservations),
            icon: Icon(Icons.visibility, color: Colors.orange.shade800),
            label: Text('عرض', style: TextStyle(color: Colors.orange.shade800)),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showOverdueBanner = false;
              });
            },
            icon: Icon(Icons.close, color: Colors.orange.shade800),
            tooltip: 'إخفاء',
          ),
        ],
      ),
    );
  }

  // باقي الدوال المساعدة
  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإعدادات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('إعدادات المؤسسة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrganizationSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('قائمة المؤسسات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrganizationListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
    );
  }

  void _showPrintSingleDialog(BuildContext context) {
    final provider = Provider.of<DocumentsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) =>
          _PrintSingleDocumentDialog(documents: provider.documents),
    );
  }

  void _showPrintMultipleDialog(BuildContext context) {
    final provider = Provider.of<DocumentsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) =>
          _PrintMultipleDocumentsDialog(documents: provider.documents),
    );
  }

  Future<void> _createExcelTemplate() async {
    final provider = Provider.of<DocumentsProvider>(context, listen: false);
    final filePath = await provider.createExcelTemplate();
    if (filePath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إنشاء القالب: $filePath')));
    }
  }

  Future<void> _exportToExcel(DocumentsProvider provider) async {
    final filePath = await provider.exportToExcel();
    if (filePath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تصدير الملف: $filePath')));
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

// باقي dialog classes سيتم نسخها كما هي...
class _PrintSingleDocumentDialog extends StatefulWidget {
  final List<Document> documents;

  const _PrintSingleDocumentDialog({required this.documents});

  @override
  State<_PrintSingleDocumentDialog> createState() =>
      _PrintSingleDocumentDialogState();
}

class _PrintSingleDocumentDialogState
    extends State<_PrintSingleDocumentDialog> {
  Document? selectedDocument;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طباعة مستند مفرد'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Document>(
              value: selectedDocument,
              decoration: const InputDecoration(
                labelText: 'اختر المستند',
                border: OutlineInputBorder(),
              ),
              items: widget.documents.map((doc) {
                return DropdownMenuItem(
                  value: doc,
                  child: Text('${doc.recipientAddress} - ${doc.amount} دينار'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDocument = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: selectedDocument != null
              ? () async {
                  await PrintingService.printSingleDocument(
                    selectedDocument!,
                    context,
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('طباعة'),
        ),
      ],
    );
  }
}

class _PrintMultipleDocumentsDialog extends StatefulWidget {
  final List<Document> documents;

  const _PrintMultipleDocumentsDialog({required this.documents});

  @override
  State<_PrintMultipleDocumentsDialog> createState() =>
      _PrintMultipleDocumentsDialogState();
}

class _PrintMultipleDocumentsDialogState
    extends State<_PrintMultipleDocumentsDialog> {
  List<Document> selectedDocuments = [];
  int _mode = 0; // 0 = preview+print, 1 = preview only, 2 = final only
  bool _requireConfirmation = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طباعة متعددة'),
      content: SizedBox(
        width: double.maxFinite,
        height: 480,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: widget.documents.map((doc) {
                  return CheckboxListTile(
                    value: selectedDocuments.contains(doc),
                    title: Text(doc.recipientAddress ?? 'غير محدد'),
                    subtitle: Text('المبلغ: ${doc.amount ?? 0} دينار'),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedDocuments.add(doc);
                        } else {
                          selectedDocuments.remove(doc);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            // Mode selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('وضع الطباعة:'),
                RadioListTile<int>(
                  value: 0,
                  groupValue: _mode,
                  title: const Text('معاينة ثم طباعة (الافتراضي)'),
                  onChanged: (v) => setState(() => _mode = v ?? 0),
                ),
                RadioListTile<int>(
                  value: 1,
                  groupValue: _mode,
                  title: const Text('معاينة فقط (بدون طباعة نهائية)'),
                  onChanged: (v) => setState(() => _mode = v ?? 1),
                ),
                RadioListTile<int>(
                  value: 2,
                  groupValue: _mode,
                  title: const Text('طباعة نهائية بدون معاينة'),
                  onChanged: (v) => setState(() => _mode = v ?? 2),
                ),

                CheckboxListTile(
                  title: const Text('اطلب تأكيد قبل الطباعة/المعاينة'),
                  value: _requireConfirmation,
                  onChanged: (v) => setState(() => _requireConfirmation = v ?? true),
                ),
              ],
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      // Add printing mode controls below the list
      actionsPadding: const EdgeInsets.all(12),
      insetPadding: const EdgeInsets.all(16),
      scrollable: true,
      // We'll show mode selection above the actions via a footer
      // To keep AlertDialog structure simple, show an extra column dialog after the list
      // (We'll display mode selection in the actions area previously modified)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: selectedDocuments.isNotEmpty
                    ? () async {
                        try {
                          if (_mode == 1) {
                            // Preview only
                            await PrintingService.previewMultipleDocuments(
                              selectedDocuments,
                              context,
                              requireConfirmation: _requireConfirmation,
                            );
                          } else if (_mode == 2) {
                            // Final only (no preview)
                            await PrintingService.printMultipleDocuments(
                              selectedDocuments,
                              context: context,
                              showPreview: false,
                              requireConfirmation: _requireConfirmation,
                            );
                          } else {
                            // Default: preview then print
                            await PrintingService.printMultipleDocuments(
                              selectedDocuments,
                              context: context,
                              showPreview: true,
                              requireConfirmation: _requireConfirmation,
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('خطأ في الطباعة: $e')),
                          );
                        }
                        Navigator.pop(context);
                      }
                    : null,
                child: Text('تنفيذ (${selectedDocuments.length})'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
