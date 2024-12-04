import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height /
                    10),
            Image.asset('assets/icon/jobyparalogo.png'),
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
