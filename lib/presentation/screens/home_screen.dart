import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController(
      text: 'ابحث عن أزياء، عبايات، أحذية أو متاجر...');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search & Filters
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    // Rewards Card
                    _buildRewardsCard(context),
                    const SizedBox(height: 20),

                    // Verified Stores Section
                    _buildVerifiedStoresSection(),
                    const SizedBox(height: 24),

                    // Seasonal Picks Section
                    _buildSeasonalPicksSection(),
                    const SizedBox(height: 16),

                    // Multi-Store Shipping Banner
                    _buildShippingBanner(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black87),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const Text(
            'تفضّل',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // Filter Button
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        // Search TextField
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              decoration: const InputDecoration(
                hintText: 'ابحث عن أزياء، عبايات، أحذية أو متاجر...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                prefixIcon: Icon(Icons.close, size: 18, color: Colors.grey),
                suffixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // For RTL flow
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEEDDF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 14, color: Color(0xFFC2410C)),
                SizedBox(width: 4),
                Text(
                  '3 عناصر من متجر',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _buildFilterChip('المتجر'),
          const SizedBox(width: 6),
          _buildFilterChip('اللون'),
          const SizedBox(width: 6),
          _buildFilterChip('المقاس'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2623),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF78350F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'عضو مميز',
                  style: TextStyle(fontSize: 11, color: Color(0xFFFDE68A), fontWeight: FontWeight.bold),
                ),
              ),
              const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'نقاط المكافآت: 450 نقطة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'تعادل رصيد \$45 نقداً',
                        style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC)),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.stars, color: Color(0xFF22C55E), size: 28),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Coupon Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111815),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ كود الخصم: TAFADDAL25')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('نسخ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'كود الخصم الحصري (-25% على أول طلب):',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'TAFADDAL25',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'استبدل نقاطك عند الدفع للحصول على خصم إضافي',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedStoresSection() {
    final stores = [
      {'name': 'متجر الأناقة', 'city': 'دمشق'},
      {'name': 'أزياء الشام', 'city': 'حلب'},
      {'name': 'بوتيك النخبة', 'city': 'بيروت'},
      {'name': 'دار الحرير', 'city': 'دبي'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(Icons.chevron_left, size: 16, color: Color(0xFFC2410C)),
                  Text(
                    'عرض الكل',
                    style: TextStyle(fontSize: 13, color: Color(0xFFC2410C), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Row(
              children: [
                Text(
                  'متاجر معتمدة وموثقة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(width: 6),
                Icon(Icons.verified, color: Color(0xFF059669), size: 18),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stores.map((s) {
            return Column(
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.store, color: Colors.grey.shade700, size: 28),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: const Icon(Icons.verified, color: Color(0xFF059669), size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  s['name']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  s['city']!,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeasonalPicksSection() {
    final products = [
      {
        'title': 'معطف صوف كشمير فاخر',
        'store': 'متجر الأناقة - معتمد',
        'stock': 'متبقي 3 في المخزون',
        'sizes': 'M / L / XL',
        'colors': 'أسود / كحلي',
        'price': '185',
        'oldPrice': '220',
        'isWarningStock': false,
      },
      {
        'title': 'فستان سهرة كريب مطرز',
        'store': 'أزياء الشام - معتمد',
        'stock': 'متبقي 2 في المخزون',
        'sizes': 'S / M',
        'colors': 'زمردي',
        'price': '240',
        'oldPrice': null,
        'isWarningStock': false,
      },
      {
        'title': 'حذاء جلدي إيطالي كلاسيك',
        'store': 'بوتيك النخبة - معتمد',
        'stock': 'متبقي 5 في المخزون',
        'sizes': '41 / 42 / 43',
        'colors': 'بني داكن',
        'price': '130',
        'oldPrice': null,
        'isWarningStock': false,
      },
      {
        'title': 'عباية حرير مطرزة يدوياً',
        'store': 'دار الحرير - معتمد',
        'stock': 'متبقي 1 فقط!',
        'sizes': '54 / 56',
        'colors': 'أسود ملكي',
        'price': '310',
        'oldPrice': null,
        'isWarningStock': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '4 قطع متاحة',
                style: TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مختارات أزياء الموسم',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'قطع حصرية تم التحقق من جودتها وأصالتها',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
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

  Widget _buildProductCard(Map<String, dynamic> p) {
    final bool isWarning = p['isWarningStock'] as bool;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(Icons.checkroom, size: 50, color: Colors.grey.shade600),
                  ),
                ),
                // Favorite Heart Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.black87),
                  ),
                ),
                // Stock Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWarning ? const Color(0xFF991B1B) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p['stock'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? Colors.white : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
                // Add to Cart Floating Button
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Info Box
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        p['store'] as String,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.verified, size: 12, color: Color(0xFF059669)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p['title'] as String,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p['colors'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      p['sizes'] as String,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (p['oldPrice'] != null) ...[
                      Text(
                        '\$ ${p['oldPrice']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '\$ ${p['price']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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

  Widget _buildShippingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'شحن موحد متعدد المتاجر',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
                Text(
                  'اطلب من عدة بوتيكات واستلمها بشحنة واحدة',
                  style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFA7F3D0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF065F46), size: 20),
          ),
        ],
      ),
    );
  }
}
