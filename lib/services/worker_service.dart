import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

class WorkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'workers';

  // Obtener todos los trabajadores
  Stream<List<WorkerModel>> getWorkers() {
    return _firestore
        .collection(collection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener trabajadores por tipo
  // Stream<List<WorkerModel>> getWorkersByType(String type) { ... }

  // Agregar un nuevo trabajador
  Future<void> addWorker(WorkerModel worker) {
    return _firestore.collection(collection).add(worker.toFirestore());
  }

  // Actualizar un trabajador
  Future<void> updateWorker(String id, WorkerModel worker) {
    return _firestore.collection(collection).doc(id).update(worker.toFirestore());
  }

  // Eliminar un trabajador
  Future<void> deleteWorker(String id) {
    return _firestore.collection(collection).doc(id).delete();
  }

  // Actualizar este método para usar arrayContains en lugar de isEqualTo
  Stream<List<WorkerModel>> getWorkersByArea(String areaId) {
    return _firestore
        .collection(collection)
        .where('areaIds', arrayContains: areaId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<WorkerModel?> getWorkerById(String workerId) async {
    try {
      final doc = await _firestore.collection(collection).doc(workerId).get();
      if (doc.exists && doc.data() != null) {
        return WorkerModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener el trabajador: $e');
      return null;
    }
  }
} 