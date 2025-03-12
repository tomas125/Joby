import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_styles.dart';

class HomeScreen extends StatelessWidget {
  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saliendo de la aplicación'),
        content: Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            child: Text('No'),
            style: TextButton.styleFrom(
              foregroundColor: AppStyles.textDarkColor,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Sí'),
            style: TextButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;

    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop(context);
        if (result && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppStyles.primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height /
                      10),
              Image.asset('assets/icon/logo-transparent.png'),
              const SizedBox(height: 40),
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textLightColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildUserButton(
                  context, 'Cliente', '/login', false),
              const SizedBox(height: 20),
              _buildUserButton(context, 'Trabajador', '/signup/worker',
                  false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserButton(
      BuildContext context, String label, String route, bool disabled) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: disabled ? null : () => Navigator.pushNamed(context, route),
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 80,
            alignment: Alignment.center,
            child: Text(
              label,
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
