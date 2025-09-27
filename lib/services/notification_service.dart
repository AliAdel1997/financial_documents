import 'package:flutter/material.dart';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class NotificationService {
  static const int OVERDUE_DAYS_THRESHOLD = 30;

  /// التحقق من الحجوزات المتأخرة
  static Future<List<FundingTransaction>> getOverdueReservations() async {
    try {
      // الحصول على جميع المعاملات المعلقة
      List<FundingTransaction> allTransactions = await DatabaseService.getAllFundingTransactions();
      
      DateTime now = DateTime.now();
      DateTime thirtyDaysAgo = now.subtract(Duration(days: OVERDUE_DAYS_THRESHOLD));
      
      // فلترة الحجوزات المعلقة القديمة
      List<FundingTransaction> overdueReservations = allTransactions.where((transaction) {
        return transaction.status == 'pending' && 
               transaction.requestDate != null &&
               transaction.requestDate!.isBefore(thirtyDaysAgo);
      }).toList();
      
      // ترتيب حسب التاريخ الأقدم أولاً
      overdueReservations.sort((a, b) => a.requestDate!.compareTo(b.requestDate!));
      
      return overdueReservations;
    } catch (e) {
      print('خطأ في الحصول على الحجوزات المتأخرة: $e');
      return [];
    }
  }

  /// حساب عدد الأيام منذ إنشاء الحجز
  static int getDaysOverdue(DateTime createdAt) {
    DateTime now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// الحصول على لون التحذير حسب عدد الأيام
  static Color getOverdueColor(int daysOverdue) {
    if (daysOverdue >= 60) {
      return Colors.red[800]!; // أحمر داكن للحجوزات القديمة جداً
    } else if (daysOverdue >= 45) {
      return Colors.red; // أحمر للحجوزات القديمة
    } else if (daysOverdue >= 30) {
      return Colors.orange; // برتقالي للحجوزات المتأخرة
    } else {
      return Colors.green; // أخضر للحجوزات العادية
    }
  }

  /// الحصول على نص التحذير
  static String getOverdueMessage(int count) {
    if (count == 0) {
      return 'لا توجد حجوزات متأخرة';
    } else if (count == 1) {
      return 'يوجد حجز واحد متأخر';
    } else if (count == 2) {
      return 'يوجد حجزان متأخران';
    } else if (count <= 10) {
      return 'يوجد $count حجوزات متأخرة';
    } else {
      return 'يوجد $count حجز متأخر';
    }
  }

  /// عرض تنبيه الحجوزات المتأخرة
  static void showOverdueReservationsAlert(
    BuildContext context,
    List<FundingTransaction> overdueReservations,
    VoidCallback onViewReservations,
  ) {
    if (overdueReservations.isEmpty) return;

    int count = overdueReservations.length;
    String message = getOverdueMessage(count);
    
    // أقدم حجز
    FundingTransaction oldestReservation = overdueReservations.first;
    int oldestDays = getDaysOverdue(oldestReservation.createdAt!);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          title: Text(
            'تنبيه: حجوزات متأخرة',
            style: TextStyle(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                        SizedBox(width: 4),
                        Text(
                          'أقدم حجز: $oldestDays يوماً',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'المبلغ: ${oldestReservation.requestedAmount.toStringAsFixed(0)} د.ع',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('تجاهل'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onViewReservations();
              },
              icon: Icon(Icons.visibility),
              label: Text('عرض الحجوزات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// عرض banner للحجوزات المتأخرة
  static Widget buildOverdueReservationsBanner(
    List<FundingTransaction> overdueReservations,
    VoidCallback onTap,
    VoidCallback onDismiss,
  ) {
    if (overdueReservations.isEmpty) {
      return SizedBox.shrink();
    }

    int count = overdueReservations.length;
    String message = getOverdueMessage(count);
    
    return Container(
      margin: EdgeInsets.all(16),
      child: MaterialBanner(
        backgroundColor: Colors.orange[50],
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  Text(
                    'حجوزات لم يتم تنفيذها لأكثر من 30 يوماً',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onDismiss,
            child: Text('إخفاء'),
          ),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.visibility, size: 16),
            label: Text('عرض'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض snackbar للحجوزات المتأخرة
  static void showOverdueReservationsSnackBar(
    BuildContext context,
    List<FundingTransaction> overdueReservations,
    VoidCallback onAction,
  ) {
    if (overdueReservations.isEmpty) return;

    int count = overdueReservations.length;
    String message = getOverdueMessage(count);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange[700],
        duration: Duration(seconds: 5),
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }

  /// إنشاء معلومات مفصلة عن حجز متأخر
  static Widget buildOverdueReservationCard(
    FundingTransaction reservation,
    String categoryName,
    String institutionName,
  ) {
    int daysOverdue = getDaysOverdue(reservation.requestDate!);
    Color overdueColor = getOverdueColor(daysOverdue);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Header مع التحذير
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
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: overdueColor,
                      ),
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
            
            // تفاصيل الحجز
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
                  'تاريخ الحجز: ${_formatDate(reservation.requestDate!)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            
            if (reservation.requestDescription != null && reservation.requestDescription!.isNotEmpty) ...[
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
          ],
        ),
      ),
    );
  }

  /// تنسيق التاريخ
  static String formatDate(DateTime date) {
    return _formatDate(date);
  }

  /// تنسيق التاريخ (دالة مساعدة)
  static String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// فحص دوري للحجوزات المتأخرة (يمكن استخدامه في initState)
  static Future<void> checkAndNotifyOverdueReservations(
    BuildContext context,
    VoidCallback onNavigateToReservations,
  ) async {
    try {
      List<FundingTransaction> overdueReservations = await getOverdueReservations();
      
      if (overdueReservations.isNotEmpty) {
        // تأخير قصير للسماح للواجهة بالتحميل
        await Future.delayed(Duration(milliseconds: 500));
        
        if (context.mounted) {
          showOverdueReservationsSnackBar(
            context,
            overdueReservations,
            onNavigateToReservations,
          );
        }
      }
    } catch (e) {
      print('خطأ في فحص الحجوزات المتأخرة: $e');
    }
  }
}