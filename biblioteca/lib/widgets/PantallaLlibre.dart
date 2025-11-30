import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

// Ejemplo de playlist
List<Canco> playy = getCancons();

class _PantallaLlibreState extends State<PantallaLlibre> {
  final List<Llibre> listaLibros = [
    Llibre(
      id: 0,
      titol: '1984',
      autor: 'George Orwell',
      idioma: 'Español',
      playlist: playy,
      stock: 5,
      valoracions: [],
      urlImatge: 'https://upload.wikimedia.org/wikipedia/en/c/c3/1984first.jpg',
      tags: ['Distopia', 'Clásico'],
    ),
    Llibre(
      id: 1,
      titol: 'El Principito',
      autor: 'Antoine de Saint-Exupéry',
      idioma: 'Francés',
      stock: 3,
      valoracions: [],
      urlImatge: 'https://upload.wikimedia.org/wikipedia/en/4/4f/Le_Petit_Prince_(1943).jpg',
      tags: ['Infantil', 'Fábula'],
    ),
    Llibre(
      id: 2,
      titol: 'Cien Años de Soledad',
      autor: 'Gabriel García Márquez',
      idioma: 'Español',
      stock: 2,
      valoracions: [],
      urlImatge: null,
      tags: ['Realismo mágico', 'Clásico'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final llibre = widget.llibre;

    return Scaffold(
      appBar: AppBar(title: Text(llibre.titol)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del libro
            Center(
              child: llibre.urlImatge != null
                  ? Image.network(llibre.urlImatge!, height: 200)
                  : const Icon(Icons.book, size: 150),
            ),
            const SizedBox(height: 16),

            // Título y autor
            Text(
              llibre.titol,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'de ${llibre.autor}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),

            // Idioma y stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Idioma: ${llibre.idioma}'),
                Text('Stock: ${llibre.stock}'),
              ],
            ),
            const SizedBox(height: 8),

            // Puntuación media
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  llibre.mitjanaPuntuacio() != null
                      ? llibre.mitjanaPuntuacio()!.toStringAsFixed(1)
                      : "Sin puntuación",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            if (llibre.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: llibre.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Botón reservar
            ElevatedButton(
              onPressed: llibre.disponible()
                  ? () {
                      setState(() {
                        llibre.disminuirStock(1);
                      });
                    }
                  : null,
              child: const Text('Reservar'),
            ),
            const SizedBox(height: 30),

            // Playlist asociada
            Text(
              'Playlist asociada al libro:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: llibre.playlist
                  .map(
                    (canco) => ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(canco.titol),
                      subtitle: Text(canco.autor),
                      trailing: Text('${canco.minuts.inMinutes} min'),
                    ),
                  )
                  .toList(),
            ),

            // Otros libros
            const SizedBox(height: 20),
            Text(
              'Otros libros disponibles:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: listaLibros
                  .map(
                    (lib) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(lib.titol),
                      subtitle: Text(lib.autor),
                      trailing: Text("Stock: ${lib.stock}"),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
