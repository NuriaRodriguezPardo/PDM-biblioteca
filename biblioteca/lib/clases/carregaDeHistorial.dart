import 'package:flutter/material.dart';

class ActivitatItem {
  final String titol;
  final String subtitol;
  final DateTime data;
  final IconData icona;

  ActivitatItem({
    required this.titol,
    required this.subtitol,
    required this.icona,
  }) : data = DateTime.now();
}

// Lista global que guardará el historial
List<ActivitatItem> historialActivitat = [];

// Función para añadir actividad desde cualquier pantalla
void registrarActivitat(String titol, String subtitol, IconData icona) {
  // Insertamos al principio (índice 0) para que salga lo más nuevo arriba
  historialActivitat.insert(
    0,
    ActivitatItem(titol: titol, subtitol: subtitol, icona: icona),
  );
}
