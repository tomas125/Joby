import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4451A), // Fondo #D4451A
      appBar: AppBar(
        title: Text('Tipo de usuario',
            style: TextStyle(color: Colors.black)), // Letras negras
        backgroundColor: Color.fromARGB(255, 199, 50, 5), // Botones #F88C6A
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/icon/jobyparalogo.png'), // Agrega la imagen aquí
            SizedBox(height: 40), // Espacio entre la imagen y los botones
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, // Letras negras
                backgroundColor: Color(0xFFF88C6A), // Botones #F88C6A
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Bordes redondeados
                ),
              ),
              child: Text('CLIENTE'),
            ),
            SizedBox(height: 30), // Espacio entre los botones
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/loginWorker');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, // Letras negras
                backgroundColor: Color(0xFFF88C6A), // Botones #F88C6A
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Bordes redondeados
                ),
              ),
              child: Text('TRABAJADOR'),
            ),
          ],
        ),
      ),
    );
  }
}
