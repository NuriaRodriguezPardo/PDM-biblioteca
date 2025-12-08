class LlistaPersonalitzada {
  final String id;
  String nom;

  // Llistes privades
  List<String> _llibres;
  List<String> _usuaris;

  LlistaPersonalitzada({
    required this.id,
    required this.nom,
    List<String>? llibres,
    List<String>? usuaris,
  }) : _llibres = llibres ?? [],
       _usuaris = usuaris ?? [];

  // Getters
  List<String> get llibres => _llibres;
  List<String> get usuaris => _usuaris;

  int get numLlibres => _llibres.length;

  LlistaPersonalitzada.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? "-1",
      nom = json['nom'] ?? "Llista Desconeguda",
      _llibres = List<String>.from(json['llibres'] ?? []),
      _usuaris = List<String>.from(json['usuaris'] ?? []);

  // Mètode toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      // Serialització de Llibre
      'llibres': _llibres,
      'usuaris': _usuaris,
    };
  }
}
