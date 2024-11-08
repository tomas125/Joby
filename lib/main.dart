import 'package:Joby/pages/worker_request.dart';
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
import 'preferences/pref_usuarios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PreferenciasUsuario.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JOBY',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PreferenciasUsuario.isLoggedIn
          ? ServiceSelectionScreen()
          : SelectionScreen(),
      routes: {
        '/init': (context) => SelectionScreen(),
        '/login': (context) => LoginPages(),
        '/register': (context) => RegistroClientes(),
        '/service_selection': (context) => ServiceSelectionScreen(),
        '/worker_request': (context) => WorkerRequestScreen()
      },
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/worker_results':
        final workers = settings.arguments as List<Worker>;
        return MaterialPageRoute(
          builder: (context) => WorkerResultsScreen(workers: workers),
        );
      case '/worker_profile':
        final worker = settings.arguments as Worker;
        return MaterialPageRoute(
          builder: (context) => WorkerProfileScreen(worker: worker),
        );
      default:
        return null;
    }
  }
}
