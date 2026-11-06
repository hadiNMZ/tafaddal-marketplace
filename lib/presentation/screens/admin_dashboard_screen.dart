import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/audit_log.dart';
import '../../domain/shop_product.dart';
import '../../services/audit_service.dart';
import '../../services/catalog_service.dart';
import '../../utils/bidi_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/atelier_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController(
    text: '12',
  );

  String _activeFilter = 'pending'; // pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleApproveShop(Shop shop) {
    CatalogService.instance.approveShop(shop.id);

    // CON-07: Log Shop Approval
    AuditService.instance.addLog(
      AuditAction.shopApproval,
      'اعتماد متجر #${shop.id}',
      'بواسطة: أحمد سالم (مدير العمليات) - تم تفعيل المتجر (${shop.name})',
      actor: 'أحمد سالم (مدير العمليات)',
      entityId: shop.id,
    );

    showCleanSnackBar(
      context,
      'تم اعتماد المتجر ${shop.name} (#${shop.id}) وتفعيله بنجاح!',
    );
  }

  void _handleRejectShop(Shop shop) {
    CatalogService.instance.rejectShop(shop.id);

    // CON-07: Log Shop Rejection
    AuditService.instance.addLog(
      AuditAction.shopApproval,
      'رفض اعتماد متجر #${shop.id}',
      'بواسطة: أحمد سالم (مدير العمليات)',
      actor: 'أحمد سالم (مدير العمليات)',
      entityId: shop.id,
    );

    showCleanSnackBar(
      context,
      'تم رفض اعتماد المتجر ${shop.name} (#${shop.id}).',
      backgroundColor: AtelierColors.error,
    );
  }

  void _handleApproveProduct(Product product, Shop shop) {
    CatalogService.instance.approveProduct(product.id);

    bool isVisible = false;
    try {
      isVisible = product.isVisibleToCustomer(shop);
    } catch (_) {}

    // CON-07: Log Product Approval
    AuditService.instance.addLog(
      AuditAction.statusChange,
      'اعتماد ونشر منتج #${product.id}',
      'بواسطة: أحمد سالم (مدير العمليات) - المنتج: ${product.name}',
      actor: 'أحمد سالم (مدير العمليات)',
      entityId: product.id,
    );

    showCleanSnackBar(
      context,
      'تم اعتماد ونشر المنتج (${product.name})! حالة رؤية الزبائن (CON-01): ${isVisible ? "مرئي (True)" : "غير مرئي (False)"}',
    );
  }

  bool _matchesFilter(ApprovalStatus status, String name, String id) {
    if (_activeFilter == 'pending' && status != ApprovalStatus.pending) {
      return false;
    }
    if (_activeFilter == 'approved' && status != ApprovalStatus.approved) {
      return false;
    }
    if (_activeFilter == 'rejected' && status != ApprovalStatus.rejected) {
      return false;
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      final matches =
          name.toLowerCase().contains(query) ||
          id.toLowerCase().contains(query);
      if (!matches) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) {
        final shop104 =
            CatalogService.instance.getShop('ST-104') ??
            Shop(
              id: 'ST-104',
              name: 'متجر لمسة أزياء',
              status: ApprovalStatus.pending,
            );
        final shopElegance =
            CatalogService.instance.getShop('shop_elegance') ??
            Shop(
              id: 'shop_elegance',
              name: 'متجر الأناقة',
              status: ApprovalStatus.approved,
            );
        final shopSham =
            CatalogService.instance.getShop('shop_sham') ??
            Shop(
              id: 'shop_sham',
              name: 'أزياء الشام',
              status: ApprovalStatus.approved,
            );

        final dressProduct =
            CatalogService.instance.getProduct('PROD-501') ??
            Product(
              id: 'PROD-501',
              shopId: 'shop_sham',
              name: 'فستان سواريه مطرز',
              price: 195.0,
              stockQuantity: 4,
              status: ApprovalStatus.pending,
            );

        final showShop104 = _matchesFilter(
          shop104.status,
          shop104.name,
          shop104.id,
        );
        final showShopElegance = _matchesFilter(
          shopElegance.status,
          shopElegance.name,
          shopElegance.id,
        );
        final showProduct = _matchesFilter(
          dressProduct.status,
          dressProduct.name,
          dressProduct.id,
        );

        final String filterTitle;
        switch (_activeFilter) {
          case 'approved':
            filterTitle = 'الطلبات المعتمدة';
            break;
          case 'rejected':
            filterTitle = 'الطلبات المرفوضة';
            break;
          case 'pending':
          default:
            filterTitle = 'الطلبات المعلقة';
            break;
        }

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
                  // Header
                  _buildTopAppBar(context),
                  const SizedBox(height: 18),

                  // KPI Stats Row
                  _buildKpiStatsRow(),
                  const SizedBox(height: 20),

                  // Search & Filter
                  _buildSearchAndFilters(),
                  const SizedBox(height: 20),

                  Text(
                    filterTitle,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AtelierColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (!showShop104 && !showShopElegance && !showProduct)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AtelierColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AtelierColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: AtelierColors.textMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'لا توجد عناصر في قائمة ($filterTitle)',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AtelierColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (showShop104) ...[
                      _buildShopApprovalCard(shop104),
                      const SizedBox(height: 18),
                    ],
                    if (showShopElegance) ...[
                      _buildShopApprovalCard(shopElegance),
                      const SizedBox(height: 18),
                    ],
                    if (showProduct) ...[
                      _buildProductInspectionCard(dressProduct, shopSham),
                      const SizedBox(height: 18),
                    ],
                  ],

                  // Dynamic Audit Log Card
                  _buildAuditLogCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button on the RIGHT (start of screen in RTL)
        IconButton(
          icon: const Icon(
            Icons.arrow_forward,
            color: AtelierColors.textPrimary,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        // Title in the center
        Expanded(
          child: Text(
            'إدارة العمليات والرقابة',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AtelierColors.textPrimary,
            ),
          ),
        ),
        // Ops Badge on the LEFT (end of screen in RTL)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AtelierColors.goldTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AtelierColors.goldBorder, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 7, color: AtelierColors.gold),
              const SizedBox(width: 4),
              Text(
                'تفضّل Ops',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: AtelierColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            '158',
            'شحنة مكتملة',
            AtelierColors.primary,
            AtelierColors.primaryTint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildKpiCard(
            '12',
            'متجر نشط',
            AtelierColors.info,
            AtelierColors.infoBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildKpiCard(
            '3',
            'طلبات معلقة',
            AtelierColors.warning,
            AtelierColors.warningBg,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String value,
    String label,
    Color accentColor,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AtelierColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AtelierColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AtelierColors.border),
            boxShadow: AtelierTheme.subtleShadow,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AtelierColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم، المعرّف، أو المتجر...',
                    hintStyle: GoogleFonts.tajawal(
                      fontSize: 11,
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
                  child: const Icon(
                    Icons.clear,
                    color: AtelierColors.textMuted,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterPill('معلق (Pending)', 'pending'),
              const SizedBox(width: 8),
              _buildFilterPill('معتمد (Approved)', 'approved'),
              const SizedBox(width: 8),
              _buildFilterPill('مرفوض (Rejected)', 'rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, String code) {
    final bool isSelected = _activeFilter == code;
    return InkWell(
      onTap: () => setState(() => _activeFilter = code),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AtelierColors.primary : AtelierColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AtelierColors.primary
                : AtelierColors.borderSubtle,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AtelierColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AtelierTheme.subtleShadow,
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AtelierColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildShopApprovalCard(Shop shop) {
    final isPending = shop.status == ApprovalStatus.pending;
    final isApproved = shop.status == ApprovalStatus.approved;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Store Avatar on the RIGHT (start of row in RTL)
              AtelierStoreAvatar(
                storeName: shop.name,
                isSelected: isApproved,
                radius: 20,
              ),
              const SizedBox(width: 12),
              // Store Name & Subtitle in the MIDDLE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Right aligned in RTL
                  children: [
                    Text(
                      shop.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AtelierColors.textPrimary,
                      ),
                    ),
                    Text(
                      isApproved
                          ? 'متجر معتمد وموثق'
                          : 'طلب توثيق واعتماد متجر',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: isApproved
                            ? AtelierColors.primary
                            : AtelierColors.goldDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Store ID Badge on the LEFT (end of row in RTL)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved
                      ? AtelierColors.primaryTint
                      : AtelierColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatBidi('#${shop.id}'),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isApproved
                        ? AtelierColors.primary
                        : AtelierColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // File Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AtelierColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AtelierColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showCleanSnackBar(
                      context,
                      'معاينة السجل التجاري لـ ${shop.name}.pdf',
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'معاينة',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: AtelierColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'السجل التجاري.pdf',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AtelierColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AtelierColors.goldDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Commission Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 44,
                    child: TextField(
                      controller: _commissionController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AtelierColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AtelierColors.gold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'نسبة العمولة:',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AtelierColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRejectShop(shop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AtelierColors.errorBg,
                      foregroundColor: AtelierColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: AtelierColors.errorBorder,
                        ),
                      ),
                    ),
                    child: Text(
                      'رفض',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _handleApproveShop(shop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AtelierColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'اعتماد',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isApproved
                    ? AtelierColors.primaryTint
                    : AtelierColors.errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isApproved
                      ? AtelierColors.primaryBorder
                      : AtelierColors.errorBorder,
                ),
              ),
              child: Center(
                child: Text(
                  isApproved ? 'تم اعتماد وتفعيل المتجر' : 'تم رفض المتجر',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isApproved
                        ? AtelierColors.primary
                        : AtelierColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInspectionCard(Product product, Shop shop) {
    final isApproved = product.status == ApprovalStatus.approved;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Product Visual Thumbnail on the RIGHT
              SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AtelierProductVisual(
                    productName: product.name,
                    category: product.category,
                    height: 48,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Name & Store in the MIDDLE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Right aligned in RTL
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AtelierColors.textPrimary,
                      ),
                    ),
                    Text(
                      'المتجر: ${shop.name}',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: AtelierColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Price on the LEFT
              Text(
                '\$${product.price.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AtelierColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quality Inspection Certificate Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AtelierColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AtelierColors.primaryBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'تم فحص الصور بدقة عالية ومطابقة معايير المنصة الفاخرة وخلو المحتوى من أي انتهاكات.',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AtelierColors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: AtelierColors.gold, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!isApproved)
            ElevatedButton.icon(
              onPressed: () => _handleApproveProduct(product, shop),
              style: ElevatedButton.styleFrom(
                backgroundColor: AtelierColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: Text(
                'اعتماد ونشر للعملاء',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AtelierColors.primaryTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AtelierColors.primaryBorder),
              ),
              child: Center(
                child: Text(
                  'تم اعتماد ونشر المنتج للعملاء',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title on the RIGHT
              Row(
                children: [
                  const Icon(
                    Icons.security,
                    size: 16,
                    color: AtelierColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'سجل التدقيق الأمني (للقراءة فقط)',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AtelierColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Status Beacon Dot on the LEFT
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AtelierColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<AuditLogEntry>>(
            stream: AuditService.instance.logStream,
            initialData: AuditService.instance.logs,
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'لا توجد سجلات تدقيق حتى الآن',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: AtelierColors.textMuted,
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 20,
                  color: AtelierColors.borderSubtle,
                ),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final hour12 = log.timestamp.hour % 12 == 0
                      ? 12
                      : log.timestamp.hour % 12;
                  final period = log.timestamp.hour >= 12 ? 'م' : 'ص';
                  final timeStr =
                      '${hour12.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} $period';

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Description on the RIGHT
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Right aligned in RTL
                          children: [
                            Text(
                              formatBidi(log.title),
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AtelierColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatBidi(log.description),
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AtelierColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Time badge on the LEFT
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AtelierColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          formatBidi(timeStr),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AtelierColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
