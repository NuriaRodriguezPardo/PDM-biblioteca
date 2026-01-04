import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/usuari.dart';

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
Future<User?> signInWithGoogle() async {
  try {
    // 1. FORZAR CIERRE DE SESIÓN PREVIO (para que pida elegir cuenta)
    await _googleSignIn.signOut();

    // 2. Iniciar el flujo de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Iniciar sesión en Firebase Auth
    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    final User? user = userCredential.user;

    if (user != null) {
      // 4. COMPROBAR SI YA EXISTE EN FIRESTORE
      final docRef = FirebaseFirestore.instance
          .collection('usuaris')
          .doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // 5. SI NO EXISTE, CREAR EL DOCUMENTO USANDO TU CLASE 'Usuari'
        // Extraemos el nombre (Google suele dar el nombre completo)
        String nombreCompleto = user.displayName ?? "Usuari Google";

        Usuari nouUsuari = Usuari(
          id: user.uid,
          nom: nombreCompleto,
          email: user.email,
          fotoUrl: user.photoURL,
          tags: [], // Lista vacía por defecto
        );

        await _db.collection('usuaris').doc(user.uid).set(nouUsuari.toJson());
      }
    }
    return user;
  } catch (e) {
    print("Error Google Sign-In: $e");
    return null;
  }
}

Future<void> signOut() async {
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
