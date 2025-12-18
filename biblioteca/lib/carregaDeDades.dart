import 'dart:convert';
import 'clases/canço.dart';
// import 'clases/valoracio.dart';
import 'clases/llibre.dart';
import 'clases/reserva.dart';
import 'clases/llista_personalitzada.dart';

// --- JSON ADAPTAT A LES NOVES CLASES (IDS com Strings i llistes planes) ---
const String _BASE_DATA_JSON = '''
{
  "usuaris": [
    {
      "id": "1",
      "nom": "Usuari Principal",
      "tags": ["Fantasia", "Thriller"],
      "pendents": ["3"],
      "llegits": ["0"],
      "reserves": ["100"],
      "seguidors": ["2", "3"],
      "amics": ["2"]
    },
    {
      "id": "2",
      "nom": "Maria F.",
      "tags": ["Romance", "Clásico"],
      "pendents": ["2"],
      "llegits": ["1"],
      "reserves": ["101"],
      "seguidors": ["1"],
      "amics": ["1", "4"]
    },
    {
      "id": "3",
      "nom": "Jordi L.",
      "tags": ["Ciència-Ficció", "Distopia"],
      "pendents": [],
      "llegits": ["3"],
      "reserves": [],
      "seguidors": [],
      "amics": []
    },
    {
      "id": "4",
      "nom": "Laura P.",
      "tags": ["Misteri", "Història"],
      "pendents": [],
      "llegits": [],
      "reserves": [],
      "seguidors": ["2"],
      "amics": ["2"]
    },
    {
      "id": "5",
      "nom": "Enric R.",
      "tags": ["Aventura", "Acció"],
      "pendents": ["4"],
      "llegits": [],
      "reserves": [],
      "seguidors": [],
      "amics": []
    }
  ],
  "llibres": [
    {
      "id": "0",
      "titol": "1984",
      "autor": "George Orwell",
      "idioma": "Español",
      "playlist": ["0"],
      "stock": 5,
      "valoracions": ["2", "3"], 
      "urlImatge": "https://imagessl4.casadellibro.com/a/l/s5/44/9780141036144.webp",
      "tags": ["Distopia", "Política", "Societat"]
    },
    {
      "id": "1",
      "titol": "El Principito",
      "autor": "Antoine de Saint-Exupéry",
      "idioma": "Francés",
      "playlist": ["3"],
      "stock": 3,
      "valoracions": ["1"],
      "urlImatge": "https://m.media-amazon.com/images/I/711MY86KW9L._AC_UF1000,1000_QL80_.jpg",
      "tags": ["Infantil", "Fábula", "Filosofia"]
    },
    {
      "id": "2",
      "titol": "Cien Años de Soledad",
      "autor": "Gabriel García Márquez",
      "idioma": "Español",
      "playlist": ["2"],
      "stock": 2,
      "valoracions": [],
      "urlImatge": null,
      "tags": ["Realismo mágico", "Història", "Drama"]
    },
    {
      "id": "3",
      "titol": "El Codi Da Vinci",
      "autor": "Dan Brown",
      "idioma": "Anglès",
      "playlist": ["4", "1"],
      "stock": 1,
      "valoracions": ["4"],
      "urlImatge": "https://m.media-amazon.com/images/I/71PR0C4XNjL._AC_UF1000,1000_QL80_.jpg",
      "tags": ["Thriller", "Misteri", "Religió"]
    },
    {
      "id": "4",
      "titol": "Dune",
      "autor": "Frank Herbert",
      "idioma": "Anglès",
      "playlist": ["1"],
      "stock": 6,
      "valoracions": [],
      "urlImatge": "https://m.media-amazon.com/images/I/91iRBWAAG1L._AC_UF1000,1000_QL80_.jpg",
      "tags": ["Ciència-Ficció", "Èpica", "Aventura"]
    }
  ],
  "cancons": [
    {
      "titol": "Gran Hermano",
      "autor": "Vigilant",
      "id": "0",
      "minuts": "02:30",
      "lletra": "Les pantalles et miren...",
      "urlImatge": "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg9ySvrB8CnHBBJoA7F45REbfH96dJRTAh-Hp4GFt6kQzEw_7AV3t4fWil4dj3fgok8JygeDrt8L031Z9sjDnPEe5WCPnaEGkZf_6iWMge5vd-pNAu6UVNWx9LSdV_tdI-72dwdZKtFtkGk/s1600/caratula-cd-gh16-640x491.jpg",
      "tags": ["Distopia", "Vigilància", "Tensió"]
    },
    {
      "titol": "Polvo y Arena",
      "autor": "The K.",
      "id": "1",
      "minuts": "04:10",
      "lletra": "El foc no s'apaga...",
      "urlImatge": null,
      "tags": ["Ciència-Ficció", "Èpica", "Aventura"]
    },
    {
      "titol": "Ritmos Calientes",
      "autor": "Gabo",
      "id": "2",
      "minuts": "03:15",
      "lletra": "Records de Macondo...",
      "urlImatge": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpMa9qxL2q2Yi9i6bBigjEjD-qslR-9cH_9Q&s",
      "tags": ["Realismo mágico", "Història", "Drama"]
    },
    {
      "titol": "Simple i Bonica",
      "autor": "El Meu Petit",
      "id": "3",
      "minuts": "01:50",
      "lletra": "Quan era petit tot era fàcil...",
      "urlImatge": null,
      "tags": ["Infantil", "Calma", "Fábula"]
    },
    {
      "titol": "Codis i Símbols",
      "autor": "Anon",
      "id": "4",
      "minuts": "03:45",
      "lletra": "Saps el que amagues?...",
      "urlImatge": null,
      "tags": ["Misteri", "Thriller", "Conspiració"]
    }
  ],
  "reserves": [
    {
      "id": "100",
      "llibre": "1",
      "data_reserva": "2024-11-20T10:00:00.000",
      "data_venciment": "2024-12-20T10:00:00.000"
    },
    {
      "id": "101",
      "llibre": "2",
      "data_reserva": "2025-11-01T15:00:00.000",
      "data_venciment": "2025-11-30T15:00:00.000"
    }
  ],
  "llistes_personalitzades": [
    {
      "id": "10",
      "nom": "Lectura Actual",
      "llibres": ["1", "3"],
      "usuaris": ["1"]
    },
    {
      "id": "11",
      "nom": "Novel·les Grans",
      "llibres": ["2", "4"],
      "usuaris": ["4"]
    }
  ]
}
''';

