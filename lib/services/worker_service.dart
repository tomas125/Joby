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
        .where('status', isEqualTo: 'approved')
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

  // Obtener trabajadores por área
  Stream<List<WorkerModel>> getWorkersByArea(String areaId) {
    return _firestore
        .collection(collection)
        .where('areaIds', arrayContains: areaId)
        .where('isAvailable', isEqualTo: true)
        .where('status', isEqualTo: 'approved')
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

  // Obtener todas las solicitudes de registro (para administradores)
  Stream<List<WorkerModel>> getRegistrationRequests() {
    return _firestore
        .collection(collection)
        .where('status', isEqualTo: 'pending')
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Aprobar una solicitud de registro
  Future<void> approveRequest(String workerId, String adminId) async {
    final worker = await getWorkerById(workerId);
    if (worker == null) throw 'Trabajador no encontrado';

    await _firestore.collection(collection).doc(workerId).update({
      'status': 'approved',
      'approvedBy': adminId,
      'processedAt': FieldValue.serverTimestamp(),
    });
  }

  // Rechazar una solicitud de registro
  Future<void> rejectRequest(String workerId, String adminId, String reason) async {
    final worker = await getWorkerById(workerId);
    if (worker == null) throw 'Trabajador no encontrado';

    await _firestore.collection(collection).doc(workerId).update({
      'status': 'rejected',
      'approvedBy': adminId,
      'rejectionReason': reason,
      'processedAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener todos los trabajadores para el admin
  Stream<List<WorkerModel>> getAllWorkersForAdmin() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener trabajadores activos para el admin
  Stream<List<WorkerModel>> getActiveWorkersForAdmin() {
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

  // Obtener trabajadores inactivos para el admin
  Stream<List<WorkerModel>> getInactiveWorkersForAdmin() {
    return _firestore
        .collection(collection)
        .where('isAvailable', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener trabajadores por status (pending, approved, rejected)
  Stream<List<WorkerModel>> getWorkersByStatus(String status) {
    return _firestore
        .collection(collection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkerModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
} 