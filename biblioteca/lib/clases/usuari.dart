class Usuari {
  final String id;
  String nom;
  String? fotoUrl;

  List<String> tags;
  List<String> pendents;
  List<String> llegits;
  List<String> reserves;
  List<String> seguidors;
  List<String> amics;

  Usuari({
    required this.id,
    required this.nom,
    this.fotoUrl,
    List<String>? tags,
    List<String>? pendents,
    List<String>? llegits,
    List<String>? reserves,
    List<String>? seguidors,
    List<String>? amics,
  }) : tags = tags ?? [],
       pendents = pendents ?? [],
       llegits = llegits ?? [],
       reserves = reserves ?? [],
       seguidors = seguidors ?? [],
       amics = amics ?? [];

  Usuari.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      nom = json['nom'] ?? 'Usuari Desconegut',
      fotoUrl = json['fotoUrl'],
      tags = List<String>.from(json['tags'] ?? []),
      pendents = List<String>.from(json['pendents'] ?? []),
      llegits = List<String>.from(json['llegits'] ?? []),
      reserves = List<String>.from(json['reserves'] ?? []),
      seguidors = List<String>.from(json['seguidors'] ?? []),
      amics = List<String>.from(json['amics'] ?? []);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'fotoUrl': fotoUrl,
      'tags': tags,
      'pendents': pendents,
      'llegits': llegits,
      'reserves': reserves,
      'seguidors': seguidors,
      'amics': amics,
    };
  }
}
