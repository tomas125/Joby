import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_styles.dart';

class HomeScreen extends StatelessWidget {
  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: AppStyles.commonDecoration(borderRadius: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saliendo de la aplicación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro que deseas salir?',
                style: TextStyle(
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(false),
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
                  SizedBox(width: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(true),
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
              ),
            ],
          ),
        ),
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
