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
  final TextEditingController _couponController =
      TextEditingController(text: 'TAFADDAL25');

  int _item1Qty = 1;
  int _item2Qty = 1;
  int _item3Qty = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Scrollable Checkout Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Title Bar
                    _buildCartHeaderBar(),
                    const SizedBox(height: 12),

                    // Smart Split Banner
                    _buildSmartSplitBanner(),
                    const SizedBox(height: 16),

                    // Shipment 1 Card
                    _buildShipment1Card(),
                    const SizedBox(height: 16),

                    // Shipment 2 Card
                    _buildShipment2Card(),
                    const SizedBox(height: 16),

                    // Delivery Address Card
                    _buildDeliveryAddressCard(),
                    const SizedBox(height: 16),

                    // Rewards & Coupon Card
                    _buildRewardsAndCouponCard(),
                    const SizedBox(height: 16),

                    // Payment Method Card
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 16),

                    // Final Invoice Summary
                    _buildInvoiceSummaryCard(),
                    const SizedBox(height: 20),

                    // Order Submission Button
                    _buildSubmitOrderButton(context),
                    const SizedBox(height: 12),

                    // Protection Guarantee Footer
                    _buildBuyerProtectionFooter(),
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
          const Text(
            'تفضّل',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '3 عناصر',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
        const Row(
          children: [
            Text(
              'سلة التسوق وإتمام الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.shopping_bag_outlined, color: Color(0xFF9A3412)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartSplitBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'تجزئة الطلب الذكية',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.call_split, size: 16, color: Color(0xFFB45309)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'سلتك تحتوي على منتجات من متجرين مختلفين، سيتم تقسيم الطلب تلقائياً إلى شحنتين مستقلتين لضمان سرعة التوصيل وأعلى معايير الجودة.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 4,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipment1Card() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text(
                      '2-3 أيام',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.bolt, size: 12, color: Color(0xFF92400E)),
                  ],
                ),
              ),
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'شحنة 1: متجر أزياء الشام',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'رمز الحزمة: SO-902',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade200,
                    child: const Text('ش', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item 1
          _buildCartItemRow(
            title: 'جاكيت جلد راقي',
            specs: 'المقاس: L | اللون: أسود فاخر',
            badgeText: 'متبقي 2 بالمخزون فقط',
            badgeBg: const Color(0xFFFEF3C7),
            badgeColor: const Color(0xFFB45309),
            price: r'$ 120',
            qty: _item1Qty,
            onIncrement: () => setState(() => _item1Qty++),
            onDecrement: () => setState(() => _item1Qty = _item1Qty > 1 ? _item1Qty - 1 : 1),
          ),
          const Divider(height: 20),

          // Item 2
          _buildCartItemRow(
            title: 'قميص كلاسيكي قطني',
            specs: 'المقاس: M | اللون: أبيض عاجي',
            badgeText: 'متوفر للشحن الفوري',
            badgeBg: const Color(0xFFECFDF5),
            badgeColor: const Color(0xFF047857),
            price: r'$ 45',
            qty: _item2Qty,
            onIncrement: () => setState(() => _item2Qty++),
            onDecrement: () => setState(() => _item2Qty = _item2Qty > 1 ? _item2Qty - 1 : 1),
          ),
          const Divider(height: 20),

          // Subtotal
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r'$ 165',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                ':المجموع الفرعي للشحنة 1 (منتجان)',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text(
                      '3-5 أيام',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.local_shipping_outlined, size: 12, color: Colors.black87),
                  ],
                ),
              ),
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'شحنة 2: بوتيك النخبة',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'رمز الحزمة: SO-903',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade200,
                    child: const Text('ن', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item 1
          _buildCartItemRow(
            title: 'حقيبة جلدية أصلية يدوية الصنع',
            specs: 'اللون: بني كلاسيكي عتيق',
            badgeText: 'صناعة يدوية فاخرة',
            badgeBg: const Color(0xFFEFF6FF),
            badgeColor: const Color(0xFF1D4ED8),
            price: r'$ 95',
            qty: _item3Qty,
            onIncrement: () => setState(() => _item3Qty++),
            onDecrement: () => setState(() => _item3Qty = _item3Qty > 1 ? _item3Qty - 1 : 1),
          ),
          const Divider(height: 20),

          // Subtotal
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r'$ 95',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                ':المجموع الفرعي للشحنة 2 (منتج واحد)',
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
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required String price,
    required int qty,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity Controls & Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: onIncrement,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text('+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('$qty', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  InkWell(
                    onTap: onDecrement,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Item Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                specs,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Image Thumbnail
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 30),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
                child: const Row(
                  children: [
                    Text('موثق', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                    SizedBox(width: 4),
                    Icon(Icons.lock_outlined, size: 12, color: Color(0xFF047857)),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    'عنوان التوصيل المعتمد',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.location_on_outlined, color: Colors.black87, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'منزل العائلة (الأساسي)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'دمشق، المزة - فيلات عربية، بناء الياسمين ط 3، شقة 6',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '+963 456 123 944',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_city, color: Colors.grey.shade600, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Security Alert
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تنبيه أمني للطلب',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'لا يمكن تعديل بيانات الطلب أو العنوان بعد إرساله نهائياً وفق لوائح الحماية والتتبع السريع.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, color: Color(0xFF9A3412)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC2410C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsAndCouponCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'المكافآت وكوبون الخصم',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(width: 6),
              Icon(Icons.local_offer_outlined, color: Color(0xFFC2410C), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          // Coupon Input
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تطبيق الكوبون TAFADDAL25 بنجاح!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('تطبيق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _couponController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      prefixIcon: Icon(Icons.sell_outlined, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Reward Switch Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: _useRewardPoints,
                  activeTrackColor: const Color(0xFFB45309),
                  onChanged: (val) {
                    setState(() {
                      _useRewardPoints = val;
                    });
                  },
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text('450 نقطة', style: TextStyle(fontSize: 10, color: Color(0xFF92400E))),
                        SizedBox(width: 4),
                        Text(
                          'نقاط المكافآت',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                        ),
                      ],
                    ),
                    Text(
                      r'خصم 45 $ فوراً على الشحنة',
                      style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
                'مشفر وآمن 100%',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Row(
                children: [
                  Text(
                    'طريقة الدفع',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.payment, color: Colors.black87, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            id: 'wallet',
            title: 'المحفظة الإلكترونية الرقمية',
            subtitle: 'سيريتل كاش / شام بنك / Apple Pay',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            id: 'card',
            title: 'بطاقة ائتمان / مدى',
            subtitle: 'Visa / MasterCard / البطاقات الوطنية',
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            id: 'cod',
            title: 'الدفع عند الاستلام (COD)',
            subtitle: r'رسوم تحصيل إضافية تدفع لمندوب التوصيل + $2',
            badgeText: r'+$2',
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badgeText,
  }) {
    final bool isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.black : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (badgeText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.black87, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSummaryCard() {
    final double productsTotal = 260;
    final double shippingFee = 15;
    final double rewardDiscount = _useRewardPoints ? 45 : 0;
    final double grandTotal = productsTotal + shippingFee - rewardDiscount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تفاصيل الفاتورة النهائية',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          _buildInvoiceRow('مجموع المنتجات (3 عناصر)', '\$ ${productsTotal.toInt()}'),
          const SizedBox(height: 6),
          _buildInvoiceRow('تكلفة الشحن والتوصيل', '\$ ${shippingFee.toInt()}', badge: 'شحنتين'),
          if (_useRewardPoints) ...[
            const SizedBox(height: 6),
            _buildInvoiceRow('خصم نقاط المكافآت', '-\$ ${rewardDiscount.toInt()}', color: const Color(0xFF047857), isBold: true),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$ ${grandTotal.toInt()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'المبلغ الإجمالي المستحق',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (_useRewardPoints)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        r'وفرت $ 45 بهذا الطلب',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {String? badge, Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Row(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: const TextStyle(fontSize: 9, color: Colors.black87)),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.black54,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitOrderButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Instantiate real domain shipment order objects to verify domain classes
        final order1 = ShipmentOrder(id: 'SO-902', shopId: 'shop_sham');
        final order2 = ShipmentOrder(id: 'SO-903', shopId: 'shop_nokhba');

        if (widget.onOrderSubmitted != null) {
          widget.onOrderSubmitted!(order1);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F4C3A),
            content: Text(
              'تم إنشاء الشحنتين (${order1.id} & ${order2.id}) بنجاح! الحالة: ${order1.currentState.name}',
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SO-902 & SO-903',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'تأكيد وإرسال الطلب',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerProtectionFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ضمان حماية المشتري، وإرجاع ميسر خلال 14 يوماً',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        SizedBox(width: 4),
        Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF059669)),
      ],
    );
  }
}
