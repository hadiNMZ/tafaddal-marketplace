enum ApprovalStatus { pending, approved, rejected }

class InsufficientStockException implements Exception {
  final String message;
  InsufficientStockException(this.message);

  @override
  String toString() => message;
}

class Shop {
  final String id;
  final String name;
  ApprovalStatus status;

  Shop({
    required this.id,
    required this.status,
    this.name = '',
  });
}

class Product {
  final String id;
  final String shopId;
  final String name;
  final double price;
  int stockQuantity;
  ApprovalStatus status;

  Product({
    required this.id,
    required this.shopId,
    required this.status,
    this.name = '',
    this.price = 0.0,
    this.stockQuantity = 0,
  }) {
    // CON-02: Mandatory Tenant Link
    if (shopId.isEmpty) {
      throw ArgumentError('CON-02: Product MUST be linked to a valid shopId');
    }
  }

  // CON-01: Visibility Guard
  bool isVisibleToCustomer(Shop shop) {
    if (shop.id != shopId) throw ArgumentError('Shop mismatch');
    return status == ApprovalStatus.approved &&
        shop.status == ApprovalStatus.approved;
  }

  // CON-03: Inventory Stock Limit Guard
  void validateStock(int requestedQuantity) {
    if (requestedQuantity <= 0) {
      throw ArgumentError('Requested quantity must be greater than zero');
    }
    if (requestedQuantity > stockQuantity) {
      throw InsufficientStockException(
        'CON-03: Requested quantity ($requestedQuantity) exceeds available stock ($stockQuantity).',
      );
    }
  }

  // CON-03: Deduct Stock upon valid purchase/reservation request
  void deductStock(int quantity) {
    validateStock(quantity);
    stockQuantity -= quantity;
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final int availableStock;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.availableStock,
  }) {
    // CON-03: Inventory Stock Limit Guard
    if (quantity > availableStock) {
      throw InsufficientStockException(
        'CON-03: Requested quantity ($quantity) exceeds available stock ($availableStock).',
      );
    }
  }
}
