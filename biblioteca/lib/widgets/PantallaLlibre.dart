import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Solo añadimos esto
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/valoracio.dart';
import '../clases/reserva.dart';
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
  final String? currentUser = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _reviewController = TextEditingController();
  double _novaPuntuacio = 5.0; // Puntuación por defecto

  @override
  void initState() {
    super.initState();
    _comprovarReservaUsuari();
  }

  // Getter que filtra automáticamente las valoraciones de la lista global
  List<ValoracioId> get valoracionsFiltrades {
    return llistaValoracionsGlobal
        .where((v) => v.idLlibre == widget.llibre.id)
        .map(
          (v) => v.id,
        ) // Obtenemos el objeto ValoracioId (idUsuari + idLlibre)
        .toList();
  }

  // Lògica per saber si l'usuari actual té aquest llibre reservat
  void _comprovarReservaUsuari() {
    if (currentUser != null) {
      final usuariActual = getUsuariById(currentUser!);
      if (usuariActual != null) {
        // Busquem si alguna de les reserves de l'usuari apunta a aquest llibre
        jaReservat = llistaReservesGlobal.any(
          (r) =>
              usuariActual.reserves.contains(r.id) &&
              r.llibre == widget.llibre.id,
        );
      }
    }
  }

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

  Widget _buildFormulariValoracio() {
    if (currentUser == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
        vertical: 15,
      ), // Reducido un poco el margen
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ), // Padding ajustado
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Escriu la teva ressenya",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ), // Fuente un punto más pequeña
            ),

            // Selector de Estrellas
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  constraints:
                      const BoxConstraints(), // Reduce espacio extra del botón
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  icon: Icon(
                    index < _novaPuntuacio ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  ),
                  onPressed: () => setState(() => _novaPuntuacio = index + 1.0),
                );
              }),
            ),

            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: "Què t'ha semblat aquest llibre? (Màx. 80 paraules)",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10), // Caja más compacta
              ),
              maxLines: 2, // Caja un punto más pequeña (de 3 a 2 líneas)
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Lógica de validación de 80 palabras
                int numParaules = _reviewController.text
                    .trim()
                    .split(RegExp(r'\s+'))
                    .length;

                if (_reviewController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("La ressenya no pot estar buida"),
                    ),
                  );
                } else if (numParaules > 80) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Has superat el límit: $numParaules/80 paraules",
                      ),
                    ),
                  );
                } else {
                  _enviarValoracio();
                  // Limpieza del formulario tras el envío
                  setState(() {
                    _reviewController.clear();
                    _novaPuntuacio = 5.0;
                  });
                }
              },
              child: const Text("Publicar ressenya"),
            ),
          ],
        ),
      ),
    );
  }

  // --- ENVIAR VALORACIÓN A TIEMPO REAL ---
  void _enviarValoracio() async {
    if (currentUser == null || _reviewController.text.isEmpty) return;

    final nuevoId = ValoracioId(
      idUsuari: currentUser!,
      idLlibre: widget.llibre.id,
    );

    final nuevaVal = Valoracio(
      puntuacio: _novaPuntuacio,
      review: _reviewController.text,
      idUsuari: currentUser!,
      idLlibre: widget.llibre.id,
    );

    // 1. ACTUALIZACIÓN LOCAL INMEDIATA (UI)
    setState(() {
      // Añadimos el ID a la lista del libro si no está
      if (!widget.llibre.valoracions.contains(nuevoId)) {
        widget.llibre.valoracions.add(nuevoId);
      }

      // Actualizamos la lista global de memoria
      int idx = llistaValoracionsGlobal.indexWhere(
        (v) => v.idUsuari == currentUser && v.idLlibre == widget.llibre.id,
      );

      if (idx != -1) {
        llistaValoracionsGlobal[idx] = nuevaVal;
      } else {
        llistaValoracionsGlobal.add(nuevaVal);
      }
    });

    try {
      // 2. FIREBASE: Guardar la valoración
      // Usamos el .toString() del ID como nombre de documento para evitar duplicados del mismo usuario en el mismo libro
      await FirebaseFirestore.instance
          .collection('valoracions')
          .doc(nuevoId.toString())
          .set(nuevaVal.toJson());

      // 3. FIREBASE: Actualizar la lista de IDs en el documento del libro
      await FirebaseFirestore.instance
          .collection('libros')
          .doc(widget.llibre.id)
          .update({
            'valoraciones': widget.llibre.valoracions
                .map((v) => v.toString())
                .toList(),
          });

      // Registrar en el historial local
      registrarActivitat(
        "Nova valoració",
        "Has valorat ${widget.llibre.titol} amb ${_novaPuntuacio.toInt()} estrelles",
        Icons.star,
      );
    } catch (e) {
      print("Error al enviar valoració: $e");
      // Opcional: Podrías revertir el setState aquí si falla
    }

    _reviewController.clear();
    FocusScope.of(context).unfocus(); // Cierra el teclado
  }

  bool _estaAPendents() {
    final usuari = getUsuariById(currentUser ?? "");
    return usuari?.pendents.contains(widget.llibre.id) ?? false;
  }

  bool _estaALlegits() {
    final usuari = getUsuariById(currentUser ?? "");
    return usuari?.llegits.contains(widget.llibre.id) ?? false;
  }

  void _afegirAPendents() {
    if (_estaAPendents()) return;
    final usuari = getUsuariById(currentUser ?? "");
    if (usuari != null) {
      setState(() {
        // 1. Lògica excloent: si estava a llegits, el treiem
        usuari.llegits.remove(widget.llibre.id);

        // 2. Afegim a pendents
        usuari.pendents.add(widget.llibre.id);
      });

      // 3. Sincronitzem amb Firebase (actualitzem ambdós camps per seguretat)
      FirebaseFirestore.instance.collection('usuaris').doc(currentUser).update({
        'pendents': usuari.pendents,
        'llegits': usuari.llegits,
      });

      // 4. Registrem al historial
      registrarActivitat(
        "Llibre pendent",
        "Afegit a pendents: ${widget.llibre.titol}",
        Icons.bookmark_border,
      );
    }
  }

  void _marcarComLlegit() {
    if (_estaALlegits()) return;
    final usuari = getUsuariById(currentUser ?? "");
    if (usuari != null) {
      setState(() {
        // 1. Lògica excloent: si estava a pendents, el treiem
        usuari.pendents.remove(widget.llibre.id);

        // 2. Afegim a llegits
        usuari.llegits.add(widget.llibre.id);
      });

      // 3. Sincronitzem amb Firebase
      FirebaseFirestore.instance.collection('usuaris').doc(currentUser).update({
        'llegits': usuari.llegits,
        'pendents': usuari.pendents,
      });

      // 4. Registrem al historial
      registrarActivitat(
        "Llibre llegit",
        "Has acabat de llegir: ${widget.llibre.titol}",
        Icons.check_circle,
      );
    }
  }

  Widget _buildSeccioValoracions() {
    // Ahora usamos directamente la lista que tiene el objeto llibre
    final valoracionsDelLlibre = widget.llibre.valoracions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valoracions (${valoracionsDelLlibre.length}):',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...valoracionsDelLlibre.map((vId) {
          // Buscamos el contenido de la valoración en la lista global cargada
          final valoracio = llistaValoracionsGlobal.firstWhere(
            (v) => v.id == vId,
            orElse: () =>
                Valoracio(puntuacio: 0, review: '', idUsuari: '', idLlibre: ''),
          );

          if (valoracio.idUsuari.isEmpty) return const SizedBox.shrink();

          final autor = getUsuariById(valoracio.idUsuari);

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: (autor?.fotoUrl != null)
                    ? NetworkImage(autor!.fotoUrl!)
                    : null,
                child: (autor?.fotoUrl == null)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(autor?.nom ?? "Usuari desconegut"),
              subtitle: Text(valoracio.review),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildStars(valoracio.puntuacio),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _ferReserva() async {
    // Añadimos async
    bool exito = reservarLlibreGlobal(widget.llibre.id);
    final user = currentUser;

    if (exito && user != null) {
      final docRef = FirebaseFirestore.instance.collection('reserves').doc();
      final String idFirebase = docRef.id;

      final novaReserva = Reserva(
        id: idFirebase,
        llibre: widget.llibre.id,
        dataReserva: DateTime.now(),
        dataVenciment: DateTime.now().add(const Duration(days: 30)),
      );

      // 1. Guardar el objeto Reserva en Firebase
      await FirebaseFirestore.instance
          .collection('reserves')
          .doc(idFirebase)
          .set(novaReserva.toJson());

      setState(() {
        jaReservat = true;
        llistaReservesGlobal.add(novaReserva);
        final usuariActual = getUsuariById(user);
        if (usuariActual != null) {
          usuariActual.reserves.add(idFirebase);

          // 2. Actualizar el documento del Usuario con la nueva ID de reserva
          FirebaseFirestore.instance.collection('usuaris').doc(user).update({
            'reserves': usuariActual.reserves,
          });
        }

        // 3. Actualizar el Stock del libro en Firebase
        FirebaseFirestore.instance
            .collection('libros')
            .doc(widget.llibre.id)
            .update({'stock': widget.llibre.stock});
      });

      registrarActivitat(
        "Reserva realitzada",
        "Reservat: ${widget.llibre.titol}",
        Icons.bookmark_added,
      );
    }
  }

  bool reservarLlibreGlobal(String idLlibre) {
    try {
      // 1. Busquem el llibre "real" dins la llista global 'totsElsLlibres'
      final llibre = llistaLlibresGlobal.firstWhere((l) => l.id == idLlibre);

      // 2. Intentem disminuir l'stock usant el mètode de la classe Llibre
      // (El mètode disminuirStock ja controla si stock > 0)
      bool resultat = llibre.disminuirStock(1);

      return resultat;
    } catch (e) {
      // Si no troba el llibre o passa algo raro
      return false;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BOTÓN PENDENTS
                ElevatedButton.icon(
                  onPressed: _estaAPendents() ? null : _afegirAPendents,
                  icon: Icon(
                    Icons.bookmark,
                    color: _estaAPendents() ? Colors.white : Colors.black,
                  ),
                  label: const Text('Pendent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estaAPendents()
                        ? Colors.orange
                        : Colors.grey[200],
                    foregroundColor: _estaAPendents()
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                // BOTÓN MARCAR COM LLEGIT
                ElevatedButton.icon(
                  onPressed: _estaALlegits() ? null : _marcarComLlegit,
                  icon: Icon(
                    Icons.check_circle,
                    color: _estaALlegits() ? Colors.white : Colors.green,
                  ),
                  label: const Text('Llegit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estaALlegits()
                        ? Colors.green
                        : Colors.grey[200],
                    foregroundColor: _estaALlegits()
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildFormulariValoracio(), // <--- Tu nueva sección aquí
            const SizedBox(height: 20),
            _buildSeccioValoracions(), // La lista de valoraciones existentes

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
    // Solo mostramos las listas donde el usuario actual es miembro
    final llistesUsuari = llistesPersonalitzadesGlobals
        .where((l) => l.usuaris.contains(currentUser))
        .toList();

    if (llistesUsuari.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No tens llistes creades')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Afegir a llista:'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: llistesUsuari.length,
            itemBuilder: (context, index) {
              final llista = llistesUsuari[index];
              return ListTile(
                title: Text(llista.nom),
                onTap: () async {
                  // 1. Actualización local inmediata (UI)
                  setState(() {
                    if (!llista.llibres.contains(widget.llibre.id)) {
                      llista.llibres.add(widget.llibre.id);
                    }
                  });

                  // 2. Firebase
                  await FirebaseFirestore.instance
                      .collection('llistes_personalitzades')
                      .doc(llista.id)
                      .update({'llibres': llista.llibres});

                  // 3. Sincronizar con la lista global de memoria para que otras pantallas lo vean
                  int indexGlobal = llistesPersonalitzadesGlobals.indexWhere(
                    (l) => l.id == llista.id,
                  );
                  if (indexGlobal != -1) {
                    llistesPersonalitzadesGlobals[indexGlobal] = llista;
                  }

                  registrarActivitat(
                    "Afegit a llista",
                    "Has afegit '${widget.llibre.titol}' a la llista '${llista.nom}'",
                    Icons.playlist_add,
                  );

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
