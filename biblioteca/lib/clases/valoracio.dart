import 'dart:convert';
import 'dart:io';
import 'usuari.dart';
import 'llibre.dart';

class Valoracio {
  final int id;
  final double puntuacio;
  final String review;
  final Usuari usuari; // Nou camp final

  // CORRECCIÓ 1: S'elimina 'const'
  Valoracio({
    required this.id,
    required this.puntuacio,
    required this.review,
    required this.usuari,
  }) : assert(
         puntuacio >= 0.0 && puntuacio <= 5.0,
         'La puntuació ha d\'estar entre 0.0 i 5.0.',
       );

  // CORRECCIÓ 2: S'implementa Valoracio.fromJson utilitzant
  // la llista d'inicialització per a tots els camps final.
  Valoracio.fromJson(Map<String, dynamic> json)
    : id = json["id"] ?? -1,
      puntuacio = json["puntuacio"]?.toDouble() ?? 0.0,
      review = json["review"] ?? '',
      // Deserialització de l'objecte Usuari
      usuari = Usuari.fromJson(json["usuari"] as Map<String, dynamic>? ?? {});

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialització de l'Usuari (Utilitzem toJson() que ja gestiona el cicle a usuari.dart)
      'usuari': usuari.toJson(),
      'puntuacio': puntuacio,
      'review': review,
    };
  }
}
