import 'package:flutter/foundation.dart';

import '../domain/shop_product.dart';
import 'catalog_service.dart';

class CartItemModel {
  final String id;
  final String shopId;
  final String title;
  final String storeName;
  final String specs;
  final double price;
  final String shipmentCode;
  final String deliveryDays;
  int quantity;

  CartItemModel({
    required this.id,
    required this.shopId,
    required this.title,
    required this.storeName,
    required this.specs,
    required this.price,
    required this.shipmentCode,
    required this.deliveryDays,
    this.quantity = 1,
  });
}

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart({
    required String id,
    required String shopId,
    required String title,
    required String storeName,
    required String specs,
    required double price,
    String shipmentCode = 'SO-902',
    String deliveryDays = '2-3 أيام',
  }) {
    final domainProduct = CatalogService.instance.getProduct(id);
    final existingIndex = _items.indexWhere((i) => i.id == id);
    final currentQty = existingIndex >= 0 ? _items[existingIndex].quantity : 0;

    if (domainProduct != null &&
        (currentQty + 1) > domainProduct.stockQuantity) {
      throw InsufficientStockException(
        'CON-03: تجاوزت الكمية المطلوبة رصيد المخزون المتاح (${domainProduct.stockQuantity})',
      );
    }

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItemModel(
          id: id,
          shopId: shopId,
          title: title,
          storeName: storeName,
          specs: specs,
          price: price,
          shipmentCode: shipmentCode,
          deliveryDays: deliveryDays,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final domainProduct = CatalogService.instance.getProduct(id);
      final currentQty = _items[index].quantity;

      if (domainProduct != null &&
          (currentQty + 1) > domainProduct.stockQuantity) {
        throw InsufficientStockException(
          'CON-03: تجاوزت الكمية المطلوبة رصيد المخزون المتاح (${domainProduct.stockQuantity})',
        );
      }

      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Map<String, List<CartItemModel>> get groupedByShipment {
    final Map<String, List<CartItemModel>> groups = {};
    for (var item in _items) {
      groups.putIfAbsent(item.shipmentCode, () => []).add(item);
    }
    return groups;
  }

  double get productsTotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
