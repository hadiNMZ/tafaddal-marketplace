enum AuditAction { statusChange, shopApproval, returnRequest, securityEvent }

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final AuditAction action;
  final String title;
  final String description;
  final String txHash;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.title,
    required this.description,
    required this.txHash,
  });
}
