import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/valoracio.dart';
import '../carregaDeDades.dart'; // Importat per accedir a les dades globals

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

class _PantallaLlibreState extends State<PantallaLlibre> {
  // 1. Carreguem totes les dades necessàries per fer les cerques per ID
  final List<Llibre> listaLibros =
      totsElsLlibres; // Variable global de carregaDeDades
  final List<Canco> totesLesCancons =
      getAllCancons(); // Funció global de carregaDeDades

  bool jaReservat = false;

  // Funció auxiliar per construir les estrelles
  List<Widget> _buildStars(double puntuacio) {
    int fullStars = puntuacio.floor();
    bool hasHalfStar = (puntuacio - fullStars) >= 0.5;
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

  // HELPER: Buscar Canco per ID
  Canco? _getCancoById(String id) {
    try {
      return totesLesCancons.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // HELPER: Recuperar Valoracio per ID
  // (Com que no tenim una BBDD de valoracions a carregaDeDades, en generem una de mostra
  // basada en l'ID per tal que la UI no falli).
  Valoracio _getValoracioSimulada(String idRef) {
    return Valoracio(
      puntuacio: 4.5, // Puntuació simulada
      review:
          "Aquesta és una ressenya simulada per a la referència $idRef, ja que les dades reals no estan carregades.",
      idUsuari: "User-$idRef",
      idLlibre: widget.llibre.id,
    );
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
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.book, size: 150),
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

            // Botó reservar
            ElevatedButton(
              onPressed: (llibre.disponible() && !jaReservat)
                  ? () {
                      setState(() {
                        // TODO: Implementar lògica real de disminuir stock a carregaDeDades
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
                ? const Text('Encara no hi ha valoracions per a aquest llibre.')
                : Column(
                    children: llibre.valoracions.map((idValoracio) {
                      // CORRECCIÓ: Transformem l'ID (String) en objecte Valoracio
                      final valoracio = _getValoracioSimulada(idValoracio);

                      return Card(
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
                                        valoracio.idUsuari,
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
                                        valoracio.puntuacio.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 14),
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
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 30),

            // PLAYLIST ASSOCIADA
            Text(
              'Playlist associada al llibre (${llibre.playlist.length}):',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            llibre.playlist.isEmpty
                ? const Text('No hi ha playlist associada.')
                : Column(
                    children: llibre.playlist.map((idCanco) {
                      // CORRECCIÓ: Busquem l'objecte Canco real usant l'ID
                      final Canco? canco = _getCancoById(idCanco);

                      if (canco == null)
                        return const SizedBox.shrink(); // Si no troba la cançó, no pinta res

                      return ListTile(
                        leading: canco.urlImatge != null
                            ? Image.network(
                                canco.urlImatge!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.music_note),
                              )
                            : const Icon(Icons.music_note),
                        title: Text(canco.titol),
                        subtitle: Text(canco.autor),
                        // 'duracioToString' ve de canço.dart
                        trailing: Text(duracioToString(canco.minuts)),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 30),

            // ALTRES LLIBRES
            Text(
              'Altres llibres disponibles:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: listaLibros
                  .where(
                    (lib) => lib.id != llibre.id,
                  ) // Excloem el llibre actual
                  .map(
                    (lib) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(lib.titol),
                      subtitle: Text(lib.autor),
                      trailing: Text("Stock: ${lib.stock}"),
                      onTap: () {
                        // Naveguem al nou llibre (push replacement o push normal)
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
