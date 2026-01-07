import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/usuari.dart';
import '../clases/carregaDeHistorial.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseFirestore _db = FirebaseFirestore.instance;

// --- REGISTRO CON EMAIL ---
Future<User?> signUp(
  String email,
  String password,
  String nom,
  List<String> interessos,
) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;

    if (user != null) {
      // Creamos el objeto Usuari usando el UID de Auth
      Usuari nouUsuari = Usuari(
        id: user.uid, // <--- VÍNCULO CLAVE
        nom: nom,
        email: email,
        tags: interessos,
      );

      // Guardamos en Firestore usando el UID como nombre del documento (.doc(user.uid))
      await _db.collection('usuaris').doc(user.uid).set(nouUsuari.toJson());

      await user.updateDisplayName(nom);
    }
    return user;
  } catch (e) {
    rethrow;
  }
}

// --- LOGIN CON EMAIL ---
Future<User?> signIn(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  } on FirebaseAuthException catch (e) {
    throw e.message ?? "Error en l'inici de sessió";
  }
}

// --- GOOGLE SIGN IN ---
Future<Map<String, dynamic>?> signInWithGoogle() async {
  try {
    // ESTA ES LA CLAVE: Forzamos que Google se desconecte antes de pedir el login
    // Así siempre te preguntará qué cuenta quieres usar.
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    final User? user = userCredential.user;

    if (user != null) {
      final docRef = _db.collection('usuaris').doc(user.uid);
      final docSnap = await docRef.get();

      bool esNuevo = !docSnap.exists;

      if (esNuevo) {
        Usuari nouUsuari = Usuari(
          id: user.uid,
          nom: user.displayName ?? "Usuari Google",
          email: user.email,
          fotoUrl: user.photoURL,
          tags: [],
        );
        await docRef.set(nouUsuari.toJson());
      }
      return {'user': user, 'esNuevo': esNuevo};
    }
    return null;
  } catch (e) {
    print("Error Google Sign-In: $e");
    return null;
  }
}

Future<void> signOut() async {
  historialActivitat.clear();
  await _googleSignIn.signOut();
  await _auth.signOut();
}

Future<Usuari?> obtenerDatosPerfil() async {
  User? userAuth = FirebaseAuth.instance.currentUser;

  if (userAuth != null) {
    // Vamos directo al documento que se llama como el UID
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(userAuth.uid)
        .get();

    if (doc.exists) {
      return Usuari.fromJson(doc.data() as Map<String, dynamic>);
    }
  }
  return null;
}
