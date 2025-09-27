# FundingManager - مدير التمويل المتقدم

كلاس متطور لإدارة العمليات المالية والتوزيع الهرمي للأموال في نظام إدارة المستشفيات.

## 🎯 الوظائف الأساسية

### 1️⃣ addFundingCategory
إضافة باب تمويلي جديد (رئيسي أو فرعي) مع التحقق من صحة البيانات.

```dart
// إضافة باب رئيسي
final categoryId = await FundingManager.addFundingCategory(
  'باب الرواتب والأجور',
  allocatedAmount: 5000000.0,
);

// إضافة باب فرعي
final subCategoryId = await FundingManager.addFundingCategory(
  'رواتب الأطباء',
  parentId: categoryId,
  allocatedAmount: 3000000.0,
);
```

**المميزات:**
- ✅ التحقق من صحة البيانات (اسم غير فارغ، مبلغ موجب)
- ✅ التحقق من وجود الباب الأعلى
- ✅ منع تكرار الأسماء في نفس المستوى
- ✅ تحديث تلقائي للباب الأعلى عند إضافة باب فرعي

### 2️⃣ allocateFundsToInstitution
تخصيص مبلغ معين لمؤسسة ضمن باب محدد مع التحقق من توفر الأموال.

```dart
// تخصيص 800,000 لمستشفى بغداد من باب الرواتب
await FundingManager.allocateFundsToInstitution(
  institutionId: 1,
  categoryId: 2,
  amount: 800000.0,
  year: 2025,        // اختياري - افتراضي السنة الحالية
  month: 10,         // اختياري - افتراضي الشهر الحالي
);
```

**المميزات:**
- ✅ التحقق من وجود المؤسسة والباب التمويلي
- ✅ التحقق من توفر المبلغ في الباب
- ✅ دعم التخصيص التراكمي (إضافة مبالغ جديدة للمبلغ الموجود)
- ✅ إنشاء تمويل جديد أو تحديث الموجود تلقائياً

### 3️⃣ distributeFundsHierarchically
توزيع الأموال تلقائياً على الأبواب الفرعية بطرق متعددة.

```dart
// التوزيع بالتساوي
await FundingManager.distributeFundsHierarchically(
  categoryId,
  distributionType: DistributionType.equal,
  totalAmount: 1000000.0,
);

// التوزيع النسبي حسب المخصصات الحالية
await FundingManager.distributeFundsHierarchically(
  categoryId,
  distributionType: DistributionType.proportional,
);

// التوزيع حسب الأولوية (الأقل مخصصاً يحصل على أكثر)
await FundingManager.distributeFundsHierarchically(
  categoryId,
  distributionType: DistributionType.priority,
);
```

**أنواع التوزيع:**
- 🟰 **equal**: بالتساوي على جميع الأبواب الفرعية
- 📊 **proportional**: حسب النسب الحالية للمخصصات
- 🎯 **priority**: الأبواب ذات المخصصات الأقل تحصل على أولوية أكبر

## 🔧 الوظائف المساعدة

### تقارير المؤسسات
```dart
// ملخص تمويل مؤسسة لسنة معينة
final summary = await FundingManager.getInstitutionFundingSummary(
  institutionId: 1,
  year: 2025,
);

print('إجمالي المخصص: ${summary.totalAllocated}');
print('إجمالي المصروف: ${summary.totalSpent}');
print('نسبة الاستغلال: ${summary.utilizationRate}%');
```

### تقارير الأبواب التمويلية
```dart
// ملخص باب تمويلي لسنة معينة
final summary = await FundingManager.getCategoryFundingSummary(
  categoryId: 1,
  year: 2025,
);

print('الميزانية الكلية: ${summary.totalBudget}');
print('المخصص للمؤسسات: ${summary.totalAllocated}');
print('المتبقي من الميزانية: ${summary.remainingBudget}');
```

### التقرير الشامل
```dart
// تقرير شامل للتمويل
await FundingManager.generateComprehensiveReport(year: 2025);
```

## 📊 أمثلة عملية

### الاستخدام الكامل
```dart
import 'package:financial_documents/services/funding_manager_examples.dart';

// تشغيل مثال شامل على جميع الوظائف
await FundingManagerExamples.runCompleteExample();
```

### الاستخدام السريع
```dart
// مثال سريع للاختبار
await FundingManagerExamples.quickExample();
```

### اختبار حالات الخطأ
```dart
// اختبار معالجة الأخطاء
await FundingManagerExamples.testErrorCases();
```

