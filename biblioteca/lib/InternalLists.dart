import 'clases/canço.dart'; // Asegúrate de que la ruta sea correcta
import 'clases/llibre.dart';
import 'clases/usuari.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Llibre> llistaLlibresGlobal = [];
List<Canco> llistaCanconsGlobal = [];
List<Usuari> llistaUsuarisGlobal = [];

// 1. Definimos la referencia a la colección fuera de las funciones para reutilizarla.
final coleccionLibros = FirebaseFirestore.instance
    .collection('libros')
    .withConverter<Llibre>(
      fromFirestore: (snapshot, _) => Llibre.fromFirestore(snapshot),
      toFirestore: (llibre, _) => {
        'titulo': llibre.titol,
        'autor': llibre.autor,
        'stock': llibre.stock,
        'idioma': llibre.idioma,
        'tags': llibre.tags,
        'playlist': llibre.playlist,
        'valoraciones': llibre.valoracions,
        'url': llibre.urlImatge,
      },
    );

final coleccionCancons = FirebaseFirestore.instance
    .collection('cançons')
    .withConverter<Canco>(
      fromFirestore: (snapshot, _) => Canco.fromFirestore(snapshot),
      toFirestore: (canco, _) => {
        'titol': canco.titol,
        'autor': canco.autor,
        'minuts':
            '${canco.minuts.inMinutes.toString().padLeft(2, '0')}:${(canco.minuts.inSeconds % 60).toString().padLeft(2, '0')}',
        'lletra': canco.lletra,
        'urlImatge': canco.urlImatge,
        'tags': canco.tags,
        'urlAudio': canco.urlAudio,
      },
    );

final coleccionUsuaris = FirebaseFirestore.instance
    .collection('usuaris')
    .withConverter<Usuari>(
      fromFirestore: (snapshot, _) => Usuari.fromJson(snapshot.data()!),
      toFirestore: (usuari, _) => {
        'uid': usuari.id,
        'nom': usuari.nom,
        'email': usuari.email,
        'fotoUrl': usuari.fotoUrl,
        'interessos': usuari.tags,
        'pendents': usuari.pendents,
        'llegits': usuari.llegits,
        'reserves': usuari.reserves,
        'seguidors': usuari.seguidors,
        'amics': usuari.amics,
      },
    );

Future<void> inicialitzarDadesGlobals() async {
  try {
    final queryLibros = await coleccionLibros.get();
    llistaLlibresGlobal = queryLibros.docs.map((doc) => doc.data()).toList();

    final queryCancons = await coleccionCancons.get();
    llistaCanconsGlobal = queryCancons.docs.map((doc) => doc.data()).toList();

    final queryUsuaris = await coleccionUsuaris.get();
    llistaUsuarisGlobal = queryUsuaris.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error cargando datos globales: $e");
  }
}

Llibre? getLlibreById(String id) {
  try {
    // Busca en la lista que ya cargaste en el main
    return llistaLlibresGlobal.firstWhere((c) => c.id == id);
  } catch (e) {
    return null;
  }
}

Canco? getCancoById(String id) {
  try {
    // Busca en la lista que cargamos en el main
    return llistaCanconsGlobal.firstWhere((c) => c.id == id);
  } catch (e) {
    print("Error: No se encontró la canción con ID $id");
    return null;
  }
}

Usuari? getUsuariById(String id) {
  try {
    return llistaUsuarisGlobal.firstWhere((u) => u.id == id);
  } catch (e) {
    return null;
  }
}
