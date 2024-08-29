import 'package:flutter/material.dart';
import 'package:Joby/util/snackbar.dart';
import 'package:Joby/utils/auth.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4451A), // Fondo #D4451A
      appBar: AppBar(
          title: Text('Iniciar Sesión'),
          backgroundColor: Color.fromARGB(255, 199, 50, 5)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Letras negras
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Letras negras
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    print('Formulario validado');
                    var result = await _auth.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                    print('Resultado del inicio de sesión: $result');
                    if (result == '1' || result == '2') {
                      showSnackBar(context, 'Error en el usuario o contraseña');
                    } else if (result != null) {
                      Navigator.pushNamed(context, '/selection');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF88C6A), // Botones #F88C6A
                  padding: EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20), // Ajusta el padding
                  textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black), // Letras negras
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(25), // Bordes redondeados
                  ),
                ),
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 16.0), // Espacio entre botones
              ElevatedButton(
                onPressed: () async {
                  // Implementar inicio de sesión con Google
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF88C6A), // Botones #F88C6A
                  padding: EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20), // Ajusta el padding
                  textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black), // Letras negras
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(25), // Bordes redondeados
                  ),
                ),
                child: Text('Continuar con Google'),
              ),
              SizedBox(height: 16.0), // Espacio entre botones
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('¿No tienes cuenta?'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 16.0), // Espacio entre botones
              TextButton(
                onPressed: () {
                  // Implementar la funcionalidad de "Olvidó su contraseña?"
                },
                child: Text('¿Olvidó su contraseña?'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
