import 'package:flutter/material.dart';
import '../services/funding_service.dart';
import '../services/funding_service_examples.dart';
import '../services/database_service.dart';
import '../models/funding_models.dart';

/// شاشة اختبار تفاعلية لـ FundingService
class FundingServiceTestScreen extends StatefulWidget {
  @override
  _FundingServiceTestScreenState createState() =>
      _FundingServiceTestScreenState();
}

class _FundingServiceTestScreenState extends State<FundingServiceTestScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _logs = [];
  bool _isRunning = false;
  List<InstitutionFunding> _fundings = [];
  InstitutionFunding? _selectedFunding;

  // Controllers للمدخلات
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFundings();
  }

  /// تحميل سجلات التمويل المتاحة
  Future<void> _loadFundings() async {
    try {
      await DatabaseService.initialize();
      final fundings = await DatabaseService.getAllInstitutionFunding();
      setState(() {
        _fundings = fundings;
        if (_fundings.isNotEmpty) {
          _selectedFunding = _fundings.first;
        }
      });
      _addLog('📋 تم تحميل ${fundings.length} سجل تمويل');
    } catch (e) {
      _addLog('❌ خطأ في تحميل السجلات: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });

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

  /// حجز مبلغ
  Future<void> _reserveFunds() async {
    if (_selectedFunding == null) {
      _addLog('❌ يرجى اختيار سجل تمويل');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _addLog('❌ يرجى إدخال مبلغ صحيح');
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      final success = await FundingService.reserveFunds(
        DatabaseService.isar,
        _selectedFunding!.id,
        amount,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      if (success) {
        _addLog('✅ تم حجز مبلغ ${amount.toStringAsFixed(2)} بنجاح');
        await _refreshSelectedFunding();
      } else {
        _addLog('❌ فشل في حجز المبلغ');
      }
    } catch (e) {
      _addLog('❌ خطأ في عملية الحجز: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// صرف مبلغ
  Future<void> _spendFunds() async {
    if (_selectedFunding == null) {
      _addLog('❌ يرجى اختيار سجل تمويل');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _addLog('❌ يرجى إدخال مبلغ صحيح');
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      final success = await FundingService.validateAndSpend(
        DatabaseService.isar,
        _selectedFunding!.id,
        amount,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      if (success) {
        _addLog('✅ تم صرف مبلغ ${amount.toStringAsFixed(2)} بنجاح');
        await _refreshSelectedFunding();
      } else {
        _addLog('❌ فشل في صرف المبلغ');
      }
    } catch (e) {
      _addLog('❌ خطأ في عملية الصرف: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// إلغاء حجز مبلغ
  Future<void> _unreserveFunds() async {
    if (_selectedFunding == null) {
      _addLog('❌ يرجى اختيار سجل تمويل');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _addLog('❌ يرجى إدخال مبلغ صحيح');
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      final success = await FundingService.unreserveFunds(
        DatabaseService.isar,
        _selectedFunding!.id,
        amount,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      if (success) {
        _addLog('✅ تم إلغاء حجز مبلغ ${amount.toStringAsFixed(2)} بنجاح');
        await _refreshSelectedFunding();
      } else {
        _addLog('❌ فشل في إلغاء حجز المبلغ');
      }
    } catch (e) {
      _addLog('❌ خطأ في عملية إلغاء الحجز: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// تحديث السجل المختار
  Future<void> _refreshSelectedFunding() async {
    if (_selectedFunding == null) return;

    try {
      final updatedFunding = await DatabaseService.isar.institutionFundings.get(
        _selectedFunding!.id,
      );
      if (updatedFunding != null) {
        setState(() {
          _selectedFunding = updatedFunding;
          // تحديث القائمة أيضاً
          final index = _fundings.indexWhere((f) => f.id == updatedFunding.id);
          if (index != -1) {
            _fundings[index] = updatedFunding;
          }
        });
      }
    } catch (e) {
      _addLog('❌ خطأ في تحديث البيانات: $e');
    }
  }

  /// عرض تقرير مفصل
  Future<void> _showDetailedReport() async {
    if (_selectedFunding == null) {
      _addLog('❌ يرجى اختيار سجل تمويل');
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('📊 عرض التقرير المفصل...');
      await FundingService.printFundingReport(
        DatabaseService.isar,
        _selectedFunding!.id,
      );
      _addLog('✅ تم عرض التقرير بنجاح');
    } catch (e) {
      _addLog('❌ خطأ في عرض التقرير: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  /// تشغيل الأمثلة
  Future<void> _runExamples() async {
    setState(() {
      _isRunning = true;
    });

    try {
      _addLog('🚀 بدء تشغيل الأمثلة...');
      await FundingServiceExamples.runCompleteExample();
      await _loadFundings(); // إعادة تحميل البيانات
      _addLog('🎉 تم الانتهاء من الأمثلة بنجاح');
    } catch (e) {
      _addLog('❌ خطأ في تشغيل الأمثلة: $e');
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
        title: Text('اختبار FundingService'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadFundings,
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'مسح اللوجز',
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة المدخلات والتحكم
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار سجل التمويل
                Row(
                  children: [
                    Text(
                      'سجل التمويل: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<InstitutionFunding>(
                        value: _selectedFunding,
                        hint: Text('اختر سجل تمويل'),
                        isExpanded: true,
                        items: _fundings.map((funding) {
                          return DropdownMenuItem(
                            value: funding,
                            child: Text(
                              '${funding.id} - ${funding.institutionId}/${funding.categoryId}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFunding = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // عرض تفاصيل السجل المختار
                if (_selectedFunding != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل السجل المختار:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '💰 المخصص: ${_selectedFunding!.allocatedAmount.toStringAsFixed(2)}',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '🔒 المحجوز: ${_selectedFunding!.reservedAmount.toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '💸 المصروف: ${_selectedFunding!.spentAmount.toStringAsFixed(2)}',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '💎 المتبقي: ${_selectedFunding!.remainingAmount.toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                // مدخلات المبلغ والوصف
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'المبلغ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'الوصف (اختياري)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // أزرار العمليات
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _reserveFunds,
                        icon: Icon(Icons.lock),
                        label: Text('حجز'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _spendFunds,
                        icon: Icon(Icons.payment),
                        label: Text('صرف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _unreserveFunds,
                        icon: Icon(Icons.lock_open),
                        label: Text('إلغاء حجز'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // أزرار التقارير والأمثلة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _showDetailedReport,
                        icon: Icon(Icons.analytics),
                        label: Text('تقرير مفصل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runExamples,
                        icon: Icon(Icons.play_arrow),
                        label: Text('تشغيل الأمثلة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                        Icon(Icons.terminal, color: Colors.purple, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'سجل العمليات - FundingService',
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.purple,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد سجلات بعد...\nاختر سجل تمويل وجرب العمليات المختلفة',
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

                              if (log.contains('❌')) {
                                textColor = Colors.red[300]!;
                              } else if (log.contains('✅')) {
                                textColor = Colors.green[300]!;
                              } else if (log.contains('🚀') ||
                                  log.contains('⚡')) {
                                textColor = Colors.blue[300]!;
                              } else if (log.contains('💰') ||
                                  log.contains('🔒') ||
                                  log.contains('💸')) {
                                textColor = Colors.yellow[300]!;
                              } else if (log.contains('📊') ||
                                  log.contains('📋')) {
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
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
