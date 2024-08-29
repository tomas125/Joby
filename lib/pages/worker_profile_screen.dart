import 'package:flutter/material.dart';
import 'worker.dart';

class WorkerProfileScreen extends StatelessWidget {
  final Worker worker;

  WorkerProfileScreen({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 199, 50, 5),
        title: Text(worker.name),
        actions: [
          IconButton(
            color: Colors.black, // Color de icono de contacto
            icon: Icon(Icons.contact_phone),
            onPressed: () {
              // Reemplaza el enlace con el enlace de WhatsApp del trabajador
              final whatsappUrl = 'https://wa.me/1234567890';
              launchUrl(whatsappUrl);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(worker.imageUrl),
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              worker.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${worker.rating} ★',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implementa la lógica para mostrar la descripción del trabajo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF88C6A), // Color del botón
              ),
              child: Column(
                children: [
                  Text('Descripción del Trabajo'),
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/electricista.jpg', // Reemplaza con la ruta de tu imagen
                    height: 30,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implementa la lógica para mostrar la foto del trabajo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF88C6A), // Color del botón
              ),
              child: Column(
                children: [
                  Text('Foto del Trabajo'),
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/mecanico.jpg', // Reemplaza con la ruta de tu imagen
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchUrl(String url) {
    // Implementa la lógica para abrir el enlace de WhatsApp
  }
}
