import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  /// generar instancia

  static late SharedPreferences _prefs;

//inicializar las prefrerencias
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get ultimaPagina {
    return _prefs.getString('ultimPagina') ?? 'Login';
  }

  set ultimaPagina(String value) {
    _prefs.setString('ultimaPagina', value);
  }
}
