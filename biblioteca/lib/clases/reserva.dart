import 'llibre.dart';

class Reserva {
  final int id;
  final Llibre llibre;
  final DateTime dataReserva;
  final DateTime dataVenciment;

  const Reserva({
    required this.id,
    required this.llibre,
    required this.dataReserva,
    required this.dataVenciment,
  });

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Serialització d'Usuari i Llibre per simplificar la Reserva
      'llibre': {'id': llibre.id, 'nom': llibre.titol},
      'data_reserva': dataReserva.toIso8601String(), // Format ISO per DateTime
      'data_venciment': dataVenciment
          .toIso8601String(), // Format ISO per DateTime
    };
  }
}
