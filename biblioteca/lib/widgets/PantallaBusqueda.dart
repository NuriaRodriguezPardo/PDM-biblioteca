import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import '../InternalLists.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String query = '';

  // CORRECCIÓ: Usem la llista global exportada a carregaDeDades.dart en lloc de cridar la funció de nou.
  // Això garanteix consistència (mateixa instància d'objectes).
  final List<Llibre> llibresPerMostrar = llistaLlibresGlobal;
  @override
  Widget build(BuildContext context) {
    // Definimos la lista de resultados basándonos en si hay búsqueda o no
    List<Llibre> resultados;

    if (query.isEmpty) {
      // SI NO HAY BÚSQUEDA: Mostramos solo los 5 primeros (o una muestra aleatoria)
      // Usamos .take(10) para asegurar que no intentamos coger más de los que hay
      resultados = llistaLlibresGlobal.take(5).toList();
    } else {
      // SI HAY BÚSQUEDA: Filtramos todos los que coincidan
      resultados = llistaLlibresGlobal.where((llibre) {
        final queryLower = query.toLowerCase();

        final tituloMatch = llibre.titol.toLowerCase().contains(queryLower);
        final autorMatch = llibre.autor.toLowerCase().contains(queryLower);
        final tagMatch = llibre.tags.any(
          (tag) => tag.toLowerCase().contains(queryLower),
        );

        return tituloMatch || autorMatch || tagMatch;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar llibres')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar per títol, autor o etiqueta...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => query = ''),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Subtítulo informativo opcional
            if (query.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Suggeriments per a tu:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: resultados.isNotEmpty
                  ? ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final llibre = resultados[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: llibre.urlImatge != null
                                ? Image.network(
                                    llibre.urlImatge!,
                                    width: 45,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                  )
                                : const Icon(Icons.book, size: 40),
                          ),
                          title: Text(llibre.titol),
                          subtitle: Text(llibre.autor),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
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
