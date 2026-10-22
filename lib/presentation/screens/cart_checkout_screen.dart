import 'package:flutter/material.dart';

import '../../domain/shipment_order.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../utils/bidi_utils.dart';

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
          backgroundColor: const Color(0xFFF9F9F8),
          body: SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                _buildTopAppBar(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
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

                          // Delivery Address Card
                          _buildDeliveryAddressCard(),
                          const SizedBox(height: 20),

                          // Rewards & Payment Method Card
                          _buildRewardsAndPaymentCard(),
                          const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.black87,
              size: 20,
            ),
          ),
          const Text(
            'تفضّل',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(int totalItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$totalItems عناصر',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
        const Text(
          'سلة التسوق وإتمام الطلب',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCartView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'سلة التسوق فارغة حالياً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإضافة قطع مميزة من مختارات الموسم للبدء بتجهيز طلبك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onNavigateTab?.call(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'تصفح المنتجات الآن',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تم تقسيم السلة تلقائياً إلى $shipmentCount شحنات حسب المتجر',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.call_split, size: 16, color: Color(0xFF047857)),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      deliveryDays,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF047857),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatBidi('شحنة $index: $storeName (#$shipmentCode)'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              ...items.map(
                (item) => Column(
                  children: [
                    _buildCartItemRow(item),
                    const Divider(height: 20),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${subtotal.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'المجموع الفرعي (${items.length} عناصر)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () {
            CartService.instance.removeItem(item.id);
            showCleanSnackBar(context, 'تم حذف (${item.title}) من السلة');
          },
        ),
        Container(
          width: 48,
          height: 48,
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
                item.title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatBidi(item.specs),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${(item.price * item.quantity).toInt()}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      try {
                        CartService.instance.incrementQuantity(item.id);
                      } on Exception catch (e) {
                        showCleanSnackBar(
                          context,
                          e.toString(),
                          backgroundColor: const Color(0xFF991B1B),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        CartService.instance.decrementQuantity(item.id),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outlined,
              size: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'عنوان التوصيل: دمشق، المزة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'لا يمكن تعديل العنوان بعد تأكيد الطلب',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'معتمد',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF047857),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsAndPaymentCard() {
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
          // Rewards Switch Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: _useRewardPoints,
                activeTrackColor: const Color(0xFF047857),
                onChanged: (val) => setState(() => _useRewardPoints = val),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        r'استخدام 450 نقطة مكافآت (-$45)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.stars, color: Color(0xFFF59E0B), size: 18),
                    ],
                  ),
                  Text(
                    'خصم فوري مطبق',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          const Text(
            'طريقة الدفع',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF047857) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF047857)
                  : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF047857) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSubmitBar(BuildContext context, double finalTotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الإجمالي النهائي',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                '\$${finalTotal.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              try {
                // Group cart items by vendor shipment and create ShipmentOrders
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

                // Smoothly transition to the Orders tab (index 2)
                widget.onNavigateTab?.call(2);
              } on Exception catch (e) {
                showCleanSnackBar(
                  context,
                  e.toString(),
                  backgroundColor: const Color(0xFF991B1B),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text(
              'تأكيد وإرسال الطلب',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
