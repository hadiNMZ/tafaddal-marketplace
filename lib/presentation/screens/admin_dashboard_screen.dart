import 'package:flutter/material.dart';

import '../../domain/audit_log.dart';
import '../../domain/shop_product.dart';
import '../../services/audit_service.dart';
import '../../services/catalog_service.dart';
import '../../utils/bidi_utils.dart';

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
      backgroundColor: const Color(0xFF991B1B),
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

                  // KPI Stats Row
                  _buildKpiStatsRow(),
                  const SizedBox(height: 20),

                  // Search & Filter
                  _buildSearchAndFilters(),
                  const SizedBox(height: 20),

                  Text(
                    filterTitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (!showShop104 && !showShopElegance && !showProduct)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد عناصر في قائمة ($filterTitle)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (showShop104) ...[
                      _buildShopApprovalCard(shop104),
                      const SizedBox(height: 20),
                    ],
                    if (showShopElegance) ...[
                      _buildShopApprovalCard(shopElegance),
                      const SizedBox(height: 20),
                    ],
                    if (showProduct) ...[
                      _buildProductInspectionCard(dressProduct, shopSham),
                      const SizedBox(height: 20),
                    ],
                  ],

                  // Dynamic Audit Log Card
                  _buildAuditLogCard(),
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
        const Expanded(
          child: Text(
            'إدارة العمليات والرقابة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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

  Widget _buildKpiStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            '158',
            'شحنة مكتملة',
            const Color(0xFFECFDF5),
            const Color(0xFF047857),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            '12',
            'متجر نشط',
            const Color(0xFFEFF6FF),
            const Color(0xFF1D4ED8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            '3',
            'طلبات معلقة',
            const Color(0xFFFEF3C7),
            const Color(0xFFB45309),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String value, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: textColor)),
        ],
      ),
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
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () => _searchController.clear(),
                  child: const Icon(Icons.clear, color: Colors.grey, size: 16),
                )
              else
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFilterPill('مرفوض (Rejected)', 'rejected'),
              const SizedBox(width: 6),
              _buildFilterPill('معتمد (Approved)', 'approved'),
              const SizedBox(width: 6),
              _buildFilterPill('معلق (Pending)', 'pending'),
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

  Widget _buildShopApprovalCard(Shop shop) {
    final isPending = shop.status == ApprovalStatus.pending;
    final isApproved = shop.status == ApprovalStatus.approved;

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
                  color: isApproved
                      ? const Color(0xFFECFDF5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatBidi('#${shop.id}'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isApproved ? const Color(0xFF047857) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shop.name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      isApproved
                          ? 'متجر معتمد وموثق'
                          : 'طلب توثيق واعتماد متجر',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFECFDF5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.storefront,
                  color: isApproved
                      ? const Color(0xFF047857)
                      : Colors.grey.shade700,
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
                    showCleanSnackBar(
                      context,
                      'معاينة السجل التجاري لـ ${shop.name}.pdf',
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
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'السجل التجاري.pdf',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
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
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRejectShop(shop),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _handleApproveShop(shop),
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isApproved
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isApproved ? 'تم اعتماد وتفعيل المتجر ✓' : 'تم رفض المتجر ✕',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isApproved
                        ? const Color(0xFF047857)
                        : const Color(0xFF991B1B),
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
                '\$${product.price.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'المتجر: ${shop.name}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
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
          const SizedBox(height: 10),

          // Quality Inspection Info Box
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
                Icon(Icons.check_circle, color: Color(0xFF047857), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (!isApproved)
            ElevatedButton.icon(
              onPressed: () => _handleApproveProduct(product, shop),
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'تم اعتماد ونشر المنتج للعملاء ✓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857),
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
                  final hour12 = log.timestamp.hour % 12 == 0
                      ? 12
                      : log.timestamp.hour % 12;
                  final period = log.timestamp.hour >= 12 ? 'م' : 'ص';
                  final timeStr =
                      '${hour12.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')} $period';

                  return Row(
                    children: [
                      Text(
                        formatBidi(timeStr),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatBidi(log.title),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              formatBidi(log.description),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
