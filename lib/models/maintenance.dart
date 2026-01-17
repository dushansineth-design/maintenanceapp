enum MaintenanceStatus { open, inProgress, resolved, closed }

class Maintenance {
  static int _idCounter = 0;
  final String reportID;
  final String citizenID;
  String? adminID;
  String location;
  String category;
  String description;
  String? photo;
  MaintenanceStatus status;
  DateTime dateReported;

  Maintenance({
    String? reportID,
    required this.citizenID,
    this.adminID,
    required this.location,
    required this.category,
    required this.description,
    this.photo,
    this.status = MaintenanceStatus.open,
    DateTime? dateReported,
  })  : reportID = reportID ?? 'R${++_idCounter}',
        dateReported = dateReported ?? DateTime.now();

  void assignToAdmin(String adminId) {
    adminID = adminId;
    status = MaintenanceStatus.inProgress;
  }

  void updateStatus(MaintenanceStatus newStatus) {
    status = newStatus;
  }

  @override
  String toString() {
    return 'Maintenance($reportID, $location, $status)';
  }
}
