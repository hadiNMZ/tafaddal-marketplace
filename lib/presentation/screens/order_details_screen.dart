import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/shipment_order.dart';
import '../../services/order_service.dart';
import '../../utils/bidi_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/atelier_components.dart';

class OrderDetailsScreen extends StatefulWidget {
  final ShipmentOrder? initialOrder;
  const OrderDetailsScreen({super.key, this.initialOrder});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String _activeOrderId;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _activeOrderId = widget.initialOrder!.id;
    } else if (OrderService.instance.orders.isNotEmpty) {
      _activeOrderId = OrderService.instance.orders.first.id;
    } else {
      _activeOrderId = 'SO-902';
    }
  }

  ShipmentOrder get _order {
    if (widget.initialOrder != null) {
      return widget.initialOrder!;
    }
    final list = OrderService.instance.orders;
    try {
      return list.firstWhere((o) => o.id == _activeOrderId);
    } catch (_) {
      return list.first;
    }
  }

  void _handleNextStage() {
    try {
      OrderState targetState = OrderState.preparing;
      if (_order.currentState == OrderState.placed) {
        targetState = OrderState.preparing;
      } else if (_order.currentState == OrderState.preparing) {
        targetState = OrderState.shipping;
      } else if (_order.currentState == OrderState.shipping) {
        targetState = OrderState.delivered;
      }

      OrderService.instance.transitionOrderState(_order, targetState);

      setState(() {});
      showCleanSnackBar(
        context,
        'تم الانتقال بنجاح إلى: ${_order.currentState.name.toUpperCase()}',
      );
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _handleInvalidTransition(OrderState targetState) {
    try {
      OrderService.instance.transitionOrderState(_order, targetState);
      setState(() {});
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _handleReturnRequest() {
    try {
      OrderService.instance.requestOrderReturn(_order);

      showCleanSnackBar(
        context,
        'تم إرسال طلب الاعتماد والاستبدال بنجاح (CON-05 Valid)',
      );
      setState(() {});
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _showExceptionSnackBar(Exception e) {
    String message = e.toString();
    if (e is IllegalStateTransitionException) {
      message = e.message;
    } else if (e is ImmutableOrderException) {
      message = e.message;
    } else if (e is InvalidReturnStateException) {
      message = e.message;
    }

    showCleanSnackBar(context, message, backgroundColor: AtelierColors.error);
  }

  int _getStepIndex() {
    switch (_order.currentState) {
      case OrderState.placed:
        return 1;
      case OrderState.preparing:
        return 2;
      case OrderState.shipping:
        return 3;
      case OrderState.delivered:
        return 4;
      case OrderState.rejected:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OrderService.instance,
      builder: (context, _) {
        final allOrders = OrderService.instance.orders;

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

                  // Interactive Order Switcher Bar
                  if (allOrders.isNotEmpty) _buildOrderSwitcher(allOrders),
                  const SizedBox(height: 24),

                  // Atelier Financial Settlement Ledger
                  _buildSettlementCard(),
                  const SizedBox(height: 24),

                  // Dispatch & Shipment Monograph Ledger
                  _buildActiveShipmentCard(),
                  const SizedBox(height: 24),

                  // Return Request Slip
                  _buildReturnRequestCard(),
                  const SizedBox(height: 28),
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
        // Title in the center (Wrapped in Expanded to prevent narrow screen overflows)
        Expanded(
          child: Text(
            'إدارة الطلبات والامتثال',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AtelierColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Shop Name Badge on the LEFT (end of screen in RTL)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AtelierColors.primaryTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AtelierColors.primaryBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _order.shopName,
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: AtelierColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 13, color: AtelierColors.gold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSwitcher(List<ShipmentOrder> allOrders) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allOrders.map((orderObj) {
          final isSelected = _activeOrderId == orderObj.id;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () => setState(() => _activeOrderId = orderObj.id),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AtelierColors.primary
                      : AtelierColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AtelierColors.primary
                        : AtelierColors.borderSubtle,
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AtelierColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : AtelierTheme.subtleShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : AtelierColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        orderObj.currentState.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AtelierColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatBidi('شحنة #${orderObj.id}'),
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AtelierColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Atelier Financial Settlement Ledger (Refined parchment ledger)
  Widget _buildSettlementCard() {
    const double totalSales = 8350.0;
    const double commissionRate = 0.15;
    const double commissionCut = totalSales * commissionRate; // 1252.50
    const double netDues = totalSales - commissionCut; // 7097.50

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AtelierColors.goldBorder.withValues(alpha: 0.7),
        ),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Right: Title & Ledger Icon
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                      color: AtelierColors.gold,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'التسوية المالية الأسبوعية',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AtelierColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Left: Period Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AtelierColors.goldTint,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AtelierColors.goldBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'دورة يناير الحالية',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AtelierColors.borderSubtle),
          const SizedBox(height: 14),

          // Ledger Key Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildSettlementMetric(
                  'صافي المستحقات',
                  '\$${netDues.toStringAsFixed(2)}',
                  AtelierColors.primary,
                  isBold: true,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: AtelierColors.borderSubtle,
              ),
              Expanded(
                child: _buildSettlementMetric(
                  'عمولة 15%',
                  '-\$${commissionCut.toStringAsFixed(2)}',
                  AtelierColors.warning,
                  isNegative: true,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: AtelierColors.borderSubtle,
              ),
              Expanded(
                child: _buildSettlementMetric(
                  'المبيعات',
                  '\$${totalSales.toInt()}',
                  AtelierColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementMetric(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    bool isNegative = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AtelierColors.textMuted,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Dispatch & Shipment Monograph Ledger
  Widget _buildActiveShipmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AtelierColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtelierColors.borderSubtle),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Shipment Title (Right) & Status Badge (Left) in strict RTL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Right: Title
              Expanded(
                child: Text(
                  formatBidi('شحنة #${_order.id}'),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AtelierColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Left: State Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AtelierColors.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AtelierColors.primaryBorder),
                ),
                child: Text(
                  _order.currentState.name.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Customer Name (Right) & Destination Address (Left) in strict RTL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Right: Customer Name
              Text(
                'العميل: ${_order.customerName}',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AtelierColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              // Left: Address with Icon & Truncation
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AtelierColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _order.shippingAddress,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AtelierColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.lock_outlined,
                      size: 11,
                      color: AtelierColors.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AtelierColors.borderSubtle),
          const SizedBox(height: 8),

          // Receipt Items List (Clean, airy, uncrowded without nested heavy boxes)
          if (_order.items.isNotEmpty)
            ..._order.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildItemRow(
                    item.productTitle,
                    item.specs,
                    '\$${(item.price * item.quantity).toInt()}',
                  ),
                  if (idx < _order.items.length - 1)
                    const Divider(
                      height: 16,
                      color: AtelierColors.borderSubtle,
                    ),
                ],
              );
            })
          else ...[
            _buildItemRow('معطف صوف كشمير', 'مقاس L • أسود', r'$120'),
            const Divider(height: 16, color: AtelierColors.borderSubtle),
            _buildItemRow('قميص كلاسيكي قطن', 'مقاس M • أبيض', r'$45'),
          ],
          const SizedBox(height: 16),
          const Divider(color: AtelierColors.borderSubtle),
          const SizedBox(height: 18),

          // Stepper Tracker Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'مسار حالة الطلب الصارم',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AtelierColors.primaryTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'المرحلة ${_getStepIndex()} من 4',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stepper Items (Cleanly centered & spaced)
          _buildStepperTracker(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildStateTransitionButtons(),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, String specs, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AtelierProductVisual(
                productName: title,
                category: '',
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Right aligned in RTL
              children: [
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AtelierColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specs,
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AtelierColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            price,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AtelierColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperTracker() {
    final int step = _getStepIndex();
    return Row(
      children: [
        _buildStepCircle(stepNum: 4, label: 'تم التسليم', activeStep: step),
        _buildStepLine(isCompleted: step >= 4),
        _buildStepCircle(stepNum: 3, label: 'قيد الشحن', activeStep: step),
        _buildStepLine(isCompleted: step >= 3),
        _buildStepCircle(stepNum: 2, label: 'قيد التحضير', activeStep: step),
        _buildStepLine(isCompleted: step >= 2),
        _buildStepCircle(stepNum: 1, label: 'تم الإنشاء', activeStep: step),
      ],
    );
  }

  Widget _buildStepCircle({
    required int stepNum,
    required String label,
    required int activeStep,
  }) {
    final bool isCompleted = activeStep > stepNum;
    final bool isCurrent = activeStep == stepNum;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AtelierColors.primary
                  : AtelierColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? AtelierColors.primary
                    : AtelierColors.border,
                width: 1.5,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AtelierColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : (isCurrent
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AtelierColors.gold,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            '$stepNum',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AtelierColors.textMuted,
                            ),
                          )),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent
                  ? AtelierColors.primary
                  : AtelierColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      width: 18,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? AtelierColors.primary : AtelierColors.border,
    );
  }

  Widget _buildStateTransitionButtons() {
    String primaryButtonText = 'تسليم لشركة الشحن (Shipping)';
    if (_order.currentState == OrderState.placed) {
      primaryButtonText = 'بدء التحضير (Preparing)';
    } else if (_order.currentState == OrderState.preparing) {
      primaryButtonText = 'تسليم لشركة الشحن (Shipping)';
    } else if (_order.currentState == OrderState.shipping) {
      primaryButtonText = 'تأكيد التسليم (Delivered)';
    } else if (_order.currentState == OrderState.delivered) {
      primaryButtonText = 'الطلب مكتمل (Delivered)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Button -> calls transitionTo()
        ElevatedButton.icon(
          onPressed:
              _order.currentState == OrderState.delivered ||
                  _order.currentState == OrderState.rejected
              ? null
              : _handleNextStage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AtelierColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: Text(
            primaryButtonText,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Secondary Action Buttons (Uncluttered, elegant & secondary)
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.delivered),
                style: TextButton.styleFrom(
                  foregroundColor: AtelierColors.textSecondary,
                  backgroundColor: AtelierColors.surfaceElevated,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.shield_outlined,
                  size: 13,
                  color: AtelierColors.textMuted,
                ),
                label: Text(
                  'تخطي (Delivered)',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.placed),
                style: TextButton.styleFrom(
                  foregroundColor: AtelierColors.textSecondary,
                  backgroundColor: AtelierColors.surfaceElevated,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.lock_reset_outlined,
                  size: 13,
                  color: AtelierColors.textMuted,
                ),
                label: Text(
                  'رجوع (Placed)',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReturnRequestCard() {
    final bool isDelivered = _order.currentState == OrderState.delivered;

    return Container(
      padding: const EdgeInsets.all(20),
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
              // Right side in RTL: Title & status dot
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isDelivered
                          ? AtelierColors.primary
                          : AtelierColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        formatBidi('طلب #${_order.id}'),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AtelierColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Left side in RTL: Eligibility Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? AtelierColors.primaryTint
                      : AtelierColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDelivered
                        ? AtelierColors.primaryBorder
                        : AtelierColors.warningBorder,
                  ),
                ),
                child: Text(
                  isDelivered ? 'مؤهل للإرجاع (Delivered)' : 'غير مؤهل للإرجاع',
                  style: GoogleFonts.tajawal(
                    fontSize: 10,
                    color: isDelivered
                        ? AtelierColors.primary
                        : AtelierColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AtelierColors.borderSubtle),
          const SizedBox(height: 8),

          // Item preview (Clean receipt row directly on white surface)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AtelierProductVisual(
                      productName: _order.items.isNotEmpty
                          ? _order.items.first.productTitle
                          : 'فستان السهرة المطرز الملكي',
                      category: '',
                      height: 44,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Right aligned in RTL
                    children: [
                      Text(
                        _order.items.isNotEmpty
                            ? _order.items.first.productTitle
                            : 'فستان السهرة المطرز الملكي',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AtelierColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'طلب استبدال المقاس من M إلى L',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AtelierColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: _handleReturnRequest,
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
              'اعتماد الاستبدال',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
