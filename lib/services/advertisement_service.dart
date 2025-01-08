import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advertisement_model.dart';

class AdvertisementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'advertisements';

  Stream<List<AdvertisementModel>> getAdvertisements() {
    return _firestore
        .collection(collection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdvertisementModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addAdvertisement(AdvertisementModel advertisement) {
    return _firestore.collection(collection).add(advertisement.toFirestore());
  }

  Future<void> updateAdvertisement(String id, AdvertisementModel advertisement) {
    return _firestore.collection(collection).doc(id).update(advertisement.toFirestore());
  }

  Future<void> deleteAdvertisement(String id) {
    return _firestore.collection(collection).doc(id).delete();
  }
} 