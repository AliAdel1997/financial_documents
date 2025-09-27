import 'package:isar/isar.dart';
import '../models/funding_models.dart';

/// عقدة تقرير التمويل - تمثل مستوى في الهيكل الشجري للتقرير
class FundingReportNode {
  final String categoryName;
  final double allocated;
  final double reserved;
  final double spent;
  final double remaining;
  final List<FundingReportNode> children;
  
  // معرف الفئة للمرجعية الداخلية
  final int categoryId;
  
  // مستوى العمق في الشجرة (0 للجذر، 1 للمستوى الأول، إلخ)
  final int level;

  FundingReportNode({
    required this.categoryName,
    required this.allocated,
    required this.reserved,
    required this.spent,
    required this.remaining,
    required this.children,
    required this.categoryId,
    this.level = 0,
  });

  /// نسبة الاستغلال
  double get utilizationRate => allocated > 0 ? (spent / allocated) * 100 : 0;

  /// نسبة الحجز
  double get reservationRate => allocated > 0 ? (reserved / allocated) * 100 : 0;

  /// نسبة المتبقي
  double get remainingRate => allocated > 0 ? (remaining / allocated) * 100 : 0;

  /// التحقق من وجود أطفال
  bool get hasChildren => children.isNotEmpty;

  /// عدد الأطفال المباشرين
  int get childrenCount => children.length;

  /// العدد الإجمالي للعقد (شامل الأطفال والأحفاد)
  int get totalNodesCount {
    int count = 1; // العقدة الحالية
    for (final child in children) {
      count += child.totalNodesCount;
    }
    return count;
  }

  /// إنشاء نسخة مع تحديث القيم
  FundingReportNode copyWith({
    String? categoryName,
    double? allocated,
    double? reserved,
    double? spent,
    double? remaining,
    List<FundingReportNode>? children,
    int? categoryId,
    int? level,
  }) {
    return FundingReportNode(
      categoryName: categoryName ?? this.categoryName,
      allocated: allocated ?? this.allocated,
      reserved: reserved ?? this.reserved,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
      children: children ?? this.children,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
    );
  }

  @override
  String toString() {
    final indent = '  ' * level;
    return '${indent}FundingReportNode{name: $categoryName, allocated: $allocated, spent: $spent, children: ${children.length}}';
  }

  /// طباعة تمثيل شجري للعقدة والأطفال
  String toTreeString() {
    final buffer = StringBuffer();
    _buildTreeString(buffer, '', true);
    return buffer.toString();
  }

  void _buildTreeString(StringBuffer buffer, String prefix, bool isLast) {
    // رمز الاتصال
    final connector = isLast ? '└── ' : '├── ';
    
    // معلومات العقدة
    buffer.writeln('$prefix$connector$categoryName');
    buffer.writeln('$prefix${isLast ? "    " : "│   "}💰 المخصص: ${allocated.toStringAsFixed(2)}');
    buffer.writeln('$prefix${isLast ? "    " : "│   "}🔒 المحجوز: ${reserved.toStringAsFixed(2)}');
    buffer.writeln('$prefix${isLast ? "    " : "│   "}💸 المصروف: ${spent.toStringAsFixed(2)}');
    buffer.writeln('$prefix${isLast ? "    " : "│   "}💎 المتبقي: ${remaining.toStringAsFixed(2)}');
    
    if (children.isNotEmpty) {
      buffer.writeln('$prefix${isLast ? "    " : "│   "}📊 نسبة الاستغلال: ${utilizationRate.toStringAsFixed(1)}%');
    }

    // رسم الأطفال
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final childPrefix = prefix + (isLast ? '    ' : '│   ');
      final isLastChild = i == children.length - 1;
      
      if (i == 0) {
        buffer.writeln('$prefix${isLast ? "    " : "│   "}');
      }
      
      child._buildTreeString(buffer, childPrefix, isLastChild);
    }
  }
}

