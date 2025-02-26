import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Joby/utils/snackbar.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({Key? key}) : super(key: key);

  void _launchWhatsAppHelp(BuildContext context) async {
    const phoneNumber = '+5493364179227';
    const message = 'Hola, necesito asistencia con la aplicación Joby. ¿Podrían ayudarme?';
    
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
    return IconButton(
      icon: Icon(Icons.help_outline, color: const Color(0xFFE2E2E2)),
      onPressed: () => _launchWhatsAppHelp(context),
    );
  }
} 