import 'package:flutter/material.dart';
import '../services/funding_manager.dart';
import '../services/funding_manager_examples.dart';
import '../services/database_service.dart';
import '../models/funding_models.dart';

/// شاشة اختبار FundingManager
class FundingManagerTestScreen extends StatefulWidget {
  @override
  _FundingManagerTestScreenState createState() => _FundingManagerTestScreenState();
}

class _FundingManagerTestScreenState extends State<FundingManagerTestScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _logs = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // إعادة توجيه print إلى قائمة اللوجز
    _interceptPrint();
  }

  void _interceptPrint() {
    // هذا مجرد مثال - في التطبيق الحقيقي نحتاج طريقة أخرى
    _addLog('📱 جاهز لاختبار FundingManager');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    
    // التمرير إلى الأسفل تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Future<void> _runQuickExample() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('🚀 بدء تشغيل المثال السريع...');
      
      // تهيئة قاعدة البيانات
      await DatabaseService.initialize();
      _addLog('✅ تم تهيئة قاعدة البيانات');

      // تشغيل المثال السريع
      await _runQuickExampleSteps();
      
      _addLog('🎉 تم الانتهاء من المثال السريع بنجاح!');
      
    } catch (e) {
      _addLog('❌ خطأ: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _runQuickExampleSteps() async {
    // إنشاء باب رئيسي
    _addLog('📁 إنشاء باب رئيسي...');
    final categoryId = await FundingManager.addFundingCategory(
      'باب اختبار التطبيق',
      allocatedAmount: 1000000.0,
    );

    if (categoryId != null) {
      _addLog('✅ تم إنشاء الباب الرئيسي بالمعرف: $categoryId');

      // إنشاء أبواب فرعية
      _addLog('📂 إنشاء أبواب فرعية...');
      
      await FundingManager.addFundingCategory(
        'فرع اختبار 1',
        parentId: categoryId,
        allocatedAmount: 300000.0,
      );
      
      await FundingManager.addFundingCategory(
        'فرع اختبار 2',
        parentId: categoryId,
        allocatedAmount: 400000.0,
      );
      
      await FundingManager.addFundingCategory(
        'فرع اختبار 3',
        parentId: categoryId,
        allocatedAmount: 200000.0,
      );

      _addLog('✅ تم إنشاء الأبواب الفرعية');

      // توزيع الأموال
      _addLog('💰 توزيع الأموال بالتساوي...');
      final distribution = await FundingManager.distributeFundsHierarchically(
        categoryId,
        distributionType: DistributionType.equal,
        totalAmount: 900000.0,
      );

      if (distribution != null) {
        _addLog('✅ تم توزيع الأموال على ${distribution.length} أبواب فرعية');
        
        for (final entry in distribution.entries) {
          _addLog('   💵 الباب ${entry.key}: ${entry.value.toStringAsFixed(2)}');
        }
      }

      // إنشاء مؤسسة للاختبار
      final testInstitution = Institution()
        ..name = 'مؤسسة اختبار FundingManager'
        ..address = 'عنوان اختبار'
        ..code = 'TEST001';

      final institutionId = await DatabaseService.addInstitution(testInstitution);
      _addLog('✅ تم إنشاء مؤسسة اختبار بالمعرف: $institutionId');

      // تخصيص أموال للمؤسسة
      _addLog('💼 تخصيص أموال للمؤسسة...');
      final success = await FundingManager.allocateFundsToInstitution(
        institutionId,
        categoryId,
        250000.0,
      );

      if (success) {
        _addLog('✅ تم تخصيص 250,000 للمؤسسة بنجاح');
      } else {
        _addLog('❌ فشل في تخصيص الأموال');
      }

      // توليد تقرير
      _addLog('📊 توليد تقرير الملخص...');
      final summary = await FundingManager.getInstitutionFundingSummary(
        institutionId,
        DateTime.now().year,
      );

      _addLog('📋 ملخص المؤسسة:');
      _addLog('   💰 إجمالي المخصص: ${summary.totalAllocated}');
      _addLog('   💸 إجمالي المصروف: ${summary.totalSpent}');
      _addLog('   💵 إجمالي المتبقي: ${summary.totalRemaining}');
      _addLog('   📈 نسبة الاستغلال: ${summary.utilizationRate.toStringAsFixed(1)}%');

    } else {
      _addLog('❌ فشل في إنشاء الباب الرئيسي');
    }
  }

  Future<void> _runCompleteExample() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('🚀 بدء تشغيل المثال الشامل...');
      
      // تهيئة قاعدة البيانات
      await DatabaseService.initialize();
      
      // تشغيل المثال الشامل
      await FundingManagerExamples.runCompleteExample();
      
      _addLog('🎉 تم الانتهاء من المثال الشامل!');
      
    } catch (e) {
      _addLog('❌ خطأ في المثال الشامل: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testErrorCases() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('🧪 بدء اختبار حالات الخطأ...');
      await FundingManagerExamples.testErrorCases();
      _addLog('✅ تم الانتهاء من اختبار حالات الخطأ');
      
    } catch (e) {
      _addLog('❌ خطأ في اختبار حالات الخطأ: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار FundingManager'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'مسح اللوجز',
          ),
        ],
      ),
      body: Column(
        children: [
          // أزرار التحكم
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runQuickExample,
                        icon: Icon(Icons.flash_on),
                        label: Text('مثال سريع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runCompleteExample,
                        icon: Icon(Icons.analytics),
                        label: Text('مثال شامل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _testErrorCases,
                    icon: Icon(Icons.bug_report),
                    label: Text('اختبار حالات الخطأ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // منطقة اللوجز
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'سجل العمليات',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        if (_isRunning)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد سجلات بعد...\nاضغط على أحد الأزرار لبدء الاختبار',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(8),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[index];
                              Color textColor = Colors.white;
                              
                              // تلوين مختلف حسب نوع الرسالة
                              if (log.contains('❌')) {
                                textColor = Colors.red[300]!;
                              } else if (log.contains('✅')) {
                                textColor = Colors.green[300]!;
                              } else if (log.contains('⚡') || log.contains('🚀')) {
                                textColor = Colors.blue[300]!;
                              } else if (log.contains('💰') || log.contains('💵')) {
                                textColor = Colors.yellow[300]!;
                              } else if (log.contains('📊') || log.contains('📋')) {
                                textColor = Colors.purple[300]!;
                              }

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 1),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}