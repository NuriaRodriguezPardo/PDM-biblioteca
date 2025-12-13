import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import 'PantallaLlibre.dart';
import '../carregaDeDades.dart';
import 'PantallaMatch.dart';
import 'pantallaBiblioteca.dart'; // Afegida importació per BibliotecaScreen
import 'PantallaBusqueda.dart';
import 'PantallaUsuari.dart';

// Dades simulades per a PantallaMatch (Usuari Principal)
final Usuari usuariActual = Usuari(id: "1", nom: "Usuari Principal");

// CORRECCIÓ: Utilitzem getAllLlibres() per carregar les dades del JSON de manera dinàmica i global
final List<Llibre> listaLibros = totsElsLlibres;

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  // CORRECCIÓ: La llista de llibres ara és global (listaLibros) i es pot accedir.
  // Es pot fer pública si cal. La deixo com a final global per consistència.

  @override
  Widget build(BuildContext context) {
    List<Llibre> llibresPerMostrar = listaLibros;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catàleg de Llibres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // CORRECCIÓ: Navegació real a PantallaBusqueda
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
              // CORRECCIÓ: Navegació a la pantalla d'usuari
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
      // NAVEGACIÓ: Drawer per accedir a Biblioteca i Matching
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
                Navigator.pop(context); // Tanca el drawer
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
                Navigator.pop(context); // Tanca el drawer
                Navigator.push(
                  context,
                  // PantallaMatching requereix un Usuari
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: llibresPerMostrar.length,
                itemBuilder: (context, index) {
                  final llibre = llibresPerMostrar[index];
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
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          llibre.urlImatge != null &&
                                  llibre.urlImatge!.isNotEmpty
                              ? Image.network(
                                  llibre.urlImatge!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book, size: 100),
                          const SizedBox(height: 5),
                          Text(
                            llibre.titol,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Populares',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: llibresPerMostrar.map((llibre) {
                return ListTile(
                  leading:
                      llibre.urlImatge != null && llibre.urlImatge!.isNotEmpty
                      ? Image.network(
                          llibre.urlImatge!,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book),
                  title: Text(llibre.titol),
                  subtitle: Text(llibre.autor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaLlibre(llibre: llibre),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
