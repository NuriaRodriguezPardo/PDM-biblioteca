import 'package:cloud_firestore/cloud_firestore.dart';

// El "struct" para la clave compuesta
class ValoracioId {
  final String idUsuari;
  final String idLlibre;

  ValoracioId({required this.idUsuari, required this.idLlibre});

  factory ValoracioId.fromString(String idString) {
    final partes = idString.split('_');
    return ValoracioId(
      idUsuari: partes[0],
      // Si por alguna razón el string no tiene '_', evitamos errores
      idLlibre: partes.length > 1 ? partes[1] : '',
    );
  }

  @override
  String toString() => '${idUsuari}_$idLlibre';

  // Para poder comparar objetos por valor
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValoracioId &&
          idUsuari == other.idUsuari &&
          idLlibre == other.idLlibre;

  @override
  int get hashCode => idUsuari.hashCode ^ idLlibre.hashCode;
}

class Valoracio {
  final double puntuacio;
  final String review;
  final ValoracioId id; // Ahora el ID es el objeto ValoracioId
  final DateTime data;

  Valoracio({
    required this.puntuacio,
    required this.review,
    required String idUsuari,
    required String idLlibre,
  }) : id = ValoracioId(idUsuari: idUsuari, idLlibre: idLlibre),
       data = DateTime.now();

  // Getters para mantener compatibilidad con tu código actual
  String get idUsuari => id.idUsuari;
  String get idLlibre => id.idLlibre;

  Valoracio.fromJson(Map<String, dynamic> json)
    : puntuacio = json["puntuacio"]?.toDouble() ?? 0.0,
      review = json["review"] ?? '',
      id = ValoracioId(
        idUsuari: json["idUsuari"] ?? json["usuari"] ?? '',
        idLlibre: json["idLlibre"] ?? json["llibre"] ?? '',
      ),
      data = (json["data"] is Timestamp)
          ? (json["data"] as Timestamp).toDate()
          : DateTime.tryParse(json["data"] ?? '') ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'usuari': id.idUsuari,
      'llibre': id.idLlibre,
      'puntuacio': puntuacio,
      'review': review,
      'data': data.toIso8601String(),
    };
  }
}
