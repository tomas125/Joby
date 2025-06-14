import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/area_model.dart';

class AreaService {
  final CollectionReference _areasCollection = 
      FirebaseFirestore.instance.collection('areas');

  Stream<List<AreaModel>> getAreas() {
    return _areasCollection.snapshots().map((snapshot) {
      List<AreaModel> areas = snapshot.docs.map((doc) {
        return AreaModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
      
      // Ordenar alfabéticamente por nombre
      areas.sort((a, b) => a.name.compareTo(b.name));
      
      return areas;
    });
  }

  Future<void> addArea(AreaModel area) async {
    await _areasCollection.add(area.toMap());
  }

  Future<void> updateArea(AreaModel area) async {
    await _areasCollection.doc(area.id).update(area.toMap());
  }

  Future<void> deleteArea(String areaId) async {
    await _areasCollection.doc(areaId).delete();
  }

  Stream<String> getAreaIdByName(String areaName) {
    return FirebaseFirestore.instance
        .collection('areas')
        .where('name', isEqualTo: areaName)
        .snapshots()
        .map((snapshot) => snapshot.docs.first.id);
  }
} 