import 'package:flutter/material.dart';
import 'package:Joby/utils/snackbar.dart';
import 'package:Joby/utils/auth.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Joby/preferences/pref_user.dart';
import '../widgets/help_button.dart';
import '../utils/app_styles.dart';

class SignUpUserScreen extends StatefulWidget {
  static const String routeName = '/signup/user';

  @override
  _SignUpUserScreenState createState() => _SignUpUserScreenState();
}

class _SignUpUserScreenState extends State<SignUpUserScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text(
          'Crear una cuenta',
          style: TextStyle(color: AppStyles.textLightColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.textLightColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          HelpButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildEmailField(),
                SizedBox(height: 16.0),
                _buildPasswordField(),
                SizedBox(height: 16.0),
                _buildSignUpButton(),
                SizedBox(height: 16.0),
                _buildGoogleButton(),
                SizedBox(height: 8.0),
                _buildLoginButton(),
              ],
            ),
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
        obscureText: _obscureText,
        decoration: AppStyles.textFieldDecoration('Ingrese su contraseña').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: AppStyles.textDarkColor,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        style: TextStyle(color: AppStyles.textDarkColor),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: _handleRegister,
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 45,
            alignment: Alignment.center,
            child: Text(
              'Registrarse',
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

  Widget _buildGoogleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: _handleGoogleRegister,
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 45,
            alignment: Alignment.center,
            child: Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 14,
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

  TextButton _buildLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('¿Ya tienes una cuenta? '),
          Text(
            'Inicia sesión',
            style: TextStyle(
                color: AppStyles.secondaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppStyles.secondaryColor,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() == true) {
      var result = await _auth.createAccount(
        _emailController.text,
        _passwordController.text,
      );
      if (result == '1') {
        SnackBarUtil.showError(
          context: context,
          message: 'Error, contraseña demasiado débil. Cambiar.',
        );
      } else if (result == '2') {
        SnackBarUtil.showError(
          context: context,
          message: 'Error, email ya está en uso',
        );
      } else {
        Navigator.pushNamed(context, '/list/areas');
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
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
}
