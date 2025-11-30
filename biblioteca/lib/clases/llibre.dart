// [llibre.dart]
import 'dart:convert';
import 'dart:io';
import 'canço.dart';
import 'valoracio.dart';

class Llibre {
  int id;
  String titol;
  String autor;
  String idioma;
  List<String> _tags;
  List<Canco> _playlist;
  int _stock;
  String? urlImatge;
  List<Valoracio>? _valoracions;

  Llibre({
    required this.id,
    required this.titol,
    required this.autor,
    required this.idioma,
    List<String>? tags,
    List<Canco>? playlist,
    required int stock,
    List<Valoracio>? valoracions,
    this.urlImatge,
  }) : _tags = tags ?? [],
       _playlist = playlist ?? [],
       _stock = stock,
       _valoracions = valoracions ?? [];

  int get stock => _stock;
  List<String> get tags => _tags;
  List<Canco> get playlist => _playlist;
  List<Valoracio>? get valoracions => _valoracions;

  bool disponible() => _stock > 0;

  Llibre.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      titol = json["titol"],
      autor = json["autor"],
      idioma = json["idioma"],
      urlImatge = json["urlImatge"],
      _tags = List<String>.from(
        json["tags"] ?? [],
      ), // Modificat: utilitzar 'tags' en comptes de '_tags'
      _playlist =
          (json["playlist"]
                  as List<
                    dynamic
                  >?) // Modificat: utilitzar 'playlist' en comptes de '_playlist'
              ?.map((item) => Canco.fromJson(item))
              .toList() ??
          [],
      _stock =
          json["stock"], // Modificat: utilitzar 'stock' en comptes de '_stock'
      _valoracions =
          (json["valoracions"]
                  as List<
                    dynamic
                  >?) // Modificat: utilitzar 'valoracions' en comptes de '_valoracions'
              ?.map((item) => Valoracio.fromJson(item))
              .toList() ??
          [];

  void augmentarStock(int num) {
    _stock += num;
  }

  bool disminuirStock(int num) {
    if (num <= _stock) {
      _stock -= num;
      return true;
    }
    return false;
  }

  void agregarTag(String tag) {
    if (!_tags.contains(tag)) _tags.add(tag);
  }

  bool tieneTag(String tag) => _tags.contains(tag);

  void agregarCanco(Canco canco) {
    if (!_playlist.contains(canco)) _playlist.add(canco);
  }

  void eliminarCanco(Canco canco) {
    _playlist.remove(canco);
  }

  double? mitjanaPuntuacio() {
    if (_valoracions == null || _valoracions!.isEmpty) return null;

    double suma = 0;
    for (var v in _valoracions!) {
      suma += v.puntuacio;
    }

    return suma / _valoracions!.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titol': titol,
      'autor': autor,
      'idioma': idioma,
      // Los campos privados se mapean usando sus getters o el nombre directo si no hay getter.
      'tags': _tags,

      // Para serializar listas de objetos complejos (Canco y Valoracio),
      // debemos llamar al .toJson() de CADA objeto dentro de la lista.
      'playlist': _playlist.map((canco) => canco.toJson()).toList(),

      'stock': _stock,
      'urlImatge': urlImatge,

      'valoracions': _valoracions != null
          ? _valoracions!.map((valoracio) => valoracio.toJson()).toList()
          : null,
    };
  }
}

const jsonLlibres = '''
[
  {
    "id": 0,
    "titol": "1984",
    "autor": "George Orwell",
    "idioma": "Español",
    "playlist": [
      {
        "titol": "Si tu supieras",
        "autor": "F & BB",
        "id": 0,
        "minuts": "02:30",
        "lletra": "...",
        "tags": ["romantica", "trist"]
      },
      {
        "titol": "En la otra vida",
        "autor": "Funzo",
        "id": 1,
        "minuts": "02:45",
        "lletra": "...",
        "tags": ["romantic", "trist"]
      }
    ],
    "stock": 5,
    "valoracions": [],
    "urlImatge": "https://upload.wikimedia.org/wikipedia/en/c/c3/1984first.jpg",
    "tags": [
      "Distopia",
      "Clásico"
    ]
  },
  {
    "id": 1,
    "titol": "El Principito",
    "autor": "Antoine de Saint-Exupéry",
    "idioma": "Francés",
    "playlist": [],
    "stock": 3,
    "valoracions": [],
    "urlImatge": "https://upload.wikimedia.org/wikipedia/en/4/4f/Le_Petit_Prince_(1943).jpg",
    "tags": [
      "Infantil",
      "Fábula"
    ]
  },
  {
    "id": 2,
    "titol": "Cien Años de Soledad",
    "autor": "Gabriel García Márquez",
    "idioma": "Español",
    "playlist": [
      {
        "titol": "Remember",
        "autor": "F & BB",
        "id": 2,
        "minuts": "03:15",
        "lletra": "...",
        "tags": ["romantic", "feliç"]
      }
    ],
    "stock": 2,
    "valoracions": [],
    "urlImatge": null,
    "tags": [
      "Realismo mágico",
      "Clásico"
    ]
  }
]
''';

List<Llibre> getAllLlibres() {
  // 1. Decodificar la cadena JSON a una List<dynamic> de objetos Dart (Map<String, dynamic>)
  List<dynamic> lObjetosDart = jsonDecode(jsonLlibres);

  // 2. Usar .map para iterar sobre la lista dinámica y convertir cada elemento
  // Map<String, dynamic> a un objeto Llibre usando el factory constructor Llibre.fromJson().
  return lObjetosDart.map<Llibre>((e) => Llibre.fromJson(e)).toList();
}
