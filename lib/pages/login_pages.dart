import 'package:flutter/material.dart';
import 'package:Joby/util/snackbar.dart';
import 'package:Joby/utils/auth.dart';

import 'dart:developer' as developer;

import 'package:Joby/preferences/pref_usuarios.dart';

class LoginPages extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginPagesState createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    PreferenciasUsuario.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A), // Fondo #D4451A
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A), // Fondo #D4451A
        title: Text(
          'Iniciar Sesión',
          style: TextStyle(
              color: const Color(0xFFE2E2E2)), // Cambiar color de texto
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFFE2E2E2)), // Cambiar color aquí
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
              _buildRegisterButton(),
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
        filled: true, // Habilitar el fondo
        fillColor: const Color(0xFFD2CACA), // Color de fondo deseado
        border: InputBorder.none, // Mantener sin borde de contorno
        // Agregar borde redondeado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Radio del borde
          borderSide:
              BorderSide(color: Colors.transparent), // Sin borde visible
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Radio del borde
          borderSide:
              BorderSide(color: Colors.transparent), // Sin borde visible
        ),
        // Agregar hintText para mejorar la posición
        hintText: 'Ingrese su email', // Usar hintText en lugar de labelText
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su email';
        }
        // Puedes agregar más validaciones de email aquí si lo deseas
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
                : Icons.visibility_off, // Cambiar ícono
          ),
          onPressed:
              _togglePasswordVisibility, // Método para alternar visibilidad
        ),
      ),
      obscureText: _obscureText, // Usar _obscureText aquí
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su contraseña';
        }
        // Puedes agregar más validaciones de contraseña aquí si lo deseas
        return null;
      },
    );
  }

  // Método para alternar la visibilidad de la contraseña
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Cambiar el estado de _obscureText
    });
  }

  ElevatedButton _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin, // Llamar a la función separada
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030), // Cambiar color del texto
        backgroundColor: const Color(0xFFD2CACA), // Color de fondo del botón
        fixedSize: const Size(200, 45), // Tamaño fijo para el botón
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Bordes redondeados
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
          developer
              .log('Inicio de sesión exitoso, navegando a /service_selection');
          await PreferenciasUsuario.setLoggedIn(true);
          await PreferenciasUsuario.setUserEmail(_emailController.text);
          Navigator.pushReplacementNamed(context, '/service_selection');
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
      // Puedes mostrar un mensaje al usuario aquí si lo deseas
      SnackBarUtil.showError(
        context: context,
        message: 'Por favor, complete todos los campos correctamente',
      );
    }
  }

  ElevatedButton _buildGoogleLoginButton() {
    return ElevatedButton(
      onPressed: _handleGoogleLogin, // Llamar a la función separada
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF343030), // Cambiar color del texto
        backgroundColor: const Color(0xFFD2CACA), // Color de fondo del botón
        fixedSize: const Size(200, 45), // Tamaño fijo para el botón
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Bordes redondeados
        ),
      ),
      child: Text('Continuar con Google'),
    );
  }

  Future<void> _handleGoogleLogin() async {
    // Nueva función para manejar el inicio de sesión con Google
    // Implementar inicio de sesión con Google aquí
  }

  TextButton _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
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
        // Implementar la funcionalidad de "Olvidó su contraseña?"
      },
      child: Text('¿Olvidó su contraseña?'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFD2CACA),
      ),
    );
  }
}