/// توليد تقرير التمويل الهرمي
/// 
/// [isar] مثيل قاعدة البيانات
/// [institutionId] معرف المؤسسة للتصفية (اختياري)
/// [year] السنة للتصفية (اختياري)
/// 
/// يرجع قائمة بالعقد الجذرية للهيكل الشجري
Future<List<FundingReportNode>> generateFundingReport(
  Isar isar, {
  int? institutionId,
  int? year,
}) async {
  try {
    print('🚀 بدء توليد التقرير الهرمي...');
    
    // الخطوة 1: جلب جميع سجلات التمويل
    List<InstitutionFunding> allFundings = await isar.institutionFundings.where().findAll();
    
    // تطبيق المرشحات
    if (institutionId != null) {
      allFundings = allFundings.where((f) => f.institutionId == institutionId).toList();
      print('🏥 مرشح المؤسسة: $institutionId (${allFundings.length} سجل)');
    }
    
    if (year != null) {
      allFundings = allFundings.where((f) => f.year == year).toList();
      print('📅 مرشح السنة: $year (${allFundings.length} سجل)');
    }

    print('📋 إجمالي سجلات التمويل: ${allFundings.length}');

    // الخطوة 2: جلب جميع الفئات التمويلية
    final allCategories = await isar.fundingCategorys.where().findAll();
    print('💰 إجمالي الفئات التمويلية: ${allCategories.length}');

    // إنشاء خريطة للوصول السريع للفئات
    final categoryMap = <int, FundingCategory>{};
    for (final category in allCategories) {
      categoryMap[category.id] = category;
    }

    // الخطوة 3: تجميع البيانات حسب الفئة
    final categoryData = <int, _CategoryData>{};
    
    for (final funding in allFundings) {
      final categoryId = funding.categoryId;
      
      if (categoryData.containsKey(categoryId)) {
        // إضافة إلى البيانات الموجودة
        final existing = categoryData[categoryId]!;
        categoryData[categoryId] = existing.copyWith(
          allocated: existing.allocated + funding.allocatedAmount,
          reserved: existing.reserved + funding.reservedAmount,
          spent: existing.spent + funding.spentAmount,
          remaining: existing.remaining + funding.remainingAmount,
        );
      } else {
        // إنشاء بيانات جديدة
        categoryData[categoryId] = _CategoryData(
          categoryId: categoryId,
          allocated: funding.allocatedAmount,
          reserved: funding.reservedAmount,
          spent: funding.spentAmount,
          remaining: funding.remainingAmount,
        );
      }
    }

    print('📊 تم تجميع البيانات لـ ${categoryData.length} فئة');

    // الخطوة 4: بناء الهيكل الشجري
    final rootNodes = <FundingReportNode>[];
    final processedCategories = <int>{};

    // العثور على الفئات الجذرية (بدون parentId)
    final rootCategories = allCategories.where((cat) => cat.parentId == null).toList();
    print('🌳 الفئات الجذرية: ${rootCategories.length}');

    for (final rootCategory in rootCategories) {
      final node = await _buildCategoryNode(
        rootCategory,
        categoryData,
        categoryMap,
        allCategories,
        processedCategories,
        0, // مستوى الجذر
      );
      
      if (node != null) {
        rootNodes.add(node);
        print('✅ تم بناء عقدة جذرية: ${rootCategory.name}');
      }
    }

    // التحقق من وجود فئات غير مرتبطة (orphaned)
    final orphanedCategories = categoryData.keys.where((id) => !processedCategories.contains(id)).toList();
    if (orphanedCategories.isNotEmpty) {
      print('⚠️ فئات غير مرتبطة: ${orphanedCategories.length}');
      
      for (final orphanId in orphanedCategories) {
        final category = categoryMap[orphanId];
        if (category != null) {
          final data = categoryData[orphanId]!;
          final orphanNode = FundingReportNode(
            categoryName: '${category.name} (غير مرتبط)',
            allocated: data.allocated,
            reserved: data.reserved,
            spent: data.spent,
            remaining: data.remaining,
            children: [],
            categoryId: category.id,
            level: 0,
          );
          rootNodes.add(orphanNode);
          processedCategories.add(orphanId);
        }
      }
    }

    print('🎉 تم توليد التقرير بنجاح! العقد الجذرية: ${rootNodes.length}');
    
    // طباعة ملخص
    _printReportSummary(rootNodes);
    
    return rootNodes;

  } catch (e) {
    print('❌ خطأ في توليد التقرير: $e');
    return [];
  }
}

