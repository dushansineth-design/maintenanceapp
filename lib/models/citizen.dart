import 'maintenance.dart';

class Citizen {
  static int _idCounter = 0;
  final String citizenID;
  String name;
  String contact;
  String email;

  Citizen({
    String? citizenID,
    required this.name,
    required this.contact,
    required this.email,
  }) : citizenID = citizenID ?? 'C${++_idCounter}';

  Maintenance reportIssue({
    required String location,
    required String category,
    required String description,
    String? photo,
  }) {
    return Maintenance(
      citizenID: citizenID,
      location: location,
      category: category,
      description: description,
      photo: photo,
    );
  }

  String trackStatus(Maintenance report) => report.status.toString();
}
