import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/domain/shipment_order.dart';
import 'package:tafaddal_marketplace/presentation/screens/home_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/cart_checkout_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/order_details_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/admin_dashboard_screen.dart';
import 'package:tafaddal_marketplace/services/cart_service.dart';

void main() {
  Widget buildRtlTestApp(Widget child) {
    return MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }

  group('Presentation Screens Tests', () {
    testWidgets('HomeScreen renders marketplace products and rewards card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildRtlTestApp(const HomeScreen()));
      expect(find.text('تفضّل'), findsWidgets);
      expect(find.text('نقاط المكافآت: 450 نقطة'), findsOneWidget);
      expect(find.text('معطف صوف فاخر'), findsOneWidget);
      expect(find.text('فستان سهرة كريب'), findsOneWidget);
    });

    testWidgets('CartCheckoutScreen renders shipment breakdown and totals', (
      WidgetTester tester,
    ) async {
      CartService.instance.clearCart();
      CartService.instance.addToCart(
        id: 'p1',
        shopId: 'shop_sham',
        title: 'جاكيت جلد راقي',
        storeName: 'أزياء الشام',
        specs: 'المقاس: L | أسود',
        price: 120,
        shipmentCode: 'SO-902',
      );
      CartService.instance.addToCart(
        id: 'p2',
        shopId: 'shop_nokhba',
        title: 'حقيبة جلدية أصلية',
        storeName: 'بوتيك النخبة',
        specs: 'اللون: بني كلاسيكي',
        price: 95,
        shipmentCode: 'SO-903',
      );

      await tester.pumpWidget(buildRtlTestApp(const CartCheckoutScreen()));
      expect(find.text('سلة التسوق وإتمام الطلب'), findsOneWidget);
      expect(find.textContaining('أزياء الشام'), findsOneWidget);
      expect(find.textContaining('بوتيك النخبة'), findsOneWidget);
      expect(find.text('تأكيد وإرسال الطلب'), findsOneWidget);
    });

    testWidgets(
      'OrderDetailsScreen transitions stage and catches illegal transition',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final order = ShipmentOrder(
          id: 'SO-902',
          shopId: 'shop_sham',
          initialState: OrderState.preparing,
        );

        await tester.pumpWidget(
          buildRtlTestApp(OrderDetailsScreen(initialOrder: order)),
        );

        // Tap Next Stage: Preparing -> Shipping
        final nextStageBtn = find.text('تسليم لشركة الشحن (Shipping)');
        expect(nextStageBtn, findsOneWidget);
        await tester.ensureVisible(nextStageBtn);
        await tester.tap(nextStageBtn);
        await tester.pumpAndSettle();

        expect(order.currentState, OrderState.shipping);

        // Tap Invalid Action: Backward from Shipping to Placed -> Exception SnackBar
        final invalidBackwardBtn = find.text('رجوع (Placed)');
        expect(invalidBackwardBtn, findsOneWidget);
        await tester.ensureVisible(invalidBackwardBtn);
        await tester.tap(invalidBackwardBtn);
        await tester.pumpAndSettle();

        // SnackBar should display exact exception message & order state remains unchanged (Shipping)
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Invalid transition'), findsOneWidget);
        expect(order.currentState, OrderState.shipping);
      },
    );

    testWidgets('AdminDashboardScreen handles shop and product approvals', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildRtlTestApp(const AdminDashboardScreen()));
      expect(find.text('إدارة العمليات والرقابة'), findsOneWidget);
      expect(find.text('اعتماد'), findsOneWidget);
      expect(find.text('اعتماد ونشر للعملاء'), findsOneWidget);

      // Tap Approve Shop
      final approveShopBtn = find.text('اعتماد');
      await tester.ensureVisible(approveShopBtn);
      await tester.tap(approveShopBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
