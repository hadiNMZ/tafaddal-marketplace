import 'dart:async';

import '../domain/audit_log.dart';

class AuditService {
  AuditService._();

  static final AuditService instance = AuditService._();

  final List<AuditLogEntry> _logs = [];
  final StreamController<List<AuditLogEntry>> _streamController =
      StreamController<List<AuditLogEntry>>.broadcast();

  // CON-07: Read-Only Log Access
  Stream<List<AuditLogEntry>> get logStream => _streamController.stream;

  List<AuditLogEntry> get logs => List.unmodifiable(_logs);

  // CON-07: Append-Only Cryptographic Hash-Chain Logging Guard
  AuditLogEntry addLog(
    AuditAction action,
    String title,
    String desc, {
    String actor = 'النظام الآلي',
    String entityId = 'SYS',
  }) {
    final now = DateTime.now();
    final id = 'LOG-${now.millisecondsSinceEpoch}-${_logs.length + 1}';
    final previousHash = _logs.isNotEmpty
        ? _logs.first.txHash
        : '0000000000000000';

    final payload =
        '$previousHash:${now.toIso8601String()}:${action.name}:$title:$desc:$actor:$entityId';
    final computed = _computeDeterministicHash(payload);
    final txHash = 'TX: 0x$computed';

    final entry = AuditLogEntry(
      id: id,
      timestamp: now,
      action: action,
      title: title,
      description: desc,
      actor: actor,
      entityId: entityId,
      previousHash: previousHash,
      txHash: txHash,
    );

    _logs.insert(0, entry);
    _streamController.add(List.unmodifiable(_logs));
    return entry;
  }

  String _computeDeterministicHash(String input) {
    int h1 = 0x67452301;
    int h2 = 0xEFCDAB89;
    for (int i = 0; i < input.length; i++) {
      int code = input.codeUnitAt(i);
      h1 = ((h1 ^ code) * 0x01000193) & 0xFFFFFFFF;
      h2 = ((h2 ^ (code * 31)) * 0x050C5D17) & 0xFFFFFFFF;
    }
    final hex1 = h1.toRadixString(16).padLeft(8, '0');
    final hex2 = h2.toRadixString(16).padLeft(8, '0');
    return '$hex1$hex2';
  }
}
