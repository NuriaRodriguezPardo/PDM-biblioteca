class Canco {
  final String titol;
  final String autor;
  final String id;
  final Duration minuts;
  final String? lletra;
  final String? urlImatge;
  DateTime? _escoltada;
  final List<String> tags;
  final String urlAudio;

  Canco({
    required this.titol,
    required this.autor,
    required this.id,
    required this.minuts,
    this.lletra,
    this.urlImatge,
    DateTime? escoltada,
    required List<String> tags,
    required this.urlAudio,
  }) : _escoltada = escoltada,
       this.tags = tags;

  Canco.fromJson(Map<String, dynamic> json)
    : titol = json["titol"] ?? "",
      autor = json["autor"] ?? "",
      id = json["id"] ?? -1,
      minuts = duracio(json["minuts"] ?? "00:00"),
      lletra = json["lletra"],
      urlImatge = json["urlImatge"],
      _escoltada = json["escoltada"] != null
          ? DateTime.tryParse(json["escoltada"])
          : null,
      tags = List<String>.from(json["tags"] ?? []),
      urlAudio = json["urlAudio"] ?? "";

  Map<String, dynamic> toJson() => {
    "titol": titol,
    "autor": autor,
    "id": id,
    "minuts": duracioToString(minuts),
    "lletra": lletra,
    "urlImatge": urlImatge,
    "escoltada": _escoltada?.toIso8601String(),
    "tags": tags,
    "urlAudio": urlAudio,
  };

  DateTime? get escoltada => _escoltada;
  void reproduir() => _escoltada = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Canco && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      '''Canco
    titol: $titol,
    autor: $autor,
    id: $id,
    minuts: ${duracioToString(minuts)},
    lletra: $lletra,
    urlImatge: $urlImatge
    urlAudio: $urlAudio
    ''';
}

/// Parsea un string en formato "MM:SS" a un objeto Duration.
///
/// Si el formato no es válido, devuelve Duration.zero.
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
/* DURATION DEL FIREBASE 
// Ejemplo para Flutter:
List<String> partes = cancion.minuts.split(':');
Duration duracion = Duration(
  minutes: int.parse(partes[0]), 
  seconds: int.parse(partes[1])
);
*/