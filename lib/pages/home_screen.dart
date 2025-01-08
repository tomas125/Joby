import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saliendo de la aplicación'),
        content: Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            child: Text('No'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF343030),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Sí'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD4451A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop(context);
        if (result && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD4451A),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height /
                      10),
              Image.asset('assets/icon/logo-transparent.png'),
              const SizedBox(height: 40),
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE2E2E2)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildUserButton(
                  context, 'Cliente', '/login', false),
              const SizedBox(height: 20),
              _buildUserButton(context, 'Trabajador', '/signup/worker',
                  false),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildUserButton(
      BuildContext context, String label, String route, bool disabled) {
    return ElevatedButton(
      onPressed: () => disabled
          ? null
          : Navigator.pushNamed(
              context, route),
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 80),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(label),
    );
  }
}
