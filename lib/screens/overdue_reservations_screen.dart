import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';

/// شاشة إدارة الحجوزات المتأخرة
class OverdueReservationsScreen extends StatefulWidget {
  const OverdueReservationsScreen({super.key});

  @override
  State<OverdueReservationsScreen> createState() =>
      _OverdueReservationsScreenState();
}

class _OverdueReservationsScreenState extends State<OverdueReservationsScreen> {
  List<FundingTransaction> _overdueReservations = [];
  bool _isLoading = true;
  String? _error;
  Map<int, FundingCategory> _categories = {};
  Map<int, Institution> _institutions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// تحميل البيانات
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // تحميل الحجوزات المتأخرة
      final overdueReservations =
          await NotificationService.getOverdueReservations();

      // تحميل الأبواب والمؤسسات
      final categories = await DatabaseService.getAllFundingCategories();
      final institutions = await DatabaseService.getAllInstitutions();

      // تحويل القوائم إلى خرائط للوصول السريع
      final categoriesMap = <int, FundingCategory>{};
      for (final category in categories) {
        categoriesMap[category.id] = category;
      }

      final institutionsMap = <int, Institution>{};
      for (final institution in institutions) {
        institutionsMap[institution.id] = institution;
      }

      setState(() {
        _overdueReservations = overdueReservations;
        _categories = categoriesMap;
        _institutions = institutionsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  /// حذف حجز متأخر
  Future<void> _cancelReservation(FundingTransaction reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد الإلغاء'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إلغاء هذا الحجز؟\n'
          'المبلغ: ${reservation.requestedAmount.toStringAsFixed(2)} د.ع\n'
          'الوصف: ${reservation.requestDescription ?? 'غير محدد'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedReservation = reservation.copyWith(
          status: ReservationStatus.cancelled,
          updatedAt: DateTime.now(),
        );

        await DatabaseService.saveFundingTransaction(updatedReservation);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // إعادة تحميل البيانات
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إلغاء الحجز: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// تنفيذ الحجز
  Future<void> _executeReservation(FundingTransaction reservation) async {
    // يمكن إضافة شاشة تنفيذ الحجز هنا أو فتح شاشة منفصلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ميزة تنفيذ الحجز قيد التطوير'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الحجوزات المتأخرة'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جارٍ تحميل الحجوزات المتأخرة...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text('إعادة المحاولة')),
          ],
        ),
      );
    }

    if (_overdueReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'لا توجد حجوزات متأخرة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'جميع الحجوزات محدثة ولا توجد حجوزات معلقة لأكثر من 30 يوماً',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // إحصائيات سريعة
        _buildStatisticsCard(),

        // قائمة الحجوزات المتأخرة
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _overdueReservations.length,
            itemBuilder: (context, index) {
              final reservation = _overdueReservations[index];
              final categoryName =
                  _categories[reservation.categoryId]?.name ?? 'غير محدد';
              final institutionName =
                  _institutions[reservation.institutionId]?.name ?? 'غير محدد';

              return _buildReservationCard(
                reservation,
                categoryName,
                institutionName,
              );
            },
          ),
        ),
      ],
    );
  }

  /// بطاقة الإحصائيات
  Widget _buildStatisticsCard() {
    final totalAmount = _overdueReservations.fold<double>(
      0.0,
      (sum, reservation) => sum + reservation.requestedAmount,
    );

    final oldestReservation = _overdueReservations.isNotEmpty
        ? _overdueReservations.reduce(
            (a, b) => a.requestDate!.isBefore(b.requestDate!) ? a : b,
          )
        : null;

    final averageDaysOverdue = _overdueReservations.isNotEmpty
        ? _overdueReservations
                  .map((r) => DateTime.now().difference(r.requestDate!).inDays)
                  .reduce((a, b) => a + b) /
              _overdueReservations.length
        : 0.0;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.orange.shade700),
              SizedBox(width: 8),
              Text(
                'إحصائيات الحجوزات المتأخرة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'العدد الإجمالي',
                  '${_overdueReservations.length}',
                  Icons.format_list_numbered,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  'المبلغ الإجمالي',
                  '${totalAmount.toStringAsFixed(0)} د.ع',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'متوسط أيام التأخير',
                  '${averageDaysOverdue.round()} يوم',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  'أقدم حجز',
                  oldestReservation != null
                      ? '${DateTime.now().difference(oldestReservation.requestDate!).inDays} يوم'
                      : '0',
                  Icons.history,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  /// بطاقة الحجز المتأخر
  Widget _buildReservationCard(
    FundingTransaction reservation,
    String categoryName,
    String institutionName,
  ) {
    final daysOverdue = DateTime.now()
        .difference(reservation.requestDate!)
        .inDays;
    final overdueColor = NotificationService.getOverdueColor(daysOverdue);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: overdueColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: overdueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: overdueColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: overdueColor),
                      SizedBox(width: 4),
                      Text(
                        'متأخر $daysOverdue يوماً',
                        style: TextStyle(
                          color: overdueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  '${reservation.requestedAmount.toStringAsFixed(0)} د.ع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: overdueColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // معلومات الحجز
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'الباب: $categoryName',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),

            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'الجهة: $institutionName',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),

            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'تاريخ الحجز: ${NotificationService.formatDate(reservation.requestDate!)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),

            if (reservation.requestDescription?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'الوصف: ${reservation.requestDescription}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _executeReservation(reservation),
                    icon: Icon(Icons.play_arrow, size: 16),
                    label: Text('تنفيذ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelReservation(reservation),
                    icon: Icon(Icons.cancel, size: 16),
                    label: Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
