class Report {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;

  Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
  });

  // Convert map from database to Report object
  factory Report.fromMap(Map<String, dynamic> data, String documentId) {
    return Report(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Pending',
    );
  }

  // Convert Report object to map for database
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}