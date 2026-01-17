import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference reportsCollection = 
      FirebaseFirestore.instance.collection('reports');

  // 1. GET HISTORY (Read)
  // We stream the data so the UI updates automatically when status changes
  Stream<QuerySnapshot> getUserReports(String userId) {
    return reportsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true) 
        .snapshots();
  }

  // 2. EDIT REPORT (Update)
  Future<void> updateReport(String docId, String newTitle, String newDesc) async {
    return await reportsCollection.doc(docId).update({
      'title': newTitle,
      'description': newDesc,
    });
  }

  // 3. DELETE REPORT (Delete)
  Future<void> deleteReport(String docId) async {
    return await reportsCollection.doc(docId).delete();
  }
}