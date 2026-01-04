import 'package:biblioteca/clases/usuari.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // IMPORTANTE: Para gestionar el estado de la sesión
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import 'PantallaMatch.dart';
import 'pantallaBiblioteca.dart';
import 'PantallaBusqueda.dart';
import 'PantallaUsuari.dart';
import 'PantallaLogin.dart';
import '../InternalLists.dart';
import '../usuarios/auth.dart'; // IMPORTANTE: Para la función de cierre de sesión

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  static const String route = '/pantalla_principal';

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late List<Llibre> novedades;
  late List<Llibre> populares;

  User? user;
  Usuari? usuari;

  @override
  void initState() {
    super.initState();
    _generarListasAleatorias(); // Mantenemos tu lógica de aleatoriedad original
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      usuari = getUsuariById(user!.uid);
    }
  }

  void _generarListasAleatorias() {
    // Creamos copias de la lista global para no desordenar la original
    List<Llibre> copiaNovedades = List.from(llistaLlibresGlobal);
    List<Llibre> copiaPopulares = List.from(llistaLlibresGlobal);

    // Mezclamos las listas aleatoriamente
    copiaNovedades.shuffle();
    copiaPopulares.shuffle();

    // Cogemos un máximo de 10 elementos
    novedades = copiaNovedades.take(10).toList();
    populares = copiaPopulares.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catàleg de Llibres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaBusqueda(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // PantallaUsuari detecta automáticamente al usuario logueado vía Firebase
                  builder: (context) => const PantallaUsuari(),
                ),
              );
            },
          ),
        ],
      ),

      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuaris')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Extraemos los datos actualizados de Firebase
          Map<String, dynamic>? data =
              snapshot.data?.data() as Map<String, dynamic>?;
          String? fotoUrlActualizada = data?['fotoUrl'];
          String? nombreActualizado = data?['nom'] ?? 'Menú Biblioteca';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(180, 30, 17, 10),
                  ),
                  accountName: Text(
                    nombreActualizado!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  accountEmail: Text(user?.email ?? 'usuari@email.com'),
                  currentAccountPicture: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    // Se actualiza automáticamente mediante el Stream
                    backgroundImage:
                        (fotoUrlActualizada != null &&
                            fotoUrlActualizada.isNotEmpty)
                        ? NetworkImage(fotoUrlActualizada)
                        : null,
                    child:
                        (fotoUrlActualizada == null ||
                            fotoUrlActualizada.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 45,
                            color: Color.fromARGB(180, 30, 17, 10),
                          )
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('La Meva Biblioteca'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BibliotecaScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shuffle),
                  title: const Text('Matching Llibre/Cançó'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaMatching(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Tancar Sessió',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaLogin(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Novedades',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: novedades.length,
                itemBuilder: (context, index) {
                  final llibre = novedades[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaLlibre(llibre: llibre),
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                llibre.urlImatge != null &&
                                    llibre.urlImatge!.isNotEmpty
                                ? Image.network(
                                    llibre.urlImatge!,
                                    height: 180,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.book, size: 50),
                                    ),
                                  )
                                : Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book, size: 50),
                                  ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            llibre.titol,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            llibre.autor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Populares',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: populares.map((llibre) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color.fromARGB(176, 255, 228, 221),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          llibre.urlImatge != null &&
                              llibre.urlImatge!.isNotEmpty
                          ? Image.network(
                              llibre.urlImatge!,
                              width: 50,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 55,
                                color: Colors.grey[200],
                                child: const Icon(Icons.book),
                              ),
                            )
                          : Container(
                              width: 55,
                              color: Colors.grey[200],
                              child: const Icon(Icons.book),
                            ),
                    ),
                    title: Text(
                      llibre.titol,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(llibre.autor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaLlibre(llibre: llibre),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
