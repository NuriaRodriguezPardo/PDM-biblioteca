import 'dart:convert';
import 'dart:io';
import 'usuari.dart';
import 'llibre.dart';

class Valoracio {
  final int id;
  final double puntuacio;
  final String review;

  const Valoracio({
    required this.id,
    required this.puntuacio,
    required this.review,
  }) : assert(
         puntuacio >= 0.0 && puntuacio <= 5.0,
         'La puntuació ha d\'estar entre 0.0 i 5.0.',
       );

  Valoracio.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      puntuacio = json["puntuacio"]?.toDouble() ?? 0.0,
      review = json["review"];

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialització per Usuari i Llibre
      'puntuacio': puntuacio,
      'review': review,
    };
  }
}
