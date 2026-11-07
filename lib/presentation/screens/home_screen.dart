import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/shop_product.dart';
import '../../services/cart_service.dart';
import '../../services/catalog_service.dart';
import '../../utils/bidi_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/atelier_components.dart';
import 'product_details_screen.dart';

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
      backgroundColor: AtelierColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final approvedShops = CatalogService.instance.shops
            .where((s) => s.status == ApprovalStatus.approved)
            .toList();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AtelierColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AtelierColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                size: 16,
                                color: AtelierColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'المتاجر المعتمدة في تفضّل',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AtelierColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AtelierColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: AtelierColors.borderSubtle),
                  const SizedBox(height: 8),

                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedStoreFilter == null
                                  ? AtelierColors.primaryTint
                                  : AtelierColors.surfaceElevated,
                              border: Border.all(
                                color: _selectedStoreFilter == null
                                    ? AtelierColors.primary
                                    : AtelierColors.borderSubtle,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ك',
                                style: GoogleFonts.tajawal(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedStoreFilter == null
                                      ? AtelierColors.primary
                                      : AtelierColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'جميع المتاجر',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: _selectedStoreFilter == null
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedStoreFilter == null
                                  ? AtelierColors.primary
                                  : AtelierColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'عرض تشكيلة كافة دور الأزياء (${approvedShops.length} متاجر)',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AtelierColors.textMuted,
                            ),
                          ),
                          trailing: _selectedStoreFilter == null
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AtelierColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedStoreFilter = null);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AtelierColors.borderSubtle,
                        ),
                        ...approvedShops.map(
                          (shop) => Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _selectedStoreFilter == shop.name
                                        ? AtelierColors.primaryTint
                                        : AtelierColors.surfaceElevated,
                                    border: Border.all(
                                      color: _selectedStoreFilter == shop.name
                                          ? AtelierColors.primary
                                          : AtelierColors.borderSubtle,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getStoreInitialLetter(shop.name),
                                      style: GoogleFonts.tajawal(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedStoreFilter == shop.name
                                            ? AtelierColors.primary
                                            : AtelierColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  shop.name,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight:
                                        _selectedStoreFilter == shop.name
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _selectedStoreFilter == shop.name
                                        ? AtelierColors.primary
                                        : AtelierColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  'دار أزياء معتمدة في الأتيليه',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 11,
                                    color: AtelierColors.textMuted,
                                  ),
                                ),
                                trailing: _selectedStoreFilter == shop.name
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AtelierColors.primary,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  setState(
                                    () => _selectedStoreFilter = shop.name,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              const Divider(
                                height: 1,
                                color: AtelierColors.borderSubtle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        final visibleProducts = CatalogService.instance.visibleCustomerProducts;
        final filteredProducts = _getFilteredProducts(visibleProducts);

        return Scaffold(
          backgroundColor: AtelierColors.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Editorial Masthead & Search Header
                  _buildHeader(),
                  const SizedBox(height: 18),

                  // Category Selector Pills
                  _buildCategoryPills(),
                  const SizedBox(height: 20),

                  // Active Store Filter Indicator
                  if (_selectedStoreFilter != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AtelierColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AtelierColors.primaryBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المتجر المصفى: $_selectedStoreFilter',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AtelierColors.primary,
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                setState(() => _selectedStoreFilter = null),
                            child: Row(
                              children: [
                                Text(
                                  'إلغاء التصفية',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AtelierColors.error,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AtelierColors.error,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Privilege Rewards Editorial Banner
                  _buildRewardCard(context),
                  const SizedBox(height: 28),

                  // Certified Ateliers Section (Editorial Flow)
                  _buildCertifiedStoresSection(),
                  const SizedBox(height: 32),

                  // Seasonal Picks Section (Editorial Lookbook Grid)
                  _buildSeasonalPicksSection(filteredProducts),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Branding Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Filter Circular Button (Right in RTL)
            InkWell(
              onTap: _showFilterModal,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _selectedStoreFilter != null
                      ? AtelierColors.primaryTint
                      : AtelierColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedStoreFilter != null
                        ? AtelierColors.primary
                        : AtelierColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: AtelierTheme.subtleShadow,
                ),
                child: Icon(
                  Icons.tune_outlined,
                  color: _selectedStoreFilter != null
                      ? AtelierColors.primary
                      : AtelierColors.textPrimary,
                  size: 20,
                ),
              ),
            ),

            // Center Brand Title & Subtitle
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AtelierBrandLogo(size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'تفضّل',
                        style: GoogleFonts.tajawal(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AtelierColors.primary,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'HAUTE COUTURE MARKETPLACE',
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AtelierColors.goldDark,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notification Bell Button (Left in RTL)
            InkWell(
              onTap: () => showAtelierNotificationsModal(context),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AtelierColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AtelierColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: AtelierTheme.subtleShadow,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_outlined,
                      color: AtelierColors.textPrimary,
                      size: 20,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AtelierColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar Pill
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AtelierColors.surface,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AtelierColors.border, width: 1.0),
            boxShadow: AtelierTheme.subtleShadow,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AtelierColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AtelierColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن فستان، معطف، عباية، متجر...',
                    hintStyle: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AtelierColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () => _searchController.clear(),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.cancel,
                      color: AtelierColors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPills() {
    final categories = [
      'الكل',
      'فساتين',
      'معاطف',
      'عبايات',
      'بدلات',
      'حقائب',
      'أحذية',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AtelierColors.primary
                      : AtelierColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AtelierColors.primary
                        : AtelierColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AtelierColors.primary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : AtelierTheme.subtleShadow,
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AtelierColors.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AtelierColors.goldBorder.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Row(
        children: [
          // 1. Gold Star Crest (Rightmost in RTL)
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AtelierColors.goldTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, color: AtelierColors.gold, size: 20),
          ),
          const SizedBox(width: 10),

          // 2. Rewards Text Column (Flexible & Expanded, zero overflow)
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Right aligned in RTL
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'نقاط المكافآت: 450 نقطة',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'عضوية تفضّل بريفيليدج الذهبية',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AtelierColors.goldDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. VIP Code Button (Leftmost in RTL)
          InkWell(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'TAFADDAL25'));
              showCleanSnackBar(
                context,
                'تم نسخ كود الخصم الحصري (TAFADDAL25) بنجاح!',
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AtelierColors.goldTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AtelierColors.goldBorder, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.copy_outlined,
                    size: 11,
                    color: AtelierColors.goldDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'كود: TAFADDAL25',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AtelierColors.goldDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
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
        // Editorial Header with Hairline Rule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right (child 0 in RTL): Section Title
            Row(
              children: [
                Text(
                  'متاجر معتمدة',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AtelierColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: AtelierColors.gold, size: 16),
              ],
            ),
            // Left (child 1 in RTL): View All Link
            TextButton(
              onPressed: () {
                if (_selectedStoreFilter != null) {
                  setState(() => _selectedStoreFilter = null);
                } else {
                  _showFilterModal();
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _selectedStoreFilter != null ? 'عرض الكل' : 'الكل ›',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AtelierColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AtelierColors.borderSubtle),
        const SizedBox(height: 14),

        // Stores Avatars Flowing Horizontally
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: approvedShops.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              final isSelected = _selectedStoreFilter == s.name;
              return Padding(
                padding: EdgeInsets.only(
                  left: idx == approvedShops.length - 1 ? 0 : 16,
                ),
                child: AtelierStoreAvatar(
                  storeName: s.name,
                  isSelected: isSelected,
                  radius: 28,
                  onTap: () {
                    setState(() {
                      _selectedStoreFilter = isSelected ? null : s.name;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalPicksSection(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editorial Header with Hairline Rule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right (child 0 in RTL): Section Title
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'مختارات الموسم',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AtelierColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.auto_awesome,
                    color: AtelierColors.gold,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Left (child 1 in RTL): Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AtelierColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${products.length} قطع',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AtelierColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AtelierColors.borderSubtle),
        const SizedBox(height: 16),

        if (products.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: AtelierColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AtelierColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.manage_search_outlined,
                  size: 44,
                  color: AtelierColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'لم يتم العثور على منتجات تطابق البحث أو منتجات غير معتمدة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AtelierColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          // Editorial Lookbook Grid: Products breathe directly on canvas without card boxes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 16,
              mainAxisSpacing: 22,
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

  void _openProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  /// Editorial Lookbook Item: Pure fashion visual + editorial typography, no outer card box
  Widget _buildProductCard(Product p) {
    final isFav = _favorites.contains(p.id);
    final shop = CatalogService.instance.getShop(p.shopId);
    final storeName = shop?.name ?? 'متجر معتمد';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fashion Visual Cover (Framed with subtle hairline border)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openProductDetails(p),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AtelierProductVisual(
                      productName: p.name,
                      category: p.category,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              // Remaining stock pill (Right side in RTL)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'متبقي ${p.stockQuantity}',
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Wishlist heart (Left side in RTL)
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
                          ? 'تم إزالة المنتج من قائمة الرغبات'
                          : 'تمت إضافة (${p.name}) إلى قائمة الرغبات',
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav
                          ? AtelierColors.error
                          : AtelierColors.textSecondary,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Editorial Metadata (Directly on canvas)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openProductDetails(p),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                p.name,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AtelierColors.textPrimary,
                  height: 1.25,
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
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AtelierColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.verified,
                    size: 12,
                    color: AtelierColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                p.specs,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AtelierColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Bottom Price & Quick Add
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Price on the RIGHT
            Text(
              '\$${p.price.toInt()}',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AtelierColors.textPrimary,
              ),
            ),
            // Minimalist Add Button on the LEFT
            InkWell(
              onTap: () {
                try {
                  p.validateStock(1);

                  CartService.instance.addToCart(
                    id: p.id,
                    shopId: p.shopId,
                    title: p.name,
                    storeName: storeName,
                    specs: p.specs,
                    price: p.price,
                    shipmentCode: _getStoreShipmentCode(p.shopId),
                  );

                  showCleanSnackBar(
                    context,
                    'تمت إضافة (${p.name}) إلى سلة التسوق!',
                    action: SnackBarAction(
                      label: 'عرض السلة',
                      textColor: AtelierColors.goldLight,
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
                    backgroundColor: AtelierColors.error,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AtelierColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AtelierColors.primary.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 17),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStoreShipmentCode(String shopId) {
    switch (shopId) {
      case 'shop_sham':
        return 'SO-902';
      case 'shop_nokhba':
        return 'SO-903';
      case 'shop_elegance':
        return 'SO-904';
      case 'shop_harir':
        return 'SO-905';
      case 'shop_yasmeen':
        return 'SO-906';
      case 'shop_qasab':
        return 'SO-907';
      case 'shop_fairuz':
        return 'SO-908';
      case 'shop_jawaher':
        return 'SO-909';
      default:
        return 'SO-910';
    }
  }

  String _getStoreInitialLetter(String name) {
    if (name.isEmpty) return 'ت';
    String clean = name
        .replaceFirst('متجر ', '')
        .replaceFirst('بوتيك ', '')
        .replaceFirst('دار ', '')
        .replaceFirst('أزياء ', '')
        .replaceFirst('مشغل ', '')
        .replaceFirst('أتيليه ', '')
        .trim();
    if (clean.startsWith('ال') && clean.length > 2) {
      clean = clean.substring(2);
    }
    return clean.isNotEmpty ? clean[0] : name[0];
  }
}
