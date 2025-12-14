import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/valoracio.dart';
import '../clases/reserva.dart';
import '../carregaDeDades.dart';
import '../clases/carregaDeHistorial.dart';

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

class _PantallaLlibreState extends State<PantallaLlibre> {
  final List<Llibre> listaLibros = totsElsLlibres;
  final List<Canco> totesLesCancons = getAllCancons();

  bool jaReservat = false;

  @override
  void initState() {
    super.initState();
    // Comprovar si ja està reservat
    jaReservat = reserves.any((r) => r.llibre == widget.llibre.id);
  }

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

  Canco? _getCancoById(String id) {
    try {
      return totesLesCancons.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Valoracio _getValoracioSimulada(String idRef) {
    return Valoracio(
      puntuacio: 4.5,
      review:
          "Aquesta és una ressenya simulada per a la referència $idRef, ja que les dades reals no estan carregades.",
      idUsuari: "User-$idRef",
      idLlibre: widget.llibre.id,
    );
  }

  // Comprovar si el llibre està a pendents
  bool _estaAPendents() {
    return llibresPendents.any((l) => l.id == widget.llibre.id);
  }

  // Comprovar si el llibre està a llegits
  bool _estaALlegits() {
    return llibresLlegits.any((l) => l.id == widget.llibre.id);
  }

  // Afegir a pendents
  void _afegirAPendents() {
    if (_estaAPendents()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aquest llibre ja està a la llista de pendents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      llibresPendents.add(widget.llibre);
    });

    registrarActivitat(
      "Afegit a Pendents",
      "Has afegit '${widget.llibre.titol}' a la llista de pendents.",
      Icons.bookmark_add,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.llibre.titol}" afegit a pendents'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Marcar com a llegit
  void _marcarComLlegit() {
    if (_estaALlegits()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aquest llibre ja està marcat com a llegit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      // Afegir a llegits
      llibresLlegits.add(widget.llibre);

      // Treure de pendents si hi era
      llibresPendents.removeWhere((l) => l.id == widget.llibre.id);
    });

    registrarActivitat(
      "Llibre llegit",
      "Has marcat '${widget.llibre.titol}' com a llegit.",
      Icons.check_circle,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.llibre.titol}" marcat com a llegit!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Fer reserva
  void _ferReserva() {
    bool exito = reservarLlibreGlobal(widget.llibre.id);

    if (exito) {
      // Crear nova reserva
      final novaReserva = Reserva(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        llibre: widget.llibre.id,
        dataReserva: DateTime.now(),
        dataVenciment: DateTime.now().add(const Duration(days: 30)),
      );

      setState(() {
        jaReservat = true;
        reserves.add(novaReserva);
      });

      registrarActivitat(
        "Reserva realitzada",
        "Has reservat el llibre '${widget.llibre.titol}'.",
        Icons.bookmark_added,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva confirmada: ${widget.llibre.titol}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No queda stock disponible.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final llibre = widget.llibre;
    final estaAPendents = _estaAPendents();
    final estaALlegits = _estaALlegits();

    return Scaffold(
      appBar: AppBar(
        title: Text(llibre.titol),
        actions: [
          // Menú d'opcions ràpides
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'pendents':
                  _afegirAPendents();
                  break;
                case 'llegit':
                  _marcarComLlegit();
                  break;
                case 'llista':
                  _mostrarSeleccioLlista(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pendents',
                enabled: !estaAPendents,
                child: Row(
                  children: [
                    Icon(
                      estaAPendents ? Icons.bookmark : Icons.bookmark_add,
                      color: estaAPendents ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(estaAPendents ? 'Ja a pendents' : 'Afegir a pendents'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'llegit',
                enabled: !estaALlegits,
                child: Row(
                  children: [
                    Icon(
                      estaALlegits
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: estaALlegits ? Colors.grey : null,
                    ),
                    const SizedBox(width: 8),
                    Text(estaALlegits ? 'Ja llegit' : 'Marcar com llegit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'llista',
                child: Row(
                  children: [
                    Icon(Icons.playlist_add),
                    SizedBox(width: 8),
                    Text('Afegir a llista'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

            // Indicadors d'estat
            if (estaAPendents || estaALlegits)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (estaAPendents)
                      Chip(
                        avatar: const Icon(Icons.bookmark, size: 18),
                        label: const Text('A pendents'),
                        backgroundColor: Colors.orange.shade100,
                      ),
                    if (estaALlegits)
                      Chip(
                        avatar: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Llegit'),
                        backgroundColor: Colors.green.shade100,
                      ),
                  ],
                ),
              ),

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
            const SizedBox(height: 20),

            // Botons d'acció
            Row(
              children: [
                // Botó reservar
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (llibre.disponible() && !jaReservat)
                        ? _ferReserva
                        : null,
                    icon: Icon(jaReservat ? Icons.check : Icons.shopping_cart),
                    label: Text(jaReservat ? 'Reservat' : 'Reservar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Botó pendent
                IconButton(
                  onPressed: estaAPendents ? null : _afegirAPendents,
                  icon: Icon(
                    estaAPendents ? Icons.bookmark : Icons.bookmark_border,
                    color: estaAPendents ? Colors.orange : null,
                  ),
                  tooltip: estaAPendents
                      ? 'Ja a pendents'
                      : 'Afegir a pendents',
                  style: IconButton.styleFrom(
                    backgroundColor: estaAPendents
                        ? Colors.orange.shade100
                        : Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 5),

                // Botó llegit
                IconButton(
                  onPressed: estaALlegits ? null : _marcarComLlegit,
                  icon: Icon(
                    estaALlegits
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: estaALlegits ? Colors.green : null,
                  ),
                  tooltip: estaALlegits ? 'Ja llegit' : 'Marcar com llegit',
                  style: IconButton.styleFrom(
                    backgroundColor: estaALlegits
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                  ),
                ),
              ],
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
                      final valoracio = _getValoracioSimulada(idValoracio);

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                      final Canco? canco = _getCancoById(idCanco);
                      if (canco == null) return const SizedBox.shrink();

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
                  .where((lib) => lib.id != llibre.id)
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

  // Mostrar selecció de llista personalitzada
  void _mostrarSeleccioLlista(BuildContext context) {
    if (llistesPersonalitzades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No tens cap llista personalitzada. Crea\'n una a la Biblioteca!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Afegir "${widget.llibre.titol}" a:'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: llistesPersonalitzades.length,
              itemBuilder: (context, index) {
                final llista = llistesPersonalitzades[index];
                final jaConte = llista.llibres.contains(widget.llibre.id);

                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: jaConte
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(llista.nom),
                  subtitle: Text(
                    jaConte
                        ? 'Ja conté aquest llibre'
                        : '${llista.numLlibres} llibres',
                  ),
                  enabled: !jaConte,
                  onTap: jaConte
                      ? null
                      : () {
                          setState(() {
                            llista.llibres.add(widget.llibre.id);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '"${widget.llibre.titol}" afegit a "${llista.nom}"',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
          ],
        );
      },
    );
  }
}
