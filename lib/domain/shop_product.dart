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
  ApprovalStatus _status;

  Shop({
    required this.id,
    this.name = '',
    ApprovalStatus initialStatus = ApprovalStatus.pending,
    ApprovalStatus? status,
  }) : _status = status ?? initialStatus {
    if (id.isEmpty) {
      throw ArgumentError('Shop ID cannot be empty');
    }
  }

  ApprovalStatus get status => _status;

  void approve() {
    _status = ApprovalStatus.approved;
  }

  void reject() {
    _status = ApprovalStatus.rejected;
  }
}

class Product {
  final String id;
  final String shopId;
  final String name;
  final double price;
  final String category;
  final String specs;
  int _stockQuantity;
  ApprovalStatus _status;

  Product({
    required this.id,
    required this.shopId,
    this.name = '',
    this.price = 0.0,
    this.category = 'أزياء',
    this.specs = '',
    int stockQuantity = 0,
    ApprovalStatus initialStatus = ApprovalStatus.pending,
    ApprovalStatus? status,
  }) : _stockQuantity = stockQuantity,
       _status = status ?? initialStatus {
    // CON-02: Mandatory Tenant Link
    if (shopId.isEmpty) {
      throw ArgumentError('CON-02: Product MUST be linked to a valid shopId');
    }
    if (stockQuantity < 0) {
      throw ArgumentError('Stock quantity cannot be negative');
    }
  }

  ApprovalStatus get status => _status;

  int get stockQuantity => _stockQuantity;

  void approve() {
    _status = ApprovalStatus.approved;
  }

  void reject() {
    _status = ApprovalStatus.rejected;
  }

  // CON-01: Visibility Guard
  bool isVisibleToCustomer(Shop shop) {
    if (shop.id != shopId) throw ArgumentError('Shop mismatch');
    return _status == ApprovalStatus.approved &&
        shop.status == ApprovalStatus.approved;
  }

  // CON-03: Inventory Stock Limit Guard
  void validateStock(int requestedQuantity) {
    if (requestedQuantity <= 0) {
      throw ArgumentError('Requested quantity must be greater than zero');
    }
    if (requestedQuantity > _stockQuantity) {
      throw InsufficientStockException(
        'CON-03: Requested quantity ($requestedQuantity) exceeds available stock ($_stockQuantity).',
      );
    }
  }

  // CON-03: Deduct Stock upon valid purchase/reservation request
  void deductStock(int quantity) {
    validateStock(quantity);
    _stockQuantity -= quantity;
  }

  void replenishStock(int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Replenish quantity must be greater than zero');
    }
    _stockQuantity += quantity;
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String specs;
  final double price;
  final int quantity;
  final int availableStock;

  OrderItem({
    required this.productId,
    this.productTitle = '',
    this.specs = '',
    this.price = 0.0,
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
