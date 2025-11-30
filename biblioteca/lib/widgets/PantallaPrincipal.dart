import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import 'PantallaBusqueda.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  // Ejemplo de libros
  static final List<Llibre> listaLibros = [
    Llibre(
      id: 0,
      titol: '1984',
      autor: 'George Orwell',
      idioma: 'Español',
      stock: 5,
      tags: ['Distopia', 'Clásico'],
      urlImatge: null,
      valoracions: [],
    ),
    Llibre(
      id: 1,
      titol: 'El Principito',
      autor: 'Antoine de Saint-Exupéry',
      idioma: 'Francés',
      stock: 3,
      tags: ['Infantil', 'Fábula'],
      urlImatge: null,
      valoracions: [],
    ),
    Llibre(
      id: 2,
      titol: 'Cien Años de Soledad',
      autor: 'Gabriel García Márquez',
      idioma: 'Español',
      stock: 2,
      tags: ['Realismo mágico', 'Clásico'],
      valoracions: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaBusqueda()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Aquí iría la pantalla de usuario
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Novedades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listaLibros.length,
                itemBuilder: (context, index) {
                  final llibre = listaLibros[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PantallaLlibre(llibre: llibre)),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          llibre.urlImatge != null
                              ? Image.network(llibre.urlImatge!, height: 150)
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
            const Text('Populares', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: listaLibros.map((llibre) {
                return ListTile(
                  leading: llibre.urlImatge != null
                      ? Image.network(llibre.urlImatge!, width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(llibre.titol),
                  subtitle: Text(llibre.autor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PantallaLlibre(llibre: llibre)),
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
