import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<UserCredential> login(
      String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }


  Future<UserCredential> register(
      String email, String password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}