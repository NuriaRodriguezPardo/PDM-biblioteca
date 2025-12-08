class Reserva {
  final String id;
  final String llibre;
  final DateTime dataReserva;
  final DateTime dataVenciment;

  Reserva({
    required this.id,
    required this.llibre,
    required this.dataReserva,
    required this.dataVenciment,
  });

  Reserva.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? -1,
      llibre = json['llibre'] ?? "Llibre Desconegut",
      dataReserva =
          DateTime.tryParse(json['data_reserva'] ?? '') ?? DateTime.now(),
      dataVenciment =
          DateTime.tryParse(json['data_venciment'] ?? '') ?? DateTime.now();

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'llibre': llibre,
      'data_reserva': dataReserva.toIso8601String(), // Format ISO per DateTime
      'data_venciment': dataVenciment
          .toIso8601String(), // Format ISO per DateTime
    };
  }
}
