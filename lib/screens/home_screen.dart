import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/documents_provider.dart';
import '../providers/organization_provider.dart';
import '../screens/add_document_screen.dart';
import '../screens/organization_settings_screen.dart';
import '../screens/reports_by_recipient_screen.dart';
import '../models/document.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تأخير تحميل البيانات حتى ما بعد اكتمال البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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

    // إنشاء مؤسسة افتراضية إذا لم تكن موجودة
    if (mounted && !organizationProvider.hasOrganizationData) {
      await organizationProvider.createDefaultOrganization();
    }
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة معلومات المؤسسة
                _buildOrganizationCard(organizationProvider.organization),

                const SizedBox(height: 20),

                // إحصائيات سريعة
                _buildStatsCards(),

                const SizedBox(height: 20),

                // الأزرار الرئيسية
                _buildMainButtons(context, documentsProvider),

                const SizedBox(height: 20),

                // قائمة المستندات الأخيرة
                _buildRecentDocuments(documentsProvider.documents),
              ],
            ),
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

  Widget _buildStatsCards() {
    return Consumer<DocumentsProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<DocumentStatus, int>>(
          future: provider.getDocumentStatistics(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stats = snapshot.data!;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'المجموع',
                      stats.values.fold(0, (a, b) => a + b).toString(),
                      Colors.blue,
                      Icons.description,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'مطبوع',
                      (stats[DocumentStatus.printed] ?? 0).toString(),
                      Colors.green,
                      Icons.print,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'مرفوع',
                      (stats[DocumentStatus.uploaded] ?? 0).toString(),
                      Colors.orange,
                      Icons.cloud_upload,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(height: 80);
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, DocumentsProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPrintSingleDialog(context),
                icon: const Icon(Icons.print),
                label: const Text('طباعة مستند مفرد'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPrintMultipleDialog(context),
                icon: const Icon(Icons.print_outlined),
                label: const Text('طباعة متعددة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.importFromExcel,
                icon: const Icon(Icons.upload_file),
                label: const Text('استيراد من Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportToExcel(provider),
                icon: const Icon(Icons.download),
                label: const Text('تصدير إلى Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentDocuments(List<Document> documents) {
    final recentDocs = documents.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المستندات الأخيرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (recentDocs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد مستندات'),
                ),
              )
            else
              ...recentDocs.map((doc) => _buildDocumentTile(doc)),
            if (documents.length > 5)
              TextButton(
                onPressed: () => _showAllDocuments(context),
                child: const Text('عرض جميع المستندات'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(Document document) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(document.status),
        child: Text(
          document.outgoingNumber?.toString() ?? '؟',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      title: Text(
        document.documentDetails ?? 'بدون عنوان',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        document.documentDate != null
            ? '${document.documentDate!.day}/${document.documentDate!.month}/${document.documentDate!.year}'
            : 'بدون تاريخ',
      ),
      trailing: Chip(
        label: Text(
          _getStatusText(document.status),
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: _getStatusColor(document.status).withOpacity(0.2),
      ),
      onTap: () => _showDocumentDetails(context, document),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Colors.grey;
      case DocumentStatus.printed:
        return Colors.green;
      case DocumentStatus.uploaded:
        return Colors.orange;
      case DocumentStatus.notUploaded:
        return Colors.red;
      case DocumentStatus.archived:
        return Colors.purple;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return 'مسودة';
      case DocumentStatus.printed:
        return 'مطبوع';
      case DocumentStatus.uploaded:
        return 'مرفوع';
      case DocumentStatus.notUploaded:
        return 'غير مرفوع';
      case DocumentStatus.archived:
        return 'مؤرشف';
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showSettingsDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrganizationSettingsScreen(),
      ),
    ).then((_) => _loadData());
  }

  void _showAddDocumentDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
    ).then((_) => _loadData());
  }

  void _showPrintSingleDialog(BuildContext context) {
    // TODO: إنشاء حوار طباعة مستند مفرد
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خيار طباعة المستند المفرد قيد التطوير')),
    );
  }

  void _showPrintMultipleDialog(BuildContext context) {
    // TODO: إنشاء حوار الطباعة المتعددة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خيار الطباعة المتعددة قيد التطوير')),
    );
  }

  void _showAllDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsByRecipientScreen()),
    );
  }

  void _showDocumentDetails(BuildContext context, Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentScreen(document: document),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _exportToExcel(DocumentsProvider provider) async {
    final filePath = await provider.exportToExcel();
    if (filePath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تصدير الملف: $filePath')));
    }
  }
}
