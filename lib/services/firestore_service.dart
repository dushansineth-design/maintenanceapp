import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createReport(String userId, String category, String description, LatLng location) async {
    await _db.collection('reports').add({
      'userId': userId,
      'category': category,
      'description': description,
      'status': 'open',
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReports() {
    return _db.collection('reports').snapshots();
  }
}
