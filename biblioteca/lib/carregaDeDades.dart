import 'dart:convert';
import 'clases/llibre.dart';
import 'clases/reserva.dart';
import 'clases/llista_personalitzada.dart';
import 'InternalLists.dart';

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
/*
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
*/

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
  /*
  Llibre? getLlibreById(String id) {
    try {
      return totsElsLlibres.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
  */
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
    final llibre = llistaLlibresGlobal.firstWhere((l) => l.id == idLlibre);

    // 2. Intentem disminuir l'stock usant el mètode de la classe Llibre
    // (El mètode disminuirStock ja controla si stock > 0)
    bool resultat = llibre.disminuirStock(1);

    return resultat;
  } catch (e) {
    // Si no troba el llibre o passa algo raro
    return false;
  }
}
