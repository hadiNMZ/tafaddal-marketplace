# Master Prompt & System Constraints - Tafaddal Marketplace

Build an Arabic RTL Multi-Vendor E-Commerce Marketplace application in Flutter following Domain-Driven Design (DDD) principles.

## Core Domain Constraints
- `CON-01`: Product visibility guard (`Product.isVisibleToCustomer(Shop)`).
- `CON-02`: Mandatory store link (`Product` constructor throws `ArgumentError` if `shopId` is empty).
- `CON-03`: Inventory stock limit guard (`Product.validateStock()`, `Product.deductStock()`, `OrderItem`).
- `CON-04`: Order immutability guard post-submission (`ShipmentOrder.updateShippingAddress()` throws `ImmutableOrderException`).
- `CON-05`: Return eligibility guard (`ShipmentOrder.requestReturn()` throws `InvalidReturnStateException` unless in `Delivered` state).
- `CON-06`: Sequential workflow state machine (`Placed` -> `Preparing` -> `Shipping` -> `Delivered`).
- `CON-07`: Cryptographic append-only hash-chained audit logging (`AuditService`).
