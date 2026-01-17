import '../models/citizen.dart';
import '../models/maintenance.dart';

class MaintenanceService {
  final List<Maintenance> _reports = [];

  Maintenance createReport(
    Citizen citizen,
    String location,
    String category,
    String description,
  ) {
    final report = citizen.reportIssue(
      location: location,
      category: category,
      description: description,
    );
    _reports.add(report);
    return report;
  }

  List<Maintenance> getReports() => List.unmodifiable(_reports);

  Maintenance? getReportById(String id) {
    try {
      return _reports.firstWhere((r) => r.reportID == id);
    } catch (e) {
      return null;
    }
  }

  // Optional helper if you want to assign by adminID (no Admin import needed)
  bool assignReport(String reportID, String adminID) {
    final r = getReportById(reportID);
    if (r == null) return false;
    r.assignToAdmin(adminID);
    return true;
  }

  bool updateStatus(String reportID, MaintenanceStatus newStatus) {
    final r = getReportById(reportID);
    if (r == null) return false;
    r.updateStatus(newStatus);
    return true;
  }
}
