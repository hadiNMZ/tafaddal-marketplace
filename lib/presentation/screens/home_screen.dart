import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/shop_product.dart';
import '../../services/cart_service.dart';
import '../../services/catalog_service.dart';
import '../../utils/bidi_utils.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStoreFilter;
  String _selectedCategory = 'الكل';
  final Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> visibleProducts) {
    return visibleProducts.where((p) {
      final shop = CatalogService.instance.getShop(p.shopId);
      final storeName = shop?.name ?? '';
      final query = _searchController.text.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          storeName.toLowerCase().contains(query) ||
          p.specs.toLowerCase().contains(query);

      final matchesStore =
          _selectedStoreFilter == null || storeName == _selectedStoreFilter;

      final matchesCategory =
          _selectedCategory == 'الكل' || p.category == _selectedCategory;

      return matchesSearch && matchesStore && matchesCategory;
    }).toList();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تصفية المنتجات حسب المتجر',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  title: const Text('جميع المتاجر'),
                  trailing: _selectedStoreFilter == null
                      ? const Icon(Icons.check, color: Color(0xFF1B4D3E))
                      : null,
                  onTap: () {
                    setState(() => _selectedStoreFilter = null);
                    Navigator.pop(context);
                  },
                ),
                ...CatalogService.instance.shops
                    .where((s) => s.status == ApprovalStatus.approved)
                    .map(
                      (shop) => ListTile(
                        title: Text(shop.name),
                        trailing: _selectedStoreFilter == shop.name
                            ? const Icon(Icons.check, color: Color(0xFF1B4D3E))
                            : null,
                        onTap: () {
                          setState(() => _selectedStoreFilter = shop.name);
                          Navigator.pop(context);
                        },
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) {
        // CON-01: Only show products approved by platform admins
        final visibleProducts = CatalogService.instance.visibleCustomerProducts;
        final filteredProducts = _getFilteredProducts(visibleProducts);

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F8),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Category Selector Pills
                  _buildCategoryPills(),
                  const SizedBox(height: 16),

                  // Active Store Filter Indicator
                  if (_selectedStoreFilter != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _selectedStoreFilter = null),
                          child: const Text(
                            'إلغاء التصفية',
                            style: TextStyle(fontSize: 11, color: Colors.red),
                          ),
                        ),
                        Text(
                          'المتجر المصفى: $_selectedStoreFilter',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4D3E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Reward Points Card
                  _buildRewardCard(context),
                  const SizedBox(height: 20),

                  // Certified Stores Section
                  _buildCertifiedStoresSection(),
                  const SizedBox(height: 20),

                  // Seasonal Picks Section
                  _buildSeasonalPicksSection(filteredProducts),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Filter Circle Button
        InkWell(
          onTap: _showFilterModal,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _selectedStoreFilter != null
                  ? const Color(0xFFECFDF5)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedStoreFilter != null
                    ? const Color(0xFF047857)
                    : Colors.grey.shade200,
              ),
            ),
            child: Icon(
              Icons.tune,
              color: _selectedStoreFilter != null
                  ? const Color(0xFF047857)
                  : Colors.black87,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search Pill
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 16,
                    ),
                  )
                else
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '...ابحث عن فستان، معطف، عباية، متجر',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Logo
        const Text(
          'تفضّل',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4D3E),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPills() {
    final categories = ['الكل', 'فساتين', 'معاطف', 'عبايات', 'أحذية'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1B4D3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1B4D3E)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'TAFADDAL25'));
              showCleanSnackBar(
                context,
                'تم نسخ كود الخصم (TAFADDAL25) إلى الحافظة!',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'كود: TAFADDAL25',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF047857),
                ),
              ),
            ),
          ),
          const Row(
            children: [
              Text(
                'نقاط المكافآت: 450 نقطة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.stars_outlined, color: Color(0xFF047857), size: 22),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertifiedStoresSection() {
    final approvedShops = CatalogService.instance.shops
        .where((s) => s.status == ApprovalStatus.approved)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() => _selectedStoreFilter = null);
              },
              child: Text(
                _selectedStoreFilter != null ? 'عرض الكل' : 'الكل ›',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const Text(
              'متاجر معتمدة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: approvedShops.map((s) {
            final isSelected = _selectedStoreFilter == s.name;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedStoreFilter = isSelected ? null : s.name;
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isSelected
                            ? const Color(0xFF1B4D3E)
                            : Colors.grey.shade300,
                        child: Icon(
                          Icons.store,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          size: 26,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF047857),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF1B4D3E)
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeasonalPicksSection(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${products.length} قطع',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Text(
              'مختارات الموسم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'لم يتم العثور على منتجات تطابق البحث أو منتجات غير معتمدة',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return _buildProductCard(p);
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(Product p) {
    final isFav = _favorites.contains(p.id);
    final shop = CatalogService.instance.getShop(p.shopId);
    final storeName = shop?.name ?? 'متجر معتمد';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Box
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.checkroom,
                      size: 48,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'متبقي ${p.stockQuantity}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isFav) {
                          _favorites.remove(p.id);
                        } else {
                          _favorites.add(p.id);
                        }
                      });
                      showCleanSnackBar(
                        context,
                        isFav
                            ? 'تم إزالة المنتج من المفضلة'
                            : 'تمت إضافة المنتج إلى المفضلة ❤️',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  p.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Color(0xFF047857),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.specs,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        try {
                          // CON-03: Inventory Stock Limit Validation
                          p.validateStock(1);

                          CartService.instance.addToCart(
                            id: p.id,
                            shopId: p.shopId,
                            title: p.name,
                            storeName: storeName,
                            specs: p.specs,
                            price: p.price,
                            shipmentCode: p.shopId == 'shop_sham'
                                ? 'SO-902'
                                : 'SO-903',
                          );

                          showCleanSnackBar(
                            context,
                            'تمت إضافة (${p.name}) إلى سلة التسوق!',
                            action: SnackBarAction(
                              label: 'عرض السلة',
                              textColor: const Color(0xFF86EFAC),
                              onPressed: () {
                                if (widget.onNavigateTab != null) {
                                  widget.onNavigateTab!(1);
                                }
                              },
                            ),
                          );
                        } on Exception catch (e) {
                          showCleanSnackBar(
                            context,
                            e.toString(),
                            backgroundColor: const Color(0xFF991B1B),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B4D3E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    Text(
                      '\$${p.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
