# نماذج التمويل - Funding Models

تم إضافة ثلاثة نماذج جديدة لإدارة نظام التمويل في التطبيق:

## 📊 النماذج المضافة

### 1️⃣ FundingCategory (الأبواب التمويلية)
يمثل الأبواب الرئيسية والفرعية للتمويل.

**الحقول:**
- `id`: المعرف الفريد (تلقائي)
- `name`: اسم الباب التمويلي
- `parentId`: معرف الباب الأعلى (null للأبواب الرئيسية)
- `allocatedAmount`: المبلغ المخصص للباب
- `createdAt`: تاريخ الإنشاء
- `updatedAt`: تاريخ آخر تحديث

**مثال:**
```dart
final category = FundingCategory()
  ..name = 'باب الرواتب والأجور'
  ..allocatedAmount = 1000000.0
  ..createdAt = DateTime.now()
  ..updatedAt = DateTime.now();

await DatabaseService.addFundingCategory(category);
```

### 2️⃣ Institution (المؤسسات)
يمثل المستشفيات والمؤسسات الصحية.

**الحقول:**
- `id`: المعرف الفريد (تلقائي)
- `name`: اسم المؤسسة
- `address`: العنوان (اختياري)
- `code`: كود المؤسسة (اختياري)

**مثال:**
```dart
final institution = Institution()
  ..name = 'مستشفى بغداد التعليمي'
  ..address = 'بغداد - الرصافة'
  ..code = 'BGH001';

await DatabaseService.addInstitution(institution);
```

### 3️⃣ InstitutionFunding (تمويل المؤسسات)
يربط بين المؤسسة والباب التمويلي مع تفاصيل المبالغ.

**الحقول:**
- `id`: المعرف الفريد (تلقائي)
- `institutionId`: معرف المؤسسة
- `categoryId`: معرف الباب التمويلي
- `allocatedAmount`: المبلغ المخصص
- `reservedAmount`: المبلغ المحجوز
- `spentAmount`: المبلغ المصروف
- `year`: السنة
- `month`: الشهر
- `createdAt`: تاريخ الإنشاء
- `updatedAt`: تاريخ آخر تحديث

**الخاصيات المحسوبة:**
- `remainingAmount`: المبلغ المتبقي (محسوب تلقائياً)

**مثال:**
```dart
final funding = InstitutionFunding()
  ..institutionId = 1
  ..categoryId = 1
  ..allocatedAmount = 200000.0
  ..reservedAmount = 50000.0
  ..spentAmount = 100000.0
  ..year = 2025
  ..month = 10
  ..createdAt = DateTime.now()
  ..updatedAt = DateTime.now();

await DatabaseService.addInstitutionFunding(funding);

// المبلغ المتبقي = 200000 - 50000 - 100000 = 50000
print('المبلغ المتبقي: ${funding.remainingAmount}');
```

## 🔧 الخدمات المتوفرة

### DatabaseService - دوال الأبواب التمويلية
```dart
// إضافة باب تمويلي
await DatabaseService.addFundingCategory(category);

// الحصول على جميع الأبواب
final categories = await DatabaseService.getAllFundingCategories();

// الحصول على الأبواب الرئيسية فقط
final mainCategories = await DatabaseService.getMainFundingCategories();

// الحصول على الأبواب الفرعية
final subCategories = await DatabaseService.getSubFundingCategories(parentId);

// البحث في الأبواب
final results = await DatabaseService.searchFundingCategories('رواتب');
```

### DatabaseService - دوال المؤسسات
```dart
// إضافة مؤسسة
await DatabaseService.addInstitution(institution);

// الحصول على جميع المؤسسات
final institutions = await DatabaseService.getAllInstitutions();

// البحث في المؤسسات
final results = await DatabaseService.searchInstitutions('مستشفى');

// الحصول على مؤسسة بالكود
final institution = await DatabaseService.getInstitutionByCode('BGH001');
```

### DatabaseService - دوال التمويل
```dart
// إضافة تمويل
await DatabaseService.addInstitutionFunding(funding);

// الحصول على تمويلات مؤسسة معينة
final fundings = await DatabaseService.getInstitutionFundingByInstitution(institutionId);

// الحصول على تمويلات باب معين
final fundings = await DatabaseService.getInstitutionFundingByCategory(categoryId);

// الحصول على تمويلات سنة معينة
final fundings = await DatabaseService.getInstitutionFundingByYear(2025);

// حساب إجمالي المبالغ
final totalAllocated = await DatabaseService.getTotalAllocatedAmountForInstitution(institutionId, year);
final totalSpent = await DatabaseService.getTotalSpentAmountForInstitution(institutionId, year);
```

