import 'package:flutter/material.dart';
import '../../domain/shop_product.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController(text: '12');

  String _activeFilter = 'pending'; // all, pending, approved, rejected

  // Domain state instances
  late Shop _shop104;
  late Shop _shopElegance;
  late Product _dressProduct;

  @override
  void initState() {
    super.initState();
    // Initialize Domain Entities matching design
    _shop104 = Shop(id: 'ST-104', name: 'متجر لمسة أزياء', status: ApprovalStatus.pending);
    _shopElegance = Shop(id: 'ST-201', name: 'متجر الأناقة', status: ApprovalStatus.approved);
    _dressProduct = Product(
      id: 'PROD-501',
      shopId: 'ST-201',
      name: 'فستان سواريه مخملي فاخر',
      price: 190.0,
      status: ApprovalStatus.pending,
    );
  }

  void _handleApproveShop() {
    setState(() {
      _shop104.status = ApprovalStatus.approved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F4C3A),
        content: Text('تم اعتماد المتجر ${_shop104.name} (#${_shop104.id}) وتفعيله بنجاح!'),
      ),
    );
  }

  void _handleRejectShop() {
    setState(() {
      _shop104.status = ApprovalStatus.rejected;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF991B1B),
        content: Text('تم رفض اعتماد المتجر ${_shop104.name} (#${_shop104.id}).'),
      ),
    );
  }

  void _handleApproveProduct() {
    setState(() {
      _dressProduct.status = ApprovalStatus.approved;
    });

    // Test Domain Visibility Guard (CON-01)
    bool isVisible = false;
    try {
      isVisible = _dressProduct.isVisibleToCustomer(_shopElegance);
    } catch (e) {
      // ignore
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F4C3A),
        content: Text(
          'تم اعتماد ونشر المنتج (${_dressProduct.name})! فحص الرؤية للزبائن CON-01: ${isVisible ? "مرئي للزبائن (True)" : "غير مرئي (False)"}',
        ),
      ),
    );
  }

  void _testEmptyShopIdConstraint() {
    try {
      // CON-02: Mandatory Tenant Link -> throws ArgumentError
      Product(id: 'invalid_p', shopId: '', status: ApprovalStatus.approved);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF991B1B),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
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

            // Scrollable Dashboard Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ops Control Header
                    _buildOpsHeaderCard(),
                    const SizedBox(height: 16),

                    // Search & Filter Controls
                    _buildSearchAndFilterSection(),
                    const SizedBox(height: 16),

                    // Section Title
                    _buildPendingApprovalsTitle(),
                    const SizedBox(height: 12),

                    // Pending Shop Approval Request Card
                    _buildShopApprovalCard(),
                    const SizedBox(height: 16),

                    // Pending Product Inspection Request Card
                    _buildProductInspectionCard(),
                    const SizedBox(height: 16),

                    // Immutable Audit Log Section
                    _buildAuditLogSection(),
                    const SizedBox(height: 16),

                    // WebSocket Footer Indicator
                    _buildWebSocketFooter(),
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

  Widget _buildOpsHeaderCard() {
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('تفضّل Ops', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF047857)),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    'إدارة الرقابة والعمليات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.circle, color: Color(0xFFF59E0B), size: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'الحوكمة الفورية، اعتماد الشركاء، وسجل المعاملات المشفّر للمنصة',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Metrics Pills
          Row(
            children: [
              _buildMetricPill('3', 'اعتماد معلّق', const Color(0xFFFEF3C7), const Color(0xFFB45309), Icons.pending_actions),
              const SizedBox(width: 8),
              _buildMetricPill('2', 'فحص منتجات', const Color(0xFFECFDF5), const Color(0xFF047857), Icons.verified),
              const SizedBox(width: 8),
              _buildMetricPill('نشط', 'تدقيق أمني', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), Icons.lock_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String count, String label, Color bg, Color textCol, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: textCol),
                const SizedBox(width: 4),
                Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textCol)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: textCol)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Input
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'ابحث بالاسم، المعرّف (ID)، أو اسم المتجر...',
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildFilterPill('الكل', 'all'),
            const SizedBox(width: 6),
            _buildFilterPill('معلق (Pending)', 'pending', count: '3'),
            const SizedBox(width: 6),
            _buildFilterPill('معتمد (Approved)', 'approved'),
            const SizedBox(width: 6),
            _buildFilterPill('مرفوض', 'rejected'),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: [
              _buildTagPill('آخر 7 أيام', Icons.calendar_today),
              const SizedBox(width: 6),
              _buildTagPill('إرجاع', Icons.assignment_return),
              const SizedBox(width: 6),
              _buildTagPill('منتجات (2)', Icons.checkroom),
              const SizedBox(width: 6),
              _buildTagPill('متاجر (3)', Icons.store),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, String code, {String? count}) {
    final bool isSelected = _activeFilter == code;
    return InkWell(
      onTap: () => setState(() => _activeFilter = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (count != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white24 : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('إجراء مطلوب', style: TextStyle(fontSize: 10, color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
        ),
        const Row(
          children: [
            Text(
              'طلبات الاعتماد والرقابة المعلقة',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(width: 6),
            Icon(Icons.gavel_outlined, color: Color(0xFFB45309), size: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildShopApprovalCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _shop104.status == ApprovalStatus.approved
              ? const Color(0xFF059669)
              : (_shop104.status == ApprovalStatus.rejected ? Colors.red : const Color(0xFFF59E0B)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID #${_shop104.id}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _shop104.status.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _shop104.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'المالك: ريم الخالد • تقديم: منذ ساعتين',
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // PDF Commercial Register
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('عرض معاينة السجل التجاري الموثق.pdf')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('معاينة', style: TextStyle(fontSize: 11)),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('السجل التجاري الموثق.pdf', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('مفحوص ومطابق للهيئة', style: TextStyle(fontSize: 9, color: Color(0xFF047857))),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.picture_as_pdf, color: Color(0xFF047857), size: 24),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Inputs Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('سياسة الإرجاع المعتمدة', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          Text('14 يوماً (أزياء راقية)', style: TextStyle(fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('نسبة عمولة المنصة (%)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _commissionController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: '%',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleRejectShop,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF991B1B),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('رفض مع سبب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _handleApproveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF032B20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF34D399)),
                  label: const Text('اعتماد المتجر وتفعيله', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductInspectionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _dressProduct.status == ApprovalStatus.approved ? const Color(0xFF059669) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('\$ ${_dressProduct.price.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('فحص جودة العرض', style: TextStyle(fontSize: 9, color: Color(0xFFB45309))),
                      ),
                      const SizedBox(width: 6),
                      Text(_dressProduct.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Text('المتجر: ${_shopElegance.name} • أزياء نسائية سهرة', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.checkroom, color: Colors.grey.shade600, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quality Inspection Check
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
                    'تم فحص الصور بدقة عالية ومطابقة معايير المنصة الفاخرة وخلو المحتوى من أي انتهاكات.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, color: Color(0xFF047857)),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.verified, color: Color(0xFF047857), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال طلب تعديل البيانات للتاجر')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('طلب تعديل بيانات', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _handleApproveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF032B20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.publish, size: 16, color: Color(0xFF34D399)),
                  label: const Text('اعتماد ونشر فوراً', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Test Constraint CON-02 Button
          OutlinedButton.icon(
            onPressed: _testEmptyShopIdConstraint,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade800,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('اختبار ربط متجر فارغ (CON-02)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogSection() {
    final logs = [
      {
        'time': 'AM 10:42',
        'title': 'اعتماد متجر جديد',
        'desc': 'قام مدير العمليات - أحمد سالم باعتمد متجر #104 (متجر لمسة أزياء) بنسبة عمولة متفق عليها 12%.',
        'tx': 'TX: 0x9f8c...3b41',
      },
      {
        'time': 'AM 10:38',
        'title': 'تحديث مسار طلب',
        'desc': 'تم تغيير حالة الطلب #SO-902 من [Placed] إلى [Preparing] بواسطة التاجر (أزياء الشام).',
        'tx': 'TX: 0x7a11...4e89',
      },
      {
        'time': 'AM 10:15',
        'title': 'حكم إرجاع نزاع',
        'desc': 'قرار قبول طلب إرجاع #RET-12 للطلب المسلَم #SO-840 وفق سياسة حماية العميل (14 يوماً).',
        'tx': 'TX: 0x4d66...12cd',
      },
      {
        'time': 'AM 09:30',
        'title': 'مصادقة أمنية',
        'desc': 'محاولة تسجيل دخول ناجحة بحساب مسؤول النظام من عنوان موثوق IP (194.32.78.10).',
        'tx': 'TX: 0x11be...99aa',
      },
    ];

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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('للقراءة فقط (Read-Only)', style: TextStyle(fontSize: 9, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
              ),
              const Row(
                children: [
                  Text(
                    'سجل التدقيق الأمني والعمليات',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.shield, color: Colors.black87, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hash Chain Info Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'سجل مشفر غير قابل للتعديل الرجعي',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        'سلسلة تدقيق أمنية موثقة بتقنية Hash-Chain المعيارية',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.lock, size: 18, color: Colors.black87),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Log Entries List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['time']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.verified_outlined, size: 12, color: Color(0xFF059669)),
                            const SizedBox(width: 4),
                            Text(
                              log['title']!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log['desc']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 10, color: Colors.black87, height: 1.3),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log['tx']!,
                            style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.lock_clock, size: 16, color: Color(0xFF059669)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebSocketFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'تحديث تدفق العمليات مباشر (WebSocket مشفر متصل)',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        SizedBox(width: 6),
        Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
      ],
    );
  }
}
