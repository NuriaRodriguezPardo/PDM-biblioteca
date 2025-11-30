import 'dart:convert';
import 'dart:io';
import 'usuari.dart';
import 'llibre.dart';

class Valoracio {
  final int id;
  final Usuari usuari;
  final Llibre llibre;
  final double puntuacio;
  final String review;

  const Valoracio({
    required this.id,
    required this.usuari,
    required this.llibre,
    required this.puntuacio,
    required this.review,
  }) : assert(
         puntuacio >= 0.0 && puntuacio <= 5.0,
         'La puntuació ha d\'estar entre 0.0 i 5.0.',
       );

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialització per Usuari i Llibre
      'usuari': {'id': usuari.id, 'nom': usuari.nom},
      'llibre': {'id': llibre.id, 'titol': llibre.titol},
      'puntuacio': puntuacio,
      'review': review,
    };
  }
}
