# 🛍️ Tafaddal Marketplace ("تفضّل")

A multi-vendor fashion e-commerce marketplace built with **Flutter**, **Dart**, and strict **Domain-Driven Design (DDD)** and **Test-Driven Development (TDD)** principles.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

---

## 📌 Architecture & Design Principles

* **Domain-Driven Design (DDD):** Pure, framework-decoupled domain models with explicit business invariants and guards.
* **Test-Driven Development (TDD):** Automated test suite covering 100% of business constraints (`CON-01` through `CON-07`).
* **Clean Arabic RTL UI:** Material 3 responsive layouts tailored for native Arabic RTL e-commerce workflows.

---

## 🔒 Mandatory Business Constraints (`CON-01` - `CON-07`)

| Constraint | Description | Implementation |
| :--- | :--- | :--- |
| **`CON-01`** | Unapproved products/shops cannot be visible to customers. | [`Product.isVisibleToCustomer(Shop)`](lib/domain/shop_product.dart) |
| **`CON-02`** | Every product must be linked to a valid `shopId`. | [`Product`](lib/domain/shop_product.dart) constructor check |
| **`CON-03`** | Order item quantity cannot exceed available inventory stock. | [`Product.validateStock()`](lib/domain/shop_product.dart) & [`InsufficientStockException`](lib/domain/shop_product.dart) |
| **`CON-04`** | Order details cannot be modified after placement. | [`ShipmentOrder.updateShippingAddress()`](lib/domain/shipment_order.dart) & [`ImmutableOrderException`](lib/domain/shipment_order.dart) |
| **`CON-05`** | Return/exchange requests are only allowed for `Delivered` orders. | [`ShipmentOrder.requestReturn()`](lib/domain/shipment_order.dart) & [`InvalidReturnStateException`](lib/domain/shipment_order.dart) |
| **`CON-06`** | Sequential workflow state machine (`Placed` $\rightarrow$ `Preparing` $\rightarrow$ `Shipping` $\rightarrow$ `Delivered`). | [`ShipmentOrder.transitionTo()`](lib/domain/shipment_order.dart) & [`IllegalStateTransitionException`](lib/domain/shipment_order.dart) |
| **`CON-07`** | Append-only, immutable cryptographic audit trail. | [`AuditService`](lib/services/audit_service.dart) & [`AuditLogEntry`](lib/domain/audit_log.dart) |

---

## 📱 Application Screens (`lib/presentation/screens/`)

1. **`HomeScreen`**: Marketplace showcase, certified stores, reward points banner (`TAFADDAL25`), and product grid.
2. **`CartCheckoutScreen`**: Smart multi-vendor cart splitting (`SO-902` & `SO-903`), address lock, payment selector, and invoice summary.
3. **`OrderDetailsScreen`**: Vendor weekly financial payout, strict order state machine progress tracker, and return request processing.
4. **`AdminDashboardScreen`**: Operations governance dashboard, shop/product approval controls, and live streaming `AuditLog` timeline.

---

## 🧪 Testing & Verification

Run static analysis and tests locally:

```bash
# Analyze code quality
flutter analyze

# Run unit and widget test suite
flutter test
```
