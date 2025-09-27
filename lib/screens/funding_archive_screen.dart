import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'dart:async';
import '../models/funding_models.dart';
import '../services/database_service.dart';

class FundingArchiveScreen extends StatefulWidget {
  @override
  _FundingArchiveScreenState createState() => _FundingArchiveScreenState();
}

class _FundingArchiveScreenState extends State<FundingArchiveScreen> {
  List<FundingArchive> allArchives = [];
  List<FundingArchive> filteredArchives = [];
  List<FundingCategory> categories = [];
  List<Institution> institutions = [];
  List<FundingTransaction> transactions = [];
  
  // فلاتر البحث
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  String _selectedOperationType = 'all'; // all, حجز, صرف
  String _selectedStatus = 'all'; // all, pending, executed, cancelled
  FundingCategory? _selectedCategory;
  double? _minAmount;
  double? _maxAmount;
  
  // تحكم البحث النصي
  final _searchController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  
  // تحكم الفلاتر المتقدمة

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _minAmountController.addListener(_onAmountFilterChanged);
    _maxAmountController.addListener(_onAmountFilterChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _onAmountFilterChanged() {
    setState(() {
      _minAmount = double.tryParse(_minAmountController.text);
      _maxAmount = double.tryParse(_maxAmountController.text);
    });
    _applyFilters();
  }

  Future<void> _loadData() async {
    try {
      // تحميل جميع الأرشيف
      final loadedArchives = await DatabaseService.getAllFundingArchives();
      
      // تحميل الأبواب
      final loadedCategories = await DatabaseService.isar.fundingCategorys.where().findAll();
      
      // تحميل المؤسسات
      final loadedInstitutions = await DatabaseService.isar.institutions.where().findAll();
      
      // تحميل المعاملات للحصول على معلومات الحالة
      final loadedTransactions = await DatabaseService.getAllFundingTransactions();
      
      setState(() {
        allArchives = loadedArchives;
        categories = loadedCategories;
        institutions = loadedInstitutions;
        transactions = loadedTransactions;
      });
      
      _applyFilters();
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      filteredArchives = allArchives.where((archive) {
        // فلترة حسب السنة
        if (archive.year != _selectedYear) return false;
        
        // فلترة حسب الشهر
        if (_selectedMonth != null && archive.month != _selectedMonth) return false;
        
        // فلترة حسب نوع العملية
        if (_selectedOperationType != 'all' && archive.operationType != _selectedOperationType) return false;
        
        // فلترة حسب الباب
        if (_selectedCategory != null && archive.categoryId != _selectedCategory!.id) return false;
        
        // فلترة حسب المبلغ
        if (_minAmount != null && archive.amount < _minAmount!) return false;
        if (_maxAmount != null && archive.amount > _maxAmount!) return false;
        
        // البحث النصي في الملاحظات
        if (_searchController.text.isNotEmpty) {
          final searchText = _searchController.text.toLowerCase();
          final description = archive.description?.toLowerCase() ?? '';
          if (!description.contains(searchText)) return false;
        }
        
        // فلترة حسب الحالة (من خلال ربطها بالمعاملة إن وجدت)
        if (_selectedStatus != 'all') {
          final relatedTransaction = transactions.firstWhere(
            (t) => t.fundingId == archive.fundingId && 
                   t.institutionId == archive.institutionId &&
                   t.categoryId == archive.categoryId,
            orElse: () => FundingTransaction()..status = 'executed', // افتراضي للعمليات المباشرة
          );
          if (relatedTransaction.status != _selectedStatus) return false;
        }
        
        return true;
      }).toList();
      
      // ترتيب حسب التاريخ (الأحدث أولاً)
      filteredArchives.sort((a, b) => (b.executedAt ?? DateTime.now()).compareTo(a.executedAt ?? DateTime.now()));
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedYear = DateTime.now().year;
      _selectedMonth = null;
      _selectedOperationType = 'all';
      _selectedStatus = 'all';
      _selectedCategory = null;
      _minAmount = null;
      _maxAmount = null;
    });
    
    _searchController.clear();
    _minAmountController.clear();
    _maxAmountController.clear();
    
    _applyFilters();
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      if (await File(filePath).exists()) {
        await Process.start('explorer', [filePath], runInShell: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الملف غير موجود')),
        );
      }
    } catch (e) {
      print('خطأ في فتح الملف: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح الملف')),
      );
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

  String _getInstitutionName(int? institutionId) {
    if (institutionId == null) return 'غير محدد';
    final institution = institutions.firstWhere(
      (i) => i.id == institutionId,
      orElse: () => Institution()..name = 'غير معروف',
    );
    return institution.name;
  }

  String _getOperationStatus(FundingArchive archive) {
    final relatedTransaction = transactions.firstWhere(
      (t) => t.fundingId == archive.fundingId && 
             t.institutionId == archive.institutionId &&
             t.categoryId == archive.categoryId,
      orElse: () => FundingTransaction()..status = 'executed',
    );
    
    switch (relatedTransaction.status) {
      case 'pending':
        return 'في الانتظار';
      case 'executed':
        return 'منفذ';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'منفذ';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'في الانتظار':
        return Colors.orange;
      case 'منفذ':
        return Colors.green;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];
    
    if (_selectedOperationType != 'all') {
      chips.add(Chip(
        label: Text('العملية: $_selectedOperationType'),
        onDeleted: () {
          setState(() {
            _selectedOperationType = 'all';
          });
          _applyFilters();
        },
      ));
    }
    
    if (_selectedStatus != 'all') {
      chips.add(Chip(
        label: Text('الحالة: $_selectedStatus'),
        onDeleted: () {
          setState(() {
            _selectedStatus = 'all';
          });
          _applyFilters();
        },
      ));
    }
    
    if (_selectedCategory != null) {
      chips.add(Chip(
        label: Text('الباب: ${_selectedCategory!.name}'),
        onDeleted: () {
          setState(() {
            _selectedCategory = null;
          });
          _applyFilters();
        },
      ));
    }
    
    if (_selectedMonth != null) {
      const monthNames = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      chips.add(Chip(
        label: Text('الشهر: ${monthNames[_selectedMonth! - 1]}'),
        onDeleted: () {
          setState(() {
            _selectedMonth = null;
          });
          _applyFilters();
        },
      ));
    }
    
    if (_minAmount != null || _maxAmount != null) {
      String amountText = 'المبلغ: ';
      if (_minAmount != null && _maxAmount != null) {
        amountText += '${_minAmount!.toStringAsFixed(0)} - ${_maxAmount!.toStringAsFixed(0)}';
      } else if (_minAmount != null) {
        amountText += 'أكبر من ${_minAmount!.toStringAsFixed(0)}';
      } else {
        amountText += 'أصغر من ${_maxAmount!.toStringAsFixed(0)}';
      }
      
      chips.add(Chip(
        label: Text(amountText),
        onDeleted: () {
          setState(() {
            _minAmount = null;
            _maxAmount = null;
          });
          _minAmountController.clear();
          _maxAmountController.clear();
          _applyFilters();
        },
      ));
    }
    
    if (_searchController.text.isNotEmpty) {
      chips.add(Chip(
        label: Text('البحث: ${_searchController.text}'),
        onDeleted: () {
          _searchController.clear();
          _applyFilters();
        },
      ));
    }
    
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: Text('مسح الكل'),
          onPressed: _resetFilters,
          backgroundColor: Colors.red[100],
        ),
      );
    }
    
    return chips.isEmpty 
      ? Container()
      : Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chips,
          ),
        );
  }

  Widget _buildStatsRow() {
    final totalAmount = filteredArchives.fold<double>(0, (sum, archive) => sum + archive.amount);
    final spentAmount = filteredArchives.where((a) => a.operationType == 'صرف').fold<double>(0, (sum, archive) => sum + archive.amount);
    final reservedAmount = filteredArchives.where((a) => a.operationType == 'حجز').fold<double>(0, (sum, archive) => sum + archive.amount);
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('${filteredArchives.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text('إجمالي العمليات', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          Column(
            children: [
              Text('${totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              Text('إجمالي المبلغ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          Column(
            children: [
              Text('${spentAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              Text('إجمالي الصرف', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          Column(
            children: [
              Text('${reservedAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              Text('إجمالي الحجز', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أرشيف عمليات الصرف والحجز'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _resetFilters();
              _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // البحث والفلاتر
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث في العمليات...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                SizedBox(height: 16),
                
                // فلاتر أساسية
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'السنة',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(10, (index) {
                          final year = DateTime.now().year - 5 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                            _loadData();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedOperationType,
                        decoration: InputDecoration(
                          labelText: 'نوع العملية',
                          border: OutlineInputBorder(),
                        ),
                        items: ['all', 'صرف', 'حجز'].map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type == 'all' ? 'الكل' : type),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOperationType = value!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // فلاتر إضافية
                Row(
                  children: [
                    // فلتر الحالة
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'الحالة',
                          border: OutlineInputBorder(),
                        ),
                        items: ['all', 'في الانتظار', 'منفذ', 'ملغي'].map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status == 'all' ? 'كل الحالات' : status),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // فلتر الباب
                    Expanded(
                      child: DropdownButtonFormField<FundingCategory?>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'الباب',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<FundingCategory?>(
                            value: null,
                            child: Text('كل الأبواب'),
                          ),
                          ...categories.map((category) => DropdownMenuItem<FundingCategory?>(
                            value: category,
                            child: Text(category.name),
                          )).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // مرشحات المبلغ
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minAmountController,
                        decoration: InputDecoration(
                          labelText: 'الحد الأدنى للمبلغ',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _minAmount = double.tryParse(value);
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxAmountController,
                        decoration: InputDecoration(
                          labelText: 'الحد الأقصى للمبلغ',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _maxAmount = double.tryParse(value);
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // عرض المرشحات النشطة
          _buildFilterChips(),
          
          // إحصائيات سريعة
          _buildStatsRow(),
          
          // قائمة العمليات
          Expanded(
            child: filteredArchives.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد عمليات أرشيف', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredArchives.length,
                    itemBuilder: (context, index) {
                      final archive = filteredArchives[index];
                      final categoryName = _getCategoryName(archive.categoryId);
                      final institutionName = _getInstitutionName(archive.institutionId);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: archive.operationType == 'صرف' ? Colors.red[100] : Colors.orange[100],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          archive.operationType,
                                          style: TextStyle(
                                            color: archive.operationType == 'صرف' ? Colors.red[700] : Colors.orange[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(_getOperationStatus(archive)).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _getOperationStatus(archive),
                                          style: TextStyle(
                                            color: _getStatusColor(_getOperationStatus(archive)),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${archive.amount.toStringAsFixed(0)} د.ع',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: archive.operationType == 'صرف' ? Colors.red : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 12),
                              
                              Row(
                                children: [
                                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'الباب: ${categoryName}',
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
                                    'الجهة: ${institutionName}',
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
                                    'التاريخ: ${archive.executedAt?.toLocal().toString().split(' ')[0] ?? 'غير محدد'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              
                              if (archive.description != null && archive.description!.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.description, size: 16, color: Colors.grey[600]),
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
                              
                              if (archive.executionAttachmentPath != null) ...[
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'مرفق PDF متوفر',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.open_in_new, color: Colors.blue),
                                      onPressed: () => _openPdfFile(archive.executionAttachmentPath!),
                                      tooltip: 'فتح المرفق',
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
          ),
        ],
      ),
    );
  }
}