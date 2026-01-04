import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';
import '../clases/carregaDeHistorial.dart';
import '../InternalLists.dart';

class PantallaMatching extends StatefulWidget {
  static String route = '/PantallaMatching';
  const PantallaMatching({super.key});

  @override
  State<PantallaMatching> createState() => _PantallaMatchingState();
}

class _PantallaMatchingState extends State<PantallaMatching> {
  List<Canco> _allCancons = [];
  List<Canco> _canconsMostrades = [];
  Canco? _cancoSeleccionada;
  Llibre? _llibreAssignat;
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _allCancons = llistaCanconsGlobal;
    _canconsMostrades = _seleccionarCanconsAleatories(_allCancons, 10);
  }

  // Lógica de selección aleatoria (se mantiene igual)
  List<Canco> _seleccionarCanconsAleatories(
    List<Canco> totesLesCancons,
    int num,
  ) {
    if (totesLesCancons.isEmpty) return [];
    final List<Canco> seleccionades = List.from(totesLesCancons);
    seleccionades.shuffle();
    return seleccionades.take(num).toList();
  }

  void _seleccionarCanco(Canco canco) {
    setState(() {
      _cancoSeleccionada = canco;
      _llibreAssignat = _getLlibrePerCanco(canco);

      if (_llibreAssignat != null && _llibreAssignat!.id != "-1") {
        registrarActivitat(
          "Match Musical",
          "Match: '${canco.titol}' -> '${_llibreAssignat!.titol}'.",
          Icons.auto_awesome,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con degradado sutil
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F7561), Color(0xFFEDE7DC)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Match per a ${firebaseUser?.displayName ?? 'Tu'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _cancoSeleccionada == null
                    ? _buildSeleccioCancoVisual()
                    : _buildResultatMatchingVisual(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccioCancoVisual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Com et sents avui?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
        const Text(
          'Tria una cançó i trobarem la teva lectura ideal',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 25),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: _canconsMostrades.length,
          itemBuilder: (context, index) {
            final canco = _canconsMostrades[index];
            return GestureDetector(
              onTap: () => _seleccionarCanco(canco),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Imagen de fondo (Carátula)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            canco.urlImatge ??
                                'https://via.placeholder.com/150',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Degradado sobre la imagen para legibilidad
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    // Texto
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            canco.titol,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            canco.tags.take(2).join(' • '),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResultatMatchingVisual() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Efecto de brillo/aura detrás del libro
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD7676D).withValues(alpha: 0.5),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            // Portada del Libro
            Hero(
              tag: _llibreAssignat!.id,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    _llibreAssignat?.urlImatge ??
                        'https://via.placeholder.com/300x450',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "EL TEU MATCH PERFECTE:",
          style: TextStyle(
            color: Color(0xFFEDE7DC),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _llibreAssignat?.titol ?? 'Llibre no trobat',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          "per ${_llibreAssignat?.autor}",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 40),
        // Botón con estilo neón
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
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
          child: const Text(
            'TORNAR A PROVAR',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 50),
      ],
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
    titol: 'Cap match avui',
    autor: 'Explora més cançons',
    idioma: '-',
    playlist: [],
    stock: 0,
    valoracions: [],
    urlImatge: "https://via.placeholder.com/300x450",
    tags: [],
  );
}
