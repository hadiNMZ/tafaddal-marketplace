import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/domain/shop_product.dart';

// --- TDD Test Suite ---
void main() {
  group('Sprint 1: Store & Product Constraints (CON-01, CON-02)', () {
    test('CON-02: Product creation throws error if shop_id is empty', () {
      expect(
        () => Product(id: 'p1', shopId: '', status: ApprovalStatus.approved),
        throwsArgumentError,
      );
    });

    test('CON-01: Product is NOT visible if the Shop is still pending', () {
      final pendingShop = Shop(id: 'shop_1', status: ApprovalStatus.pending);
      final approvedProduct = Product(
        id: 'prod_1',
        shopId: 'shop_1',
        status: ApprovalStatus.approved,
      );

      expect(approvedProduct.isVisibleToCustomer(pendingShop), isFalse);
    });

    test('CON-01: Product is NOT visible if the Product itself is pending', () {
      final approvedShop = Shop(id: 'shop_2', status: ApprovalStatus.approved);
      final pendingProduct = Product(
        id: 'prod_2',
        shopId: 'shop_2',
        status: ApprovalStatus.pending,
      );

      expect(pendingProduct.isVisibleToCustomer(approvedShop), isFalse);
    });

    test(
      'CON-01: Product IS visible when both Shop and Product are approved',
      () {
        final approvedShop = Shop(
          id: 'shop_3',
          status: ApprovalStatus.approved,
        );
        final approvedProduct = Product(
          id: 'prod_3',
          shopId: 'shop_3',
          status: ApprovalStatus.approved,
        );

        expect(approvedProduct.isVisibleToCustomer(approvedShop), isTrue);
      },
    );
  });
}
