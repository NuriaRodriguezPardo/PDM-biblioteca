import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/valoracio.dart'; // Assegurem la importació de Valoracio
import '../carregaDeDades.dart'; // Afegit per getAllLlibres

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

// Exemple de playlist (Aquesta línia hauria de ser al fitxer canço.dart o carregaDeDades.dart)
// List<Canco> playy = getCancons();

class _PantallaLlibreState extends State<PantallaLlibre> {
  // CRIDA CORREGIDA: Utilitzem getAllLlibres() (pública)
  final List<Llibre> listaLibros = getAllLlibres();
  bool jaReservat = false; // Controla si el usuario ya reservó este libro

  // Funció auxiliar per construir les estrelles
  List<Widget> _buildStars(double puntuacio) {
    // S'utilitza .floor() per estrelles completes
    int fullStars = puntuacio.floor();
    // Comprovem la mitja estrella
    bool hasHalfStar = (puntuacio - fullStars) >= 0.5;
    // Calculem les estrelles buides
    int emptyStars = 5 - (fullStars + (hasHalfStar ? 1 : 0));

    final stars = <Widget>[];

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }

    return stars;
  }

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
            // Imatge del llibre
            Center(
              child: llibre.urlImatge != null && llibre.urlImatge!.isNotEmpty
                  ? Image.network(
                      llibre.urlImatge!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.book, size: 150),
            ),
            const SizedBox(height: 16),

            // Títol i autor
            Text(
              llibre.titol,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              llibre.autor,
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),

            // Idioma i stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Idioma: ${llibre.idioma}'),
                Text(
                  llibre.disponible()
                      ? 'Stock: ${llibre.stock}'
                      : 'No disponible',
                  style: TextStyle(
                    color: llibre.disponible() ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tags
            Wrap(
              spacing: 8.0,
              children: llibre.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            const SizedBox(height: 30),

            // Botón reservar
            ElevatedButton(
              onPressed: (llibre.disponible() && !jaReservat)
                  ? () {
                      setState(() {
                        // S'hauria de cridar a un mètode que disminueixi l'stock remot
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reservant ${llibre.titol}')),
                        );
                        jaReservat = true;
                      });
                    }
                  : null,
              child: Text(jaReservat ? 'Ja reservat' : 'Reservar'),
            ),
            const SizedBox(height: 30),

            // SECCIÓ DE VALORACIONS
            Text(
              'Valoracions dels usuaris (${llibre.valoracions.length}):',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            llibre.valoracions.isEmpty
                ? const Text('Aún no hay valoracions per a aquest llibre.')
                : Column(
                    children: llibre.valoracions
                        .map(
                          (valoracio) => Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fila superior: Nom d'usuari i Puntuació
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 18,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            valoracio.usuari.nom,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Puntuació d'estrelles
                                      Row(
                                        children: [
                                          ..._buildStars(valoracio.puntuacio),
                                          const SizedBox(width: 4),
                                          Text(
                                            valoracio.puntuacio.toStringAsFixed(
                                              1,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Ressenya
                                  Text(
                                    valoracio.review,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 30),

            // Playlist asociada
            Text(
              'Playlist asociada al libro (${llibre.playlist.length}):',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            llibre.playlist.isEmpty
                ? const Text('No hi ha playlist associada.')
                : Column(
                    children: llibre.playlist
                        .map(
                          (canco) => ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(canco.titol),
                            subtitle: Text(canco.autor),
                            // Corregit: utilitzem duracioToString
                            trailing: Text(duracioToString(canco.minuts)),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 30),

            // Otros libros
            Text(
              'Otros libros disponibles:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: listaLibros
                  .where(
                    (lib) => lib.id != llibre.id,
                  ) // Excluim el llibre actual
                  .map(
                    (lib) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(lib.titol),
                      subtitle: Text(lib.autor),
                      trailing: Text("Stock: ${lib.stock}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaLlibre(llibre: lib),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