// CARREGA RAW
Map<String, dynamic> loadAllDataMap() {
  return jsonDecode(_BASE_DATA_JSON) as Map<String, dynamic>;
}

// OBTENIR TOTS ELS LLIBRES (Variable global per accedir des d'altres arxius)
final List<Llibre> totsElsLlibres = _getAllLlibresInternal();

List<Llibre> _getAllLlibresInternal() {
  final Map<String, dynamic> data = loadAllDataMap();
  final List<dynamic> llibresJson = data['llibres'] ?? [];
  return llibresJson.map<Llibre>((e) => Llibre.fromJson(e)).toList();
}

// OBTENIR TOTES LES CANÇONS
List<Canco> getAllCancons() {
  final Map<String, dynamic> data = loadAllDataMap();
  final List<dynamic> canconsJson = data['cancons'] ?? [];
  return canconsJson.map<Canco>((e) => Canco.fromJson(e)).toList();
}

// Mètode per carregar les dades específiques de l'Usuari Principal (ID: "1")
Map<String, dynamic> _loadUserData() {
  final Map<String, dynamic> allData = loadAllDataMap();

  // 1. Trobem l'Usuari Principal (ID "1")
  final userJson = (allData['usuaris'] as List<dynamic>?)?.firstWhere(
    (u) => u['id'] == "1",
    orElse: () => null,
  );

  if (userJson == null) {
    return {
      'llibresPendents': <Llibre>[],
      'llibresLlegits': <Llibre>[],
      'reserves': <Reserva>[],
      'llistesPersonalitzades': <LlistaPersonalitzada>[],
    };
  }

  // Helper per buscar llibre per ID dins de la llista global ja carregada
  Llibre? getLlibreById(String id) {
    try {
      return totsElsLlibres.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // 2. Resoldre llibres pendents i llegits a objectes Llibre reals (per la UI)
  final List<Llibre> llibresPendents =
      (userJson['pendents'] as List<dynamic>?)
          ?.map((id) => getLlibreById(id.toString()))
          .whereType<Llibre>()
          .toList() ??
      [];

  final List<Llibre> llibresLlegits =
      (userJson['llegits'] as List<dynamic>?)
          ?.map((id) => getLlibreById(id.toString()))
          .whereType<Llibre>()
          .toList() ??
      [];

  // 3. Reserves de l'usuari (Filtrem per ID de reserva a l'usuari)
  // Nota: Ara les reserves tenen "llibre" com a ID (String).
  final List<Reserva> allReservesObjects =
      (allData['reserves'] as List<dynamic>?)
          ?.map((r) => Reserva.fromJson(r))
          .toList() ??
      [];

  final List<String> reservesIdsUsuari = List<String>.from(
    userJson['reserves'] ?? [],
  );

  final List<Reserva> reservesUsuari = allReservesObjects
      .where((r) => reservesIdsUsuari.contains(r.id))
      .toList();

  // 4. Llistes personalitzades (Objectes amb llistes d'IDs)
  final List<LlistaPersonalitzada> allLlistes =
      (allData['llistes_personalitzades'] as List<dynamic>?)
          ?.map((l) => LlistaPersonalitzada.fromJson(l))
          .toList() ??
      [];

  // Filtrem les llistes on l'usuari "1" hi sigui present
  final List<LlistaPersonalitzada> llistesUsuari = allLlistes
      .where((lista) => lista.usuaris.contains("1"))
      .toList();

  return {
    'llibresPendents': llibresPendents,
    'llibresLlegits': llibresLlegits,
    'reserves': reservesUsuari,
    'llistesPersonalitzades': llistesUsuari,
  };
}

// EXPORTACIONS FINALS
final Map<String, dynamic> _data = _loadUserData();

final List<Llibre> llibresPendents = _data['llibresPendents'];
final List<Llibre> llibresLlegits = _data['llibresLlegits'];
final List<Reserva> reserves = _data['reserves'];
final List<LlistaPersonalitzada> llistesPersonalitzades =
    _data['llistesPersonalitzades'];

bool reservarLlibreGlobal(String idLlibre) {
  try {
    // 1. Busquem el llibre "real" dins la llista global 'totsElsLlibres'
    final llibre = totsElsLlibres.firstWhere((l) => l.id == idLlibre);

    // 2. Intentem disminuir l'stock usant el mètode de la classe Llibre
    // (El mètode disminuirStock ja controla si stock > 0)
    bool resultat = llibre.disminuirStock(1);

    return resultat;
  } catch (e) {
    // Si no troba el llibre o passa algo raro
    return false;
  }
}
