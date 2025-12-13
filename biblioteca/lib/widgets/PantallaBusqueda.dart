import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import '../carregaDeDades.dart'; // Importat per getAllLlibres

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String query = '';

  // CORRECCIÓ: Usem la llista global exportada a carregaDeDades.dart en lloc de cridar la funció de nou.
  // Això garanteix consistència (mateixa instància d'objectes).
  final List<Llibre> allLlibres = totsElsLlibres;

  @override
  Widget build(BuildContext context) {
    // Filtre de cerca
    final resultados = allLlibres.where((llibre) {
      final tituloMatch = llibre.titol.toLowerCase().contains(
        query.toLowerCase(),
      );
      final autorMatch = llibre.autor.toLowerCase().contains(
        query.toLowerCase(),
      );

      // Opcional: També pots buscar per tags si vols
      final tagMatch = llibre.tags.any(
        (tag) => tag.toLowerCase().contains(query.toLowerCase()),
      );

      return tituloMatch || autorMatch || tagMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar llibres')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar per títol, autor o etiqueta...',
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
                              ? Image.network(
                                  llibre.urlImatge!,
                                  width: 50,
                                  height: 75, // Afegit height per proporció
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Si la imatge falla, mostrem icona
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    );
                                  },
                                )
                              : const Icon(Icons.book, size: 40),
                          title: Text(llibre.titol),
                          subtitle: Text(llibre.autor),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PantallaLlibre(llibre: llibre),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No s\'han trobat resultats'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
