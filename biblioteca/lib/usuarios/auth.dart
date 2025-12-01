import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> signUp(String email, String password) async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // El usuario se creó exitosamente y se almacenó en Firebase Auth
  } on FirebaseAuthException catch (e) {
    // Manejar errores (ej. email ya en uso, contraseña débil)
    print(e.message);
  }
}
