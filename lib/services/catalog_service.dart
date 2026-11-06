import 'package:flutter/foundation.dart';

import '../domain/shop_product.dart';

class CatalogService extends ChangeNotifier {
  CatalogService._() {
    _seedCatalog();
  }

  static final CatalogService instance = CatalogService._();

  final Map<String, Shop> _shops = {};
  final List<Product> _products = [];

  List<Shop> get shops => List.unmodifiable(_shops.values);
  List<Product> get products => List.unmodifiable(_products);

  /// CON-01: Filter visible products for customers
  List<Product> get visibleCustomerProducts {
    return _products.where((p) {
      final shop = _shops[p.shopId];
      if (shop == null) return false;
      return p.isVisibleToCustomer(shop);
    }).toList();
  }

  Shop? getShop(String id) => _shops[id];

  Product? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _seedCatalog() {
    final shopSham = Shop(
      id: 'shop_sham',
      name: 'أزياء الشام',
      status: ApprovalStatus.approved,
    );
    final shopElegance = Shop(
      id: 'shop_elegance',
      name: 'متجر الأناقة',
      status: ApprovalStatus.approved,
    );
    final shopNokhba = Shop(
      id: 'shop_nokhba',
      name: 'بوتيك النخبة',
      status: ApprovalStatus.approved,
    );
    final shopHarir = Shop(
      id: 'shop_harir',
      name: 'دار الحرير',
      status: ApprovalStatus.approved,
    );
    final shopYasmeen = Shop(
      id: 'shop_yasmeen',
      name: 'دار الياسمين',
      status: ApprovalStatus.approved,
    );
    final shopQasab = Shop(
      id: 'shop_qasab',
      name: 'أتيليه القصب',
      status: ApprovalStatus.approved,
    );
    final shopFairuz = Shop(
      id: 'shop_fairuz',
      name: 'مشغل الفيروز',
      status: ApprovalStatus.approved,
    );
    final shopJawaher = Shop(
      id: 'shop_jawaher',
      name: 'دار الجواهر',
      status: ApprovalStatus.approved,
    );
    final shopLamsa = Shop(
      id: 'ST-104',
      name: 'متجر لمسة أزياء',
      status: ApprovalStatus.pending,
    );
    final shopZaizafoun = Shop(
      id: 'ST-105',
      name: 'أتيليه الزيزفون',
      status: ApprovalStatus.pending,
    );

    _shops[shopSham.id] = shopSham;
    _shops[shopElegance.id] = shopElegance;
    _shops[shopNokhba.id] = shopNokhba;
    _shops[shopHarir.id] = shopHarir;
    _shops[shopYasmeen.id] = shopYasmeen;
    _shops[shopQasab.id] = shopQasab;
    _shops[shopFairuz.id] = shopFairuz;
    _shops[shopJawaher.id] = shopJawaher;
    _shops[shopLamsa.id] = shopLamsa;
    _shops[shopZaizafoun.id] = shopZaizafoun;

    _products.addAll([
      Product(
        id: 'p_dress',
        shopId: 'shop_sham',
        name: 'فستان سهرة كريب',
        price: 240.0,
        category: 'فساتين',
        specs: 'S, M • زمردي',
        stockQuantity: 2,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_coat',
        shopId: 'shop_elegance',
        name: 'معطف صوف فاخر',
        price: 185.0,
        category: 'معاطف',
        specs: 'L, M • أسود',
        stockQuantity: 3,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_abaya',
        shopId: 'shop_harir',
        name: 'عباية حرير مطرزة',
        price: 310.0,
        category: 'عبايات',
        specs: '54, 56 • أسود',
        stockQuantity: 1,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_shoes',
        shopId: 'shop_nokhba',
        name: 'حذاء كلاسيك جلدي',
        price: 130.0,
        category: 'أحذية',
        specs: '42, 43 • بني',
        stockQuantity: 5,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_suit_blazer',
        shopId: 'shop_elegance',
        name: 'بدلة تويد كلاسيكية',
        price: 295.0,
        category: 'بدلات',
        specs: '48, 50 • كحلي ملكي',
        stockQuantity: 3,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_kaftan_gold',
        shopId: 'shop_qasab',
        name: 'قفطان مخمل مقصّب',
        price: 380.0,
        category: 'عبايات',
        specs: 'M, L • عنابي ذهبي',
        stockQuantity: 2,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_bag_leather',
        shopId: 'shop_jawaher',
        name: 'حقيبة يد جلدية محبوكة',
        price: 175.0,
        category: 'حقائب',
        specs: 'جلد عجل • عسلي دافئ',
        stockQuantity: 4,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_evening_gown',
        shopId: 'shop_yasmeen',
        name: 'فستان درابيه ميكادو',
        price: 320.0,
        category: 'فساتين',
        specs: 'S, M • لؤلؤي عاجي',
        stockQuantity: 2,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_wool_cape',
        shopId: 'shop_fairuz',
        name: 'كاب صوف إيطالي',
        price: 225.0,
        category: 'معاطف',
        specs: 'One Size • جملي فاخر',
        stockQuantity: 3,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_oxford_leather',
        shopId: 'shop_nokhba',
        name: 'حذاء أوكسفورد فينيسي',
        price: 160.0,
        category: 'أحذية',
        specs: '41, 42, 44 • عنابي غامق',
        stockQuantity: 4,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_silk_scarf',
        shopId: 'shop_fairuz',
        name: 'شال حرير دمشقي يدوي',
        price: 95.0,
        category: 'حقائب',
        specs: 'حرير طبيعي 100% • فيروزي ذهبي',
        stockQuantity: 6,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'p_tuxedo',
        shopId: 'shop_sham',
        name: 'بدلة سهرة تاكسيدو',
        price: 350.0,
        category: 'بدلات',
        specs: '50, 52 • أسود فحمي',
        stockQuantity: 2,
        status: ApprovalStatus.approved,
      ),
      Product(
        id: 'PROD-501',
        shopId: 'shop_sham',
        name: 'فستان سواريه مطرز',
        price: 195.0,
        category: 'فساتين',
        specs: 'M, L • كحلي',
        stockQuantity: 4,
        status: ApprovalStatus.pending,
      ),
      Product(
        id: 'PROD-502',
        shopId: 'shop_elegance',
        name: 'سترة جلد سويدي فاخرة',
        price: 280.0,
        category: 'معاطف',
        specs: 'L, XL • تبغي',
        stockQuantity: 3,
        status: ApprovalStatus.pending,
      ),
    ]);
  }

  void approveShop(String shopId) {
    final shop = _shops[shopId];
    if (shop != null) {
      shop.approve();
      notifyListeners();
    }
  }

  void rejectShop(String shopId) {
    final shop = _shops[shopId];
    if (shop != null) {
      shop.reject();
      notifyListeners();
    }
  }

  void approveProduct(String productId) {
    final product = getProduct(productId);
    if (product != null) {
      product.approve();
      notifyListeners();
    }
  }

  void rejectProduct(String productId) {
    final product = getProduct(productId);
    if (product != null) {
      product.reject();
      notifyListeners();
    }
  }
}
