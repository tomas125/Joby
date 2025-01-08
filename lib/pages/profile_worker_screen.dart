import 'package:Joby/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/job_service.dart';

class ProfileWorkerScreen extends StatelessWidget {
  final WorkerModel worker;
  final JobService _jobService = JobService();

  ProfileWorkerScreen({Key? key, required this.worker}) : super(key: key);

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
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      worker.category == 'Local' 
                          ? 'assets/local.jpg'
                          : 'assets/persona.jpg'
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: worker.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          worker.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(); // Muestra la imagen por defecto si falla
                          },
                        ),
                      )
                    : null,
              ),
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const Icon(Icons.star, color: Colors.yellow),
            //     const SizedBox(width: 5),
            //     Text(
            //       '${worker.rating}',
            //       style:
            //           const TextStyle(fontSize: 22, color: Color(0xFFE2E2E2)),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            _buildInfoCard('Descripción', worker.description, Icons.work),
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      SnackBarUtil.showError(
        context: context,
        message: 'Debes iniciar sesión para contactar al trabajador',
      );
      return;
    }

    final String phoneNumber = worker.phone;
    final String message = 'Hola, estoy interesado en contratar tus servicios. ¿Podrías proporcionarme más información sobre tu disponibilidad y tarifas? ¡Gracias!';
    
    try {
      // Crear el registro del trabajo
      final jobId = await _jobService.createJob(user.uid, worker.id);

      // Lanzar WhatsApp
      final whatsappUrl = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeFull(message)}'
      );
      final webWhatsappUrl = Uri.parse(
        'https://wa.me/$phoneNumber/?text=${Uri.encodeFull(message)}'
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webWhatsappUrl)) {
        await launchUrl(webWhatsappUrl);
      } else {
        throw 'No se pudo abrir WhatsApp.';
      }

      // Mostrar el diálogo cuando la app vuelva a primer plano
      Future.delayed(const Duration(seconds: 1), () {
        _showConfirmationDialog(context, jobId);
      });

    } catch (e) {
      SnackBarUtil.showError(
        context: context,
        message: 'Error: $e',
      );
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, String jobId) async {
    final TextEditingController descriptionController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de contacto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿El contacto con el trabajador fue exitoso?'),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe tu experiencia (opcional)',
                  labelStyle: TextStyle(color: Color(0xFF343030)),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _jobService.updateJobStatus(
                  jobId, 
                  false,
                  descriptionController.text,
                );
                Navigator.of(context).pop();
                if (context.mounted) {
                  SnackBarUtil.show(
                    context: context,
                    message: 'Esperamos que puedas encontrar un profesional pronto. ¡Gracias por usar JOBY!',
                    duration: Duration(seconds: 5),
                  );
                }
              },
              child: const Text('No'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF343030),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _jobService.updateJobStatus(
                  jobId, 
                  true,
                  descriptionController.text,
                );
                Navigator.of(context).pop();
                
                if (context.mounted) {
                  SnackBarUtil.showSuccess(
                    context: context,
                    message: 'Nos alegra que hayas podido encontrar un profesional. ¡Gracias por usar JOBY!',
                    duration: Duration(seconds: 5),
                  );
                }
              },
              child: const Text('Sí'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD4451A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
