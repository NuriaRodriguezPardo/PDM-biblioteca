import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para Auth
import 'dart:math';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/carregaDeHistorial.dart';
import '../InternalLists.dart';

class PantallaMatching extends StatefulWidget {
  static String route = '/PantallaMatching';
  // Ya no requerimos el parámetro 'usuari' en el constructor
  const PantallaMatching({super.key});

  @override
  State<PantallaMatching> createState() => _PantallaMatchingState();
}

class _PantallaMatchingState extends State<PantallaMatching> {
  List<Canco> _allCancons = [];
  List<Canco> _canconsMostrades = [];
  Canco? _cancoSeleccionada;
  Llibre? _llibreAssignat;

  // Obtenemos el usuario actual de Firebase
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _allCancons = llistaCanconsGlobal;
    _canconsMostrades = _seleccionarCanconsAleatories(_allCancons, 10);
  }

  List<Canco> _seleccionarCanconsAleatories(
    List<Canco> totesLesCancons,
    int num,
  ) {
    if (totesLesCancons.isEmpty) return [];
    if (totesLesCancons.length <= num) return totesLesCancons;

    final List<Canco> seleccionades = [];
    final Set<String> tagsUsats = {};
    final Random random = Random();

    while (seleccionades.length < num) {
      final int index = random.nextInt(totesLesCancons.length);
      final Canco cancoActual = totesLesCancons[index];

      bool teNouTag = false;
      for (var tag in cancoActual.tags) {
        if (!tagsUsats.contains(tag)) {
          teNouTag = true;
          break;
        }
      }

      if (teNouTag || seleccionades.length < num * 0.5) {
        if (!seleccionades.contains(cancoActual)) {
          seleccionades.add(cancoActual);
          tagsUsats.addAll(cancoActual.tags);
        }
      }
      if (seleccionades.length == totesLesCancons.length) break;
    }

    while (seleccionades.length < num) {
      final int index = random.nextInt(totesLesCancons.length);
      final Canco cancoActual = totesLesCancons[index];
      if (!seleccionades.contains(cancoActual)) {
        seleccionades.add(cancoActual);
      }
    }
    return seleccionades;
  }

  void _seleccionarCanco(Canco canco) {
    setState(() {
      _cancoSeleccionada = canco;
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
    // Usamos el nombre de Firebase o un fallback si no está disponible
    String nomUsuari =
        firebaseUser?.displayName ?? firebaseUser?.email ?? "Usuari";

    return Scaffold(
      appBar: AppBar(title: Text('Matching de llibre per a $nomUsuari')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_cancoSeleccionada == null)
              _buildSeleccioCanco()
            else
              _buildResultatMatching(),
          ],
        ),
      ),
    );
  }

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
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
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
              setState(() {
                _cancoSeleccionada = null;
                _llibreAssignat = null;
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

Llibre _getLlibrePerCanco(Canco canco) {
  final List<Llibre> allLlibres = llistaLlibresGlobal;
  for (final llibre in allLlibres) {
    if (llibre.playlist.contains(canco.id)) {
      return llibre;
    }
  }
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
