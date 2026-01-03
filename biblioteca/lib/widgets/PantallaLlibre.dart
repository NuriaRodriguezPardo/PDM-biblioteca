import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Solo añadimos esto
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/valoracio.dart';
import '../clases/reserva.dart';
import '../carregaDeDades.dart';
import '../clases/carregaDeHistorial.dart';
import 'package:audioplayers/audioplayers.dart';
import '../InternalLists.dart';

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

class _PantallaLlibreState extends State<PantallaLlibre> {
  final List<Llibre> llibresPerMostrar = llistaLlibresGlobal;
  final List<Canco> canconsPerMostrar = llistaCanconsGlobal;

  bool jaReservat = false;
  final AudioPlayer _audioplayer = AudioPlayer();
  String? _cancoActual;
  bool isPlaying = false;

  // Accedemos al usuario de Firebase para saber quién es
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Comprovar si ja està reservat (Mantenemos tu lógica original)
    jaReservat = reserves.any((r) => r.llibre == widget.llibre.id);
  }

  // --- MANTENEMOS TUS FUNCIONES ORIGINALES TAL CUAL ---

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

  Valoracio _getValoracioSimulada(String idRef) {
    return Valoracio(
      puntuacio: 4.5,
      review: "Aquesta és una ressenya simulada per a la referència $idRef.",
      idUsuari:
          currentUser?.displayName ??
          "Usuari", // Cambiamos esto por el nombre real de Firebase
      idLlibre: widget.llibre.id,
    );
  }

  bool _estaAPendents() => llibresPendents.any((l) => l.id == widget.llibre.id);
  bool _estaALlegits() => llibresLlegits.any((l) => l.id == widget.llibre.id);

  void _afegirAPendents() {
    if (_estaAPendents()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ja a pendents'),
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
      "Llibre: ${widget.llibre.titol}",
      Icons.bookmark_add,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Afegit a pendents'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _marcarComLlegit() {
    if (_estaALlegits()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ja llegit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      llibresLlegits.add(widget.llibre);
      llibresPendents.removeWhere((l) => l.id == widget.llibre.id);
    });
    registrarActivitat(
      "Llibre llegit",
      "Has llegit '${widget.llibre.titol}'.",
      Icons.check_circle,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marcat com a llegit!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _ferReserva() {
    bool exito = reservarLlibreGlobal(widget.llibre.id);
    if (exito) {
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
        "Reservat: ${widget.llibre.titol}",
        Icons.bookmark_added,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sense stock'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- MANTENEMOS TU BUILD COMPLETO ---

  @override
  Widget build(BuildContext context) {
    final llibre = widget.llibre;
    final estaAPendents = _estaAPendents();
    final estaALlegits = _estaALlegits();
    final List<Llibre> recomenats = obtenerLibrosRecomendados(
      llibre,
      llistaLlibresGlobal,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(llibre.titol),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'pendents') _afegirAPendents();
              if (value == 'llegit') _marcarComLlegit();
              if (value == 'llista') _mostrarSeleccioLlista(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pendents',
                enabled: !estaAPendents,
                child: const Text('A pendents'),
              ),
              PopupMenuItem(
                value: 'llegit',
                enabled: !estaALlegits,
                child: const Text('Marcar com llegit'),
              ),
              const PopupMenuItem(
                value: 'llista',
                child: Text('Afegir a llista'),
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
            Center(
              child: llibre.urlImatge != null
                  ? Image.network(
                      llibre.urlImatge!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.book, size: 150),
            ),
            const SizedBox(height: 16),
            Text(
              llibre.titol,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              llibre.autor,
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            if (estaAPendents || estaALlegits)
              Wrap(
                spacing: 8,
                children: [
                  if (estaAPendents)
                    Chip(
                      label: const Text('A pendents'),
                      backgroundColor: Colors.orange.shade100,
                    ),
                  if (estaALlegits)
                    Chip(
                      label: const Text('Llegit'),
                      backgroundColor: Colors.green.shade100,
                    ),
                ],
              ),
            const SizedBox(height: 10),
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
            Wrap(
              spacing: 8.0,
              children: llibre.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (llibre.disponible() && !jaReservat)
                        ? _ferReserva
                        : null,
                    icon: Icon(jaReservat ? Icons.check : Icons.shopping_cart),
                    label: Text(jaReservat ? 'Reservat' : 'Reservar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Valoracions (${llibre.valoracions.length}):',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...llibre.valoracions.map((id) {
              final val = _getValoracioSimulada(id);
              return Card(
                child: ListTile(
                  title: Text(val.idUsuari),
                  subtitle: Text(val.review),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildStars(val.puntuacio),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 30),
            const Text(
              'Playlist associada',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ...llibre.playlist.map((idCanco) {
              final canco = getCancoById(idCanco);
              if (canco == null) return const SizedBox.shrink();
              bool isCurrent = _cancoActual == canco.id;
              return Card(
                color: const Color.fromARGB(176, 255, 228, 221),
                child: ListTile(
                  leading: Image.network(
                    canco.urlImatge ?? '',
                    width: 50,
                    errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                  ),
                  title: Text(canco.titol),
                  trailing: IconButton(
                    icon: Icon(
                      isCurrent && isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    onPressed: () async {
                      if (isCurrent && isPlaying) {
                        await _audioplayer.pause();
                        setState(() => isPlaying = false);
                      } else {
                        await _audioplayer.play(UrlSource(canco.urlAudio));
                        setState(() {
                          _cancoActual = canco.id;
                          isPlaying = true;
                        });
                      }
                    },
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 30),
            const Text(
              'Llibres semblants:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...recomenats
                .map(
                  (lib) => ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(lib.titol),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaLlibre(llibre: lib),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  // --- MANTENEMOS TUS FUNCIONES DE RECOMENDACIÓN Y LISTAS ---

  List<Llibre> obtenerLibrosRecomendados(Llibre actual, List<Llibre> tots) {
    final otros = tots.where((l) => l.id != actual.id).toList();
    final tags = actual.tags.toSet();
    final res = otros
        .where((l) => tags.intersection(l.tags.toSet()).isNotEmpty)
        .toList();
    res.shuffle();
    return res.take(5).toList();
  }

  void _mostrarSeleccioLlista(BuildContext context) {
    if (llistesPersonalitzades.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Afegir a llista:'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: llistesPersonalitzades.length,
            itemBuilder: (context, index) {
              final llista = llistesPersonalitzades[index];
              return ListTile(
                title: Text(llista.nom),
                onTap: () {
                  setState(() {
                    llista.llibres.add(widget.llibre.id);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioplayer.dispose();
    super.dispose();
  }
}
