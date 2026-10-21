enum ApprovalStatus { pending, approved, rejected }

class Shop {
  final String id;
  final String name;
  ApprovalStatus status;

  Shop({required this.id, required this.status, this.name = ''});
}

class Product {
  final String id;
  final String shopId;
  final String name;
  final double price;
  ApprovalStatus status;

  Product({
    required this.id,
    required this.shopId,
    required this.status,
    this.name = '',
    this.price = 0.0,
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
}
