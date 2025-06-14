import 'package:joby/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/help_button.dart';
import '../utils/app_styles.dart';

class SignUpWorkerScreenOld extends StatelessWidget {
  const SignUpWorkerScreenOld({Key? key}) : super(key: key);

  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+5493364179227';
    const message = 'Hola, estoy interesado en formar parte del equipo de trabajadores de joby. ¿Podrías brindarme más información? ¡Gracias!';
    
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
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        title: const Text(
          'Únete como trabajador',
          style: TextStyle(color: AppStyles.textLightColor),
        ),
        backgroundColor: AppStyles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppStyles.textLightColor),
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
              style: TextStyle(fontSize: 16, color: AppStyles.textLightColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Para solicitar tu alta como trabajador, simplemente presiona el botón de abajo y te pondremos en contacto con nuestro equipo a través de WhatsApp.',
              style: TextStyle(fontSize: 16, color: AppStyles.textLightColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildRequestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: () => _launchWhatsApp(context),
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 80,
            alignment: Alignment.center,
            child: Text(
              'Solicitar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppStyles.textDarkColor,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    blurRadius: 1.0,
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
