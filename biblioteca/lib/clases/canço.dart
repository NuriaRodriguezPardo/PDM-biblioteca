import 'dart:convert';
import 'dart:io';

class Canco {
  String titol;
  String autor;
  int id;
  Duration minuts;
  // cada vegada que volem guardar o llegir els minuts, fem la conversió amb la funció duracio.
  String? lletra;
  // int _likes;
  String? urlImatge;
  DateTime? _escoltada;
  List<String> tags;

  Canco({
    required this.titol,
    required this.autor,
    required this.id,
    required this.minuts,
    required this.lletra,
    this.urlImatge,
    DateTime? escoltada = null,
    required this.tags,
  }) : // _likes = likes,
       _escoltada = escoltada;

  Canco.fromJson(Map<String, dynamic> json)
    : titol = json["titol"] ?? "",
      autor = json["autor"] ?? "",
      id = json["id"] ?? -1,
      minuts = duracio(json["minuts"] ?? "00:00"),
      lletra = json["lletra"],
      // _likes = json["likes"],
      urlImatge = json["urlImatge"],
      _escoltada = json["escoltada"] != null
          ? DateTime.tryParse(json["escoltada"])
          : null,
      tags = List<String>.from(json["tags"] ?? []);

  Map<String, dynamic> toJson() => {
    "titol": titol,
    "autor": autor,
    "id": id,
    "minuts": duracioToString(minuts),
    "lletra": lletra,
    // "likes": _likes,
    "urlImatge": urlImatge,
    "escoltada": _escoltada?.toIso8601String(),
    "tags": tags,
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
    minuts: $minuts,
    lletra: $lletra,
    urlImatge: $urlImatge
    ''';

  // De moment no es fan servir
  /*
  static List<Canco> readCanconsFromJsonFile(String path) {
    File f = File(path);
    String json = f.readAsStringSync();
    List<dynamic> lObjetosDart = jsonDecode(json);
    return lObjetosDart.map<Canco>((e) => Canco.fromJson(e)).toList();
  }

  static void writeCanconsToJsonFile(List<Canco> cancons, String path) {
    File f = File(path);
    String json = jsonEncode(cancons);
    f.writeAsStringSync(json);
  }
  */
}

String jsonCancons = '''
[
    {
        "titol": "Si tu supieras",
        "autor": "F & BB",
        "id": 0,
        "minuts": "02:30",
        "lletra": "M'he estic tornant boig és el que hi ha...",
        "urlImatge": "https://cdn-images.dzcdn.net/images/cover/573e6445237d43e173ca0186140e310e/0x1900-000000-80-0-0.jpg",
        "tags": ["romantica", "trist"]
    },
    {
        "titol": "En la otra vida",
        "autor": "Funzo",
        "id": 1,
        "minuts": "02:45",
        "lletra": "Yo no pedía tanto, un hombro pa' llorar...",
        "urlImatge": "https://i.scdn.co/image/ab67616d0000b2732b4e9369979022cc974b9753",
        "tags": ["romantic", "trist"]
    },
    {
        "titol": "Remember",
        "autor": "F & BB",
        "id": 2,
        "minuts": "03:15",
        "lletra": "Ella no puede ser de este planeta...",
        "urlImatge": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZPwFlGB_gAhctegsVGrA7s0yHEw_A_zRGyQ&s",
        "tags": ["romantic", "feliç"]
    }
]
''';

List<Canco> getCancons() {
  List<dynamic> lObjetosDart = jsonDecode(jsonCancons);
  return lObjetosDart.map<Canco>((e) => Canco.fromJson(e)).toList();
}

/*
List<Canco> classificar(List<Canco> cancons, int? eleccio) {
  /*
  null => totes
  1 => les 5 últimes (recents)
  2 => avui
  3 => mai escoltades
  */
  DateTime ara = DateTime.now();
  List<Canco> filtrades = [];

  if (eleccio == null) {
    // totes
    filtrades = cancons;
  } else if (eleccio == 1) {
    // les 5 últimes
    filtrades.clear();
    List<Canco> escoltades = cancons
        .where((canco) => canco.escoltada != null)
        .toList();
    escoltades.sort((a, b) => b.escoltada!.compareTo(a.escoltada!));
    filtrades.addAll(escoltades.take(5));
  } else if (eleccio == 2) {
    // avui
    filtrades = cancons
        .where(
          (canco) =>
              canco.escoltada != null &&
              canco.escoltada!.day == ara.day &&
              canco.escoltada!.month == ara.month &&
              canco.escoltada!.year == ara.year,
        )
        .toList();
  } else if (eleccio == 3) {
    // mai escoltades
    filtrades = cancons.where((canco) => canco.escoltada == null).toList();
  }

  return filtrades;
}
*/
/// Parsea un string en formato "MM:SS" a un objeto Duration.
///
/// Si el formato no es válido, devuelve Duration.zero.
Duration duracio(String temps) {
  try {
    // 1. Divide el string por los dos puntos
    final parts = temps.split(':');

    // 2. Asegura que tengamos exactamente dos partes (minutos y segundos)
    if (parts.length == 2) {
      // 3. Convierte las partes a enteros
      final minuts = int.tryParse(parts[0]) ?? 0;
      final segons = int.tryParse(parts[1]) ?? 0;

      // 4. Crea y devuelve la Duration
      return Duration(minutes: minuts, seconds: segons);
    }
  } catch (e) {}

  // Si el formato no era "MM:SS"
  return Duration.zero;
}

/// Convierte un Duration a un string "MM:SS".
String duracioToString(Duration duration) {
  // 'remainder(60)' asegura que no ponga "2:120" (180 segundos)
  final minuts = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final segons = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minuts:$segons';
}
