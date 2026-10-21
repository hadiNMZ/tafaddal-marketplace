import 'package:flutter/material.dart';

import '../../domain/shipment_order.dart';

class CartCheckoutScreen extends StatefulWidget {
  final Function(ShipmentOrder)? onOrderSubmitted;
  const CartCheckoutScreen({super.key, this.onOrderSubmitted});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  bool _useRewardPoints = true;
  String _selectedPaymentMethod = 'wallet';

  int _item1Qty = 1;
  int _item2Qty = 1;
  int _item3Qty = 1;

  @override
  Widget build(BuildContext context) {
    final double productsTotal = 260;
    final double shippingFee = 15;
    final double discount = _useRewardPoints ? 45 : 0;
    final double finalTotal = productsTotal + shippingFee - discount;

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
                    _buildTitleBar(),
                    const SizedBox(height: 20),

                    // Smart Split Banner
                    _buildSmartSplitBanner(),
                    const SizedBox(height: 20),

                    // Shipment 1 Card
                    _buildShipment1Card(),
                    const SizedBox(height: 20),

                    // Shipment 2 Card
                    _buildShipment2Card(),
                    const SizedBox(height: 20),

                    // Delivery Address Card
                    _buildDeliveryAddressCard(),
                    const SizedBox(height: 20),

                    // Rewards & Payment Method Card
                    _buildRewardsAndPaymentCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Invoice & Submit Bar
            _buildBottomSubmitBar(context, finalTotal),
          ],
        ),
      ),
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

  Widget _buildTitleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '3 عناصر',
            style: TextStyle(fontSize: 11, color: Colors.black87),
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

  Widget _buildSmartSplitBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تم تقسيم السلة تلقائياً إلى شحنتين حسب المتجر',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.call_split, size: 16, color: Color(0xFF047857)),
        ],
      ),
    );
  }

  Widget _buildShipment1Card() {
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2-3 أيام',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF047857)),
                  SizedBox(width: 6),
                  Text(
                    'شحنة 1: متجر أزياء الشام (#SO-902)',
                    style: TextStyle(
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

          _buildCartItemRow(
            title: 'جاكيت جلد راقي',
            specs: 'المقاس: L | أسود',
            price: r'$120',
            qty: _item1Qty,
            onIncrement: () => setState(() => _item1Qty++),
            onDecrement: () =>
                setState(() => _item1Qty = _item1Qty > 1 ? _item1Qty - 1 : 1),
          ),
          const Divider(height: 20),

          _buildCartItemRow(
            title: 'قميص كلاسيكي قطني',
            specs: 'المقاس: M | أبيض عاجي',
            price: r'$45',
            qty: _item2Qty,
            onIncrement: () => setState(() => _item2Qty++),
            onDecrement: () =>
                setState(() => _item2Qty = _item2Qty > 1 ? _item2Qty - 1 : 1),
          ),
          const Divider(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r'$165',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'المجموع الفرعي (منتجان)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipment2Card() {
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3-5 أيام',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Color(0xFF047857)),
                  SizedBox(width: 6),
                  Text(
                    'شحنة 2: بوتيك النخبة (#SO-903)',
                    style: TextStyle(
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

          _buildCartItemRow(
            title: 'حقيبة جلدية أصلية',
            specs: 'اللون: بني كلاسيكي',
            price: r'$95',
            qty: _item3Qty,
            onIncrement: () => setState(() => _item3Qty++),
            onDecrement: () =>
                setState(() => _item3Qty = _item3Qty > 1 ? _item3Qty - 1 : 1),
          ),
          const Divider(height: 20),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r'$95',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'المجموع الفرعي (منتج واحد)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow({
    required String title,
    required String specs,
    required String price,
    required int qty,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specs,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              price,
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
                    onTap: onIncrement,
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
                    '$qty',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: onDecrement,
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
              final order1 = ShipmentOrder(id: 'SO-902', shopId: 'shop_sham');
              final order2 = ShipmentOrder(id: 'SO-903', shopId: 'shop_nokhba');

              if (widget.onOrderSubmitted != null) {
                widget.onOrderSubmitted!(order1);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1B4D3E),
                  content: Text(
                    'تم تأكيد وإرسال الطلب (${order1.id} & ${order2.id}) بنجاح!',
                  ),
                ),
              );
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
