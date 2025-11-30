// [llista_personalitzada.dart]
import 'llibre.dart';
import 'usuari.dart';
import 'dart:convert';

class LlistaPersonalitzada {
  final int id;
  final String nom;

  // Llistes privades
  final List<Llibre> _llibres; // Afegit final
  final List<Usuari> _usuaris; // Afegit final

  const LlistaPersonalitzada({
    // Afegit const
    required this.id,
    required this.nom,
    List<Llibre>? llibres,
    List<Usuari>? usuaris,
  }) : _llibres = llibres ?? const [],
       _usuaris = usuaris ?? const [];

  // Getters
  List<Llibre> get llibres => List.unmodifiable(_llibres);
  List<Usuari> get usuaris => List.unmodifiable(_usuaris);

  int get numLlibres => _llibres.length;

  // CORRECCIÓ: Constructor fromJson implementat
  LlistaPersonalitzada.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? -1,
      nom = json['nom'] ?? 'Llista Desconeguda',
      _llibres =
          (json['llibres'] as List<dynamic>?)
              ?.map((l) => Llibre.fromJson(l as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      // Deserialització d'Usuari simple (ID/Nom)
      _usuaris =
          (json['usuaris'] as List<dynamic>?)
              ?.map(
                (u) => Usuari(
                  id: u['id'] ?? -1,
                  nom: u['nom'] ?? 'Usuari Llista Desconeguda',
                ),
              )
              .toList() ??
          [];

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      // Serialització de Llibre
      'llibres': _llibres.map((l) => l.toJson()).toList(),
      // Serialització d'Usuari (simple)
      'usuaris': _usuaris.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
    };
  }
}
