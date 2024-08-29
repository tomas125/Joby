import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_pages.dart';
import 'pages/register_screen.dart';
import 'pages/selection_screen.dart';
import 'pages/service_selection_screen.dart';
import 'pages/worker_results_screen.dart';
import 'pages/worker_profile_screen.dart';
import 'pages/worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JOBY',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/',
      routes: {
        '/': (context) => SelectionScreen(),
        '/login': (context) => LoginPages(),
        '/register': (context) => RegistroClientes(),
        '/selection': (context) => ServiceSelectionScreen(),
        '/service_selection': (context) => ServiceSelectionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/worker_results') {
          final List<Worker> workers = settings.arguments as List<Worker>;
          return MaterialPageRoute(
            builder: (context) => WorkerResultsScreen(workers: workers),
          );
        } else if (settings.name == '/worker_profile') {
          final Worker worker = settings.arguments as Worker;
          return MaterialPageRoute(
            builder: (context) => WorkerProfileScreen(worker: worker),
          );
        }
        return null;
      },
    );
  }
}
