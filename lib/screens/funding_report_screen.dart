import 'package:flutter/material.dart';
import '../services/funding_report_service.dart';
// import '../services/funding_report_examples.dart'; // معطل مؤقتاً
import '../services/database_service.dart';
import '../models/funding_models.dart';

/// شاشة عرض التقارير الهرمية للتمويل
class FundingReportScreen extends StatefulWidget {
  @override
  _FundingReportScreenState createState() => _FundingReportScreenState();
}

class _FundingReportScreenState extends State<FundingReportScreen> {
  List<FundingReportNode> _reportNodes = [];
  List<Institution> _institutions = [];
  bool _isLoading = false;

  // فلاتر
  Institution? _selectedInstitution;
  int? _selectedYear;
  double? _minAllocated;
  double? _minUtilizationRate;
  bool _showOnlyWithFunding = false;

  // Controllers
  final _minAllocatedController = TextEditingController();
  final _minUtilizationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadInstitutions();
    await _generateReport();
  }

  Future<void> _loadInstitutions() async {
    try {
      await DatabaseService.initialize();
      final institutions = await DatabaseService.getAllInstitutions();
      setState(() {
        _institutions = institutions;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل المؤسسات: $e');
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isar = DatabaseService.isar;

      // توليد التقرير الأساسي
      List<FundingReportNode> nodes = await generateFundingReport(
        isar,
        institutionId: _selectedInstitution?.id,
        year: _selectedYear,
      );

      // تطبيق المرشحات الإضافية
      if (_minAllocated != null ||
          _minUtilizationRate != null ||
          _showOnlyWithFunding) {
        nodes = filterReport(
          nodes,
          minAllocated: _minAllocated,
          minUtilizationRate: _minUtilizationRate,
          showOnlyWithFunding: _showOnlyWithFunding,
        );
      }

      setState(() {
        _reportNodes = nodes;
      });

      _showSuccessSnackBar(
        'تم توليد التقرير بنجاح (${nodes.length} فئة جذرية)',
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في توليد التقرير: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runExamples() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: إعادة تفعيل الأمثلة بعد إصلاح FundingReportExamples
      // await FundingReportExamples.runCompleteExample();
      await _loadInstitutions(); // إعادة تحميل المؤسسات
      await _generateReport(); // إعادة توليد التقرير
      _showSuccessSnackBar('تم تحديث البيانات');
    } catch (e) {
      _showErrorSnackBar('خطأ في تحديث البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedInstitution = null;
      _selectedYear = null;
      _minAllocated = null;
      _minUtilizationRate = null;
      _showOnlyWithFunding = false;
      _minAllocatedController.clear();
      _minUtilizationController.clear();
    });
    _generateReport();
  }

  void _exportToJson() {
    if (_reportNodes.isEmpty) {
      _showErrorSnackBar('لا توجد بيانات للتصدير');
      return;
    }

    try {
      final jsonData = exportReportToJson(_reportNodes);

      // في تطبيق حقيقي، يمكن حفظ الملف أو مشاركته
      print('تم تصدير البيانات إلى JSON:');
      print('عدد الفئات الجذرية: ${jsonData['totalRootNodes']}');
      print('إجمالي العقد: ${jsonData['totalNodes']}');

      _showSuccessSnackBar('تم تصدير البيانات إلى JSON (تحقق من console)');
    } catch (e) {
      _showErrorSnackBar('خطأ في التصدير: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير الهرمية للتمويل'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generateReport,
            tooltip: 'تحديث التقرير',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportToJson,
            tooltip: 'تصدير JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة المرشحات
          _buildFiltersSection(),

          // منطقة العرض
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.indigo),
                        SizedBox(height: 16),
                        Text('جاري توليد التقرير...'),
                      ],
                    ),
                  )
                : _reportNodes.isEmpty
                ? _buildEmptyState()
                : _buildReportTree(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _runExamples,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: Icon(Icons.play_arrow),
        label: Text('تشغيل الأمثلة'),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المرشحات والفلاتر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          SizedBox(height: 12),

          // الصف الأول: المؤسسة والسنة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المؤسسة:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    DropdownButtonFormField<Institution>(
                      value: _selectedInstitution,
                      decoration: InputDecoration(
                        hintText: 'جميع المؤسسات',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<Institution>(
                          value: null,
                          child: Text('جميع المؤسسات'),
                        ),
                        ..._institutions.map((institution) {
                          return DropdownMenuItem<Institution>(
                            value: institution,
                            child: Text(institution.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedInstitution = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السنة:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        hintText: 'جميع السنوات',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('جميع السنوات'),
                        ),
                        for (
                          int year = DateTime.now().year;
                          year >= DateTime.now().year - 5;
                          year--
                        )
                          DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // الصف الثاني: المرشحات المتقدمة
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAllocatedController,
                  decoration: InputDecoration(
                    labelText: 'أقل مبلغ مخصص',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minAllocated = double.tryParse(value);
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _minUtilizationController,
                  decoration: InputDecoration(
                    labelText: 'أقل نسبة استغلال %',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minUtilizationRate = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // الصف الثالث: checkbox والأزرار
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('الفئات التي لها تمويل فقط'),
                  value: _showOnlyWithFunding,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyWithFunding = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _generateReport,
                icon: Icon(Icons.search),
                label: Text('تطبيق المرشحات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.clear),
                label: Text('مسح'),
              ),
            ],
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
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد بيانات للتقرير',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'قم بتشغيل الأمثلة أولاً لإنشاء بيانات تجريبية',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _runExamples,
            icon: Icon(Icons.play_arrow),
            label: Text('تشغيل الأمثلة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTree() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _reportNodes.length,
      itemBuilder: (context, index) {
        final node = _reportNodes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: _buildNodeTile(node, 0),
        );
      },
    );
  }

  Widget _buildNodeTile(FundingReportNode node, int depth) {
    final indent = depth * 20.0;
    final hasChildren = node.children.isNotEmpty;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16 + indent, vertical: 4),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNodeColor(node),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            hasChildren ? Icons.folder : Icons.description,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          node.categoryName,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                _buildAmountChip('مخصص', node.allocated, Colors.blue),
                SizedBox(width: 8),
                _buildAmountChip('محجوز', node.reserved, Colors.orange),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                _buildAmountChip('مصروف', node.spent, Colors.red),
                SizedBox(width: 8),
                _buildAmountChip('متبقي', node.remaining, Colors.green),
              ],
            ),
            if (node.allocated > 0) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'نسبة الاستغلال: ${node.utilizationRate.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: node.children.map((child) {
          return _buildNodeTile(child, depth + 1);
        }).toList(),
      ),
    );
  }

  Widget _buildAmountChip(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getNodeColor(FundingReportNode node) {
    if (node.allocated == 0) return Colors.grey;

    final utilizationRate = node.utilizationRate;
    if (utilizationRate >= 80) return Colors.green;
    if (utilizationRate >= 50) return Colors.orange;
    if (utilizationRate >= 20) return Colors.blue;
    return Colors.red;
  }

  @override
  void dispose() {
    _minAllocatedController.dispose();
    _minUtilizationController.dispose();
    super.dispose();
  }
}
