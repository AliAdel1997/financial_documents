# FundingService - خدمة إدارة المدفوعات والصرف

خدمة متقدمة للتحقق من المبالغ المحجوزة وتنفيذ عمليات الصرف مع ضمان سلامة البيانات المالية.

## 🎯 الوظيفة الأساسية المطلوبة

### validateAndSpend
التحقق من المبلغ المحجوز وتنفيذ عملية الصرف مع التحديث التلقائي للأرصدة.

```dart
Future<bool> validateAndSpend(
  Isar isar,
  int fundingId,
  double amount, {
  String? description,
}) async
```

**الخطوات المُطبقة:**
1. ✅ جلب سجل `InstitutionFunding` بالمعرف المطلوب
2. ✅ التحقق من أن `reservedAmount ≥ amount`
3. ✅ إذا تحقق الشرط:
   - خصم المبلغ من `reservedAmount`
   - إضافة المبلغ إلى `spentAmount`
   - تحديث `remainingAmount` تلقائياً
   - حفظ التغييرات في قاعدة البيانات
4. ✅ إرجاع `false` في حالة فشل الشرط

## 🔧 الوظائف الإضافية

### reserveFunds - حجز الأموال
```dart
await FundingService.reserveFunds(
  isar,
  fundingId,
  150000.0,
  description: 'حجز لشراء أجهزة طبية',
);
```

**المميزات:**
- ✅ التحقق من توفر المبلغ في المخصص
- ✅ حجز المبلغ من المتاح
- ✅ تحديث `reservedAmount` تلقائياً

### unreserveFunds - إلغاء الحجز
```dart
await FundingService.unreserveFunds(
  isar,
  fundingId,
  30000.0,
  description: 'إلغاء حجز - تغيير في الخطة',
);
```

**المميزات:**
- ✅ التحقق من وجود المبلغ في المحجوز
- ✅ إرجاع المبلغ إلى المتاح
- ✅ تحديث `reservedAmount` تلقائياً

### getFundingDetails - تفاصيل محسوبة
```dart
final details = await FundingService.getFundingDetails(isar, fundingId);
print('المتاح للحجز: ${details?.availableAmount}');
print('نسبة الاستغلال: ${details?.utilizationRate}%');
```

### printFundingReport - تقرير مفصل
```dart
await FundingService.printFundingReport(isar, fundingId);
```

## 📊 مثال عملي شامل

```dart
import 'package:financial_documents/services/funding_service.dart';
import 'package:financial_documents/services/database_service.dart';

void main() async {
  // تهيئة قاعدة البيانات
  await DatabaseService.initialize();
  final isar = DatabaseService.isar;
  
  final fundingId = 1; // معرف سجل التمويل
  
  // 1. عرض الحالة الأولية
  await FundingService.printFundingReport(isar, fundingId);
  
  // 2. حجز مبلغ للمشتريات
  print('🔒 حجز مبلغ 200,000 للأجهزة الطبية');
  await FundingService.reserveFunds(
    isar,
    fundingId,
    200000.0,
    description: 'حجز لشراء جهاز أشعة مقطعية',
  );
  
  // 3. صرف دفعة أولى
  print('💸 صرف دفعة أولى 150,000');
  bool success = await FundingService.validateAndSpend(
    isar,
    fundingId,
    150000.0,
    description: 'الدفعة الأولى للجهاز',
  );
  
  if (success) {
    print('✅ تم الصرف بنجاح');
  }
  
  // 4. إلغاء حجز جزء (توفير في السعر)
  print('🔓 إلغاء حجز 30,000 (توفير)');
  await FundingService.unreserveFunds(
    isar,
    fundingId,
    30000.0,
    description: 'توفير في سعر الجهاز',
  );
  
  // 5. صرف المبلغ المتبقي
  print('💸 صرف المبلغ المتبقي');
  await FundingService.validateAndSpend(
    isar,
    fundingId,
    20000.0,
    description: 'المبلغ المتبقي للجهاز',
  );
  
  // 6. عرض التقرير النهائي
  await FundingService.printFundingReport(isar, fundingId);
}
```

## 🛡️ التحقق من الأخطاء

### الأخطاء المُتعامل معها:
- ❌ **سجل غير موجود**: التحقق من وجود `fundingId`
- ❌ **مبلغ سالب أو صفر**: التحقق من صحة المبلغ
- ❌ **مبلغ يتجاوز المحجوز**: للصرف
- ❌ **مبلغ يتجاوز المتاح**: للحجز
- ❌ **أخطاء قاعدة البيانات**: معالجة استثناءات Isar

### مثال على معالجة الأخطاء:
```dart
// محاولة صرف مبلغ أكبر من المحجوز
bool success = await FundingService.validateAndSpend(
  isar,
  fundingId,
  999999.0, // مبلغ مفرط
  description: 'محاولة صرف مفرط',
);

if (!success) {
  print('❌ فشل الصرف - المبلغ يتجاوز المحجوز');
}
```

## 📱 التطبيق العملي

### سيناريو مستشفى واقعي:
```dart
// تشغيل سيناريو مستشفى كامل
await FundingServiceExamples.hospitalScenarioExample();
```

