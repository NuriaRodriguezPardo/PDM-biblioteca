class Valoracio {
  final double puntuacio;
  final String review;
  final String idUsuari;
  final String idLlibre;
  final DateTime data;

  Valoracio({
    required this.puntuacio,
    required this.review,
    required this.idUsuari,
    required this.idLlibre,
  }) : assert(
         puntuacio >= 0.0 && puntuacio <= 5.0,
         'La puntuació ha d\'estar entre 0.0 i 5.0.',
       ),
       data =
           DateTime.now(); // Inicialitzem data amb la data actual per defecte

  Valoracio.fromJson(Map<String, dynamic> json)
    : puntuacio = json["puntuacio"]?.toDouble() ?? 0.0,
      review = json["review"] ?? '',
      idUsuari = json["idUsuari"] ?? -1,
      idLlibre = json["idLlibre"] ?? -1,
      data = DateTime.tryParse(json["data"]) ?? DateTime.now();

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      // Serialització de l'Usuari (Utilitzem toJson() que ja gestiona el cicle a usuari.dart)
      'usuari': idUsuari,
      'llibre': idLlibre,
      'puntuacio': puntuacio,
      'review': review,
      'data': data.toIso8601String(),
    };
  }
}
