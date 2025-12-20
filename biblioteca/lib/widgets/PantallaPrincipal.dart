import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import 'PantallaLlibre.dart';
import 'PantallaMatch.dart';
import 'pantallaBiblioteca.dart';
import 'PantallaBusqueda.dart';
import 'PantallaUsuari.dart';
import '../InternalLists.dart';

// Dades simulades per a PantallaMatch (Usuari Principal)
final Usuari usuariActual = Usuari(id: "1", nom: "Usuari Principal");

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  static const String route = '/pantalla_principal';

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late List<Llibre> novedades;
  late List<Llibre> populares;

  @override
  void initState() {
    super.initState();
    _generarListasAleatorias();
  }

  void _generarListasAleatorias() {
    // Creamos copias de la lista global para no desordenar la original
    List<Llibre> copiaNovedades = List.from(llistaLlibresGlobal);
    List<Llibre> copiaPopulares = List.from(llistaLlibresGlobal);

    // Mezclamos las listas aleatoriamente
    copiaNovedades.shuffle();
    copiaPopulares.shuffle();

    // Cogemos un máximo de 10 elementos (o menos si no hay suficientes)
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
                  builder: (context) => PantallaUsuari(usuari: usuariActual),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Menú Biblioteca',
                style: TextStyle(color: Colors.white, fontSize: 24),
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
                    builder: (context) =>
                        PantallaMatching(usuari: usuariActual),
                  ),
                );
              },
            ),
          ],
        ),
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
                  elevation:
                      1, // Añadimos un poco de elevación para ver mejor el borde
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // ESTA ES LA CLAVE: Añade espacio interno para que la imagen no toque el borde
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
                              //width:
                              //    55, // Un poco más ancha para que se vea mejor
                              // height: 90,
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
