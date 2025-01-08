import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUpdates {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Actualizar workers con nuevos campos
  Future<void> updateWorkersCollection() async {
    try {
      final QuerySnapshot workersSnapshot = 
          await _firestore.collection('workers').get();

      for (var doc in workersSnapshot.docs) {
        final String oldAreaId = doc.data().toString().contains('areaIds') 
            ? doc.get('areaIds') 
            : '';

        await _firestore.collection('workers').doc(doc.id).update({
          'areaIds': oldAreaId.isEmpty ? [] : [oldAreaId],
          'location': const GeoPoint(0, 0),
          'isAvailable': true,
        });
        
        print('Worker ${doc.id} actualizado');
      }
      print('Todos los workers han sido actualizados');
    } catch (e) {
      print('Error actualizando workers: $e');
    }
  }

  // Migrar collection 'services' a 'areas'
  Future<void> migrateServicesToAreas() async {
    try {
      // Obtener todos los documentos de 'services'
      final QuerySnapshot servicesSnapshot = 
          await _firestore.collection('services').get();

      // Crear batch para operaciones en lote
      final WriteBatch batch = _firestore.batch();

      // Copiar cada documento a la nueva colección
      for (var doc in servicesSnapshot.docs) {
        final newAreaRef = _firestore.collection('areas').doc(doc.id);
        batch.set(newAreaRef, doc.data());
        print('Area ${doc.id} migrada');
      }

      // Ejecutar el batch
      await batch.commit();
      print('Migración completada');

      // Opcional: Eliminar la colección antigua
      for (var doc in servicesSnapshot.docs) {
        await _firestore.collection('services').doc(doc.id).delete();
      }
      print('Colección services eliminada');
    } catch (e) {
      print('Error en la migración: $e');
    }
  }

  // Relacionar workers con areas basado en el tipo de trabajo
  Future<void> linkWorkersWithAreas() async {
    try {
      final QuerySnapshot areasSnapshot = 
          await _firestore.collection('areas').get();
      final QuerySnapshot workersSnapshot = 
          await _firestore.collection('workers').get();

      // Crear un mapa de nombre de área a ID
      Map<String, String> areaNameToId = {};
      for (var doc in areasSnapshot.docs) {
        areaNameToId[doc.get('name')] = doc.id;
      }

      // Actualizar cada worker
      for (var worker in workersSnapshot.docs) {
        String workerType = worker.get('type');
        String? areaId = areaNameToId[workerType];

        if (areaId != null) {
          await _firestore.collection('workers').doc(worker.id).update({
            'areaIds': [areaId]
          });
          print('Worker ${worker.id} vinculado con área $areaId');
        }
      }
      print('Vinculación completada');
    } catch (e) {
      print('Error en la vinculación: $e');
    }
  }

  // Ejecutar todas las actualizaciones
  Future<void> runAllUpdates() async {
    print('Iniciando actualizaciones...');
    await cleanupDuplicateAreas();
    await updateWorkersCollection();
    await migrateServicesToAreas();
    await linkWorkersWithAreas();
    print('Todas las actualizaciones completadas');
  }

  Future<void> updateImageFields() async {
    try {
      // Actualizar workers
      final workersSnapshot = await _firestore.collection('workers').get();
      for (var doc in workersSnapshot.docs) {
        final String currentImageUrl = doc.data()['imageUrl'] ?? '';
        await doc.reference.update({
          'image': {
            'url': currentImageUrl,
            'isExternalUrl': true,
          }
        });
      }

      // Actualizar areas
      final areasSnapshot = await _firestore.collection('areas').get();
      for (var doc in areasSnapshot.docs) {
        final String currentIcon = doc.data()['icon'] ?? '';
        await doc.reference.update({
          'image': {
            'url': currentIcon,
            'isExternalUrl': true,
          }
        });
      }

      // Actualizar advertisements
      final adsSnapshot = await _firestore.collection('advertisements').get();
      for (var doc in adsSnapshot.docs) {
        final String currentImageUrl = doc.data()['imageUrl'] ?? '';
        await doc.reference.update({
          'image': {
            'url': currentImageUrl,
            'isExternalUrl': true,
          }
        });
      }
    } catch (e) {
      print('Error actualizando campos de imagen: $e');
    }
  }

  Future<void> cleanupDuplicateAreas() async {
    try {
      // 1. Encontrar áreas duplicadas
      final QuerySnapshot areasSnapshot = 
          await _firestore.collection('areas').where('name', isEqualTo: 'Electricista').get();

      if (areasSnapshot.docs.length > 1) {
        // 2. Mantener el primer documento y obtener su ID
        final String keepAreaId = areasSnapshot.docs[0].id;
        
        // 3. Obtener IDs de áreas a eliminar
        final List<String> removeAreaIds = areasSnapshot.docs
            .skip(1) // Saltar el primer documento (el que mantenemos)
            .map((doc) => doc.id)
            .toList();

        // 4. Actualizar trabajadores que usan las áreas que se eliminarán
        final workersSnapshot = await _firestore
            .collection('workers')
            .where('areaIds', arrayContainsAny: removeAreaIds)
            .get();

        // 5. Batch para actualizaciones
        final batch = _firestore.batch();

        // 6. Actualizar cada trabajador
        for (var workerDoc in workersSnapshot.docs) {
          final List<String> currentAreaIds = List<String>.from(workerDoc.get('areaIds') ?? []);
          
          // Reemplazar áreas eliminadas con el área que mantenemos
          currentAreaIds.removeWhere((id) => removeAreaIds.contains(id));
          if (!currentAreaIds.contains(keepAreaId)) {
            currentAreaIds.add(keepAreaId);
          }

          // Actualizar areaIds y eliminar campo type
          batch.update(workerDoc.reference, {
            'areaIds': currentAreaIds,
            'type': FieldValue.delete(), // Eliminar campo type
          });
        }

        // 7. Eliminar las áreas duplicadas
        for (String areaId in removeAreaIds) {
          batch.delete(_firestore.collection('areas').doc(areaId));
        }

        // 8. Ejecutar todas las operaciones
        await batch.commit();
        print('Limpieza de áreas duplicadas completada');
      }

      // 9. Eliminar campo type de todos los trabajadores restantes
      final allWorkersSnapshot = await _firestore.collection('workers').get();
      final batch = _firestore.batch();
      
      for (var workerDoc in allWorkersSnapshot.docs) {
        batch.update(workerDoc.reference, {
          'type': FieldValue.delete(),
        });
      }
      
      await batch.commit();
      print('Campo type eliminado de todos los trabajadores');

    } catch (e) {
      print('Error en la limpieza: $e');
    }
  }
} 