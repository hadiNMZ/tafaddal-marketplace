import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/shipment_order.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../utils/bidi_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/atelier_components.dart';

class CartCheckoutScreen extends StatefulWidget {
  final Function(ShipmentOrder)? onOrderSubmitted;
  final Function(int)? onNavigateTab;
  const CartCheckoutScreen({
    super.key,
    this.onOrderSubmitted,
    this.onNavigateTab,
  });

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  bool _useRewardPoints = true;
  String _selectedPaymentMethod = 'wallet';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final cartItems = CartService.instance.items;
        final double productsTotal = CartService.instance.productsTotal;
        final double shippingFee = cartItems.isNotEmpty ? 15 : 0;
        final double discount = (_useRewardPoints && cartItems.isNotEmpty)
            ? 45
            : 0;
        final double finalTotal = (productsTotal + shippingFee - discount)
            .clamp(0, double.infinity);

        return Scaffold(
          backgroundColor: AtelierColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Top Masthead Bar
                _buildTopAppBar(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Bar
                        _buildTitleBar(cartItems.length),
                        const SizedBox(height: 20),

                        if (cartItems.isEmpty) ...[
                          _buildEmptyCartView(),
                        ] else ...[
                          // Smart Split Banner
                          _buildSmartSplitBanner(),
                          const SizedBox(height: 20),

                          // Grouped Shipment Cards
                          ..._buildGroupedShipmentCards(),

                          // Inset Grouped Surface for Delivery, Rewards & Payment
                          _buildCheckoutPreferencesPanel(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Invoice & Submit Bar
                if (cartItems.isNotEmpty)
                  _buildBottomSubmitBar(context, finalTotal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => showAtelierNotificationsModal(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AtelierColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AtelierColors.borderSubtle),
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
                    top: 9,
                    right: 9,
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
          Column(
            children: [
              Text(
                'تفضّل',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AtelierColors.primary,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'CHECKOUT & DISPATCH',
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AtelierColors.goldDark,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40), // Optical balance spacer
        ],
      ),
    );
  }

  Widget _buildTitleBar(int totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Right side in RTL: Title
        Expanded(
          child: Text(
            'سلة التسوق وإتمام الطلب',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AtelierColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Left side in RTL: Count Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AtelierColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AtelierColors.borderSubtle),
          ),
          child: Text(
            '$totalItems عناصر',
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AtelierColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCartView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AtelierColors.goldTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: AtelierColors.gold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'سلة التسوق فارغة حالياً',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AtelierColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة قطع مميزة من مختارات الموسم للبدء بتجهيز طلبك الفاخر',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AtelierColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onNavigateTab?.call(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AtelierColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'تصفح المنتجات الآن',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSplitBanner() {
    final grouped = CartService.instance.groupedByShipment;
    final shipmentCount = grouped.keys.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AtelierColors.primaryTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AtelierColors.primaryBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, size: 18, color: AtelierColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'تم تقسيم السلة تلقائياً إلى $shipmentCount شحنات حسب المتجر',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AtelierColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedShipmentCards() {
    final grouped = CartService.instance.groupedByShipment;
    final List<Widget> cards = [];

    int index = 1;
    grouped.forEach((shipmentCode, items) {
      final storeName = items.first.storeName;
      final deliveryDays = items.first.deliveryDays;
      final double subtotal = items.fold(
        0,
        (sum, i) => sum + (i.price * i.quantity),
      );

      cards.add(
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AtelierColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AtelierColors.borderSubtle, width: 1.0),
            boxShadow: AtelierTheme.subtleShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shipment Header (Strict RTL: Title on Right, Delivery pill on Left)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right side in RTL: Shipment Title & Store Badge
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AtelierColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: AtelierColors.borderSubtle),
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            size: 15,
                            color: AtelierColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formatBidi('شحنة $index: $storeName (#$shipmentCode)'),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AtelierColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Left side in RTL: Delivery Days Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AtelierColors.goldTint,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AtelierColors.goldBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 12, color: AtelierColors.goldDark),
                        const SizedBox(width: 4),
                        Text(
                          deliveryDays,
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AtelierColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...items.map(
                (item) => Column(
                  children: [
                    _buildCartItemRow(item),
                    const Divider(height: 24, color: AtelierColors.borderSubtle),
                  ],
                ),
              ),

              // Subtotal Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'المجموع الفرعي (${items.length} عناصر)',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AtelierColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${subtotal.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AtelierColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      index++;
    });

    return cards;
  }

  Widget _buildCartItemRow(CartItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Right side in RTL: Mini couture thumbnail visual
        SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AtelierProductVisual(
              productName: item.title,
              category: '',
              height: 50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Middle: Title and Specs (Aligned to Right in RTL)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AtelierColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatBidi(item.specs),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AtelierColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Stepper: [- Qty +]
        Container(
          height: 28,
          decoration: BoxDecoration(
            color: AtelierColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AtelierColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  try {
                    CartService.instance.incrementQuantity(item.id);
                  } on Exception catch (e) {
                    showCleanSnackBar(
                      context,
                      e.toString(),
                      backgroundColor: AtelierColors.error,
                    );
                  }
                },
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AtelierColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${item.quantity}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    CartService.instance.decrementQuantity(item.id),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AtelierColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Item Price (Numeral in Outfit font)
        Text(
          '\$${(item.price * item.quantity).toInt()}',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AtelierColors.textPrimary,
          ),
        ),
        // Left side in RTL: Delete Button
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AtelierColors.textMuted,
            size: 19,
          ),
          splashRadius: 18,
          onPressed: () {
            CartService.instance.removeItem(item.id);
            showCleanSnackBar(context, 'تم حذف (${item.title}) من السلة');
          },
        ),
      ],
    );
  }

  /// Inset Grouped Surface for Delivery Address, Loyalty Rewards, and Payment Options
  Widget _buildCheckoutPreferencesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Eyebrow Header with Hairline Accent
        Row(
          children: [
            Flexible(
              child: Text(
                'إعدادات التسليم والامتيازات',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AtelierColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Divider(
                height: 1,
                thickness: 0.8,
                color: AtelierColors.borderSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Unified Inset Grouped Surface
        Container(
          decoration: BoxDecoration(
            color: AtelierColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AtelierColors.borderSubtle, width: 1.0),
            boxShadow: AtelierTheme.subtleShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Delivery Address Row
              _buildDeliveryAddressRow(),

              // Hairline Row Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, thickness: 0.8, color: AtelierColors.borderSubtle),
              ),

              // 2. Privilege Rewards Switch Row
              _buildRewardsRow(),

              // Hairline Row Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, thickness: 0.8, color: AtelierColors.borderSubtle),
              ),

              // 3. Payment Method Section
              _buildPaymentMethodSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Right side in RTL: Location Icon Circle
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AtelierColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 19,
              color: AtelierColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Middle in RTL: Address Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان التوصيل: دمشق، المزة',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'لا يمكن تعديل العنوان بعد تأكيد الطلب',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AtelierColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Left side in RTL: Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AtelierColors.primaryTint,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AtelierColors.primaryBorder),
            ),
            child: Text(
              'معتمد',
              style: GoogleFonts.tajawal(
                fontSize: 10,
                color: AtelierColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right side in RTL: Star Icon & Info
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AtelierColors.goldTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              size: 20,
              color: AtelierColors.goldDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r'استخدام 450 نقطة مكافآت (-$45)',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _useRewardPoints
                      ? 'خصم فوري مطبق على إجمالي الطلب'
                      : 'تم إلغاء استخدام النقاط',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _useRewardPoints ? AtelierColors.goldDark : AtelierColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Left side in RTL: Switch
          Switch(
            value: _useRewardPoints,
            activeThumbColor: Colors.white,
            activeTrackColor: AtelierColors.primary,
            inactiveTrackColor: AtelierColors.surfaceSubtle,
            onChanged: (val) => setState(() => _useRewardPoints = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'طريقة الدفع',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AtelierColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'دفع مشفر وآمن',
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AtelierColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment Options Row
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodPill(
                  'wallet',
                  'محفظة',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodPill(
                  'card',
                  'بطاقة',
                  Icons.credit_card_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodPill(
                  'cash',
                  'نقداً',
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodPill(String id, String label, IconData icon) {
    final bool isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AtelierColors.primaryTint : AtelierColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AtelierColors.primary : AtelierColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AtelierColors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AtelierColors.primary
                  : AtelierColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AtelierColors.primary : AtelierColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSubmitBar(BuildContext context, double finalTotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AtelierColors.surface,
        border: Border(top: BorderSide(color: AtelierColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A1A1208),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الإجمالي النهائي',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AtelierColors.textMuted,
                ),
              ),
              Text(
                '\$${finalTotal.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AtelierColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () {
                try {
                  final grouped = CartService.instance.groupedByShipment;
                  final newOrders = OrderService.instance.createOrdersFromCart(
                    grouped,
                  );

                  if (widget.onOrderSubmitted != null && newOrders.isNotEmpty) {
                    widget.onOrderSubmitted!(newOrders.first);
                  }

                  CartService.instance.clearCart();

                  final orderIds = newOrders.map((o) => o.id).join(' & ');
                  showCleanSnackBar(
                    context,
                    'تم تأكيد وإرسال الشحنات ($orderIds) بنجاح!',
                  );

                  widget.onNavigateTab?.call(2);
                } on Exception catch (e) {
                  showCleanSnackBar(
                    context,
                    e.toString(),
                    backgroundColor: AtelierColors.error,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AtelierColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(
                'تأكيد وإرسال الطلب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
