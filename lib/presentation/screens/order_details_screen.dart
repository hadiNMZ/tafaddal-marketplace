import 'package:flutter/material.dart';

import '../../domain/shipment_order.dart';
import '../../services/order_service.dart';
import '../../utils/bidi_utils.dart';

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

    showCleanSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF991B1B),
    );
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
          backgroundColor: const Color(0xFFF9F9F8),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildTopAppBar(context),
                  const SizedBox(height: 16),

                  // Interactive Order Switcher Bar
                  if (allOrders.isNotEmpty) _buildOrderSwitcher(allOrders),
                  const SizedBox(height: 20),

                  // Settlement Summary Card
                  _buildSettlementCard(),
                  const SizedBox(height: 20),

                  // Active Shipment Card
                  _buildActiveShipmentCard(),
                  const SizedBox(height: 20),

                  // Return Request Card
                  _buildReturnRequestCard(),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _order.shopName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF047857),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.check_circle,
                size: 12,
                color: Color(0xFF047857),
              ),
            ],
          ),
        ),
        const Text(
          'إدارة الطلبات والامتثال',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.black87),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _buildOrderSwitcher(List<ShipmentOrder> allOrders) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: allOrders.map((orderObj) {
          final isSelected = _activeOrderId == orderObj.id;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(
              onTap: () => setState(() => _activeOrderId = orderObj.id),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1B4D3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1B4D3E)
                        : Colors.grey.shade300,
                  ),
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
                            ? Colors.white24
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        orderObj.currentState.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatBidi('شحنة #${orderObj.id}'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
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

  Widget _buildSettlementCard() {
    const double totalSales = 8350.0;
    const double commissionRate = 0.15;
    const double commissionCut = totalSales * commissionRate; // 1252.50
    const double netDues = totalSales - commissionCut; // 7097.50

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'دورة يناير الحالية',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                'التسوية المالية الأسبوعية',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSettlementMetric(
                'صافي المستحقات',
                '\$${netDues.toStringAsFixed(2)}',
                const Color(0xFF047857),
                isBold: true,
              ),
              Container(width: 1, height: 32, color: Colors.grey.shade200),
              _buildSettlementMetric(
                'عمولة 15%',
                '-\$${commissionCut.toStringAsFixed(2)}',
                const Color(0xFFD97706),
              ),
              Container(width: 1, height: 32, color: Colors.grey.shade200),
              _buildSettlementMetric(
                'المبيعات',
                '\$${totalSales.toInt()}',
                Colors.black87,
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
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveShipmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _order.shippingAddress,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.lock_outlined,
                      size: 10,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _order.currentState.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatBidi('شحنة #${_order.id}'),
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
          const SizedBox(height: 2),
          Text(
            'العميل: ${_order.customerName}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          // Items List
          if (_order.items.isNotEmpty)
            ..._order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildItemRow(
                  item.productTitle,
                  item.specs,
                  '\$${(item.price * item.quantity).toInt()}',
                ),
              ),
            )
          else ...[
            _buildItemRow('معطف صوف كشمير', 'مقاس L • أسود', r'$120'),
            const SizedBox(height: 8),
            _buildItemRow('قميص كلاسيكي قطن', 'مقاس M • أبيض', r'$45'),
          ],
          const SizedBox(height: 16),

          // Stepper Tracker Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المرحلة ${_getStepIndex()} من 4',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF047857),
                ),
              ),
              const Text(
                'مسار حالة الطلب الصارم',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper Items
          _buildStepperTracker(),
          const SizedBox(height: 16),

          // Action Buttons
          _buildStateTransitionButtons(),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, String specs, String price) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                specs,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          price,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? const Color(0xFF1B4D3E)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? const Color(0xFF1B4D3E)
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : (isCurrent
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            '$stepNum',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          )),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? const Color(0xFF1B4D3E) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      width: 16,
      height: 2,
      color: isCompleted ? const Color(0xFF1B4D3E) : Colors.grey.shade300,
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
            backgroundColor: const Color(0xFF1B4D3E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: Text(
            primaryButtonText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        // Secondary Invalid Action Buttons (Testing domain exceptions)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.delivered),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.lock_outlined, size: 14),
                label: const Text(
                  'تخطي (Delivered)',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.placed),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.lock_outlined, size: 14),
                label: const Text(
                  'رجوع (Placed)',
                  style: TextStyle(fontSize: 11),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                  color: isDelivered
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDelivered ? 'مؤهل للإرجاع (Delivered)' : 'غير مؤهل للإرجاع',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDelivered
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isDelivered
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatBidi('طلب #${_order.id}'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _order.items.isNotEmpty
                            ? _order.items.first.productTitle
                            : 'فستان السهرة المطرز الملكي',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'طلب استبدال المقاس من M إلى L',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _handleReturnRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text(
              'اعتماد الاستبدال',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
