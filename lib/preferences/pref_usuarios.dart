import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static late SharedPreferences _prefs;
  static const String _keyUltimaPagina = 'ultimaPagina';
  static const String _defaultPagina = 'Login';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';

  static bool _initialized = false;

  /// Inicializa las preferencias
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Obtiene la última página visitada
  static String get ultimaPagina {
    _checkInitialized();
    return _prefs.getString(_keyUltimaPagina) ?? _defaultPagina;
  }

  /// Establece la última página visitada
  static Future<void> setUltimaPagina(String value) async {
    _checkInitialized();
    await _prefs.setString(_keyUltimaPagina, value);
  }

  /// Verifica si las preferencias han sido inicializadas
  static void _checkInitialized() {
    if (!_initialized) {
      throw Exception(
          'PreferenciasUsuario no ha sido inicializado. Debes llamar a PreferenciasUsuario.init() antes de usar cualquier método.');
    }
  }

  /// Limpia todas las preferencias
  static Future<void> clear() async {
    _checkInitialized();
    await _prefs.clear();
  }

  /// Verifica si el usuario está logueado
  static bool get isLoggedIn {
    _checkInitialized();
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Establece el estado de inicio de sesión
  static Future<void> setLoggedIn(bool value) async {
    _checkInitialized();
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  /// Obtiene el email del usuario
  static String? get userEmail {
    _checkInitialized();
    return _prefs.getString(_keyUserEmail);
  }

  /// Establece el email del usuario
  static Future<void> setUserEmail(String? email) async {
    _checkInitialized();
    if (email != null) {
      await _prefs.setString(_keyUserEmail, email);
    } else {
      await _prefs.remove(_keyUserEmail);
    }
  }

  /// Cierra la sesión del usuario
  static Future<void> logout() async {
    _checkInitialized();
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyUserEmail);
  }
}
