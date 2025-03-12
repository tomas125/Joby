import 'package:Joby/pages/sign_up_worker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/firebase_config.dart';
import 'pages/login_screen.dart';
import 'pages/sign_up_user_screen.dart';
import 'pages/home_screen.dart';
import 'pages/list_area_screen.dart';
import 'pages/list_worker_screen.dart';
import 'pages/profile_worker_screen.dart';
import 'preferences/pref_user.dart';
import 'pages/admin/home_admin_screen.dart';
import 'pages/admin/worker_form_admin_screen.dart';
import 'pages/admin/area_form_admin_screen.dart';
import 'pages/admin/advertisement_form_screen.dart';
import 'utils/auth.dart';
import 'models/worker_model.dart';
import 'utils/update_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase iniatilized already');
    } else {
      rethrow;
    }
  }
  await UserPreference.init();
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
      home: FutureBuilder<dynamic>(
        future: Future.wait([
          AuthService().checkCurrentUser(),
          UpdateChecker.checkForUpdate(context),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final user = snapshot.data?[0];
          if (user) {
            return FutureBuilder<bool>(
              future: AuthService().isAdmin(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return adminSnapshot.data == true 
                    ? HomeAdminScreen()
                    : ListAreaScreen();
              },
            );
          }
          
          return HomeScreen();
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup/user': (context) => SignUpUserScreen(),
        '/signup/worker': (context) => SignUpWorkerScreen(),
        '/list/areas': (context) => ListAreaScreen(),
        '/list/workers': (context) {
          final String selectedAreaId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return ListWorkerScreen(selectedAreaId: selectedAreaId);
        },
        '/profile/worker': (context) {
          final WorkerModel worker = ModalRoute.of(context)?.settings.arguments as WorkerModel;
          return ProfileWorkerScreen(worker: worker);
        },
        '/admin/home': (context) => HomeAdminScreen(),
        '/admin/form/worker': (context) => WorkerFormAdminScreen(),
        '/admin/form/area': (context) => AreaFormAdminScreen(),
        '/admin/form/advertisement': (context) => AdvertisementFormScreen(),
      },
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/list/workers':
        final String selectedAreaId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => ListWorkerScreen(selectedAreaId: selectedAreaId),
        );
      case '/profile/worker':
        final worker = settings.arguments as WorkerModel;
        return MaterialPageRoute(
          builder: (context) => ProfileWorkerScreen(worker: worker),
        );
      default:
        return null;
    }
  }
}
