import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/cart_service.dart';
import '../theme/app_theme.dart';
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
      backgroundColor: AtelierColors.bg,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AtelierColors.surface,
          border: Border(
            top: BorderSide(color: AtelierColors.borderSubtle, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x081A1208),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, _) {
              final count = CartService.instance.itemCount;
              return BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: AtelierColors.primary,
                unselectedItemColor: AtelierColors.textMuted,
                selectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                unselectedLabelStyle: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                items: [
                  const BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.home_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.home, size: 22),
                    ),
                    label: 'الرئيسية',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: count > 0
                          ? Badge(
                              backgroundColor: AtelierColors.gold,
                              textColor: Colors.white,
                              label: Text(
                                '$count',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, size: 22),
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: count > 0
                          ? Badge(
                              backgroundColor: AtelierColors.gold,
                              textColor: Colors.white,
                              label: Text(
                                '$count',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Icon(Icons.shopping_bag, size: 22),
                            )
                          : const Icon(Icons.shopping_bag, size: 22),
                    ),
                    label: 'سلة المتاجر',
                  ),
                  const BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.local_shipping_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.local_shipping, size: 22),
                    ),
                    label: 'طلباتي / التاجر',
                  ),
                  const BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.admin_panel_settings_outlined, size: 22),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.admin_panel_settings, size: 22),
                    ),
                    label: 'إدارة Ops',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
