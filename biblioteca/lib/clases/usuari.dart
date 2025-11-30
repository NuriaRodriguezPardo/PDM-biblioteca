class Usuari {
  final int id;
  final String nom;
  
  // Llistes privades
  List<String> _tags;
  List<Llibre> _pendents;
  List<Llibre> _llegits;
  List<Reserva> _reserves;
  List<Usuari> _seguidors;
  List<Usuari> _amics;

  Usuari({
    required this.id,
    required this.nom,
    List<String>? tags,
    List<Llibre>? pendents,
    List<Llibre>? llegits,
    List<Reserva>? reserves,
    List<Usuari>? seguidors,
    List<Usuari>? amics,
  })  : _tags = tags ?? [],
        _pendents = pendents ?? [],
        _llegits = llegits ?? [],
        _reserves = reserves ?? [],
        _seguidors = seguidors ?? [],
        _amics = amics ?? [];

  // Getters
  List<String> get tags => List.unmodifiable(_tags);
  List<Llibre> get pendents => List.unmodifiable(_pendents);
  List<Llibre> get llegits => List.unmodifiable(_llegits);
  List<Reserva> get reserves => List.unmodifiable(_reserves);
  List<Usuari> get seguidors => List.unmodifiable(_seguidors);
  List<Usuari> get amics => List.unmodifiable(_amics);

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'tags': _tags,
      // Serialització de Llibre/Reserva
      'pendents': _pendents.map((l) => l.toJson()).toList(),
      'llegits': _llegits.map((l) => l.toJson()).toList(),
      'reserves': _reserves.map((r) => r.toJson()).toList(),
      
      // Serialització per evitar cicles
      'seguidors': _seguidors.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
      'amics': _amics.map((u) => {'id': u.id, 'nom': u.nom}).toList(),
    };
  }
}