import 'shop_product.dart';

enum OrderState { placed, preparing, shipping, delivered, rejected }

class IllegalStateTransitionException implements Exception {
  final String message;
  IllegalStateTransitionException(this.message);

  @override
  String toString() => message;
}

class ImmutableOrderException implements Exception {
  final String message;
  ImmutableOrderException(this.message);

  @override
  String toString() => message;
}

class InvalidReturnStateException implements Exception {
  final String message;
  InvalidReturnStateException(this.message);

  @override
  String toString() => message;
}

class ShipmentOrder {
  final String id;
  final String shopId;
  final String shopName;
  final String customerName;
  String _shippingAddress;
  OrderState _state;
  final List<OrderItem> items;

  ShipmentOrder({
    required this.id,
    required this.shopId,
    this.shopName = 'أزياء الشام',
    this.customerName = 'سامر الأحمد',
    String initialShippingAddress = 'دمشق، المزة - الفيلات الغربية',
    OrderState initialState = OrderState.placed,
    List<OrderItem>? items,
  }) : _shippingAddress = initialShippingAddress,
       _state = initialState,
       items = items ?? [];

  OrderState get currentState => _state;
  String get shippingAddress => _shippingAddress;

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  // CON-04: Order Immutability Guard
  void updateShippingAddress(String newAddress) {
    if (_state != OrderState.placed) {
      throw ImmutableOrderException(
        'CON-04: Cannot modify order data after it is placed.',
      );
    }
    _shippingAddress = newAddress;
  }

  // CON-05: Return Eligibility Guard
  void requestReturn() {
    if (_state != OrderState.delivered) {
      throw InvalidReturnStateException(
        'CON-05: Returns are only allowed for delivered orders.',
      );
    }
  }

  // CON-06: Strict Order State Machine
  void transitionTo(OrderState newState) {
    if (_state == OrderState.delivered || _state == OrderState.rejected) {
      throw IllegalStateTransitionException(
        'Order is in a terminal state and cannot be changed.',
      );
    }

    bool isValidTransition = false;

    switch (_state) {
      case OrderState.placed:
        isValidTransition =
            (newState == OrderState.preparing ||
            newState == OrderState.rejected);
        break;
      case OrderState.preparing:
        isValidTransition =
            (newState == OrderState.shipping ||
            newState == OrderState.rejected);
        break;
      case OrderState.shipping:
        isValidTransition =
            (newState == OrderState.delivered ||
            newState == OrderState.rejected);
        break;
      default:
        break;
    }

    if (!isValidTransition) {
      throw IllegalStateTransitionException(
        'Invalid transition from ${_state.name} to ${newState.name}',
      );
    }

    _state = newState;
  }
}
