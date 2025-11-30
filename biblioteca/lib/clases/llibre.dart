import 'dart:convert';
import 'dart:io';
import 'canço.dart';

class Llibre {
  int id;
  String titol;
  String autor;
  String idioma;
  List<String> _tags;
  List<Canco> _playlist;
  int _stock;
  String? urlImatge;
  double? _mitjanaPuntuacio;

  Llibre({
    required this.id,
    required this.titol,
    required this.autor,
    required this.idioma,
    List<String>? tags,
    List<Canco>? playlist,
    required int stock,
    double? mitjanaPuntuacio,
    this.urlImatge,
  }) : _tags = tags ?? [],
       _playlist = playlist ?? [],
       _stock = stock,
       _mitjanaPuntuacio = mitjanaPuntuacio;

  int get stock => _stock;
  List<String> get tags => List.unmodifiable(_tags);
  List<Canco> get playlist => List.unmodifiable(_playlist);
  double? get mitjanaPuntuacio => _mitjanaPuntuacio;

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
}
