import 'package:flutter/material.dart';
import 'dart:math';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import '../clases/canço.dart';
import '../carregaDeDades.dart'; // Importat per getAllCancons() i totsElsLlibres
import '../clases/carregaDeHistorial.dart';

class PantallaMatching extends StatefulWidget {
  static String route = '/PantallaMatching';
  final Usuari usuari;
  const PantallaMatching({super.key, required this.usuari});

  @override
  State<PantallaMatching> createState() => _PantallaMatchingState();
}

class _PantallaMatchingState extends State<PantallaMatching> {
  // Llista de totes les cançons disponibles
  List<Canco> _allCancons = [];

  // La llista de 10 cançons aleatòries per mostrar a l'usuari
  List<Canco> _canconsMostrades = [];

  // La cançó que l'usuari ha seleccionat
  Canco? _cancoSeleccionada;

  // El llibre assignat (resultat del matching)
  Llibre? _llibreAssignat;

  @override
  void initState() {
    super.initState();
    // 1. Obtenir totes les cançons (Des de carregaDeDades.dart)
    _allCancons = getAllCancons();
    // 2. Seleccionar les 10 cançons aleatòries i amb tags variats
    _canconsMostrades = _seleccionarCanconsAleatories(_allCancons, 10);
  }

  // Lògica per seleccionar 10 cançons aleatòries i variades
  List<Canco> _seleccionarCanconsAleatories(
    List<Canco> totesLesCancons,
    int num,
  ) {
    if (totesLesCancons.isEmpty) return [];
    if (totesLesCancons.length <= num) return totesLesCancons;

    // Usarem un set per controlar la varietat de tags
    final List<Canco> seleccionades = [];
    final Set<String> tagsUsats = {};
    final Random random = Random();

    // Intentem seleccionar cançons que aportin nous tags
    while (seleccionades.length < num) {
      // Elegim un índex aleatori
      final int index = random.nextInt(totesLesCancons.length);
      final Canco cancoActual = totesLesCancons[index];

      bool teNouTag = false;
      for (var tag in cancoActual.tags) {
        if (!tagsUsats.contains(tag)) {
          teNouTag = true;
          break;
        }
      }

      // Si la cançó aporta un tag nou O si ja hem intentat molt i necessitem omplir
      if (teNouTag || seleccionades.length < num * 0.5) {
        if (!seleccionades.contains(cancoActual)) {
          seleccionades.add(cancoActual);
          // Afegim els seus tags al set de control
          tagsUsats.addAll(cancoActual.tags);
        }
      }

      // Mesura de seguretat per evitar bucles infinits en col·leccions petites
      if (seleccionades.length == totesLesCancons.length) break;
    }

    // Si encara ens falten, les omplim amb les que quedin aleatòriament
    while (seleccionades.length < num) {
      final int index = random.nextInt(totesLesCancons.length);
      final Canco cancoActual = totesLesCancons[index];
      if (!seleccionades.contains(cancoActual)) {
        seleccionades.add(cancoActual);
      }
    }

    return seleccionades;
  }

  // ------------------
  // ACCIONS DE L'USUARI
  // ------------------

  void _seleccionarCanco(Canco canco) {
    setState(() {
      _cancoSeleccionada = canco;
      // Una vegada seleccionada la cançó, busquem el llibre associat
      _llibreAssignat = _getLlibrePerCanco(canco);

      if (_llibreAssignat != null && _llibreAssignat!.id != "-1") {
        registrarActivitat(
          "Match Musical",
          "Match entre '${canco.titol}' y '${_llibreAssignat!.titol}'.",
          Icons.music_note,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matching de llibre a ${widget.usuari.nom}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_cancoSeleccionada == null)
              _buildSeleccioCanco() // Mostrem la selecció de cançons
            else
              _buildResultatMatching(), // Mostrem el resultat del matching
          ],
        ),
      ),
    );
  }

  // Widget per a la selecció de cançons
  Widget _buildSeleccioCanco() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tria la cançó que et representi avui:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnes
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5, // Targetes més horitzontals
          ),
          itemCount: _canconsMostrades.length,
          itemBuilder: (context, index) {
            final canco = _canconsMostrades[index];
            return Card(
              elevation: 4,
              child: InkWell(
                onTap: () => _seleccionarCanco(canco),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canco.titol,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Tags: ${canco.tags.join(', ')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget per mostrar el resultat
  Widget _buildResultatMatching() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          Text(
            'Has seleccionat: "${_cancoSeleccionada!.titol}"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Text(
            'El llibre assignat és:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _llibreAssignat?.titol ?? 'Llibre no trobat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Resetear per tornar a la selecció
              setState(() {
                _cancoSeleccionada = null;
                _llibreAssignat = null;
                // Generar nova llista aleatòria per a la següent vegada
                _canconsMostrades = _seleccionarCanconsAleatories(
                  _allCancons,
                  10,
                );
              });
            },
            child: const Text('Tornar a començar'),
          ),
        ],
      ),
    );
  }
}

// FUNCIO HELPER EXTERNA

Llibre _getLlibrePerCanco(Canco canco) {
  // 1. Obtenir tots els llibres disponibles (Usant la variable global de carregaDeDades)
  final List<Llibre> allLlibres = totsElsLlibres;

  // 2. Iterar sobre tots els llibres
  for (final llibre in allLlibres) {
    // 3. Comprovar si la llista de cançons del llibre conté la cançó seleccionada
    // CORRECCIÓ: llibre.playlist és List<String>, per tant busquem 'canco.id'
    if (llibre.playlist.contains(canco.id)) {
      return llibre;
    }
  }

  // 4. Cas de fallback (si la cançó no està associada a cap llibre)
  return Llibre(
    id: "-1",
    titol: 'Llibre no trobat (Sin Match)',
    autor: '-',
    idioma: '-',
    playlist: [],
    stock: 0,
    valoracions: [],
    urlImatge: null,
    tags: [],
  );
}
