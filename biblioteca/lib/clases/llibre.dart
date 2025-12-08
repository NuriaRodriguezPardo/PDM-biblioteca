import 'canço.dart';

class Llibre {
  final String id;
  final String titol;
  final String autor;
  final String idioma;
  final List<String> tags;
  List<String>
  _playlist; // Llista de id de cançons que podrém eliminar o afegir.
  int _stock;
  final String? urlImatge;
  List<String> _valoracions; // Llista de id Usuari
  // bool _reservat;

  Llibre({
    required this.id,
    required this.titol,
    required this.autor,
    required this.idioma,
    required List<String> playlist,
    required this.tags,
    required int stock,
    required List<String> valoracions,

    this.urlImatge,
    reservat = false,
  }) : _playlist = playlist,
       _stock = stock,
       _valoracions = valoracions;
  //_reservat = reservat;

  int get stock => _stock;
  List<String> get playlist => _playlist;
  List<String> get valoracions => _valoracions;
  bool disponible() => _stock > 0;

  Llibre.fromJson(Map<String, dynamic> json)
    : id = json["id"] ?? -1,
      titol = json["titol"] ?? 'Llibre Desconegut',
      autor = json["autor"] ?? 'Autor Desconegut',
      idioma = json["idioma"] ?? 'Idioma Desconegut',
      urlImatge = json["urlImatge"] ?? null,
      tags = List<String>.from(json["tags"] ?? []),
      _playlist = List<String>.from(json["playlist"] ?? []),
      _stock = json["stock"] ?? 0,
      _valoracions = List<String>.from(json["valoracions"] ?? []);

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

  void agregarCanco(Canco canco) {
    if (!_playlist.contains(canco.id)) _playlist.add(canco.id);
  }

  void eliminarCanco(Canco canco) {
    _playlist.remove(canco.id);
  }

  /*
FER EN UN ALTRE LLOC 
--------------------
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
*/
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titol': titol,
      'autor': autor,
      'idioma': idioma,
      'tags': tags,
      'playlist': _playlist,
      'stock': _stock,
      'urlImatge': urlImatge,
      'valoracions': _valoracions,
    };
  }
}
