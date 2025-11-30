import 'llibre.dart';
import 'usuari.dart';
import 'dart:convert';

class LlistaPersonalitzada {
  final int id;
  final String nom;

  // Llistes privades
  List<Llibre> _llibres;
  List<Usuari> _usuaris;

  LlistaPersonalitzada({
    required this.id,
    required this.nom,
    List<Llibre>? llibres,
    List<Usuari>? usuaris,
  }) : _llibres = llibres ?? [],
       _usuaris = usuaris ?? [];

  // Getters
  List<Llibre> get llibres => List.unmodifiable(_llibres);
  List<Usuari> get usuaris => List.unmodifiable(_usuaris);

  int get numLlibres => _llibres.length;

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      // Serialització de Llibre
      'llibres': _llibres.map((l) => l.toJson()).toList(),
      // Serialització d'Usuari
      'usuaris': _usuaris.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
    };
  }
}
