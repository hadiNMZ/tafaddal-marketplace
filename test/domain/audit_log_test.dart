import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/domain/audit_log.dart';
import 'package:tafaddal_marketplace/services/audit_service.dart';

void main() {
  group('Sprint 3: CON-07 Immutable Audit Logging Suite', () {
    test('AuditService correctly appends new logs (Append-Only)', () {
      final initialCount = AuditService.instance.logs.length;

      final entry = AuditService.instance.addLog(
        AuditAction.statusChange,
        'تغيير حالة الشحنة #TEST-1',
        'تم تغيير الحالة إلى SHIPPING',
      );

      expect(AuditService.instance.logs.length, equals(initialCount + 1));
      expect(AuditService.instance.logs.first.id, equals(entry.id));
      expect(entry.title, equals('تغيير حالة الشحنة #TEST-1'));
      expect(entry.description, equals('تم تغيير الحالة إلى SHIPPING'));
      expect(entry.txHash, startsWith('TX: 0x'));
    });

    test(
      'AuditService logStream emits updated log list upon adding a log',
      () async {
        expect(
          AuditService.instance.logStream,
          emits(
            predicate<List<AuditLogEntry>>((logs) {
              return logs.isNotEmpty &&
                  logs.first.title == 'اختبار بث السجل المباشر';
            }),
          ),
        );

        AuditService.instance.addLog(
          AuditAction.securityEvent,
          'اختبار بث السجل المباشر',
          'مراقبة الأحداث عبر StreamController',
        );
      },
    );

    test('CON-07: AuditLogEntry & logs list are strictly immutable', () {
      final entry = AuditLogEntry(
        id: 'IMMUTABLE_1',
        timestamp: DateTime.now(),
        action: AuditAction.statusChange,
        title: 'سجل غير قابل للتعديل',
        description: 'اختبار الحماية ضد التعديل',
        txHash: 'TX: 0x12345678',
      );

      // Verify fields are final & non-modifiable
      expect(entry.id, equals('IMMUTABLE_1'));
      expect(entry.action, equals(AuditAction.statusChange));

      // Assert that AuditService.instance.logs throws UnsupportedError when attempted to mutate
      expect(
        () => (AuditService.instance.logs as List).clear(),
        throwsUnsupportedError,
      );

      expect(
        () => (AuditService.instance.logs as List).removeAt(0),
        throwsUnsupportedError,
      );
    });
  });
}
