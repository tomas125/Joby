import 'package:flutter/material.dart';
import 'package:Joby/utils/snackbar.dart';
import 'package:Joby/utils/auth.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Joby/preferences/pref_user.dart';
import '../widgets/help_button.dart';

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
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title: Text(
          'Crear una cuenta',
          style: TextStyle(color: const Color(0xFFE2E2E2)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFFE2E2E2)),
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

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Ingrese su email'),
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
      obscureText: _obscureText,
      decoration: _inputDecoration('Ingrese su contraseña').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF343030),
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su contraseña';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: const Color(0xFF343030)),
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
    );
  }

  ElevatedButton _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _handleRegister,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030),
        backgroundColor: const Color(0xFFD2CACA),
        fixedSize: const Size(200, 45),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Registrarse'),
    );
  }

  ElevatedButton _buildGoogleButton() {
    return ElevatedButton(
      onPressed: _handleGoogleRegister,
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
                color: const Color(0xFFD2CACA), fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD2CACA),
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
