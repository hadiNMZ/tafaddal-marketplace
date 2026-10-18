import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/domain/shipment_order.dart';

// --- TDD Test Suite ---
void main() {
  group('Sprint 2: ShipmentOrder State Machine (CON-06)', () {
    test('Valid transition: Placed -> Preparing -> Shipping -> Delivered', () {
      final order = ShipmentOrder(id: 'order_1', shopId: 'shop_1');
      order.transitionTo(OrderState.preparing);
      order.transitionTo(OrderState.shipping);
      order.transitionTo(OrderState.delivered);
      expect(order.currentState, OrderState.delivered);
    });

    test('Invalid transition: Cannot skip stages (Placed -> Shipping)', () {
      final order = ShipmentOrder(id: 'order_2', shopId: 'shop_1');
      expect(
        () => order.transitionTo(OrderState.shipping),
        throwsA(isA<IllegalStateTransitionException>()),
      );
    });
  });

  group('Sprint 2: Order Immutability & Returns (CON-04, CON-05)', () {
    test('CON-04: Can update address while Placed, but NOT when Preparing', () {
      final order = ShipmentOrder(id: 'order_3', shopId: 'shop_1');

      // Allowed
      order.updateShippingAddress('123 New Street');
      expect(order.shippingAddress, '123 New Street');

      // Move state forward
      order.transitionTo(OrderState.preparing);

      // Denied
      expect(
        () => order.updateShippingAddress('456 Another St'),
        throwsA(isA<ImmutableOrderException>()),
      );
    });

    test('CON-05: Cannot request return unless Delivered', () {
      final order = ShipmentOrder(id: 'order_4', shopId: 'shop_1');

      // Denied in Placed
      expect(
        () => order.requestReturn(),
        throwsA(isA<InvalidReturnStateException>()),
      );

      order.transitionTo(OrderState.preparing);
      order.transitionTo(OrderState.shipping);

      // Denied in Shipping
      expect(
        () => order.requestReturn(),
        throwsA(isA<InvalidReturnStateException>()),
      );

      order.transitionTo(OrderState.delivered);

      // Allowed in Delivered (should not throw)
      expect(() => order.requestReturn(), returnsNormally);
    });
  });
}
