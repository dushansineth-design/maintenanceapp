import 'maintenance.dart';

class Admin {
  static int _idCounter = 0;
  final String adminID;
  String name;
  String role;
  String email;

  Admin({
    String? adminID,
    required this.name,
    required this.role,
    required this.email,
  }) : adminID = adminID ?? 'A${++_idCounter}';

  void assignReport(Maintenance report) {
    report.assignToAdmin(adminID);
  }

  void updateStatus(Maintenance report, MaintenanceStatus newStatus) {
    report.updateStatus(newStatus);
  }
}
