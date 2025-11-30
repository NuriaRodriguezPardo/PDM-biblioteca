import 'package:flutter/material.dart';
import '../models/llibre.dart';

class PantallaLlibre extends StatefulWidget {
  static String route = '/PantallaLlibre';

  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

class _PantallaLlibreState extends State<PantallaLlibre> {
  
  // ⭐ LISTA DE EJEMPLO AÑADIDA AQUÍ
  final List<Llibre> listaLibros = [
    Llibre(
      id: 1,
      titol: '1984',
      autor: 'George Orwell',
      idioma: 'Español',
      stock: 5,
      mitjanaPuntuacio: 4.5,
      urlImatge: null,
      tags: null,
    ),
    Llibre(
      id: 2,
      titol: 'El Principito',
      autor: 'Antoine de Saint-Exupéry',
      idioma: 'Francés',
      stock: 3,
      mitjanaPuntuacio: 4.8,
      urlImatge: null,
    ),
    Llibre(
      id: 3,
      titol: 'Cien Años de Soledad',
      autor: 'Gabriel García Márquez',
      idioma: 'Español',
      stock: 2,
      mitjanaPuntuacio: 4.7,
      urlImatge: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final llibre = widget.llibre;

    return Scaffold(
      appBar: AppBar(
        title: Text(llibre.titol),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del libro
            Center(
              child: llibre.urlImatge != null
                  ? Image.network(llibre.urlImatge!, height: 200)
                  : Icon(Icons.book, size: 150),
            ),
            SizedBox(height: 16),

            // Título y autor
            Text(
              llibre.titol,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'de ${llibre.autor}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),

            // Idioma y stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Idioma: ${llibre.idioma}'),
                Text('Stock: ${llibre.stock}'),
              ],
            ),
            SizedBox(height: 8),

            // Puntuación
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text(llibre.mitjanaPuntuacio != null
                    ? llibre.mitjanaPuntuacio!.toStringAsFixed(1)
                    : "Sin puntuación"),
              ],
            ),

            SizedBox(height: 16),

            if (llibre.tags.isNotEmpty) ...[
              SizedBox(height: 8),
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
              SizedBox(height: 16),
            ],

            // Botón de reservar
            ElevatedButton(
              onPressed: llibre.disponible()
                  ? () {
                      setState(() {
                        llibre.disminuirStock(1);
                      });
                    }
                  : null,
              child: Text('Reservar'),
            ),

            SizedBox(height: 30),

            // ⭐ Vista de la lista dentro de este mismo archivo
            Text(
              'Otros libros disponibles:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Column(
              children: listaLibros
                  .map(
                    (lib) => ListTile(
                      leading: Icon(Icons.book),
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
