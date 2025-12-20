import 'package:cloud_firestore/cloud_firestore.dart';

class Canco {
  final String titol;
  final String autor;
  final String id;
  final Duration minuts;
  final String? lletra;
  final String? urlImatge;
  final List<String> tags;
  final String urlAudio;

  Canco({
    required this.titol,
    required this.autor,
    required this.id,
    required this.minuts,
    this.lletra,
    this.urlImatge,
    required List<String> tags,
    required this.urlAudio,
  }) : this.tags = tags;

  // Obtenim dades des de Firestore
  factory Canco.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Extraemos el string de duración (ej: "03:45")
    String duracioStr = data['minuts'] ?? "00:00";

    Duration duracioParsed;
    try {
      List<String> parts = duracioStr.split(':');
      // Verificamos que tenga al menos minutos y segundos
      if (parts.length >= 2) {
        duracioParsed = Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      } else {
        duracioParsed = Duration.zero;
      }
    } catch (e) {
      duracioParsed =
          Duration.zero; // Si el formato falla, evitamos que la app explote
    }
    return Canco(
      titol: data['titol'] ?? '',
      autor: data['autor'] ?? '',
      id: doc.id,
      minuts: duracioParsed,
      lletra: data['lletra'],
      urlImatge: data['urlImatge'],
      tags: List<String>.from(data['tags'] ?? []),
      urlAudio: data['urlAudio'] ?? '',
    );
  }
}

// Parsea un string en formato "MM:SS" a un objeto Duration.
Duration duracio(String temps) {
  try {
    final parts = temps.split(':');
    if (parts.length == 2) {
      final minuts = int.tryParse(parts[0]) ?? 0;
      final segons = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minuts, seconds: segons);
    }
  } catch (e) {}

  return Duration.zero;
}

/// Convierte un Duration a un string "MM:SS".
String duracioToString(Duration duration) {
  final minuts = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final segons = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minuts:$segons';
}
