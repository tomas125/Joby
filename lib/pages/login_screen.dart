import 'package:flutter/material.dart';
import 'package:Joby/utils/snackbar.dart';
import 'package:Joby/utils/auth.dart';

import 'dart:developer' as developer;

import 'package:Joby/preferences/pref_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title: Text(
          'Iniciar Sesión',
          style: TextStyle(
              color: const Color(0xFFE2E2E2)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFFE2E2E2)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              _buildSignUpButton(),
              _buildForgotPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: const Color(0xFF343030)),
        filled: true,
        fillColor: const Color(0xFFD2CACA),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        hintText: 'Ingrese su email',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su email';
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: const Color(0xFF343030)),
        filled: true,
        fillColor: const Color(0xFFD2CACA),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        hintText: 'Ingrese su contraseña',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      obscureText: _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su contraseña';
        }
        return null;
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  ElevatedButton _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 45),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Iniciar Sesión'),
    );
  }

  Future<void> _handleLogin() async {
    developer.log('Iniciando proceso de login');

    if (_formKey.currentState?.validate() ?? false) {
      developer.log('Formulario validado correctamente');

      try {
        developer.log(
            'Intentando iniciar sesión con email: ${_emailController.text}');
        var result = await _auth.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        developer.log('Resultado de inicio de sesión: ${result.toString()}');

        if (result.success == true) {
          await UserPreference.setLoggedIn(true);
          await UserPreference.setUserEmail(_emailController.text);
          if(await AuthService().isAdmin()) {
            developer
              .log('Inicio de sesión exitoso, navegando a /admin/home');
            Navigator.pushReplacementNamed(context, '/admin/home');
          } else {
            developer
              .log('Inicio de sesión exitoso, navegando a /list/areas');
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

  ElevatedButton _buildGoogleLoginButton() {
    return ElevatedButton(
      onPressed: _handleGoogleLogin,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 45),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Continuar con Google'),
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
        foregroundColor: const Color(0xFFD2CACA),
      ),
    );
  }

  TextButton _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Recuperar Contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ingresa tu correo electrónico para recuperar tu contraseña'),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    filled: true,
                    fillColor: const Color(0xFFD2CACA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF343030),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
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
                  Navigator.pop(context);

                  if (result.success) {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4451A),
                  foregroundColor: Colors.white,
                ),
                child: Text('Enviar'),
              ),
            ],
          ),
        );
      },
      child: Text('¿Olvidó su contraseña?'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD2CACA),
      ),
    );
  }
}
