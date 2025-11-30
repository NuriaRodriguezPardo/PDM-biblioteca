import 'llibre.dart';

class Reserva {
  final int id;
  final Llibre llibre;
  final DateTime dataReserva;
  final DateTime dataVenciment;

  // CORRECCIÓ 1: S'ha d'eliminar 'const' del constructor principal perquè
  // la classe serà construïda amb lògica complexa (DateTime.tryParse, Llibre.fromJson).
  // Ara permet la creació de reserves des de la lògica de dades.
  Reserva({
    required this.id,
    required this.llibre,
    required this.dataReserva,
    required this.dataVenciment,
  });

  // CORRECCIÓ 2: Constructor anomenat per a la deserialització.
  // Utilitzem una llista d'inicialització per assignar els camps `final`.
  Reserva.fromJson(Map<String, dynamic> json)
    // 1. Inicialitzar l'ID
    : id = json['id'] ?? -1,
      // 2. Deserialitzar Llibre (ha de ser un objecte complert o de referència, utilitzem Llibre.fromJson)
      llibre = Llibre.fromJson(json['llibre'] as Map<String, dynamic>? ?? {}),
      // 3. Parsejar dataReserva
      dataReserva =
          DateTime.tryParse(json['data_reserva'] ?? '') ?? DateTime.now(),
      // 4. Parsejar dataVenciment
      dataVenciment =
          DateTime.tryParse(json['data_venciment'] ?? '') ?? DateTime.now();

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialització de Llibre per simplificar la Reserva (referència simple)
      'llibre': {'id': llibre.id, 'titol': llibre.titol},
      'data_reserva': dataReserva.toIso8601String(), // Format ISO per DateTime
      'data_venciment': dataVenciment
          .toIso8601String(), // Format ISO per DateTime
    };
  }
}
