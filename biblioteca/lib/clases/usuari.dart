import 'dart:convert';
import 'dart:io';
import 'llibre.dart';
import 'reserva.dart';

class Usuari {
  final int id;
  final String nom;

  // Llistes privades
  final List<String> _tags; // Afegit final
  final List<Llibre> _pendents; // Afegit final
  final List<Llibre> _llegits; // Afegit final
  final List<Reserva> _reserves; // Afegit final
  final List<Usuari> _seguidors; // Afegit final
  final List<Usuari> _amics; // Afegit final

  // Constructor principal
  const Usuari({
    // Afegit const
    required this.id,
    required this.nom,
    List<String>? tags,
    List<Llibre>? pendents,
    List<Llibre>? llegits,
    List<Reserva>? reserves,
    List<Usuari>? seguidors,
    List<Usuari>? amics,
  }) : _tags = tags ?? const [], // const []
       _pendents = pendents ?? const [], // const []
       _llegits = llegits ?? const [], // const []
       _reserves = reserves ?? const [], // const []
       _seguidors = seguidors ?? const [], // const []
       _amics = amics ?? const []; // const []

  // Getters
  List<String> get tags => _tags;
  List<Llibre> get pendents => _pendents;
  List<Llibre> get llegits => _llegits;
  List<Reserva> get reserves => _reserves;
  List<Usuari> get seguidors => _seguidors;
  List<Usuari> get amics => _amics;

  Usuari.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? -1,
      nom = json['nom'] ?? 'Usuari Desconegut',
      _tags = List<String>.from(json['tags'] ?? []),
      // Deserialització d'objectes Llibre (haurien de ser objectes complets, no només referències)
      // Nota: Si el JSON només té ID, es resoldran com a Llibre.fromJson amb dades buides,
      // la càrrega de dades es corregeix a carregaDeDades.dart per resoldre l'objecte complet.
      _pendents =
          (json['pendents'] as List<dynamic>?)
              ?.map((l) => Llibre.fromJson(l as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      _llegits =
          (json['llegits'] as List<dynamic>?)
              ?.map((l) => Llibre.fromJson(l as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      // Deserialització d'objectes Reserva
      _reserves =
          (json['reserves'] as List<dynamic>?)
              ?.map((r) => Reserva.fromJson(r as Map<String, dynamic>? ?? {}))
              .toList() ??
          [],
      // Les dades de seguidors/amics es guarden com a Map<String, dynamic> (simples, per evitar cicles)
      _seguidors =
          (json['seguidors'] as List<dynamic>?)
              ?.map(
                (u) => Usuari(
                  id: u['id'] ?? -1,
                  nom: u['nom'] ?? 'Seguidor Desconegut',
                ),
              )
              .toList() ??
          [],
      _amics =
          (json['amics'] as List<dynamic>?)
              ?.map(
                (u) => Usuari(
                  id: u['id'] ?? -1,
                  nom: u['nom'] ?? 'Amic Desconegut',
                ),
              )
              .toList() ??
          [];

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'tags': _tags,
      // Serialització de Llibre/Reserva, utilitzant els getters
      'pendents': _pendents.map((l) => l.toJson()).toList(),
      'llegits': _llegits.map((l) => l.toJson()).toList(),
      'reserves': _reserves.map((r) => r.toJson()).toList(),

      // Serialització per evitar cicles
      'seguidors': _seguidors.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
      'amics': _amics.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
    };
  }
}
