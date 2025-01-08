import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:Joby/utils/firebase_config.dart';
import 'firebase_updates.dart';

void main() async {
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
    
    // Ejecutar actualizaciones
    print('Iniciando actualizaciones...');
    await updates.runAllUpdates();
    // await updates.updateImageFields();
    
    print('Actualizaciones completadas exitosamente');
  } catch (e) {
    print('Error ejecutando actualizaciones: $e');
  }
} 