## 📱 استخدام Provider

### إعداد Provider
```dart
// في main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FundingProvider()),
    // مقدمي الخدمة الآخرين...
  ],
  child: MyApp(),
)
```

### استخدام Provider في Widget
```dart
class FundingScreen extends StatefulWidget {
  @override
  _FundingScreenState createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FundingProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FundingProvider>(
      builder: (context, fundingProvider, child) {
        if (fundingProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (fundingProvider.errorMessage != null) {
          return Center(child: Text('خطأ: ${fundingProvider.errorMessage}'));
        }

        return ListView.builder(
          itemCount: fundingProvider.institutions.length,
          itemBuilder: (context, index) {
            final institution = fundingProvider.institutions[index];
            return ListTile(
              title: Text(institution.name),
              subtitle: Text(institution.code ?? ''),
              onTap: () {
                // عرض تفاصيل المؤسسة
              },
            );
          },
        );
      },
    );
  }
}
```

## 🎯 أمثلة عملية

### إنشاء بيانات تجريبية
```dart
import 'package:financial_documents/services/funding_examples.dart';

// إنشاء جميع البيانات التجريبية
await FundingExamples.createAllSampleData();

// عرض ملخص البيانات
await FundingExamples.displayDataSummary();

// أمثلة على البحث والتصفية
await FundingExamples.searchAndFilterExample();
```

### تصفية البيانات
```dart
final fundingProvider = context.read<FundingProvider>();

// تحديد فلتر السنة
fundingProvider.setSelectedYear(2025);

// تحديد فلتر المؤسسة
fundingProvider.setSelectedInstitution(1);

// الحصول على البيانات المفلترة
final filteredFundings = fundingProvider.filteredFundings;

// حساب الإجماليات للبيانات المفلترة
final totalAllocated = fundingProvider.getTotalAllocatedAmount();
final totalSpent = fundingProvider.getTotalSpentAmount();
final totalRemaining = fundingProvider.getTotalRemainingAmount();
```

### إضافة بيانات جديدة
```dart
final fundingProvider = context.read<FundingProvider>();

// إضافة مؤسسة جديدة
final newInstitution = Institution()
  ..name = 'مستشفى جديد'
  ..address = 'العنوان'
  ..code = 'NEW001';

final success = await fundingProvider.addInstitution(newInstitution);
if (success) {
  print('تم إضافة المؤسسة بنجاح');
} else {
  print('خطأ: ${fundingProvider.errorMessage}');
}
```

## 🏗️ بنية قاعدة البيانات

تستخدم النماذج قاعدة بيانات Isar مع الفهارس التالية:

### FundingCategory
- فهرس على `name` للبحث السريع
- فهرس على `allocatedAmount` للترتيب

### Institution
- فهرس على `name` للبحث السريع
- فهرس على `code` للعثور السريع بالكود

### InstitutionFunding
- فهرس على `institutionId` للبحث بالمؤسسة
- فهرس على `categoryId` للبحث بالباب
- فهرس على `year` للبحث بالسنة
- فهرس على `month` للبحث بالشهر

## 🔄 تشغيل Build Runner

بعد أي تعديل على النماذج، يجب تشغيل:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📝 ملاحظات مهمة

1. **المبلغ المتبقي**: يتم حسابه تلقائياً ولا يُحفظ في قاعدة البيانات
2. **العلاقات**: تتم إدارة العلاقات عبر المعرفات (Foreign Keys)
3. **التواريخ**: يتم تحديث `updatedAt` تلقائياً عند التعديل
4. **الفهارس**: تم إضافة فهارس لتحسين الأداء
5. **التحقق**: يجب التحقق من وجود البيانات قبل الربط

## 🚀 الخطوات القادمة

1. إنشاء واجهات المستخدم للإدارة
2. إضافة تقارير مفصلة
3. تصدير البيانات إلى Excel
4. إضافة رسوم بيانية
5. تطبيق صلاحيات المستخدمين