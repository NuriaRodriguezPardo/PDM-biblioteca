import 'package:biblioteca/clases/can%C3%A7o.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import '../clases/canço.dart';

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
      _llibreAssignat = _getLlibre(_cancoSeleccionada!);
    });
  }
}
