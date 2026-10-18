import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'invoices/invoices_screen.dart';
import 'expenses/expenses_screen.dart';
import 'clients/clients_screen.dart';
import 'profile/profile_screen.dart';
import 'main_actions.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    InvoicesScreen(),
    ExpensesScreen(),
    ClientsScreen(),
  ];

  List<String> get _titles => [
        'dashboard'.tr,
        'invoices'.tr,
        'expenses'.tr,
        'clients'.tr,
      ];

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        void run(void Function(BuildContext) action) {
          Navigator.of(sheetContext).pop();
          action(context);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long,
                    color: AppTheme.primaryColor),
                title: Text('new_invoice'.tr),
                onTap: () => run(openCreateInvoice),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart,
                    color: AppTheme.warningColor),
                title: Text('new_expense'.tr),
                onTap: () => run(openAddExpense),
              ),
              ListTile(
                leading: const Icon(Icons.person_add,
                    color: AppTheme.secondaryColor),
                title: Text('new_client'.tr),
                onTap: () => run(openAddClient),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'settings'.tr,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMenu,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: 'dashboard'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: 'invoices'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: 'expenses'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: 'clients'.tr,
          ),
        ],
      ),
    );
  }
}