/// بناء عقدة فئة مع أطفالها بشكل تكراري
Future<FundingReportNode?> _buildCategoryNode(
  FundingCategory category,
  Map<int, _CategoryData> categoryData,
  Map<int, FundingCategory> categoryMap,
  List<FundingCategory> allCategories,
  Set<int> processedCategories,
  int level,
) async {
  // تجنب المعالجة المكررة
  if (processedCategories.contains(category.id)) {
    return null;
  }

  // العثور على الفئات الفرعية
  final childCategories = allCategories
      .where((cat) => cat.parentId == category.id)
      .toList();

  // بناء عقد الأطفال
  final childNodes = <FundingReportNode>[];
  for (final childCategory in childCategories) {
    final childNode = await _buildCategoryNode(
      childCategory,
      categoryData,
      categoryMap,
      allCategories,
      processedCategories,
      level + 1,
    );
    
    if (childNode != null) {
      childNodes.add(childNode);
    }
  }

  // حساب القيم للعقدة الحالية
  double allocated = 0;
  double reserved = 0;
  double spent = 0;
  double remaining = 0;

  // إضافة البيانات المباشرة للفئة (إن وجدت)
  if (categoryData.containsKey(category.id)) {
    final directData = categoryData[category.id]!;
    allocated += directData.allocated;
    reserved += directData.reserved;
    spent += directData.spent;
    remaining += directData.remaining;
  }

  // إضافة قيم الأطفال (تجميع هرمي)
  for (final child in childNodes) {
    allocated += child.allocated;
    reserved += child.reserved;
    spent += child.spent;
    remaining += child.remaining;
  }

  // إنشاء العقدة
  final node = FundingReportNode(
    categoryName: category.name,
    allocated: allocated,
    reserved: reserved,
    spent: spent,
    remaining: remaining,
    children: childNodes,
    categoryId: category.id,
    level: level,
  );

  // تسجيل المعالجة
  processedCategories.add(category.id);
  
  return node;
}

/// طباعة ملخص التقرير
void _printReportSummary(List<FundingReportNode> rootNodes) {
  if (rootNodes.isEmpty) {
    print('📊 التقرير فارغ - لا توجد بيانات');
    return;
  }

  print('\n📊 ═══════════════════════════════════════');
  print('📊 ملخص التقرير الهرمي');
  print('📊 ═══════════════════════════════════════');

  double totalAllocated = 0;
  double totalReserved = 0;
  double totalSpent = 0;
  double totalRemaining = 0;
  int totalNodes = 0;

  for (final node in rootNodes) {
    totalAllocated += node.allocated;
    totalReserved += node.reserved;
    totalSpent += node.spent;
    totalRemaining += node.remaining;
    totalNodes += node.totalNodesCount;
  }

  print('🌳 عدد الفئات الجذرية: ${rootNodes.length}');
  print('📊 إجمالي العقد: $totalNodes');
  print('💰 إجمالي المخصص: ${totalAllocated.toStringAsFixed(2)}');
  print('🔒 إجمالي المحجوز: ${totalReserved.toStringAsFixed(2)}');
  print('💸 إجمالي المصروف: ${totalSpent.toStringAsFixed(2)}');
  print('💎 إجمالي المتبقي: ${totalRemaining.toStringAsFixed(2)}');

  if (totalAllocated > 0) {
    final utilizationRate = (totalSpent / totalAllocated) * 100;
    final reservationRate = (totalReserved / totalAllocated) * 100;
    print('📈 نسبة الاستغلال الإجمالية: ${utilizationRate.toStringAsFixed(1)}%');
    print('🔒 نسبة الحجز الإجمالية: ${reservationRate.toStringAsFixed(1)}%');
  }

  print('📊 ═══════════════════════════════════════\n');
}

