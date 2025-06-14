import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:joby/utils/firebase_config.dart';
import 'firebase_updates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar Firebase con manejo de error de duplicado
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        print('Firebase ya está inicializado');
      } else {
        rethrow;
      }
    }

    final updates = FirebaseUpdates();
    
    // Ejecutar solo la actualización de trabajadores
    await updates.updateWorkersStatus();
    
    // O ejecutar todas las actualizaciones
    // await updates.runAllUpdates();
    
    print('Script de actualización completado');
  } catch (e) {
    print('Error ejecutando actualizaciones: $e');
  }
} 