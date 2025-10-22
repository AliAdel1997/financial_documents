import 'package:flutter/material.dart';
import 'funding_category_screen.dart';
import 'funding_allocation_screen.dart';
import 'reservation_screen.dart';
import 'expense_screen.dart';
import 'reports_screen.dart';

/// الشاشة الرئيسية للنظام الهرمي للتمويل
class HierarchicalFundingMainScreen extends StatefulWidget {
  const HierarchicalFundingMainScreen({super.key});

  @override
  State<HierarchicalFundingMainScreen> createState() =>
      _HierarchicalFundingMainScreenState();
}

class _HierarchicalFundingMainScreenState
    extends State<HierarchicalFundingMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FundingCategoryScreen(),
    const FundingAllocationScreen(),
    const ReservationScreen(),
    const ExpenseScreen(),
    const ReportsScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_tree),
      label: 'إدارة الأبواب',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.attach_money),
      label: 'تخصيص التمويل',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bookmark),
      label: 'الحجوزات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.payment),
      label: 'المصروفات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: 'التقارير',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navigationItems,
      ),
    );
  }
}

/// شاشة ترحيبية تعرض مقدمة عن النظام
class HierarchicalFundingWelcomeScreen extends StatelessWidget {
  const HierarchicalFundingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النظام الهرمي للتمويل'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // مقدمة النظام
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_tree,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'نظام إدارة التمويل الهرمي',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نظام شامل لإدارة التمويل بطريقة هرمية حيث يتم تخصيص التمويل للأبواب الرئيسية، '
                      'ثم توزيعه على الأبواب الفرعية، مع إمكانية حجز وتنفيذ المصروفات وإنتاج التقارير المفصلة.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // مميزات النظام
            const Text(
              'مميزات النظام:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.account_tree,
                    'إدارة الأبواب',
                    'إنشاء وإدارة الأبواب الرئيسية والفرعية بشكل هرمي',
                    Colors.blue,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.attach_money,
                    'تخصيص التمويل',
                    'تخصيص المبالغ للأبواب الرئيسية وتوزيعها على الفرعية',
                    Colors.green,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.bookmark,
                    'إدارة الحجوزات',
                    'حجز المبالغ للمصروفات المستقبلية مع رفع المرفقات',
                    Colors.orange,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.payment,
                    'تنفيذ المصروفات',
                    'تنفيذ الحجوزات وتحويلها إلى مصروفات فعلية',
                    Colors.purple,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.analytics,
                    'التقارير المالية',
                    'تقارير شاملة ومفصلة مع تحليل تقادم الحجوزات',
                    Colors.indigo,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.file_present,
                    'المرفقات',
                    'رفع وإدارة ملفات PDF للحجوزات والمصروفات',
                    Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر البدء
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HierarchicalFundingMainScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('بدء استخدام النظام'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
