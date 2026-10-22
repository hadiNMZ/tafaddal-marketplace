enum AuditAction { statusChange, shopApproval, returnRequest, securityEvent }

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final AuditAction action;
  final String title;
  final String description;
  final String actor;
  final String entityId;
  final String previousHash;
  final String txHash;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.title,
    required this.description,
    this.actor = 'النظام الآلي',
    this.entityId = 'SYS',
    this.previousHash = '0000000000000000',
    required this.txHash,
  });
}
