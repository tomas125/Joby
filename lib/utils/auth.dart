import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> createAccount(String correo, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: pass,
      );
      print(userCredential.user);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es demasiado débil');
        return '1';
      } else if (e.code == 'email-already-in-use') {
        print('La cuenta ya existe para ese email');
        return '2';
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return '1';
      } else if (e.code == 'wrong-password') {
        return '2';
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
