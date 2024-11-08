import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A), // Fondo #D4451A
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height /
                    10), // Espacio superior para mover el contenido hacia arriba
            Image.asset('assets/icon/jobyparalogo.png'),
            const SizedBox(height: 40), // Agrega la imagen aquí
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE2E2E2)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Espacio entre la imagen y los botones
            _buildUserButton(
                context, 'Cliente', '/login', false), // Botón Cliente
            const SizedBox(height: 20), // Espacio entre los botones
            _buildUserButton(context, 'Trabajador', '/worker_request',
                false), // Botón Trabajador
            // SizedBox(height: MediaQuery.of(context).size.height / 4), // Eliminar o ajustar si es necesario
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
              context, route), // Deshabilitar el botón si 'disabled' es true
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 60), // Tamaño fijo para el botón
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(label),
    );
  }
}
