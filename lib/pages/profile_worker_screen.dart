import 'package:Joby/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_model.dart';

class ProfileWorkerScreen extends StatelessWidget {
  final WorkerModel worker;

  const ProfileWorkerScreen({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title:
            Text('Perfil del ${worker.category.toLowerCase()}', style: const TextStyle(color: Color(0xFFE2E2E2))),
        iconTheme: const IconThemeData(color: Color(0xFFE2E2E2)),
      ),
      backgroundColor: const Color(0xFFD4451A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              backgroundImage: worker.imageUrl.isNotEmpty ? NetworkImage(worker.imageUrl) : AssetImage('assets/persona2.jpg'),
              radius: 75,
            ),
            const SizedBox(height: 20),
            Text(
              worker.name,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE2E2E2)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 5),
                Text(
                  '${worker.rating}',
                  style:
                      const TextStyle(fontSize: 22, color: Color(0xFFE2E2E2)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoCard('Descripción de su trabajo', worker.description, Icons.work),
            const SizedBox(height: 20),
            _buildRequestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      color: const Color(0xFFD2CACA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF343030)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343030)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Color(0xFF343030)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildGalleryButton(BuildContext context) {
  //   return ElevatedButton.icon(
  //     onPressed: () {
  //       // Implementa la lógica para mostrar la galería de fotos del trabajo
  //     },
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: const Color(0xFFF88C6A),
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     ),
  //     icon: const Icon(Icons.photo_library, color: Color(0xFFE2E2E2)),
  //     label: const Text(
  //       'Ver Galería de Trabajos',
  //       style: TextStyle(fontSize: 16, color: Color(0xFFE2E2E2)),
  //     ),
  //   );
  // }

    ElevatedButton _buildRequestButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _launchWhatsApp(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 80),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Contactar'),
    );
  }

  void _launchWhatsApp(BuildContext context) async {
      final String phoneNumber = worker.phone;
      final String message = 'Hola, estoy interesado en contratar tus servicios. ¿Podrías proporcionarme más información sobre tu disponibilidad y tarifas? ¡Gracias!';
      
      final whatsappUrl = Uri.parse(
          'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeFull(message)}');
      final webWhatsappUrl = Uri.parse(
          'https://wa.me/$phoneNumber/?text=${Uri.encodeFull(message)}');

      try {
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
        } else if (await canLaunchUrl(webWhatsappUrl)) {
          await launchUrl(webWhatsappUrl);
        } else {
          throw 'No se pudo abrir WhatsApp.';
        }
      } catch (e) {
        SnackBarUtil.showError(
          context: context,
          message: 'Error: $e',
        );
      }
    }

}
