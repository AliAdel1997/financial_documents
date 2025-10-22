import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../models/organization.dart';
import '../services/database_service.dart';

/// شاشة أرشيف التمويل المبسطة (مؤقتة)
class FundingArchiveScreen extends StatefulWidget {
  @override
  _FundingArchiveScreenState createState() => _FundingArchiveScreenState();
}

class _FundingArchiveScreenState extends State<FundingArchiveScreen> {
  List<FundingArchive> archives = [];
  List<FundingCategory> categories = [];
  List<Organization> organizations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // تحميل البيانات الأساسية
      final loadedArchives = await DatabaseService.getAllFundingArchives();
      final loadedCategories = await DatabaseService.getAllFundingCategories();
      final loadedOrganizations = await DatabaseService.getAllOrganizations();

      setState(() {
        archives = loadedArchives;
        categories = loadedCategories;
        organizations = loadedOrganizations;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات')));
      }
    }
  }

  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'غير محدد';
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => FundingCategory()..name = 'غير معروف',
    );
    return category.name;
  }

  String _getOrganizationName(int? orgId) {
    if (orgId == null) return 'غير محدد';
    final org = organizations.firstWhere(
      (o) => o.id == orgId,
      orElse: () => Organization()..departmentName = 'غير معروف',
    );
    return org.departmentName ?? 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أرشيف التمويل'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : archives.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد عمليات أرشيف',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: archives.length,
              itemBuilder: (context, index) {
                final archive = archives[index];
                final categoryName = _getCategoryName(archive.categoryId);
                final organizationName = _getOrganizationName(
                  archive.institutionId,
                );

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان والمبلغ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${archive.amount.toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: archive.operationType == 'صرف'
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // نوع العملية
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: archive.operationType == 'صرف'
                                ? Colors.red[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            archive.operationType,
                            style: TextStyle(
                              color: archive.operationType == 'صرف'
                                  ? Colors.red[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // معلومات إضافية
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'الجهة: $organizationName',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'التاريخ: ${archive.executedAt?.toLocal().toString().split(' ')[0] ?? 'غير محدد'}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),

                        if (archive.description != null &&
                            archive.description!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'الوصف: ${archive.description}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
