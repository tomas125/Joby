import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<bool> checkCurrentUser() async {
    final user = _auth.currentUser;
    return user != null;
  }

  // Verificar si el usuario actual es admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final List<String> userIds = ['DboYfnM0OeU7uNNynDtC3XRQYdr1'];
    return userIds.contains(user.uid);
  }

  // Proteger rutas administrativas
  Future<bool> checkAdminAccess() async {
    bool isUserAdmin = await isAdmin();
    if (!isUserAdmin) {
      // Manejar acceso no autorizado
      return false;
    }
    return true;
  }

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

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult(
          success: false,
          errorMessage: 'Se canceló el inicio de sesión con Google'
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      return AuthResult(
        success: true,
        uid: userCredential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Error al iniciar sesión con Google: ${e.toString()}'
      );
    }
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        errorMessage: 'Se ha enviado un correo para restablecer tu contraseña'
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return AuthResult(
            success: false,
            errorMessage: 'No existe una cuenta con este correo electrónico'
          );
        case 'invalid-email':
          return AuthResult(
            success: false,
            errorMessage: 'El correo electrónico no es válido'
          );
        default:
          return AuthResult(
            success: false,
            errorMessage: 'Error al enviar el correo: ${e.message}'
          );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Error inesperado: ${e.toString()}'
      );
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
