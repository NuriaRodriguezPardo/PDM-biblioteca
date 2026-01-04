class Usuari {
  final String id;
  String nom;
  String? email;
  String? fotoUrl;

  // Todas tus listas originales recuperadas
  List<String> tags; // Se mapea desde 'interessos' en Firestore
  List<String> pendents;
  List<String> llegits;
  List<String> reserves;
  List<String> seguidors;
  List<String> seguint;

  Usuari({
    required this.id,
    required this.nom,
    this.email,
    this.fotoUrl,
    List<String>? tags,
    List<String>? pendents,
    List<String>? llegits,
    List<String>? reserves,
    List<String>? seguidors,
    List<String>? seguint,
  }) : tags = tags ?? [],
       pendents = pendents ?? [],
       llegits = llegits ?? [],
       reserves = reserves ?? [],
       seguidors = seguidors ?? [],
       seguint = seguint ?? [];

  // Constructor JSON robusto: Evita el error de Pigeon forzando el tipo String
  Usuari.fromJson(Map<String, dynamic> json)
    : id = json['uid']?.toString() ?? json['id']?.toString() ?? '',
      nom = json['nom'] ?? 'Usuari Desconegut',
      email = json['email'],
      fotoUrl = json['fotoUrl'],
      // Mapeo seguro de todas las listas
      tags =
          (json['interessos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      pendents =
          (json['pendents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      llegits =
          (json['llegits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reserves =
          (json['reserves'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      seguidors =
          (json['seguidors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      seguint =
          (json['seguint'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'nom': nom,
      'email': email,
      'fotoUrl': fotoUrl,
      'interessos':
          tags, // Mantenemos el nombre de campo 'interessos' para el registro
      'pendents': pendents,
      'llegits': llegits,
      'reserves': reserves,
      'seguidors': seguidors,
      'seguint': seguint,
    };
  }
}
