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
  List<Valoracio> _valoracions; // No és nullable

  Llibre({
    required this.id,
    required this.titol,
    required this.autor,
    required this.idioma,
    List<String>? tags,
    List<Canco>? playlist,
    required int stock,
    required List<Valoracio>
    valoracions, // S'ha de rebre, no inicialitzar buida.
    this.urlImatge,
  }) : _tags = tags ?? [],
       _playlist = playlist ?? [],
       _stock = stock,
       _valoracions =
           valoracions; // Utilitzem el valor passat o la llista buida si es gestionés d'una altra manera.

  int get stock => _stock;
  List<String> get tags => _tags;
  List<Canco> get playlist => _playlist;
  List<Valoracio> get valoracions =>
      _valoracions; // Getter per a la llista de valoracions

  bool disponible() => _stock > 0;

  Llibre.fromJson(Map<String, dynamic> json)
    : id = json["id"] ?? -1,
      titol = json["titol"] ?? 'Llibre Desconegut',
      autor = json["autor"] ?? 'Autor Desconegut',
      idioma = json["idioma"] ?? 'Catala',
      urlImatge = json["urlImatge"],
      _tags = List<String>.from(json["tags"] ?? []),
      _playlist =
          (json["playlist"] as List<dynamic>?)
              ?.map((item) => Canco.fromJson(item))
              .toList() ??
          [],
      _stock = json["stock"] ?? 0,
      _valoracions =
          (json["valoracions"] as List<dynamic>?)
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

  // Corregit: mitjanaPuntuacio()
  double? mitjanaPuntuacio() {
    if (_valoracions.isEmpty) return null;

    double suma = 0;
    // La comprovació de null a _valoracions ja no cal ja que no és nullable
    for (var v in _valoracions) {
      suma += v.puntuacio;
    }

    return suma / _valoracions.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titol': titol,
      'autor': autor,
      'idioma': idioma,
      'tags': _tags,

      // Serialització de llistes d'objectes complexos
      'playlist': _playlist.map((canco) => canco.toJson()).toList(),

      'stock': _stock,
      'urlImatge': urlImatge,

      // La llista _valoracions no és nullable
      'valoracions': _valoracions
          .map((valoracio) => valoracio.toJson())
          .toList(),
    };
  }
}
