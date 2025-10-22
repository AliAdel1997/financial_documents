import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

/// شاشة التقارير الهرمية
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // متغيرات التحكم
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  String _selectedReportType =
      'summary'; // summary, detailed, aging, comparison

  // البيانات
  List<FundingCategory> _categories = [];
  List<InstitutionFunding> _fundings = [];
  List<FundingTransaction> _transactions = [];

  // متغيرات الحالة
  bool _isLoading = true;

  // متحكمات التنسيق
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'ar');
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd', 'ar');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _categories = await DatabaseService.getAllFundingCategories();
      _fundings = await DatabaseService.getInstitutionFundingByYear(
        _selectedYear,
      );
      _transactions = await DatabaseService.getAllFundingTransactions();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير المالية'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
            tooltip: 'تصدير التقرير',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط الفلاتر والتحكم
                _buildFiltersBar(),

                // المحتوى الرئيسي
                Expanded(child: _buildReportContent()),
              ],
            ),
    );
  }

  Widget _buildFiltersBar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصف الأول: السنة والشهر ونوع التقرير
            Row(
              children: [
                // اختيار السنة
                Expanded(flex: 2, child: _buildYearSelector()),
                const SizedBox(width: 16),

                // اختيار الشهر (اختياري)
                Expanded(flex: 2, child: _buildMonthSelector()),
                const SizedBox(width: 16),

                // نوع التقرير
                Expanded(flex: 3, child: _buildReportTypeSelector()),
              ],
            ),

            const SizedBox(height: 16),

            // الصف الثاني: البحث والتصفية
            Row(
              children: [
                // حقل البحث
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'البحث في الأبواب',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // TODO: تنفيذ البحث والتصفية
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // زر تطبيق الفلاتر
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('تطبيق'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: const InputDecoration(
        labelText: 'السنة',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      items: List.generate(5, (index) {
        final year = DateTime.now().year - 2 + index;
        return DropdownMenuItem(value: year, child: Text(year.toString()));
      }),
      onChanged: (year) {
        setState(() {
          _selectedYear = year!;
        });
        _loadData();
      },
    );
  }

  Widget _buildMonthSelector() {
    const months = [
      'الكل',
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

    return DropdownButtonFormField<int?>(
      value: _selectedMonth,
      decoration: const InputDecoration(
        labelText: 'الشهر',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      items: months.asMap().entries.map((entry) {
        final index = entry.key;
        final month = entry.value;
        return DropdownMenuItem(
          value: index == 0 ? null : index,
          child: Text(month),
        );
      }).toList(),
      onChanged: (month) {
        setState(() {
          _selectedMonth = month;
        });
        _loadData();
      },
    );
  }

  Widget _buildReportTypeSelector() {
    const reportTypes = {
      'summary': 'ملخص عام',
      'detailed': 'تقرير مفصل',
      'aging': 'تقادم الحجوزات',
      'comparison': 'مقارنة الفترات',
    };

    return DropdownButtonFormField<String>(
      value: _selectedReportType,
      decoration: const InputDecoration(
        labelText: 'نوع التقرير',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.analytics),
      ),
      items: reportTypes.entries.map((entry) {
        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: (type) {
        setState(() {
          _selectedReportType = type!;
        });
      },
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 'summary':
        return _buildSummaryReport();
      case 'detailed':
        return _buildDetailedReport();
      case 'aging':
        return _buildAgingReport();
      case 'comparison':
        return _buildComparisonReport();
      default:
        return _buildSummaryReport();
    }
  }

  Widget _buildSummaryReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقات الإحصائيات العامة
          _buildStatsCards(),
          const SizedBox(height: 16),

          // جدول الأبواب الرئيسية
          _buildMainCategoriesSummary(),
          const SizedBox(height: 16),

          // جدول الأبواب الفرعية
          _buildSubCategoriesSummary(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    // حساب الإحصائيات
    final totalAllocated = _fundings.fold<double>(
      0,
      (sum, f) => sum + f.allocatedAmount,
    );
    final totalReserved = _fundings.fold<double>(
      0,
      (sum, f) => sum + f.reservedAmount,
    );
    final totalSpent = _fundings.fold<double>(
      0,
      (sum, f) => sum + f.spentAmount,
    );
    final totalRemaining = totalAllocated - totalReserved - totalSpent;

    final pendingReservations = _transactions
        .where((t) => t.status == 'pending')
        .length;
    final executedTransactions = _transactions
        .where((t) => t.status == 'executed')
        .length;

    return Column(
      children: [
        // الصف الأول: المبالغ
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المخصص',
                totalAllocated,
                Colors.blue,
                Icons.account_balance,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'إجمالي المحجوز',
                totalReserved,
                Colors.orange,
                Icons.bookmark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'إجمالي المصروف',
                totalSpent,
                Colors.red,
                Icons.payment,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'المتبقي',
                totalRemaining,
                Colors.green,
                Icons.savings,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // الصف الثاني: المعاملات
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'حجوزات معلقة',
                pendingReservations.toDouble(),
                Colors.amber,
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'معاملات منفذة',
                executedTransactions.toDouble(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'إجمالي الأبواب',
                _categories.length.toDouble(),
                Colors.purple,
                Icons.folder,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'نسبة الصرف',
                totalAllocated > 0 ? (totalSpent / totalAllocated * 100) : 0,
                Colors.indigo,
                Icons.pie_chart,
                isPercentage: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double value,
    Color color,
    IconData icon, {
    bool isPercentage = false,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isPercentage
                  ? '${value.toStringAsFixed(1)}%'
                  : _currencyFormat.format(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoriesSummary() {
    final mainCategories = _categories
        .where((c) => c.parentId == null)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.folder, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'الأبواب الرئيسية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (mainCategories.isEmpty)
              const Text('لا توجد أبواب رئيسية')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('الباب')),
                    DataColumn(label: Text('المخصص')),
                    DataColumn(label: Text('المحجوز')),
                    DataColumn(label: Text('المصروف')),
                    DataColumn(label: Text('المتبقي')),
                    DataColumn(label: Text('نسبة الصرف')),
                  ],
                  rows: mainCategories.map((category) {
                    final funding = _fundings
                        .where((f) => f.categoryId == category.id)
                        .fold<InstitutionFunding?>(null, (prev, curr) {
                          if (prev == null) return curr;
                          return InstitutionFunding()
                            ..allocatedAmount =
                                prev.allocatedAmount + curr.allocatedAmount
                            ..reservedAmount =
                                prev.reservedAmount + curr.reservedAmount
                            ..spentAmount = prev.spentAmount + curr.spentAmount;
                        });

                    final allocated = funding?.allocatedAmount ?? 0;
                    final reserved = funding?.reservedAmount ?? 0;
                    final spent = funding?.spentAmount ?? 0;
                    final remaining = allocated - reserved - spent;
                    final spentPercentage = allocated > 0
                        ? (spent / allocated * 100)
                        : 0;

                    return DataRow(
                      cells: [
                        DataCell(Text(category.name)),
                        DataCell(Text(_currencyFormat.format(allocated))),
                        DataCell(Text(_currencyFormat.format(reserved))),
                        DataCell(Text(_currencyFormat.format(spent))),
                        DataCell(Text(_currencyFormat.format(remaining))),
                        DataCell(
                          Text('${spentPercentage.toStringAsFixed(1)}%'),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoriesSummary() {
    final subCategories = _categories.where((c) => c.parentId != null).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.subdirectory_arrow_right, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'الأبواب الفرعية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (subCategories.isEmpty)
              const Text('لا توجد أبواب فرعية')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('الباب')),
                    DataColumn(label: Text('الباب الأعلى')),
                    DataColumn(label: Text('المخصص')),
                    DataColumn(label: Text('المحجوز')),
                    DataColumn(label: Text('المصروف')),
                    DataColumn(label: Text('المتبقي')),
                  ],
                  rows: subCategories.map((category) {
                    final parentCategory = _categories.firstWhere(
                      (c) => c.id == category.parentId,
                      orElse: () => FundingCategory()..name = 'غير معروف',
                    );

                    final funding = _fundings
                        .where((f) => f.categoryId == category.id)
                        .fold<InstitutionFunding?>(null, (prev, curr) {
                          if (prev == null) return curr;
                          return InstitutionFunding()
                            ..allocatedAmount =
                                prev.allocatedAmount + curr.allocatedAmount
                            ..reservedAmount =
                                prev.reservedAmount + curr.reservedAmount
                            ..spentAmount = prev.spentAmount + curr.spentAmount;
                        });

                    final allocated = funding?.allocatedAmount ?? 0;
                    final reserved = funding?.reservedAmount ?? 0;
                    final spent = funding?.spentAmount ?? 0;
                    final remaining = allocated - reserved - spent;

                    return DataRow(
                      cells: [
                        DataCell(Text(category.name)),
                        DataCell(Text(parentCategory.name)),
                        DataCell(Text(_currencyFormat.format(allocated))),
                        DataCell(Text(_currencyFormat.format(reserved))),
                        DataCell(Text(_currencyFormat.format(spent))),
                        DataCell(Text(_currencyFormat.format(remaining))),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.list_alt, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'تقرير مفصل بجميع المعاملات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_transactions.isEmpty)
                    const Text('لا توجد معاملات')
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('التاريخ')),
                          DataColumn(label: Text('النوع')),
                          DataColumn(label: Text('الباب')),
                          DataColumn(label: Text('المبلغ المطلوب')),
                          DataColumn(label: Text('المبلغ المنفذ')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('الوصف')),
                        ],
                        rows: _transactions.map((transaction) {
                          final category = _categories.firstWhere(
                            (c) => c.id == transaction.categoryId,
                            orElse: () => FundingCategory()..name = 'غير معروف',
                          );

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _dateFormat.format(
                                    transaction.requestDate ?? DateTime.now(),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  transaction.status == 'pending'
                                      ? 'حجز'
                                      : 'صرف',
                                ),
                              ),
                              DataCell(Text(category.name)),
                              DataCell(
                                Text(
                                  _currencyFormat.format(
                                    transaction.requestedAmount,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _currencyFormat.format(
                                    transaction.executedAmount ?? 0,
                                  ),
                                ),
                              ),
                              DataCell(Text(transaction.statusText)),
                              DataCell(
                                Text(
                                  transaction.requestDescription ?? 'لا يوجد',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingReport() {
    final pendingReservations = _transactions
        .where((t) => t.status == 'pending')
        .toList();
    final oldReservations = pendingReservations.where((t) {
      final age = DateTime.now()
          .difference(t.requestDate ?? DateTime.now())
          .inDays;
      return age > 30;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // إحصائيات التقادم
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'حجوزات معلقة',
                  pendingReservations.length.toDouble(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'حجوزات متقادمة (>30 يوم)',
                  oldReservations.length.toDouble(),
                  Colors.red,
                  Icons.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // جدول الحجوزات المتقادمة
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'الحجوزات المتقادمة (أكثر من 30 يوم)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (oldReservations.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green,
                          ),
                          SizedBox(height: 8),
                          Text('لا توجد حجوزات متقادمة'),
                        ],
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('تاريخ الحجز')),
                          DataColumn(label: Text('العمر (يوم)')),
                          DataColumn(label: Text('الباب')),
                          DataColumn(label: Text('المبلغ')),
                          DataColumn(label: Text('الوصف')),
                          DataColumn(label: Text('التحذير')),
                        ],
                        rows: oldReservations.map((transaction) {
                          final category = _categories.firstWhere(
                            (c) => c.id == transaction.categoryId,
                            orElse: () => FundingCategory()..name = 'غير معروف',
                          );

                          final age = DateTime.now()
                              .difference(
                                transaction.requestDate ?? DateTime.now(),
                              )
                              .inDays;

                          return DataRow(
                            color: MaterialStateProperty.all(Colors.red[50]),
                            cells: [
                              DataCell(
                                Text(
                                  _dateFormat.format(
                                    transaction.requestDate ?? DateTime.now(),
                                  ),
                                ),
                              ),
                              DataCell(Text(age.toString())),
                              DataCell(Text(category.name)),
                              DataCell(
                                Text(
                                  _currencyFormat.format(
                                    transaction.requestedAmount,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  transaction.requestDescription ?? 'لا يوجد',
                                ),
                              ),
                              DataCell(
                                Icon(
                                  age > 60 ? Icons.error : Icons.warning,
                                  color: age > 60 ? Colors.red : Colors.orange,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'تقرير مقارنة الفترات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('قريباً...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _exportReport() {
    // TODO: تنفيذ تصدير التقرير
    _showErrorSnackBar('قريباً: تصدير التقرير إلى PDF');
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
