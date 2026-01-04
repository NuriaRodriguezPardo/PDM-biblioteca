import 'package:cloud_firestore/cloud_firestore.dart';
import 'valoracio.dart';

class Llibre {
  final String id;
  final String titol;
  final String autor;
  final String idioma;
  final List<String> tags;
  List<String> _playlist;
  int _stock;
  final String? urlImatge;
  List<ValoracioId> _valoracions;

  Llibre({
    required this.id,
    required this.titol,
    required this.autor,
    required this.idioma,
    required List<String> playlist,
    required this.tags,
    required int stock,
    required List<ValoracioId> valoracions,
    this.urlImatge,
  }) : _playlist = playlist,
       _stock = stock,
       _valoracions = valoracions;

  factory Llibre.fromFirestore(DocumentSnapshot doc) {
    // Extraemos el mapa de datos del documento
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<ValoracioId> llegirValoracions(dynamic camp) {
      if (camp is List) {
        return camp
            .map((vString) => ValoracioId.fromString(vString.toString()))
            .toList();
      }
      return [];
    }

    return Llibre(
      id: doc.id,
      titol: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      idioma: data['idioma'] ?? '',
      playlist: (data['playlist'] as List?)?.cast<String>() ?? [],
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
      stock: data['stock'] ?? 0,
      valoracions: llegirValoracions(
        data['valoraciones'],
      ), // Ahora crea objetos ValoracioId
      urlImatge: data['url'],
    );
  }

  int get stock => _stock;
  List<String> get playlist => _playlist;
  List<ValoracioId> get valoracions => _valoracions;
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
}
