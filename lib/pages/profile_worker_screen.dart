import 'package:Joby/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/job_service.dart';
import '../widgets/help_button.dart';
import '../utils/app_styles.dart';

class ProfileWorkerScreen extends StatelessWidget {
  final WorkerModel worker;
  final JobService _jobService = JobService();

  ProfileWorkerScreen({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text(
          'Perfil del ${worker.category.toLowerCase()}', 
          style: const TextStyle(color: AppStyles.textLightColor)
        ),
        iconTheme: const IconThemeData(color: AppStyles.textLightColor),
        actions: [
          HelpButton(),
        ],
      ),
      backgroundColor: AppStyles.primaryColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección superior con imagen y nombre
            _buildProfileHeader(context),
            
            // Sección de descripción con botón de contacto
            _buildDescriptionCard(context),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          // Imagen de perfil con borde y sombra
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppStyles.secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 4.0,
              ),
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
                        return Container();
                      },
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          // Nombre con estilo mejorado
          Text(
            worker.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppStyles.textLightColor,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black38,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Categoría
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppStyles.textDarkColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              worker.category,
              style: TextStyle(
                color: AppStyles.textLightColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppStyles.cardDecoration(),
      child: Column(
        children: [
          // Sección de descripción (tocable para expandir)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              splashColor: AppStyles.primaryColor.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              onTap: () => _showFullDescriptionDialog(context, worker.description),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la descripción con indicador de expansión
                    Row(
                      children: [
                        Icon(Icons.description, color: AppStyles.textDarkColor),
                        SizedBox(width: 10),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppStyles.textDarkColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.touch_app,
                          color: AppStyles.textDarkColor.withOpacity(0.6),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tocar para expandir',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppStyles.textDarkColor.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Contenido de la descripción con altura limitada
                    Container(
                      constraints: BoxConstraints(maxHeight: 120),
                      child: SingleChildScrollView(
                        child: Text(
                          worker.description,
                          style: TextStyle(
                            fontSize: 16, 
                            color: AppStyles.textDarkColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Separador
          Divider(
            color: AppStyles.textDarkColor.withOpacity(0.2),
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          
          // Botón de contactar (en un contenedor separado)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContactButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.textDarkColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: () => _launchWhatsApp(context),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppStyles.textDarkColor,
                AppStyles.textDarkColor,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,
                  color: AppStyles.textLightColor,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Contactar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textLightColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFullDescriptionDialog(BuildContext context, String content) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: AppStyles.commonDecoration(borderRadius: 20.0),
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Descripción completa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textDarkColor,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppStyles.textDarkColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppStyles.primaryColor.withOpacity(0.9),
                              AppStyles.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            'Cerrar',
                            style: TextStyle(
                              color: AppStyles.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    final String message = 'Hola, me estoy contactando a través de la aplicación Joby. Estoy interesado en contratar tus servicios. ¿Podrías proporcionarme más información sobre tu disponibilidad y tarifas? ¡Gracias!';
    
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
              Container(
                decoration: AppStyles.commonDecoration(borderRadius: 10.0),
                child: TextField(
                  controller: descriptionController,
                  decoration: AppStyles.textFieldDecoration('Describe tu experiencia (opcional)'),
                  maxLines: 3,
                  style: TextStyle(color: AppStyles.textDarkColor),
                ),
              ),
            ],
          ),
          actions: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                splashColor: AppStyles.primaryColor.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                onTap: () async {
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
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppStyles.textDarkColor.withOpacity(0.9),
                        AppStyles.textDarkColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: AppStyles.textLightColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                splashColor: AppStyles.primaryColor.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                onTap: () async {
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
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppStyles.primaryColor.withOpacity(0.9),
                        AppStyles.primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Sí',
                      style: TextStyle(
                        color: AppStyles.textLightColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
