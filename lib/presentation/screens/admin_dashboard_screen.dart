import 'package:flutter/material.dart';

import '../../domain/audit_log.dart';
import '../../domain/shop_product.dart';
import '../../services/audit_service.dart';

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

  late Shop _shop104;
  late Shop _shopElegance;
  late Product _dressProduct;

  @override
  void initState() {
    super.initState();
    _shop104 = Shop(
      id: 'ST-104',
      name: 'متجر لمسة أزياء',
      status: ApprovalStatus.pending,
    );
    _shopElegance = Shop(
      id: 'ST-201',
      name: 'متجر الأناقة',
      status: ApprovalStatus.approved,
    );
    _dressProduct = Product(
      id: 'PROD-501',
      shopId: 'ST-201',
      name: 'فستان سواريه',
      price: 190.0,
      status: ApprovalStatus.pending,
    );
  }

  void _handleApproveShop() {
    setState(() {
      _shop104.status = ApprovalStatus.approved;
    });

    // CON-07: Log Shop Approval
    AuditService.instance.addLog(
      AuditAction.shopApproval,
      'اعتماد متجر #${_shop104.id}',
      'بواسطة: أحمد سالم (مدير العمليات)',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B4D3E),
        content: Text(
          'تم اعتماد المتجر ${_shop104.name} (#${_shop104.id}) وتفعيله بنجاح!',
        ),
      ),
    );
  }

  void _handleRejectShop() {
    setState(() {
      _shop104.status = ApprovalStatus.rejected;
    });

    // CON-07: Log Shop Rejection
    AuditService.instance.addLog(
      AuditAction.shopApproval,
      'رفض اعتماد متجر #${_shop104.id}',
      'بواسطة: أحمد سالم (مدير العمليات)',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF991B1B),
        content: Text(
          'تم رفض اعتماد المتجر ${_shop104.name} (#${_shop104.id}).',
        ),
      ),
    );
  }

  void _handleApproveProduct() {
    setState(() {
      _dressProduct.status = ApprovalStatus.approved;
    });

    bool isVisible = false;
    try {
      isVisible = _dressProduct.isVisibleToCustomer(_shopElegance);
    } catch (e) {
      // ignore
    }

    // CON-07: Log Product Approval
    AuditService.instance.addLog(
      AuditAction.statusChange,
      'اعتماد ونشر منتج #${_dressProduct.id}',
      'بواسطة: إدارة العمليات (المنتج: ${_dressProduct.name})',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B4D3E),
        content: Text(
          'تم اعتماد ونشر المنتج (${_dressProduct.name})! حالة رؤية الزبائن (CON-01): ${isVisible ? "مرئي (True)" : "غير مرئي (False)"}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),

              // Search & Filter
              _buildSearchAndFilters(),
              const SizedBox(height: 20),

              const Text(
                'الطلبات المعلقة',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Shop Approval Card
              _buildShopApprovalCard(),
              const SizedBox(height: 20),

              // Product Inspection Card
              _buildProductInspectionCard(),
              const SizedBox(height: 20),

              // Dynamic Audit Log Card
              _buildAuditLogCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Text(
                'تفضّل Ops',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.circle, size: 8, color: Color(0xFFF59E0B)),
            ],
          ),
        ),
        const Text(
          'إدارة العمليات والرقابة',
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

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search Input
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: '...ابحث بالاسم، المعرّف، أو المتجر',
                    hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Pills
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildFilterPill('مرفوض (Rejected)', 'rejected'),
            const SizedBox(width: 6),
            _buildFilterPill('معتمد (Approved)', 'approved'),
            const SizedBox(width: 6),
            _buildFilterPill('معلق (Pending)', 'pending'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, String code) {
    final bool isSelected = _activeFilter == code;
    return InkWell(
      onTap: () => setState(() => _activeFilter = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B4D3E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B4D3E) : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildShopApprovalCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${_shop104.id}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _shop104.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'طلب توثيق واعتماد متجر',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storefront,
                  color: Colors.grey.shade700,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // File Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('معاينة السجل التجاري.pdf')),
                    );
                  },
                  child: const Text(
                    'معاينة',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF047857),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'السجل التجاري.pdf',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                    width: 40,
                    child: TextField(
                      controller: _commissionController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'نسبة العمولة:',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleRejectShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: const Color(0xFF991B1B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'رفض',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _handleApproveShop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D3E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'اعتماد',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
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
            children: [
              Text(
                '\$${_dressProduct.price.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _dressProduct.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'المتجر: ${_shopElegance.name}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checkroom,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: _handleApproveProduct,
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
              'اعتماد ونشر للعملاء',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard() {
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
              Icon(Icons.circle, size: 8, color: Color(0xFF047857)),
              Text(
                'سجل التدقيق الأمني (للقراءة فقط 🔒)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<AuditLogEntry>>(
            stream: AuditService.instance.logStream,
            initialData: AuditService.instance.logs,
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'لا توجد سجلات تدقيق حتى الآن',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final timeStr =
                      '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} AM';

                  return Row(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            log.title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            log.description,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
