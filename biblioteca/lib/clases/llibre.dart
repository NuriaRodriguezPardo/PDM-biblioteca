import 'package:cloud_firestore/cloud_firestore.dart';

class Llibre {
  final String id;
  final String titol;
  final String autor;
  final String idioma;
  final List<String> tags;
  List<String> _playlist;
  int _stock;
  final String? urlImatge;
  List<String> _valoracions;

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
  }) : _playlist = playlist,
       _stock = stock,
       _valoracions = valoracions;

  factory Llibre.fromFirestore(DocumentSnapshot doc) {
    // Extraemos el mapa de datos del documento
    final data = doc.data() as Map<String, dynamic>? ?? {};

    List<String> segura(dynamic camp) {
      if (camp is List) return List<String>.from(camp);
      if (camp is String && camp.isNotEmpty) return [camp];
      return [];
    }

    return Llibre(
      // Usamos doc.id para asegurar que el ID sea el nombre del documento en Firebase
      id: doc.id,
      titol: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      idioma: data['idioma'] ?? '',
      playlist: segura(data['playlist']),
      tags: segura(data['tags'] ?? []),
      stock: data['stock'] ?? 0,
      valoracions: segura(data['valoraciones'] ?? []),
      urlImatge: data['url'] ?? null,
    );
  }

  int get stock => _stock;
  List<String> get playlist => _playlist;
  List<String> get valoracions => _valoracions;
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
