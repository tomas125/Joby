import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> createAccount(String correo, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: pass,
      );
      return AuthResult(success: true, uid: userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, uid: userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  AuthResult _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AuthResult(
            success: false, errorMessage: 'La contraseña es demasiado débil');
      case 'email-already-in-use':
        return AuthResult(
            success: false, errorMessage: 'La cuenta ya existe para ese email');
      case 'user-not-found':
        return AuthResult(
            success: false, errorMessage: 'Usuario no encontrado');
      case 'wrong-password':
        return AuthResult(
            success: false, errorMessage: 'Contraseña incorrecta');
      default:
        return AuthResult(
            success: false,
            errorMessage: 'Error de autenticación: ${e.message}');
    }
  }
}

class AuthResult {
  final bool success;
  final String? uid;
  final String? errorMessage;

  AuthResult({required this.success, this.uid, this.errorMessage});
}
