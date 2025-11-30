import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import 'PantallaPrincipal.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final resultados = PantallaPrincipal.listaLibros.where((llibre) {
      return llibre.titol.toLowerCase().contains(query.toLowerCase()) ||
          llibre.autor.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar libros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por título o autor',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: resultados.isNotEmpty
                  ? ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final llibre = resultados[index];
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
                      },
                    )
                  : const Center(child: Text('No se encontraron resultados')),
            ),
          ],
        ),
      ),
    );
  }
}
