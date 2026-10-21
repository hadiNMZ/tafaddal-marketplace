import 'dart:async';

import '../domain/audit_log.dart';

class AuditService {
  AuditService._() {
    _seedInitialLogs();
  }

  static final AuditService instance = AuditService._();

  final List<AuditLogEntry> _logs = [];
  final StreamController<List<AuditLogEntry>> _streamController =
      StreamController<List<AuditLogEntry>>.broadcast();

  // CON-07: Read-Only Log Access
  Stream<List<AuditLogEntry>> get logStream => _streamController.stream;

  List<AuditLogEntry> get logs => List.unmodifiable(_logs);

  // CON-07: Append-Only Immutable Logging Guard
  AuditLogEntry addLog(AuditAction action, String title, String desc) {
    final now = DateTime.now();
    final id = 'LOG-${now.millisecondsSinceEpoch}-${_logs.length + 1}';
    final hashSeed = '${now.microsecondsSinceEpoch}_${action.name}_$title';
    final txHash =
        'TX: 0x${hashSeed.hashCode.toRadixString(16).padLeft(8, '0')}';

    final entry = AuditLogEntry(
      id: id,
      timestamp: now,
      action: action,
      title: title,
      description: desc,
      txHash: txHash,
    );

    _logs.insert(0, entry);
    _streamController.add(List.unmodifiable(_logs));
    return entry;
  }

  void _seedInitialLogs() {
    if (_logs.isNotEmpty) return;
    final now = DateTime.now();
    _logs.addAll([
      AuditLogEntry(
        id: 'LOG-SEED-1',
        timestamp: now.subtract(const Duration(minutes: 18)),
        action: AuditAction.shopApproval,
        title: 'اعتماد متجر #104',
        description: 'بواسطة: أحمد سالم (مدير العمليات)',
        txHash: 'TX: 0x9f8c3b41',
      ),
      AuditLogEntry(
        id: 'LOG-SEED-2',
        timestamp: now.subtract(const Duration(minutes: 22)),
        action: AuditAction.statusChange,
        title: 'تحديث مسار الطلب #SO-902',
        description: 'بواسطة: متجر أزياء الشام',
        txHash: 'TX: 0x7a114e89',
      ),
      AuditLogEntry(
        id: 'LOG-SEED-3',
        timestamp: now.subtract(const Duration(minutes: 45)),
        action: AuditAction.returnRequest,
        title: 'قبول طلب الإرجاع #RET-12',
        description: 'بواسطة: نظام التحكيم الآلي',
        txHash: 'TX: 0x4d6612cd',
      ),
    ]);
  }
}
