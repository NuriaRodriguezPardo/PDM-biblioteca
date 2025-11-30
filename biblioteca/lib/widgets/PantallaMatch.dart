// [PantallaMatch.dart]
import 'package:biblioteca/clases/can%C3%A7o.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import '../clases/canço.dart'; // Importació duplicada (la primera ja existeix)

class PantallaMatching extends StatefulWidget {
  static String route = '/PantallaMatching';
  final Usuari usuari;
  const PantallaMatching({super.key, required this.usuari});

  @override
  State<PantallaMatching> createState() => _PantallaMatchingState();
}

class _PantallaMatchingState extends State<PantallaMatching> {
  // Lista de todas las canciones disponibles (inicializada en initState)
  List<Canco> _allCancons = [];

  // La lista de 10 canciones aleatorias para mostrar al usuario
  List<Canco> _canconsMostrades = [];

  // La canción que el usuario ha seleccionado
  Canco? _cancoSeleccionada;

  // El libro asignado (resultado del matching)
  Llibre? _llibreAssignat;

  @override
  void initState() {
    super.initState();
    // 1. Obtener todas las canciones (simulación de carga de datos)
    _allCancons = getCancons();
    // 2. Seleccionar las 10 canciones aleatorias y con tags variados
    _canconsMostrades = _seleccionarCanconsAleatories(_allCancons, 10);
  }

  // Lógica para seleccionar 10 canciones aleatorias y variadas
  List<Canco> _seleccionarCanconsAleatories(
    List<Canco> totesLesCancons,
    int num,
  ) {
    if (totesLesCancons.isEmpty) return [];
    if (totesLesCancons.length <= num) return totesLesCancons;

    // Usaremos un set para controlar la variedad de tags
    final List<Canco> seleccionades = [];
    final Set<String> tagsUsats = {};
    final Random random = Random();

    // Intentamos seleccionar canciones que aporten nuevos tags
    while (seleccionades.length < num) {
      // Elegimos un índice aleatorio
      final int index = random.nextInt(totesLesCancons.length);
      final Canco cancoActual = totesLesCancons[index];

      bool teNouTag = false;
      for (var tag in cancoActual.tags) {
        if (!tagsUsats.contains(tag)) {
          teNouTag = true;
          break;
        }
      }

      // Si la canción aporta un tag nuevo O si ya hemos intentado mucho y necesitamos rellenar
      if (teNouTag || seleccionades.length < num * 0.5) {
        if (!seleccionades.contains(cancoActual)) {
          seleccionades.add(cancoActual);
          // Añadimos sus tags al set de control
          tagsUsats.addAll(cancoActual.tags);
        }
      }

      // Medida de seguridad para evitar bucles infinitos en colecciones pequeñas
      if (seleccionades.length == totesLesCancons.length) break;
    }

    // Si aún nos faltan, las rellenamos con las que queden aleatoriamente
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
  // ACCIONES DEL USUARIO
  // ------------------

  void _seleccionarCanco(Canco canco) {
    setState(() {
      _cancoSeleccionada = canco;
      // Una vez seleccionada la canción, buscamos el libro asociado
      _llibreAssignat = _getLlibrePerCanco(canco);
    });
  } // Corregido: La definició del métode _seleccionarCanco tanca correctament aquí

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
              _buildSeleccioCanco() // Mostramos la selección de canciones
            else
              _buildResultatMatching(), // Mostramos el resultado del matching
          ],
        ),
      ),
    );
  }

  // Widget para la selección de canciones
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
          physics:
              const NeverScrollableScrollPhysics(), // Deshabilita el scroll del Grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5, // Hace las tarjetas más horizontales
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

  // Widget para mostrar el resultado
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
              // Resetear para volver a la selección
              setState(() {
                _cancoSeleccionada = null;
                _llibreAssignat = null;
                // Generar nueva lista aleatoria para la siguiente vez
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
  // 1. Obtener todos los libros disponibles (o el set de datos que uses)
  // Nota: _getAllLlibres es una funció privada del fitxer llibre.dart,
  // però ja ha estat exposada en el scope global en el teu projecte.
  final List<Llibre> allLlibres = getAllLlibres();

  // 2. Iterar sobre todos los libros
  for (final llibre in allLlibres) {
    // 3. Comprobar si la lista de canciones del libro contiene la canción seleccionada
    // CORRECCIÓ: Utilitzem el getter públic 'playlist' en comptes del camp privat '_playlist'
    if (llibre.playlist.contains(canco)) {
      // 4. ¡Coincidencia encontrada! Devolver el libro inmediatamente
      return llibre;
    }
  }

  // 5. Caso de fallback (si la canción no está asociada a ningún libro)
  // Aquí puedes devolver un libro por defecto, o lanzar una excepción.
  // Por simplicidad, devolveremos un libro de 'no encontrado'.
  return Llibre(
    id: -1,
    titol: 'Llibre no trobat',
    autor: 'Desconegut',
    idioma: 'Desconegut',
    playlist: [],
    stock: 0,
    valoracions: [],
    urlImatge: null,
    tags: [],
  );
}
