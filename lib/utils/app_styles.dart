import 'package:flutter/material.dart';

class AppStyles {
  // Colores principales
  static const Color primaryColor = Color(0xFFD4451A);
  static const Color secondaryColor = Color(0xFFD2CACA);
  static const Color textDarkColor = Color(0xFF343030);
  static const Color textLightColor = Color(0xFFE2E2E2);

  // Gradientes
  static LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE2E2E2),
      Color(0xFFD2CACA),
    ],
    stops: [0.0, 0.8],
  );

  // Estilos de botones
  static ButtonStyle elevatedButtonStyle({
    Color backgroundColor = secondaryColor,
    Color foregroundColor = textDarkColor,
    Size? fixedSize,
    double borderRadius = 25.0,
    double fontSize = 16.0,
  }) {
    return ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      fixedSize: fixedSize,
      textStyle: TextStyle(
        fontSize: fontSize, 
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Decoración común para todos los elementos (botones, cards, inputs)
  static BoxDecoration commonDecoration({
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: buttonGradient,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4.0,
          offset: Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.0,
      ),
    );
  }

  // Alias para mantener compatibilidad con código existente
  static BoxDecoration containerDecoration({double borderRadius = 20.0}) {
    return commonDecoration(borderRadius: borderRadius);
  }

  // Decoración para tarjetas
  static BoxDecoration cardDecoration({double borderRadius = 10.0}) {
    return commonDecoration(borderRadius: borderRadius);
  }

  // Decoración para campos de texto
  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: textDarkColor),
      filled: false, // No usamos filled porque aplicaremos el gradiente en el contenedor
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.0),
      ),
      errorStyle: TextStyle(color: Colors.white),
    );
  }

  // Estilo para listas
  static BoxDecoration listItemDecoration({double borderRadius = 10.0}) {
    return commonDecoration(borderRadius: borderRadius);
  }
} 