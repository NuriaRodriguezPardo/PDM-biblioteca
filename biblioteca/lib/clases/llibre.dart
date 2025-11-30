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