/// طباعة التقرير بشكل شجري مفصل
void printDetailedFundingReport(List<FundingReportNode> rootNodes) {
  print('\n🌳 ═══════════════════════════════════════');
  print('🌳 التقرير الهرمي المفصل');
  print('🌳 ═══════════════════════════════════════');

  if (rootNodes.isEmpty) {
    print('📊 لا توجد بيانات للعرض');
    return;
  }

  for (int i = 0; i < rootNodes.length; i++) {
    final node = rootNodes[i];
    print('\n${i + 1}. ${node.toTreeString()}');
    
    if (i < rootNodes.length - 1) {
      print('${'─' * 50}');
    }
  }

  print('🌳 ═══════════════════════════════════════\n');
}

/// البحث في التقرير عن فئة معينة
FundingReportNode? findNodeInReport(List<FundingReportNode> rootNodes, String categoryName) {
  for (final node in rootNodes) {
    final found = _searchNodeRecursive(node, categoryName);
    if (found != null) {
      return found;
    }
  }
  return null;
}

FundingReportNode? _searchNodeRecursive(FundingReportNode node, String categoryName) {
  if (node.categoryName.toLowerCase().contains(categoryName.toLowerCase())) {
    return node;
  }
  
  for (final child in node.children) {
    final found = _searchNodeRecursive(child, categoryName);
    if (found != null) {
      return found;
    }
  }
  
  return null;
}

/// تصدير التقرير إلى JSON
Map<String, dynamic> exportReportToJson(List<FundingReportNode> rootNodes) {
  return {
    'reportGeneratedAt': DateTime.now().toIso8601String(),
    'totalRootNodes': rootNodes.length,
    'totalNodes': rootNodes.fold(0, (sum, node) => sum + node.totalNodesCount),
    'summary': {
      'totalAllocated': rootNodes.fold(0.0, (sum, node) => sum + node.allocated),
      'totalReserved': rootNodes.fold(0.0, (sum, node) => sum + node.reserved),
      'totalSpent': rootNodes.fold(0.0, (sum, node) => sum + node.spent),
      'totalRemaining': rootNodes.fold(0.0, (sum, node) => sum + node.remaining),
    },
    'categories': rootNodes.map((node) => _nodeToJson(node)).toList(),
  };
}

Map<String, dynamic> _nodeToJson(FundingReportNode node) {
  return {
    'categoryId': node.categoryId,
    'categoryName': node.categoryName,
    'level': node.level,
    'allocated': node.allocated,
    'reserved': node.reserved,
    'spent': node.spent,
    'remaining': node.remaining,
    'utilizationRate': node.utilizationRate,
    'reservationRate': node.reservationRate,
    'hasChildren': node.hasChildren,
    'childrenCount': node.childrenCount,
    'children': node.children.map((child) => _nodeToJson(child)).toList(),
  };
}

/// فلترة التقرير حسب معايير معينة
List<FundingReportNode> filterReport(
  List<FundingReportNode> rootNodes, {
  double? minAllocated,
  double? minUtilizationRate,
  bool showOnlyWithFunding = false,
}) {
  return rootNodes.where((node) {
    // فلتر المبلغ المخصص الأدنى
    if (minAllocated != null && node.allocated < minAllocated) {
      return false;
    }
    
    // فلتر نسبة الاستغلال الأدنى
    if (minUtilizationRate != null && node.utilizationRate < minUtilizationRate) {
      return false;
    }
    
    // فلتر عرض الفئات التي لها تمويل فقط
    if (showOnlyWithFunding && node.allocated == 0) {
      return false;
    }
    
    return true;
  }).toList();
}

/// كلاس مساعد لتجميع بيانات الفئة
class _CategoryData {
  final int categoryId;
  final double allocated;
  final double reserved;
  final double spent;
  final double remaining;

  _CategoryData({
    required this.categoryId,
    required this.allocated,
    required this.reserved,
    required this.spent,
    required this.remaining,
  });

  _CategoryData copyWith({
    int? categoryId,
    double? allocated,
    double? reserved,
    double? spent,
    double? remaining,
  }) {
    return _CategoryData(
      categoryId: categoryId ?? this.categoryId,
      allocated: allocated ?? this.allocated,
      reserved: reserved ?? this.reserved,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
    );
  }
}