**السيناريو يتضمن:**
1. 🏥 إنشاء مستشفى مع ميزانية
2. 📱 حجز للأجهزة الطبية
3. 💊 حجز للأدوية
4. 💰 صرف مرحلي للمشتريات
5. 🔄 تعديل الحجوزات حسب الحاجة
6. 📊 تقرير نهائي شامل

### الشاشة التفاعلية:
```dart
// استخدام شاشة الاختبار التفاعلية
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FundingServiceTestScreen(),
  ),
);
```

## 🔄 دورة حياة العمليات المالية

### 1. التخطيط والتخصيص
```dart
// تخصيص مبلغ للمؤسسة من الباب التمويلي
await FundingManager.allocateFundsToInstitution(
  institutionId: 1,
  categoryId: 2,
  amount: 500000.0,
);
```

### 2. الحجز للمشاريع
```dart
// حجز مبلغ لمشروع محدد
await FundingService.reserveFunds(
  isar,
  fundingId,
  200000.0,
  description: 'حجز لمشروع التطوير',
);
```

### 3. التنفيذ والصرف
```dart
// صرف مراحل حسب التقدم
await FundingService.validateAndSpend(
  isar,
  fundingId,
  100000.0,
  description: 'المرحلة الأولى من المشروع',
);
```

### 4. التعديل والمرونة
```dart
// إلغاء حجز في حالة التوفير
await FundingService.unreserveFunds(
  isar,
  fundingId,
  50000.0,
  description: 'توفير في التكاليف',
);
```

## 📊 التقارير والتحليل

### كلاس FundingDetails
```dart
class FundingDetails {
  final InstitutionFunding funding;        // السجل الأساسي
  final String institutionName;            // اسم المؤسسة
  final String categoryName;               // اسم الباب التمويلي
  final double availableAmount;            // المتاح للحجز
  final double utilizationRate;            // نسبة الاستغلال %
  final double reservationRate;            // نسبة الحجز %
}
```

### الحسابات التلقائية:
```dart
// المتاح للحجز
availableAmount = allocatedAmount - reservedAmount - spentAmount

// نسبة الاستغلال
utilizationRate = (spentAmount / allocatedAmount) * 100

// نسبة الحجز
reservationRate = (reservedAmount / allocatedAmount) * 100

// المبلغ المتبقي
remainingAmount = allocatedAmount - reservedAmount - spentAmount
```

## 🔍 دوال التحقق السريع

### التحقق من إمكانية الصرف
```dart
bool canSpend = await FundingService.canSpend(isar, fundingId, 50000.0);
if (canSpend) {
  print('✅ يمكن صرف المبلغ');
} else {
  print('❌ لا يمكن صرف المبلغ');
}
```

### التحقق من إمكانية الحجز
```dart
bool canReserve = await FundingService.canReserve(isar, fundingId, 75000.0);
if (canReserve) {
  print('✅ يمكن حجز المبلغ');
} else {
  print('❌ لا يمكن حجز المبلغ');
}
```

## 🏗️ التكامل مع النظام

### مع FundingManager:
```dart
// 1. إنشاء الهيكل بواسطة FundingManager
await FundingManager.addFundingCategory('الأجهزة الطبية');
await FundingManager.allocateFundsToInstitution(1, 2, 500000.0);

// 2. إدارة العمليات بواسطة FundingService
await FundingService.reserveFunds(isar, fundingId, 200000.0);
await FundingService.validateAndSpend(isar, fundingId, 150000.0);
```

### مع DatabaseService:
```dart
// الحصول على السجلات
final fundings = await DatabaseService.getAllInstitutionFunding();

// العمل مع FundingService
for (final funding in fundings) {
  final details = await FundingService.getFundingDetails(isar, funding.id);
  if (details != null) {
    print('المؤسسة: ${details.institutionName}');
    print('نسبة الاستغلال: ${details.utilizationRate}%');
  }
}
```

## 🚀 الاستخدام السريع

### للبدء الفوري:
```dart
import 'package:financial_documents/services/funding_service_examples.dart';

// مثال سريع
await FundingServiceExamples.quickExample();

// أو مثال شامل
await FundingServiceExamples.runCompleteExample();
```

### للاختبار التفاعلي:
قم بتشغيل `FundingServiceTestScreen` لاختبار جميع الوظائف بشكل تفاعلي.

## 📈 المميزات المتقدمة

- ✅ **معاملات آمنة**: جميع العمليات تتم داخل `writeTxn`
- ✅ **تحقق شامل**: فحص جميع الحالات المحتملة
- ✅ **تسجيل مفصل**: لوجز واضحة لكل عملية
- ✅ **مرونة في الاستخدام**: دعم الوصف الاختياري
- ✅ **حسابات تلقائية**: جميع المبالغ تُحدث تلقائياً
- ✅ **تقارير غنية**: معلومات مفصلة وسهلة القراءة
- ✅ **معالجة الأخطاء**: رسائل واضحة ومفيدة

جاهز للاستخدام في بيئة الإنتاج! 🎯