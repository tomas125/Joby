import 'package:Joby/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerRequestScreen extends StatelessWidget {
  const WorkerRequestScreen({Key? key}) : super(key: key);

  void _launchWhatsApp(BuildContext context) async {
    // Agregar 'BuildContext context' como parámetro
    const phoneNumber =
        '+1234567890'; // Reemplaza con el número de WhatsApp correcto
    const message =
        'Hola, me gustaría unirme como trabajador en la aplicación.';
    final url = Uri.parse(
        'https://wa.me/$phoneNumber/?text=${Uri.encodeFull(message)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir WhatsApp.';
      }
    } catch (e) {
      // Maneja el error, por ejemplo, mostrando un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir WhatsApp: $e')),
      ); // Agregar 'context' como parámetro a la función
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        title: const Text(
          'Únete como trabajador',
          style: TextStyle(color: const Color(0xFFE2E2E2)),
        ),
        backgroundColor: const Color(0xFFD4451A),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFFE2E2E2)), // Cambiar color aquí
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/icon/jobyparalogo.png'),
            const SizedBox(height: 20),
            const Text(
              'Únete a nuestra comunidad de trabajadores y comienza a ofrecer tus servicios a través de nuestra aplicación.',
              style: TextStyle(fontSize: 16, color: const Color(0xFFE2E2E2)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Para solicitar tu alta como trabajador, simplemente presiona el botón de abajo y te pondremos en contacto con nuestro equipo a través de WhatsApp.',
              style: TextStyle(fontSize: 16, color: const Color(0xFFE2E2E2)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildRequestButton(context), // Agregar 'context' como parámetro
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildRequestButton(BuildContext context) {
    // Agregar 'BuildContext context' como parámetro
    return ElevatedButton(
      onPressed: () => SnackBarUtil.show(
        context: context,
        message: 'No disponible por el momento',
      ), // Pasar 'context' a la función
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030), // Cambiar color del texto
        backgroundColor: const Color(0xFFD2CACA), // Color de fondo del botón
        fixedSize: const Size(200, 45), // Tamaño fijo para el botón
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Bordes redondeados
        ),
      ),
      child: Text('Solicitar'),
    );
  }
}
