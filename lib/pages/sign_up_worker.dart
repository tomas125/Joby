import 'package:Joby/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/help_button.dart';

class SignUpWorkerScreen extends StatelessWidget {
  const SignUpWorkerScreen({Key? key}) : super(key: key);

  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+5493364179227';
    const message = 'Hola, estoy interesado en formar parte del equipo de trabajadores de Joby. ¿Podrías brindarme más información? ¡Gracias!';
    
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
              color: const Color(0xFFE2E2E2)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          HelpButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/icon/logo-transparent.png', width: 200, height: 200),
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
            _buildRequestButton(context),
          ],
        ),
      ),
    );
  }

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
      child: Text('Solicitar'),
    );
  }
}
