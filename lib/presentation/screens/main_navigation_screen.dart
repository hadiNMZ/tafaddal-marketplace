import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import 'admin_dashboard_screen.dart';
import 'cart_checkout_screen.dart';
import 'home_screen.dart';
import 'order_details_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      CartCheckoutScreen(onNavigateTab: _onTabTapped),
      const OrderDetailsScreen(),
      const AdminDashboardScreen(),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: CartService.instance,
        builder: (context, _) {
          final count = CartService.instance.itemCount;
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1B4D3E),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: count > 0
                    ? Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.shopping_bag_outlined),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                activeIcon: count > 0
                    ? Badge(
                        label: Text('$count'),
                        child: const Icon(Icons.shopping_bag),
                      )
                    : const Icon(Icons.shopping_bag),
                label: 'سلة المتاجر',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                activeIcon: Icon(Icons.local_shipping),
                label: 'طلباتي / التاجر',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'إدارة Ops',
              ),
            ],
          );
        },
      ),
    );
  }
}
