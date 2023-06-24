import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_box_test/exceptions/stream_exception.dart';

class PlacesService {
  final firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getPlaces() {
    try {
      final placesStream = firestore.collection('places').snapshots();

      return placesStream;
    } catch (e) {
      throw StreamException();
    }
  }
}
