import 'package:flutter/material.dart';
import 'package:Joby/util/snackbar.dart';
import 'package:Joby/utils/auth.dart';

class RegistroClientes extends StatefulWidget {
  static const String routeName = '/register';

  @override
  _RegistroClientesState createState() => _RegistroClientesState();
}

class _RegistroClientesState extends State<RegistroClientes> {
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
          title: Text('Crear una cuenta',
              style: TextStyle(color: Colors.black)), // Letras negras
          backgroundColor: Color.fromARGB(255, 199, 50, 5) // Botones #F88C6A
          ),
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
                  labelStyle: TextStyle(color: Colors.black), // Letras negras
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
                  labelStyle: TextStyle(color: Colors.black), // Letras negras
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black), // Letras negras
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black, // Letras negras
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
                    var result = await _auth.createAccount(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (result == '1') {
                      showSnackBar(context,
                          'Error, contraseña demasiado débil. Cambiar.');
                    } else if (result == '2') {
                      showSnackBar(context, 'Error, email ya está en uso');
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
                child: Text('Registrarse con email'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Implementar registro de usuario con Google
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
            ],
          ),
        ),
      ),
    );
  }
}
