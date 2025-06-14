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
    await updateAdvertisementsWithNewFields();
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

  // Actualizar anuncios con nuevos campos link y phoneNumber
  Future<void> updateAdvertisementsWithNewFields() async {
    try {
      final QuerySnapshot adsSnapshot = 
          await _firestore.collection('advertisements').get();
      
      final WriteBatch batch = _firestore.batch();
      
      for (var doc in adsSnapshot.docs) {
        // Verificar si los campos ya existen
        final bool hasLink = doc.data().toString().contains('link');
        final bool hasPhoneNumber = doc.data().toString().contains('phoneNumber');
        
        // Solo actualizar si los campos no existen
        if (!hasLink || !hasPhoneNumber) {
          final Map<String, dynamic> updateData = {};
          
          if (!hasLink) {
            // Especificar explícitamente como String nulo
            updateData['link'] = null;
          }
          
          if (!hasPhoneNumber) {
            // Especificar explícitamente como String nulo
            updateData['phoneNumber'] = null;
          }
          
          batch.update(doc.reference, updateData);
        }
      }
      
      await batch.commit();
      print('Anuncios actualizados con nuevos campos link y phoneNumber');

      // Verificar y corregir el tipo de datos para todos los documentos
      await _ensureFieldTypes();
    } catch (e) {
      print('Error actualizando anuncios: $e');
    }
  }

  // Asegurar que los campos tengan el tipo de dato correcto
  Future<void> _ensureFieldTypes() async {
    try {
      final QuerySnapshot adsSnapshot = 
          await _firestore.collection('advertisements').get();
      
      final WriteBatch batch = _firestore.batch();
      int updatedCount = 0;
      
      for (var doc in adsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bool needsUpdate = false;
        final Map<String, dynamic> updateData = {};
        
        // Verificar y corregir el tipo de link
        if (data.containsKey('link') && data['link'] != null && !(data['link'] is String)) {
          updateData['link'] = data['link'].toString();
          needsUpdate = true;
        }
        
        // Verificar y corregir el tipo de phoneNumber
        if (data.containsKey('phoneNumber') && data['phoneNumber'] != null && !(data['phoneNumber'] is String)) {
          updateData['phoneNumber'] = data['phoneNumber'].toString();
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          batch.update(doc.reference, updateData);
          updatedCount++;
        }
      }
      
      if (updatedCount > 0) {
        await batch.commit();
        print('Se corrigió el tipo de datos en $updatedCount anuncios');
      } else {
        print('Todos los anuncios tienen el tipo de datos correcto');
      }
    } catch (e) {
      print('Error verificando tipos de datos: $e');
    }
  }

  Future<void> updateWorkersStatus() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final workersRef = _firestore.collection('workers');

  try {
    // Obtener todos los trabajadores existentes
    final snapshot = await workersRef.get();
    
    // Contador para seguimiento
    int updatedCount = 0;
    int errorCount = 0;

    // Actualizar cada documento
    for (var doc in snapshot.docs) {
      try {
        final data = doc.data();
        
        // Verificar si el documento ya tiene los campos necesarios
        if (!data.containsKey('status') || 
            !data.containsKey('rejectionReason') || 
            !data.containsKey('approvedBy') || 
            !data.containsKey('processedAt')) {
          
          // Actualizar el documento con los nuevos campos
          await doc.reference.update({
            'status': 'approved', // Asumimos que los trabajadores existentes están aprobados
            'rejectionReason': null,
            'approvedBy': 'system',
            'processedAt': FieldValue.serverTimestamp(),
          });
          
          updatedCount++;
          print('Documento ${doc.id} actualizado exitosamente');
        }
      } catch (e) {
        errorCount++;
        print('Error al actualizar documento ${doc.id}: $e');
      }
    }

    print('\nResumen de la actualización:');
    print('Documentos actualizados: $updatedCount');
    print('Errores: $errorCount');
    print('Total de documentos procesados: ${snapshot.docs.length}');

  } catch (e) {
      print('Error general: $e');
    }
  }

} 