## 🏗️ البنية والتصميم

### الكلاسات المساعدة

#### FundingSummary
ملخص تمويل المؤسسة:
```dart
class FundingSummary {
  final String institutionName;
  final int year;
  final double totalAllocated;     // إجمالي المخصص
  final double totalReserved;      // إجمالي المحجوز
  final double totalSpent;         // إجمالي المصروف
  final double totalRemaining;     // إجمالي المتبقي
  final double utilizationRate;    // نسبة الاستغلال
  final int fundingCount;          // عدد التمويلات
}
```

#### CategoryFundingSummary
ملخص الباب التمويلي:
```dart
class CategoryFundingSummary {
  final String categoryName;
  final int year;
  final double totalBudget;        // الميزانية الكلية
  final double totalAllocated;     // المخصص للمؤسسات
  final double totalSpent;         // إجمالي المصروف
  final double remainingBudget;    // المتبقي من الميزانية
  final double utilizationRate;    // نسبة الاستغلال
  final int institutionCount;      // عدد المؤسسات المستفيدة
}
```

#### DistributionType (Enum)
أنواع التوزيع المتاحة:
```dart
enum DistributionType {
  equal,        // بالتساوي
  proportional, // حسب النسبة الحالية
  priority,     // حسب الأولوية
}
```

## 🛡️ التحقق من الأخطاء

### addFundingCategory
- ❌ اسم فارغ أو null
- ❌ مبلغ سالب
- ❌ باب أعلى غير موجود
- ❌ تكرار الاسم في نفس المستوى

### allocateFundsToInstitution
- ❌ مبلغ صفر أو سالب
- ❌ مؤسسة غير موجودة
- ❌ باب تمويلي غير موجود
- ❌ مبلغ يتجاوز المتاح في الباب

### distributeFundsHierarchically
- ❌ باب رئيسي غير موجود
- ❌ عدم وجود أبواب فرعية
- ❌ مبلغ صفر أو سالب للتوزيع

## 📈 مؤشرات الأداء

### نسبة الاستغلال
```dart
utilizationRate = (totalSpent / totalAllocated) * 100
```

### المبلغ المتبقي
```dart
remainingAmount = allocatedAmount - reservedAmount - spentAmount
```

### المتبقي من الميزانية
```dart
remainingBudget = totalBudget - totalAllocated
```

## 🔄 تسلسل العمليات المثلى

### 1. إعداد الهيكل التمويلي
```dart
// إنشاء الأبواب الرئيسية
final salariesId = await FundingManager.addFundingCategory('الرواتب', allocatedAmount: 5000000);
final suppliesId = await FundingManager.addFundingCategory('المستلزمات', allocatedAmount: 3000000);

// إنشاء الأبواب الفرعية
await FundingManager.addFundingCategory('رواتب الأطباء', parentId: salariesId);
await FundingManager.addFundingCategory('رواتب الممرضين', parentId: salariesId);
```

### 2. توزيع الميزانيات
```dart
// توزيع ميزانية الباب الرئيسي على الأبواب الفرعية
await FundingManager.distributeFundsHierarchically(
  salariesId,
  distributionType: DistributionType.proportional,
);
```

### 3. تخصيص الأموال للمؤسسات
```dart
// تخصيص من الأبواب الفرعية للمؤسسات
await FundingManager.allocateFundsToInstitution(hospitalId, doctorSalariesId, 800000);
await FundingManager.allocateFundsToInstitution(hospitalId, nurseSalariesId, 600000);
```

### 4. المتابعة والتقارير
```dart
// توليد التقارير الدورية
await FundingManager.generateComprehensiveReport();

// متابعة أداء المؤسسات
final summary = await FundingManager.getInstitutionFundingSummary(hospitalId, 2025);
```

## 🚀 التطويرات المستقبلية

### المخطط للإضافة:
- 📊 تصدير التقارير إلى Excel/PDF
- 📈 رسوم بيانية للاستغلال
- ⏰ تنبيهات انتهاء الميزانيات
- 🔐 صلاحيات المستخدمين للعمليات
- 📅 تخطيط الميزانيات للسنوات القادمة
- 🔄 تتبع تاريخ التغييرات (Audit Trail)

### التحسينات الممكنة:
- ⚡ تحسين الأداء للتقارير الكبيرة
- 🎯 خوارزميات توزيع أكثر تطوراً
- 📱 واجهات مستخدم تفاعلية
- 🌐 دعم العملات المتعددة