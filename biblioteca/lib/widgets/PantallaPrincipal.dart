import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {

  List<Llibre> llibres = [
    Llibre(
      id: 1,
      titol: "El Senyor dels Anells",
      autor: "J.R.R. Tolkien",
      idioma: "Català",
      stock: 5,
      tags: ["Fantasia", "Aventura"],
    ),
    Llibre(
      id: 2,
      titol: "L'ombra del vent",
      autor: "Carlos Ruiz Zafón",
      idioma: "Castellà",
      stock: 2,
      tags: ["Misteri", "Drama"],
      urlImatge: 'https://m.media-amazon.com/images/I/91r1eQ4JwpL.jpg',
    ),
    Llibre(
      id: 3,
      titol: "1984",
      autor: "George Orwell",
      idioma: "Anglès",
      stock: 3,
      tags: ["Distopia", "Política"],
    ),
  ];

  String _search = "";

  @override
  Widget build(BuildContext context) {
    List<Llibre> llibresFiltrats = llibres
        .where((l) =>
            l.titol.toLowerCase().contains(_search.toLowerCase()) ||
            l.autor.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person))
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔍 Barra de búsqueda
            TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cerca llibres...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Novetats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: llibresFiltrats
                    .map((l) => _buildLlibreCard(l, context))
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Populars", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: llibresFiltrats
                    .map((l) => _buildLlibreCard(l, context))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLlibreCard(Llibre llibre, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.book, size: 60),
            const SizedBox(height: 8),
            Text(
              llibre.titol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              llibre.autor,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
          ],
        ),
      ),
    );
  }
}
