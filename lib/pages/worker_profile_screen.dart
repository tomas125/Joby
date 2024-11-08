import 'package:Joby/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'worker.dart';

class WorkerProfileScreen extends StatelessWidget {
  final Worker worker;

  const WorkerProfileScreen({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title:
            Text(worker.name, style: const TextStyle(color: Color(0xFFE2E2E2))),
        iconTheme: const IconThemeData(color: Color(0xFFE2E2E2)),
        actions: [
          IconButton(
            color: const Color(0xFFE2E2E2),
            icon: const Icon(Icons.message),
            onPressed: () => SnackBarUtil.show(
              context: context,
              message: 'No disponible por el momento',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(worker.imageUrl),
                radius: 75,
              ),
              const SizedBox(height: 20),
              Text(
                worker.name,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE2E2E2)),
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
              const SizedBox(height: 30),
              // worker.jobDescription
              _buildInfoCard('Descripción del Trabajo', '', Icons.work),
              const SizedBox(height: 20),
              // '${worker.yearsOfExperience}
              _buildInfoCard('Experiencia', '', Icons.timeline),
              const SizedBox(height: 20),
              _buildGalleryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      color: const Color(0xFFF88C6A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE2E2E2)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E2E2)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Color(0xFFE2E2E2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Implementa la lógica para mostrar la galería de fotos del trabajo
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF88C6A),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: const Icon(Icons.photo_library, color: Color(0xFFE2E2E2)),
      label: const Text(
        'Ver Galería de Trabajos',
        style: TextStyle(fontSize: 16, color: Color(0xFFE2E2E2)),
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber) async {
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUrl)) {
      await canLaunchUrl(whatsappUrl);
    } else {
      print('No se pudo abrir WhatsApp');
    }
  }
}
