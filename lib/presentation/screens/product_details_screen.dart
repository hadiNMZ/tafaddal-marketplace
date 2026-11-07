import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/shop_product.dart';
import '../../services/cart_service.dart';
import '../../services/catalog_service.dart';
import '../../utils/bidi_utils.dart';
import '../theme/app_theme.dart';

/// Product Details Screen (شاشة تفاصيل المنتج)
/// Pixel-perfect luxury haute-couture presentation matching Atelier design system.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final void Function(int tabIndex)? onNavigateTab;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.onNavigateTab,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _selectedSize;
  late String _selectedColorName;
  bool _isFavorite = false;

  // Available Sizes
  final List<String> _sizes = const ['S', 'M', 'L', 'XL'];

  // Available Colors matching Atelier palette
  final List<_ProductColorVariant> _colors = const [
    _ProductColorVariant(name: 'زمردي', color: Color(0xFF1B4931)),
    _ProductColorVariant(name: 'أسود', color: Color(0xFF142421)),
    _ProductColorVariant(name: 'ذهبي', color: Color(0xFF9E7234)),
  ];

  @override
  void initState() {
    super.initState();
    // Default selected size: 'M' (as shown in design)
    _selectedSize = 'M';
    // Default selected color: 'زمردي' (as shown in design)
    _selectedColorName = _colors.first.name;
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
      default:
        return 'SO-901';
    }
  }

  void _handleAddToCart() {
    try {
      widget.product.validateStock(1);

      final shop = CatalogService.instance.getShop(widget.product.shopId);
      final storeName = shop?.name ?? 'متجر معتمد';

      CartService.instance.addToCart(
        id: widget.product.id,
        shopId: widget.product.shopId,
        title: widget.product.name,
        storeName: storeName,
        specs: '$_selectedSize • $_selectedColorName',
        price: widget.product.price,
        shipmentCode: _getStoreShipmentCode(widget.product.shopId),
      );

      showCleanSnackBar(
        context,
        'تمت إضافة (${widget.product.name}) إلى سلة التسوق!',
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: AtelierColors.goldLight,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onNavigateTab?.call(1);
          },
        ),
      );
    } catch (e) {
      showCleanSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AtelierColors.error,
      );
    }
  }

  String _getProductDescription() {
    if (widget.product.name.contains('فستان') ||
        widget.product.category == 'فساتين') {
      return 'فستان سهرة من الكريب الفاخر بقضة انسيابية وتفاصيل مطرزة يدوياً، مناسب للمناسبات الرسمية.';
    }
    if (widget.product.name.contains('معطف') ||
        widget.product.category == 'معاطف') {
      return 'معطف فاخر مصمم من الصوف الخالص المبطن بحرير طبيعي، يمنحك دفئاً استثنائياً وإطلالة أنيقة للمناسبات الشتوية.';
    }
    if (widget.product.name.contains('عباية') ||
        widget.product.category == 'عبايات') {
      return 'عباية شرقية راقية منسوجة من أرقى خيوط الحرير ومزينة بنقوش كلاسيكية تعكس أناقة التراث بلمسة عصرية.';
    }
    if (widget.product.name.contains('حذاء') ||
        widget.product.category == 'أحذية') {
      return 'حذاء كلاسيكي مصنوع يدوياً من الجلد الإيطالي الفاخر بنعل مريح ومقاوم، مصمم للرجال أصحاب الذوق الرفيع.';
    }
    return '${widget.product.name} بتصميم راقٍ وتفاصيل فاخرة من أجود الخامات المختارة بعناية، يجمع بين الفخامة المعاصرة والأصالة الراقية.';
  }

  @override
  Widget build(BuildContext context) {
    final shop = CatalogService.instance.getShop(widget.product.shopId);
    final storeName = shop?.name ?? 'متجر معتمد';

    return Scaffold(
      backgroundColor: AtelierColors.bg,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Hero Visual Container with Navigation & Verified Badge
                    _buildHeroVisualHeader(storeName),

                    // Product Information & Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Price & Title Row (RTL: Title on Right, Price on Left)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Store Subtitle (Right side)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AtelierColors.textPrimary,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$storeName • ${widget.product.category}',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF8A938C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Price (Left side in RTL)
                              Text(
                                '\$${widget.product.price.toInt()}',
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AtelierColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Badges Row (Stock remaining & 14-day return)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Stock Remaining Badge (Blue pill)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F2FC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFD2E4F8),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'متبقي ${widget.product.stockQuantity} قطع',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B64AC),
                                  ),
                                ),
                              ),

                              // Return Policy Badge (Golden/Tan pill)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF8EE),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEFE2C7),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'إرجاع/استبدال خلال 14 يوماً',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8C6427),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Size Selection Section (المقاس)
                          _buildSectionTitle('المقاس'),
                          const SizedBox(height: 10),
                          _buildSizeSelector(),

                          const SizedBox(height: 22),

                          // Color Selection Section (اللون)
                          _buildSectionTitle('اللون'),
                          const SizedBox(height: 12),
                          _buildColorSelector(),

                          const SizedBox(height: 22),

                          // Description Section (الوصف)
                          _buildSectionTitle('الوصف'),
                          const SizedBox(height: 8),
                          Text(
                            _getProductDescription(),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              height: 1.65,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// Top Hero Visual with custom silhouette art, navigation buttons, and certified badge
  Widget _buildHeroVisualHeader(String storeName) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF163E2D), // Deep rich forest emerald
            Color(0xFF0E281C),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Center Couture Line-Art Silhouette
            Center(
              child: SizedBox(
                width: 140,
                height: 200,
                child: CustomPaint(
                  painter: _CoutureSilhouettePainter(
                    category: widget.product.category,
                    productName: widget.product.name,
                  ),
                ),
              ),
            ),

            // Top Navigation Bar (Back & Favorite buttons)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (Right side in RTL)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: Color(0xFF191817),
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button (Left side in RTL)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      showCleanSnackBar(
                        context,
                        _isFavorite
                            ? 'تمت إضافة (${widget.product.name}) إلى قائمة الرغبات'
                            : 'تم إزالة المنتج من قائمة الرغبات',
                      );
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          size: 20,
                          color: _isFavorite
                              ? AtelierColors.error
                              : const Color(0xFF8D2525),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Verified & Certified Store Pill Badge (Bottom-Right in RTL)
            Positioned(
              bottom: 18,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'متجر معتمد وموثق',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF143D2B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Color(0xFF143D2B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AtelierColors.textPrimary,
      ),
    );
  }

  /// Size Selector Row (S, M, L, XL)
  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _sizes.map((size) {
        final isSelected = _selectedSize == size;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0E2A1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0E2A1E)
                    : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              size,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Color Selector Swatches (زمردي, أسود, ذهبي)
  Widget _buildColorSelector() {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: _colors.map((variant) {
        final isSelected = _selectedColorName == variant.name;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedColorName = variant.name;
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle Swatch with Gold Border Ring when selected
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFB5874C)
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: variant.color,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                variant.name,
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Sticky Bottom Action Bar with Add to Cart and Favorite button
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF0EBE1), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Primary Add to Cart Button (Warm gold/bronze pill)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAC8042),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'إضافة إلى السلة',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Secondary Favorite Square Button
            InkWell(
              onTap: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                showCleanSnackBar(
                  context,
                  _isFavorite
                      ? 'تمت إضافة (${widget.product.name}) إلى قائمة الرغبات'
                      : 'تم إزالة المنتج من قائمة الرغبات',
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.4,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                    size: 22,
                    color: _isFavorite
                        ? AtelierColors.error
                        : const Color(0xFF191817),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductColorVariant {
  final String name;
  final Color color;

  const _ProductColorVariant({required this.name, required this.color});
}

/// Custom painter rendering clean, haute-couture vector silhouettes matching the user's mockup.
class _CoutureSilhouettePainter extends CustomPainter {
  final String category;
  final String productName;

  _CoutureSilhouettePainter({
    required this.category,
    required this.productName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFD4E5D9) // Silver-sage line art stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    if (category == 'أحذية' || productName.contains('حذاء')) {
      // Classic Oxford/Derby shoe outline
      final path = Path();
      path.moveTo(cx - 50, h * 0.6);
      path.lineTo(cx - 30, h * 0.42);
      path.quadraticBezierTo(cx - 10, h * 0.4, cx + 20, h * 0.5);
      path.quadraticBezierTo(cx + 48, h * 0.58, cx + 55, h * 0.68);
      path.quadraticBezierTo(cx + 45, h * 0.72, cx - 45, h * 0.72);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }

    if (category == 'معاطف' ||
        productName.contains('معطف') ||
        productName.contains('بدلة')) {
      // Elegant tailored coat/suit outline
      final path = Path();
      // Collar / shoulders
      path.moveTo(cx - 38, h * 0.2);
      path.lineTo(cx + 38, h * 0.2);
      // Sides down
      path.lineTo(cx + 42, h * 0.85);
      path.lineTo(cx - 42, h * 0.85);
      path.close();
      // Inner lapel V line
      path.moveTo(cx - 20, h * 0.2);
      path.lineTo(cx, h * 0.55);
      path.lineTo(cx + 20, h * 0.2);
      canvas.drawPath(path, paint);
      return;
    }

    // Default: Haute Couture A-Line Dress Silhouette (matching exact mockup!)
    final path = Path();

    // Bodice top collar line
    final topWidth = w * 0.36;
    final waistWidth = w * 0.24;
    final skirtWidth = w * 0.76;

    final topY = h * 0.16;
    final waistY = h * 0.36;
    final hemY = h * 0.86;

    // Top horizontal neckline
    path.moveTo(cx - topWidth / 2, topY);
    path.lineTo(cx + topWidth / 2, topY);

    // Right bodice slant to waist
    path.lineTo(cx + waistWidth / 2, waistY);

    // Left bodice slant to waist
    path.lineTo(cx - waistWidth / 2, waistY);
    path.close();

    // Skirt (Flared A-line)
    path.moveTo(cx - waistWidth / 2, waistY);
    path.lineTo(cx + waistWidth / 2, waistY);
    path.lineTo(cx + skirtWidth / 2, hemY);
    path.lineTo(cx - skirtWidth / 2, hemY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CoutureSilhouettePainter oldDelegate) {
    return oldDelegate.category != category ||
        oldDelegate.productName != productName;
  }
}
