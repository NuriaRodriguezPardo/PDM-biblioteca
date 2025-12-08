class Usuari {
  final String id;
  final String nom;

  // Llistes privades
  List<String> _tags; // Afegit final
  List<String> _pendents; // Afegit final
  List<String> _llegits; // Afegit final
  List<String> _reserves; // Afegit final
  List<String> _seguidors; // Afegit final
  List<String> _amics; // Afegit final

  // Constructor principal
  Usuari({
    // Afegit const
    required this.id,
    required this.nom,
    List<String>? tags,
    List<String>? pendents,
    List<String>? llegits,
    List<String>? reserves,
    List<String>? seguidors,
    List<String>? amics,
  }) : _tags = tags ?? [],
       _pendents = pendents ?? [],
       _llegits = llegits ?? [],
       _reserves = reserves ?? [],
       _seguidors = seguidors ?? [],
       _amics = amics ?? [];

  // Getters
  List<String> get tags => _tags;
  List<String> get pendents => _pendents;
  List<String> get llegits => _llegits;
  List<String> get reserves => _reserves;
  List<String> get seguidors => _seguidors;
  List<String> get amics => _amics;

  Usuari.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? -1,
      nom = json['nom'] ?? 'Usuari Desconegut',
      _tags = List<String>.from(json['tags'] ?? []),
      _pendents = List<String>.from(json['pendents'] ?? []),
      _llegits = List<String>.from(json['llegits'] ?? []),
      _reserves = List<String>.from(json['reserves'] ?? []),
      _seguidors = List<String>.from(json['seguidors'] ?? []),
      _amics = List<String>.from(json['amics'] ?? []);

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'tags': _tags,
      'pendents': _pendents,
      'llegits': _llegits,
      'reserves': _reserves,
      'seguidors': _seguidors,
      'amics': _amics,
    };
  }
}
