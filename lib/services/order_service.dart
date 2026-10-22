import 'package:flutter/foundation.dart';

import '../domain/audit_log.dart';
import '../domain/shipment_order.dart';
import '../domain/shop_product.dart';
import 'audit_service.dart';
import 'catalog_service.dart';

class OrderService extends ChangeNotifier {
  OrderService._() {
    _seedDefaultOrders();
  }

  static final OrderService instance = OrderService._();

  final List<ShipmentOrder> _orders = [];

  List<ShipmentOrder> get orders => List.unmodifiable(_orders);

  void _seedDefaultOrders() {
    final item1 = OrderItem(
      productId: 'p_coat',
      productTitle: 'معطف صوف كشمير',
      specs: 'مقاس L • أسود',
      price: 120,
      quantity: 1,
      availableStock: 5,
    );
    final item2 = OrderItem(
      productId: 'p_shirt',
      productTitle: 'قميص كلاسيكي قطن',
      specs: 'مقاس M • أبيض',
      price: 45,
      quantity: 1,
      availableStock: 5,
    );

    _orders.addAll([
      ShipmentOrder(
        id: 'SO-902',
        shopId: 'shop_sham',
        shopName: 'أزياء الشام',
        customerName: 'سامر الأحمد',
        initialShippingAddress: 'دمشق، المزة - الفيلات الغربية',
        initialState: OrderState.preparing,
        items: [item1, item2],
      ),
      ShipmentOrder(
        id: 'SO-903',
        shopId: 'shop_nokhba',
        shopName: 'بوتيك النخبة',
        customerName: 'سامر الأحمد',
        initialShippingAddress: 'بيروت، الحمرا - شارع الرئيسي',
        initialState: OrderState.placed,
        items: [
          OrderItem(
            productId: 'p_bag',
            productTitle: 'حقيبة جلدية أصلية',
            specs: 'بني كلاسيكي',
            price: 95,
            quantity: 1,
            availableStock: 5,
          ),
        ],
      ),
      ShipmentOrder(
        id: 'SO-840',
        shopId: 'shop_harir',
        shopName: 'دار الحرير',
        customerName: 'سامر الأحمد',
        initialShippingAddress: 'دبي، جميرا - شارع الشاطئ',
        initialState: OrderState.delivered,
        items: [
          OrderItem(
            productId: 'p_dress',
            productTitle: 'فستان السهرة المطرز الملكي',
            specs: 'مقاس M',
            price: 310,
            quantity: 1,
            availableStock: 5,
          ),
        ],
      ),
    ]);
  }

  /// Create shipment orders from cart items, deducting domain stock & writing audit logs
  List<ShipmentOrder> createOrdersFromCart(
    Map<String, List<dynamic>> groupedCartItems,
  ) {
    // 1. Transactional Pre-Validation: Validate stock for all items before making changes
    for (var items in groupedCartItems.values) {
      for (var cartItem in items) {
        final product = CatalogService.instance.getProduct(cartItem.id);
        if (product != null) {
          // CON-03: Throws InsufficientStockException if requested > stock
          product.validateStock(cartItem.quantity);
        }
      }
    }

    final List<ShipmentOrder> newOrders = [];

    // 2. Process Order Creation & Stock Deduction
    int orderCounter = 100;
    groupedCartItems.forEach((shipmentCode, items) {
      final String shopId = items.first.shopId.isNotEmpty
          ? items.first.shopId
          : (items.first.storeName == 'أزياء الشام'
                ? 'shop_sham'
                : 'shop_nokhba');
      final String shopName = items.first.storeName;

      final List<OrderItem> orderItems = [];

      for (var cartItem in items) {
        final product = CatalogService.instance.getProduct(cartItem.id);
        if (product != null) {
          // CON-03: Deduct Stock
          product.deductStock(cartItem.quantity);
        }

        orderItems.add(
          OrderItem(
            productId: cartItem.id,
            productTitle: cartItem.title,
            specs: cartItem.specs,
            price: cartItem.price,
            quantity: cartItem.quantity,
            availableStock: product?.stockQuantity ?? 10,
          ),
        );
      }

      final newOrder = ShipmentOrder(
        id: 'SO-${DateTime.now().millisecondsSinceEpoch % 1000 + orderCounter}',
        shopId: shopId,
        shopName: shopName,
        customerName: 'سامر الأحمد',
        initialShippingAddress: 'دمشق، المزة - الفيلات الغربية',
        initialState: OrderState.placed,
        items: orderItems,
      );

      _orders.insert(0, newOrder);
      newOrders.add(newOrder);
      orderCounter++;

      // CON-07 Audit Log
      AuditService.instance.addLog(
        AuditAction.statusChange,
        'إنشاء شحنة جديدة #${newOrder.id}',
        'تم تقسيم السلة وإنشاء الشحنة لـ ($shopName) بمبلغ \$${newOrder.totalAmount.toInt()}',
        actor: 'العميل (سامر الأحمد)',
        entityId: newOrder.id,
      );
    });

    notifyListeners();
    return newOrders;
  }

  void transitionOrderState(ShipmentOrder order, OrderState targetState) {
    order.transitionTo(targetState);

    // CON-07 Audit Log
    AuditService.instance.addLog(
      AuditAction.statusChange,
      'تحديث مسار الشحنة #${order.id}',
      'تم تغيير الحالة إلى: ${targetState.name.toUpperCase()}',
      actor: 'التاجر (${order.shopName})',
      entityId: order.id,
    );

    notifyListeners();
  }

  void requestOrderReturn(ShipmentOrder order) {
    order.requestReturn();

    // CON-07 Audit Log
    AuditService.instance.addLog(
      AuditAction.returnRequest,
      'طلب استبدال للطلب #${order.id}',
      'تم تقديم وتم قبول طلب استبدال المقاس للطلب المسلَم',
      actor: 'العميل (${order.customerName})',
      entityId: order.id,
    );

    notifyListeners();
  }
}
