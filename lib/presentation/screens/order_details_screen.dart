import 'package:flutter/material.dart';
import '../../domain/shipment_order.dart';

class OrderDetailsScreen extends StatefulWidget {
  final ShipmentOrder? initialOrder;
  const OrderDetailsScreen({super.key, this.initialOrder});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late ShipmentOrder _order;

  @override
  void initState() {
    super.initState();
    // Default to Preparing stage as shown in Design 3 (Step 2 of 4)
    _order = widget.initialOrder ??
        ShipmentOrder(
          id: 'SO-902',
          shopId: 'shop_sham',
          shippingAddress: 'دمشق، المزة - الفيلات الغربية',
          initialState: OrderState.preparing,
        );
  }

  void _handleNextStage() {
    try {
      if (_order.currentState == OrderState.placed) {
        _order.transitionTo(OrderState.preparing);
      } else if (_order.currentState == OrderState.preparing) {
        _order.transitionTo(OrderState.shipping);
      } else if (_order.currentState == OrderState.shipping) {
        _order.transitionTo(OrderState.delivered);
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F4C3A),
          content: Text('تم تغيير حالة الشحنة بنجاح إلى: ${_order.currentState.name.toUpperCase()}'),
        ),
      );
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _handleInvalidTransition(OrderState targetState) {
    try {
      _order.transitionTo(targetState);
      setState(() {});
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _handleAddressUpdate() {
    try {
      _order.updateShippingAddress('عنوان جديد - دمشق');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F4C3A),
          content: Text('تم تحديث العنوان بنجاح!'),
        ),
      );
    } on Exception catch (e) {
      _showExceptionSnackBar(e);
    }
  }

  void _handleReturnRequest() {
    try {
      _order.requestReturn();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F4C3A),
          content: Text('تم تقديم طلب الإرجاع بنجاح (CON-05 Valid)'),
        ),
      );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF991B1B),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context),

            // Main Order Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Control Header Card
                    _buildShopHeaderCard(),
                    const SizedBox(height: 16),

                    // Financial Settlement Section
                    _buildSettlementSection(),
                    const SizedBox(height: 16),

                    // Active Order Card
                    _buildActiveShipmentCard(),
                    const SizedBox(height: 16),

                    // Stepper / Execution Track
                    _buildExecutionTrackStepper(),
                    const SizedBox(height: 16),

                    // State Transition Buttons (DOMAIN INTEGRATED)
                    _buildDomainTransitionButtons(),
                    const SizedBox(height: 16),

                    // Workflow Enforcer Rules Info Box
                    _buildWorkflowRulesBox(),
                    const SizedBox(height: 16),

                    // Pending Replacement / Return Request Card
                    _buildPendingReturnCard(),
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

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Text(
            'تفضّل',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('نشط وموثق', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'متجر أزياء الشام',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified, size: 16, color: Color(0xFF059669)),
                  ],
                ),
                Text(
                  'لوحة تحكم البائع والامتثال التشغيلي',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined, color: Colors.black87, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('دورة تسوية أسبوعية', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Row(
              children: [
                Text(
                  'التسوية المالية والعمولات',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(width: 6),
                Icon(Icons.receipt_long_outlined, color: Color(0xFFB45309), size: 18),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 16, color: Color(0xFFB45309)),
                        Text('عمولة المنصة 15%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('- \$ 1,252.5', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                    Text('تقتطع تلقائياً لكل شحنة', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.grey),
                        Text('إجمالي المبيعات', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('\$ 8,350', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('خلال هذا الشهر (يناير)', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Net Balance Dark Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F382C),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تقديم طلب التسوية بنجاح!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F382C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.account_balance_wallet, size: 16),
                label: const Text('طلب تسوية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('صافي المستحقات الجاهزة للسحب', style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC))),
                      SizedBox(width: 4),
                      Icon(Icons.lock_outlined, size: 12, color: Color(0xFF86EFAC)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    '\$ 1,250.00',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text('جاهزة للتحويل المصرفي الفوري', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveShipmentCard() {
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
                child: Text(
                  'مرحلة نشطة (${_order.currentState.name.toUpperCase()})',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'شحنة رقم #${_order.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const Text(
                        'تاريخ الطلب: اليوم 10:20 ص',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Colors.black87, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('عميل موثوق ★ 4.9', style: TextStyle(fontSize: 10, color: Colors.black87)),
                    ),
                    const Row(
                      children: [
                        Text('العميل: سامر الأحمد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(width: 4),
                        Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Text('مقفول', style: TextStyle(fontSize: 9, color: Color(0xFFB45309))),
                          SizedBox(width: 2),
                          Icon(Icons.lock_outlined, size: 10, color: Color(0xFFB45309)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'عنوان التوصيل المعتمد: ${_order.shippingAddress}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Items Required
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$ 165', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('العناصر المطلوبة للتجهيز (2)', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),

          _buildOrderItemRow('معطف صوف كشمير', 'مقاس: L | اللون: أسود فاخر', '\$ 120'),
          const SizedBox(height: 6),
          _buildOrderItemRow('قميص كلاسيكي قطن مصري', 'مقاس: M | اللون: أبيض لؤلؤي', '\$ 45'),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(String title, String specs, String price) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(specs, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionTrackStepper() {
    final int step = _getStepIndex();

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
              Text(
                'خطوة $step من 4',
                style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.bold),
              ),
              const Text(
                'شريط المسار التنفيذي الصارم',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stepper Line
          Row(
            children: [
              _buildStepItem(stepNum: 4, label: 'تم التسليم', sublabel: 'المرحلة النهائية', activeStep: step, icon: Icons.check_circle_outline),
              _buildStepLine(isCompleted: step >= 4),
              _buildStepItem(stepNum: 3, label: 'قيد الشحن', sublabel: 'مرحلة تالية', activeStep: step, icon: Icons.local_shipping_outlined),
              _buildStepLine(isCompleted: step >= 3),
              _buildStepItem(stepNum: 2, label: 'قيد التحضير', sublabel: 'الحالية', activeStep: step, icon: Icons.inventory_2_outlined),
              _buildStepLine(isCompleted: step >= 2),
              _buildStepItem(stepNum: 1, label: 'تم الإنشاء', sublabel: 'مكتملة', activeStep: step, icon: Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNum,
    required String label,
    required String sublabel,
    required int activeStep,
    required IconData icon,
  }) {
    final bool isCompleted = activeStep > stepNum;
    final bool isCurrent = activeStep == stepNum;

    Color bgColor = Colors.grey.shade200;
    Color iconColor = Colors.grey;

    if (isCompleted) {
      bgColor = const Color(0xFF059669);
      iconColor = Colors.white;
    } else if (isCurrent) {
      bgColor = const Color(0xFFB45309);
      iconColor = Colors.white;
    }

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: bgColor,
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? const Color(0xFFB45309) : (isCompleted ? const Color(0xFF059669) : Colors.black87),
            ),
          ),
          Text(
            sublabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      width: 20,
      height: 3,
      color: isCompleted ? const Color(0xFF059669) : Colors.grey.shade300,
    );
  }

  Widget _buildDomainTransitionButtons() {
    String primaryButtonText = 'التقدم إلى الخطوة التالية';
    if (_order.currentState == OrderState.placed) {
      primaryButtonText = 'بدء التحضير (الانتقال إلى Preparing)';
    } else if (_order.currentState == OrderState.preparing) {
      primaryButtonText = 'تسليم لشركة الشحن (الانتقال إلى Shipping)';
    } else if (_order.currentState == OrderState.shipping) {
      primaryButtonText = 'تأكيد التسليم (الانتقال إلى Delivered)';
    } else if (_order.currentState == OrderState.delivered) {
      primaryButtonText = 'الطلب في الحالة النهائية (Delivered)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Primary Button -> calls transitionTo()
        ElevatedButton.icon(
          onPressed: _order.currentState == OrderState.delivered || _order.currentState == OrderState.rejected
              ? null
              : _handleNextStage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.local_shipping, size: 20),
          label: Text(
            primaryButtonText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // Testing Invalid Actions / Constraint Exception Triggers
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.delivered),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.block, size: 16, color: Colors.red),
                label: const Text(
                  'تخطي إلى (Delivered)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleInvalidTransition(OrderState.placed),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.undo, size: 16, color: Colors.amber),
                label: const Text(
                  'رجوع إلى (Placed)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleReturnRequest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.assignment_return_outlined, size: 16),
                label: const Text(
                  'اختبار طلب إرجاع (CON-05)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleAddressUpdate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.edit_location_outlined, size: 16),
                label: const Text(
                  'تعديل العنوان (CON-04)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkflowRulesBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'قواعد سير العمل الصارمة (Workflow Enforcer)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
              ),
              SizedBox(width: 6),
              Icon(Icons.rule_folder_outlined, color: Color(0xFFC2410C), size: 16),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'لا يمكن العودة إلى حالة سابقة (Placed)، ولا يُسمح نظامياً بتخطي مرحلة الشحن مباشرة إلى التسليم. كل تغيير حالة يُوثّق بالتوقيع الرقمي مع رقم مندوب التوصيل في سجل التدقيق الفوري.',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: Color(0xFF9A3412), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingReturnCard() {
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
                    Text('حالة نظامية صالحة', style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                  ],
                ),
              ),
              const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'طلب استبدال معلق',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        'للطلب المسلَم رقم #SO-840',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.published_with_changes, color: Color(0xFFB45309), size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'متاح ومسموح نظامياً لأن حالة الطلب السابقة مسجلة كـ: Delivered (تم التسليم) قبل أقل من 48 ساعة.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, color: Color(0xFF047857)),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.check_circle_outline, color: Color(0xFF047857), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('فستان السهرة المطرز الملكي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('العميل يطلب استبدال المقاس من M إلى L', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('مراجعة التفاصيل', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الموافقة وإصدار بوليصة الاستبدال')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('موافقة وإصدار بوليصة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
