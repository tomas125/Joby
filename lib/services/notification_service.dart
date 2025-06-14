import 'package:url_launcher/url_launcher.dart';
import '../models/worker_model.dart';

class NotificationService {
  Future<void> sendApprovalNotification(WorkerModel worker) async {
    await _sendWhatsAppMessage(
      worker.phone,
      'Hola ${worker.name}, tu solicitud para unirte a joby ha sido *APROBADA*. '
      'Tu perfil ya está disponible en nuestra aplicación y los usuarios podrán contactarte. '
      'Bienvenido al equipo! 🎉'
    );
  }

  Future<void> sendRejectionNotification(WorkerModel worker, String reason) async {
    await _sendWhatsAppMessage(
      worker.phone,
      'Hola ${worker.name}, lamentamos informarte que tu solicitud para unirte a joby ha sido *RECHAZADA*. '
      '${reason.isNotEmpty ? '\nMotivo: $reason' : ''} '
      'Si tienes alguna duda, contáctanos para resolver los motivos de rechazo.'
    );
  }

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}'
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }
} 