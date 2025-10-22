import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class FundingReportsScreen extends StatefulWidget {
  @override
  _FundingReportsScreenState createState() => _FundingReportsScreenState();
}

class _FundingReportsScreenState extends State<FundingReportsScreen> {
  List<FundingArchive> archives = [];
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];
  List<InstitutionFunding> fundings = [];

  // فلاتر التقرير
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  bool _isLoading = false;

  // بيانات التقرير
  Map<String, FundingReportData> reportData = {};
  FundingReportSummary? summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحميل البيانات الأساسية
      categories = await DatabaseService.getAllFundingCategories();
      institutions = await DatabaseService.getAllInstitutions();
      fundings = await DatabaseService.getAllInstitutionFunding();

      // تحميل البيانات حسب السنة
      await _loadArchiveData();
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadArchiveData() async {
    try {
      // تحميل جميع التخصيصات للسنة المختارة
      List<InstitutionFunding> yearFundings =
          await DatabaseService.getInstitutionFundingByYear(_selectedYear);

      // فلترة حسب الشهر إذا تم اختياره
      if (_selectedMonth != null) {
        yearFundings = yearFundings
            .where((f) => f.month == _selectedMonth)
            .toList();
      }

      // تحميل جميع المعاملات
      List<FundingTransaction> allTransactions =
          await DatabaseService.getAllFundingTransactions();

      // فلترة المعاملات حسب السنة والشهر
      List<FundingTransaction> filteredTransactions = allTransactions.where((
        transaction,
      ) {
        bool matchesYear = transaction.year == _selectedYear;
        bool matchesMonth =
            _selectedMonth == null || transaction.month == _selectedMonth;
        return matchesYear && matchesMonth;
      }).toList();

      // استخدام البيانات المفلترة
      fundings = yearFundings;

      // تحويل المعاملات إلى أرشيف للتوافق مع الكود الحالي
      archives = filteredTransactions.map((transaction) {
        return FundingArchive()
          ..categoryId = transaction.categoryId
          ..institutionId = transaction.institutionId
          ..operationType = _getOperationTypeFromStatus(transaction.status)
          ..amount = transaction.executedAmount ?? transaction.requestedAmount
          ..executedAt = transaction.executionDate ?? transaction.requestDate
          ..year = transaction.year
          ..month = transaction.month;
      }).toList();

      // تحليل البيانات
      await _analyzeData();
    } catch (e) {
      print('خطأ في تحميل بيانات الأرشيف: $e');
    }
  }

  String _getOperationTypeFromStatus(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.reserved:
      case ReservationStatus.approved:
        return 'حجز';
      case ReservationStatus.spent:
        return 'صرف';
      default:
        return 'حجز';
    }
  }

  Future<void> _analyzeData() async {
    reportData.clear();

    double totalReserved = 0;
    double totalSpent = 0;
    double totalAllocated = 0;

    // تحليل البيانات لكل باب
    for (FundingCategory category in categories) {
      // تخطي الفئات الفرعية واعرض فقط الرئيسية في التقرير الرئيسي
      if (category.parentId != null) continue;

      FundingReportData data = FundingReportData(
        categoryId: category.id,
        categoryName: category.name,
        allocated: 0,
        reserved: 0,
        spent: 0,
        remaining: 0,
        transactions: [],
      );

      // حساب التمويل المخصص للباب (شامل الفئات الفرعية)
      double allocated = 0;

      // التخصيصات المباشرة للباب الرئيسي
      allocated += fundings
          .where((f) => f.categoryId == category.id)
          .fold(0.0, (sum, f) => sum + f.allocatedAmount);

      // التخصيصات للفئات الفرعية
      List<FundingCategory> subCategories = categories
          .where((c) => c.parentId == category.id)
          .toList();

      for (FundingCategory subCat in subCategories) {
        allocated += fundings
            .where((f) => f.categoryId == subCat.id)
            .fold(0.0, (sum, f) => sum + f.allocatedAmount);
      }

      data.allocated = allocated;
      totalAllocated += allocated;

      // حساب المحجوز والمصروف الفعلي من InstitutionFunding
      double reserved = 0;
      double spent = 0;

      // للباب الرئيسي
      reserved += fundings
          .where((f) => f.categoryId == category.id)
          .fold(0.0, (sum, f) => sum + f.reservedAmount);

      spent += fundings
          .where((f) => f.categoryId == category.id)
          .fold(0.0, (sum, f) => sum + f.spentAmount);

      // للفئات الفرعية
      for (FundingCategory subCat in subCategories) {
        reserved += fundings
            .where((f) => f.categoryId == subCat.id)
            .fold(0.0, (sum, f) => sum + f.reservedAmount);

        spent += fundings
            .where((f) => f.categoryId == subCat.id)
            .fold(0.0, (sum, f) => sum + f.spentAmount);
      }

      data.reserved = reserved;
      data.spent = spent;
      totalReserved += reserved;
      totalSpent += spent;

      // تحليل المعاملات (للباب الرئيسي والفرعية)
      List<int> categoryIds = [category.id, ...subCategories.map((c) => c.id)];
      List<FundingArchive> categoryArchives = archives
          .where((a) => categoryIds.contains(a.categoryId))
          .toList();

      data.transactions.addAll(categoryArchives);

      // حساب المتبقي
      data.remaining = data.allocated - data.spent - data.reserved;

      // إضافة البيانات إذا كان هناك نشاط
      if (data.allocated > 0 || data.reserved > 0 || data.spent > 0) {
        reportData[category.name] = data;
      }
    }

    // إنشاء الملخص العام
    summary = FundingReportSummary(
      totalAllocated: totalAllocated,
      totalReserved: totalReserved,
      totalSpent: totalSpent,
      totalRemaining: totalAllocated - totalSpent - totalReserved,
      period: _selectedMonth != null
          ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
          : 'السنة $_selectedYear',
      categoriesCount: reportData.length,
      transactionsCount: archives.length,
    );

    setState(() {});

    // طباعة تفاصيل للتصحيح
    print('\n=== تحليل البيانات للتقرير ===');
    print('إجمالي المخصص: ${totalAllocated.toStringAsFixed(0)}');
    print('إجمالي المحجوز: ${totalReserved.toStringAsFixed(0)}');
    print('إجمالي المصروف: ${totalSpent.toStringAsFixed(0)}');
    print('عدد الأبواب النشطة: ${reportData.length}');
    print('عدد المعاملات: ${archives.length}');
    print('=================================\n');
  }

  String _getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  Future<void> _exportToJSON() async {
    try {
      if (summary == null || reportData.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('لا توجد بيانات للتصدير')));
        return;
      }

      // إنشاء بيانات JSON
      Map<String, dynamic> exportData = {
        'reportInfo': {
          'title': 'تقرير التمويل الشامل',
          'period': summary!.period,
          'generatedAt': DateTime.now().toIso8601String(),
          'year': _selectedYear,
          'month': _selectedMonth,
        },
        'summary': summary!.toJson(),
        'categories': reportData.values.map((data) => data.toJson()).toList(),
        'attachments': await _getAttachmentsInfo(),
      };

      // حفظ الملف
      String fileName = 'funding_report_${_selectedYear}';
      if (_selectedMonth != null) {
        fileName += '_${_selectedMonth.toString().padLeft(2, '0')}';
      }
      fileName += '.json';

      await _saveFile(jsonEncode(exportData), fileName, 'application/json');
    } catch (e) {
      print('خطأ في تصدير JSON: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تصدير التقرير')));
    }
  }

  Future<Map<String, dynamic>> _getAttachmentsInfo() async {
    Map<String, dynamic> attachments = {};

    for (FundingArchive archive in archives) {
      if (archive.executionAttachmentPath != null &&
          archive.executionAttachmentPath!.isNotEmpty) {
        String fileName = archive.executionAttachmentPath!.split('\\').last;
        attachments[archive.id.toString()] = {
          'fileName': fileName,
          'filePath': archive.executionAttachmentPath,
          'operationType': archive.operationType,
          'amount': archive.amount,
          'date': archive.executedAt?.toIso8601String(),
        };
      }
    }

    return attachments;
  }

  Future<void> _exportToPDF() async {
    try {
      if (summary == null || reportData.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('لا توجد بيانات للتصدير')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // إنشاء تقرير PDF بصيغة مبسطة
      String fileName = 'funding_report_${_selectedYear}';
      if (_selectedMonth != null) {
        fileName += '_${_selectedMonth.toString().padLeft(2, '0')}';
      }
      fileName += '.pdf';

      // إنشاء محتوى PDF كنص بسيط لحين تطوير الخدمة
      String pdfContent = _generateReportText();

      await _saveFile(
        pdfContent,
        fileName.replaceAll('.pdf', '.txt'),
        'text/plain',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم إنشاء تقرير نصي: $fileName')));
    } catch (e) {
      print('خطأ في تصدير PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في إنشاء تقرير PDF')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateReportText() {
    StringBuffer buffer = StringBuffer();

    buffer.writeln('=== تقرير التمويل الشامل ===');
    buffer.writeln('الفترة: ${summary!.period}');
    buffer.writeln('تاريخ الإنشاء: ${DateTime.now()}');
    buffer.writeln('');

    buffer.writeln('=== ملخص عام ===');
    buffer.writeln(
      'إجمالي التمويل: ${summary!.totalAllocated.toStringAsFixed(0)} د.ع',
    );
    buffer.writeln(
      'إجمالي المحجوز: ${summary!.totalReserved.toStringAsFixed(0)} د.ع',
    );
    buffer.writeln(
      'إجمالي المصروف: ${summary!.totalSpent.toStringAsFixed(0)} د.ع',
    );
    buffer.writeln(
      'إجمالي المتبقي: ${summary!.totalRemaining.toStringAsFixed(0)} د.ع',
    );
    buffer.writeln('عدد الأبواب النشطة: ${summary!.categoriesCount}');
    buffer.writeln('عدد العمليات: ${summary!.transactionsCount}');
    buffer.writeln('');

    buffer.writeln('=== تفاصيل الأبواب ===');
    for (var data in reportData.values) {
      buffer.writeln('--- ${data.categoryName} ---');
      buffer.writeln('  المخصص: ${data.allocated.toStringAsFixed(0)} د.ع');
      buffer.writeln('  المحجوز: ${data.reserved.toStringAsFixed(0)} د.ع');
      buffer.writeln('  المصروف: ${data.spent.toStringAsFixed(0)} د.ع');
      buffer.writeln('  المتبقي: ${data.remaining.toStringAsFixed(0)} د.ع');
      buffer.writeln('  عدد العمليات: ${data.transactions.length}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  Future<void> _saveFile(
    String content,
    String fileName,
    String mimeType,
  ) async {
    try {
      // احصل على مجلد التنزيلات
      String downloadsPath =
          'C:\\Users\\${Platform.environment['USERNAME']}\\Downloads';
      String filePath = '$downloadsPath\\$fileName';

      // احفظ الملف
      File file = File(filePath);
      await file.writeAsString(content);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الملف: $fileName'),
          action: SnackBarAction(
            label: 'فتح المجلد',
            onPressed: () => Process.start('explorer', [downloadsPath]),
          ),
        ),
      );
    } catch (e) {
      print('خطأ في حفظ الملف: $e');
      throw e;
    }
  }

  Widget _buildSummaryCard() {
    if (summary == null) return Container();

    // حساب النسب المئوية
    double reservedPercentage = summary!.totalAllocated > 0
        ? (summary!.totalReserved / summary!.totalAllocated) * 100
        : 0;
    double spentPercentage = summary!.totalAllocated > 0
        ? (summary!.totalSpent / summary!.totalAllocated) * 100
        : 0;
    double remainingPercentage = summary!.totalAllocated > 0
        ? (summary!.totalRemaining / summary!.totalAllocated) * 100
        : 0;

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'ملخص التمويل - ${summary!.period}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),

            // صف الإحصائيات الرئيسية
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItemWithPercentage(
                    'إجمالي التمويل',
                    summary!.totalAllocated,
                    100.0,
                    Colors.blue,
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItemWithPercentage(
                    'المحجوز',
                    summary!.totalReserved,
                    reservedPercentage,
                    Colors.orange,
                    Icons.lock,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItemWithPercentage(
                    'المصروف',
                    summary!.totalSpent,
                    spentPercentage,
                    Colors.red,
                    Icons.payments,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItemWithPercentage(
                    'المتبقي',
                    summary!.totalRemaining,
                    remainingPercentage,
                    summary!.totalRemaining >= 0 ? Colors.green : Colors.red,
                    Icons.savings,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // شريط التقدم المرئي
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Text(
                    'توزيع التمويل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: summary!.totalAllocated > 0
                        ? (summary!.totalSpent + summary!.totalReserved) /
                              summary!.totalAllocated
                        : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مستخدم: ${(spentPercentage + reservedPercentage).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'متبقي: ${remainingPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // معلومات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${summary!.categoriesCount}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'أبواب نشطة',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${summary!.transactionsCount}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    Text(
                      'إجمالي العمليات',
                      style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildSummaryItemWithPercentage(
    String title,
    double amount,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} د.ع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          if (percentage != 100.0) // لا نظهر النسبة للإجمالي
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقارير التمويل الموسعة'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط الفلاتر
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // فلتر السنة
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'السنة',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - 2 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                            _loadArchiveData();
                          },
                        ),
                      ),

                      SizedBox(width: 16),

                      // فلتر الشهر
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          value: _selectedMonth,
                          decoration: InputDecoration(
                            labelText: 'الشهر',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('السنة كاملة'),
                            ),
                            ...List.generate(12, (index) {
                              return DropdownMenuItem<int?>(
                                value: index + 1,
                                child: Text(_getMonthName(index + 1)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value;
                            });
                            _loadArchiveData();
                          },
                        ),
                      ),

                      SizedBox(width: 16),

                      // أزرار التصدير
                      ElevatedButton.icon(
                        onPressed: _exportToJSON,
                        icon: Icon(Icons.download),
                        label: Text('JSON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      SizedBox(width: 8),

                      ElevatedButton.icon(
                        onPressed: _exportToPDF,
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // المحتوى
                Expanded(
                  child: reportData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assessment,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد بيانات للفترة المحددة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            // ملخص عام
                            _buildSummaryCard(),

                            // تفاصيل الأبواب
                            Container(
                              margin: EdgeInsets.all(16),
                              child: Text(
                                'تفاصيل حسب الأبواب',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...reportData.values.map(
                              (data) => _buildCategoryCard(data),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard(FundingReportData data) {
    double progressPercent = data.allocated > 0
        ? (data.spent + data.reserved) / data.allocated
        : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                Icon(Icons.folder, color: Colors.indigo, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.categoryName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: progressPercent > 1.0
                        ? Colors.red[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progressPercent * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: progressPercent > 1.0
                          ? Colors.red[700]
                          : Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // الأرقام
            Row(
              children: [
                Expanded(
                  child: _buildDataItem('المخصص', data.allocated, Colors.blue),
                ),
                Expanded(
                  child: _buildDataItem(
                    'المحجوز',
                    data.reserved,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDataItem('المصروف', data.spent, Colors.red),
                ),
                Expanded(
                  child: _buildDataItem(
                    'المتبقي',
                    data.remaining,
                    data.remaining >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // شريط التقدم
            LinearProgressIndicator(
              value: progressPercent > 1.0 ? 1.0 : progressPercent,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercent > 1.0 ? Colors.red : Colors.green,
              ),
            ),

            SizedBox(height: 8),

            // معلومات العمليات
            Text(
              'عدد العمليات: ${data.transactions.length}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, double value, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// فئات البيانات
class FundingReportData {
  final int categoryId;
  final String categoryName;
  double allocated;
  double reserved;
  double spent;
  double remaining;
  List<FundingArchive> transactions;

  FundingReportData({
    required this.categoryId,
    required this.categoryName,
    this.allocated = 0,
    this.reserved = 0,
    this.spent = 0,
    this.remaining = 0,
    required this.transactions,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'allocated': allocated,
      'reserved': reserved,
      'spent': spent,
      'remaining': remaining,
      'transactionsCount': transactions.length,
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'operationType': t.operationType,
              'amount': t.amount,
              'operationDate': t.executedAt?.toIso8601String(),
              'description': t.description,
              'hasAttachment':
                  t.executionAttachmentPath != null &&
                  t.executionAttachmentPath!.isNotEmpty,
              'attachmentPath': t.executionAttachmentPath,
            },
          )
          .toList(),
    };
  }
}

class FundingReportSummary {
  final double totalAllocated;
  final double totalReserved;
  final double totalSpent;
  final double totalRemaining;
  final String period;
  final int categoriesCount;
  final int transactionsCount;

  FundingReportSummary({
    required this.totalAllocated,
    required this.totalReserved,
    required this.totalSpent,
    required this.totalRemaining,
    required this.period,
    required this.categoriesCount,
    required this.transactionsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalAllocated': totalAllocated,
      'totalReserved': totalReserved,
      'totalSpent': totalSpent,
      'totalRemaining': totalRemaining,
      'period': period,
      'categoriesCount': categoriesCount,
      'transactionsCount': transactionsCount,
      'utilizationPercent': totalAllocated > 0
          ? ((totalSpent + totalReserved) / totalAllocated * 100)
          : 0,
    };
  }
}
