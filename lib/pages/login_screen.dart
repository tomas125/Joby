import 'package:flutter/material.dart';
import 'package:Joby/utils/snackbar.dart';
import 'package:Joby/utils/auth.dart';
import '../utils/app_styles.dart';

import 'dart:developer' as developer;

import 'package:Joby/preferences/pref_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/help_button.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text(
          'Iniciar Sesión',
          style: TextStyle(
              color: AppStyles.textLightColor),
        ),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEmailField(),
              SizedBox(height: 16.0),
              _buildPasswordField(),
              SizedBox(height: 16.0),
              _buildLoginButton(),
              SizedBox(height: 16.0),
              _buildGoogleLoginButton(),
              SizedBox(height: 8.0),
              _buildForgotPasswordButton(),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      child: TextFormField(
        controller: _emailController,
        decoration: AppStyles.textFieldDecoration('Ingrese su email'),
        style: TextStyle(color: AppStyles.textDarkColor),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      child: TextFormField(
        controller: _passwordController,
        decoration: AppStyles.textFieldDecoration('Ingrese su contraseña').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppStyles.textDarkColor,
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
        obscureText: _obscureText,
        style: TextStyle(color: AppStyles.textDarkColor),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: _handleLogin,
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 45,
            alignment: Alignment.center,
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 16,
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

  Future<void> _handleLogin() async {
    developer.log('Iniciando proceso de login');

    if (_formKey.currentState?.validate() ?? false) {
      developer.log('Formulario validado correctamente');

      // Validar que los campos no estén vacíos
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        SnackBarUtil.showError(
          context: context,
          message: 'Por favor, complete todos los campos',
        );
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        developer.log('Intentando iniciar sesión con email: ${_emailController.text}');
        var result = await _auth.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Cerrar el diálogo de carga
        Navigator.pop(context);

        developer.log('Resultado de inicio de sesión: ${result.toString()}');

        if (result.success == true) {
          await UserPreference.setLoggedIn(true);
          await UserPreference.setUserEmail(_emailController.text);
          if(await AuthService().isAdmin()) {
            developer.log('Inicio de sesión exitoso, navegando a /admin/home');
            Navigator.pushReplacementNamed(context, '/admin/home');
          } else {
            developer.log('Inicio de sesión exitoso, navegando a /list/areas');
            Navigator.pushReplacementNamed(context, '/list/areas');
          }
        } else {
          developer.log('Error en inicio de sesión: ${result.errorMessage}');
          SnackBarUtil.showError(
            context: context,
            message: result.errorMessage ?? 'Error en el inicio de sesión',
          );
        }
      } catch (e) {
        // Cerrar el diálogo de carga si está abierto
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        developer.log('Excepción durante el inicio de sesión: $e');
        SnackBarUtil.showError(
          context: context,
          message: 'Error inesperado: $e',
        );
      }
    } else {
      developer.log('Validación del formulario falló');
      SnackBarUtil.showError(
        context: context,
        message: 'Por favor, complete todos los campos correctamente',
      );
    }
  }

  Widget _buildGoogleLoginButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: _handleGoogleLogin,
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 45,
            alignment: Alignment.center,
            child: Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 15,
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

  Future<void> _handleGoogleLogin() async {
    try {
      developer.log('Iniciando proceso de login con Google');
      
      final result = await _auth.signInWithGoogle();

      if (result.success) {
        developer.log('Login con Google exitoso');
        await UserPreference.setLoggedIn(true);
        
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.email != null) {
          await UserPreference.setUserEmail(currentUser!.email!);
        }
        
        Navigator.pushReplacementNamed(context, '/list/areas');
      } else {
        developer.log('Error en login con Google: ${result.errorMessage}');
        SnackBarUtil.showError(
          context: context,
          message: result.errorMessage ?? 'Error al iniciar sesión con Google',
        );
      }
    } catch (e) {
      developer.log('Excepción durante el login con Google: $e');
      SnackBarUtil.showError(
        context: context,
        message: 'Error inesperado al iniciar sesión con Google: $e',
      );
    }
  }

  TextButton _buildSignUpButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signup/user');
      },
      child: Text('¿No tienes cuenta?'),
      style: TextButton.styleFrom(
        foregroundColor: AppStyles.textLightColor,
      ),
    );
  }

  TextButton _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        showDialog(
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
                    'Recuperar Contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.textDarkColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ingresa tu correo electrónico para recuperar tu contraseña',
                    style: TextStyle(
                      color: AppStyles.textDarkColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: AppStyles.commonDecoration(borderRadius: 10.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: AppStyles.textFieldDecoration('Correo electrónico'),
                      style: TextStyle(color: AppStyles.textDarkColor),
                    ),
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
                          onTap: () => Navigator.pop(context),
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
                                'Cancelar',
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
                          onTap: () async {
                            if (_emailController.text.isEmpty) {
                              SnackBarUtil.showError(
                                context: context,
                                message: 'Por favor, ingresa tu correo electrónico',
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(child: CircularProgressIndicator()),
                            );

                            final result = await _auth.resetPassword(_emailController.text);
                            
                            Navigator.pop(context);

                            if (result.success) {
                              Navigator.pop(context); // Cerrar el diálogo de recuperación
                              SnackBarUtil.showSuccess(
                                context: context,
                                message: result.errorMessage ?? 'Correo enviado exitosamente',
                              );
                            } else {
                              SnackBarUtil.showError(
                                context: context,
                                message: result.errorMessage ?? 'Error al enviar el correo',
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
                                'Enviar',
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
        );
      },
      child: Text('¿Olvidó su contraseña?'),
      style: TextButton.styleFrom(
        foregroundColor: AppStyles.textLightColor,
      ),
    );
  }
}
