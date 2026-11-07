import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/domain/shipment_order.dart';
import 'package:tafaddal_marketplace/presentation/screens/home_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/cart_checkout_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/order_details_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/admin_dashboard_screen.dart';
import 'package:tafaddal_marketplace/presentation/screens/product_details_screen.dart';
import 'package:tafaddal_marketplace/services/cart_service.dart';
import 'package:tafaddal_marketplace/services/catalog_service.dart';

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
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildRtlTestApp(const HomeScreen()));
      expect(find.text('تفضّل'), findsWidgets);
      expect(find.text('نقاط المكافآت: 450 نقطة'), findsOneWidget);
      expect(find.text('معطف صوف فاخر'), findsOneWidget);
      expect(find.text('فستان سهرة كريب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'HomeScreen renders new luxury stores and filtered categories',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildRtlTestApp(const HomeScreen()));
        expect(find.text('دار الياسمين'), findsWidgets);
        expect(find.text('أتيليه القصب'), findsWidgets);
        expect(find.text('مشغل الفيروز'), findsWidgets);
        expect(find.text('دار الجواهر'), findsWidgets);

        expect(find.text('بدلات'), findsOneWidget);
        expect(find.text('حقائب'), findsOneWidget);

        // Filter by 'بدلات'
        final suitsFilter = find.text('بدلات');
        await tester.ensureVisible(suitsFilter);
        await tester.tap(suitsFilter);
        await tester.pumpAndSettle();

        expect(find.text('بدلة تويد كلاسيكية'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HomeScreen tapping الكل shows all stores modal without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildRtlTestApp(const HomeScreen()));

        final allStoresBtn = find.text('الكل ›');
        expect(allStoresBtn, findsOneWidget);
        await tester.tap(allStoresBtn);
        await tester.pumpAndSettle();

        // Verify all stores modal opened
        expect(find.text('المتاجر المعتمدة في تفضّل'), findsOneWidget);
        expect(find.text('جميع المتاجر'), findsOneWidget);
        expect(find.text('أزياء الشام'), findsWidgets);
        expect(find.text('أتيليه القصب'), findsWidgets);
        expect(find.text('دار الياسمين'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CartCheckoutScreen tapping bell icon opens notifications modal',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildRtlTestApp(const CartCheckoutScreen()));

        final bellBtn = find.byIcon(Icons.notifications_none_outlined);
        expect(bellBtn, findsOneWidget);
        await tester.tap(bellBtn);
        await tester.pumpAndSettle();

        // Verify notifications modal opened
        expect(find.text('مركز الإشعارات والتنبيهات'), findsOneWidget);
        expect(
          find.text('تحديثات الشحنات والامتيازات الحصرية'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('CartCheckoutScreen renders shipment breakdown and totals', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

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
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'OrderDetailsScreen transitions stage and catches illegal transition',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 1000);
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

    testWidgets(
      'HomeScreen tapping on product item navigates to ProductDetailsScreen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(buildRtlTestApp(const HomeScreen()));
        final dressProductItem = find.text('فستان سهرة كريب');
        expect(dressProductItem, findsOneWidget);

        await tester.ensureVisible(dressProductItem);
        await tester.tap(dressProductItem);
        await tester.pumpAndSettle();

        // Verify ProductDetailsScreen opened and rendered matching design
        expect(find.byType(ProductDetailsScreen), findsOneWidget);
        expect(find.text('متجر معتمد وموثق'), findsOneWidget);
        expect(find.text('\$240'), findsOneWidget);
        expect(find.text('أزياء الشام • فساتين'), findsOneWidget);
        expect(find.text('المقاس'), findsOneWidget);
        expect(find.text('اللون'), findsOneWidget);
        expect(find.text('الوصف'), findsOneWidget);
        expect(find.text('زمردي'), findsOneWidget);
        expect(find.text('أسود'), findsOneWidget);
        expect(find.text('ذهبي'), findsOneWidget);
        expect(find.text('إضافة إلى السلة'), findsOneWidget);

        // Tap Size 'L'
        final sizeL = find.text('L');
        expect(sizeL, findsOneWidget);
        await tester.tap(sizeL);
        await tester.pumpAndSettle();

        // Tap Add to Cart
        final addToCartBtn = find.text('إضافة إلى السلة');
        await tester.tap(addToCartBtn);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('عرض السلة'), findsOneWidget);

        // Tap Back button to pop back to HomeScreen
        final backBtn = find.byIcon(Icons.chevron_right_rounded);
        expect(backBtn, findsOneWidget);
        await tester.tap(backBtn);
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailsScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'ProductDetailsScreen renders all design elements and handles interactions',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final dress = CatalogService.instance.getProduct('p_dress')!;
        await tester.pumpWidget(
          buildRtlTestApp(ProductDetailsScreen(product: dress)),
        );

        expect(find.text('فستان سهرة كريب'), findsOneWidget);
        expect(find.text('\$240'), findsOneWidget);
        expect(find.text('متجر معتمد وموثق'), findsOneWidget);
        expect(find.text('إرجاع/استبدال خلال 14 يوماً'), findsOneWidget);

        // Test favorite toggle
        final favBtn = find.byIcon(Icons.favorite_border_rounded).first;
        await tester.tap(favBtn);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.favorite), findsWidgets);
      },
    );
  });
}
