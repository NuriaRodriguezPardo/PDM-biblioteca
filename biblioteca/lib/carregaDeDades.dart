import 'dart:convert';
import 'clases/canço.dart';
import 'clases/valoracio.dart';
import 'clases/llibre.dart';
import 'clases/reserva.dart';
import 'clases/llista_personalitzada.dart';
import 'clases/usuari.dart';

// CONTENIDO COMPLETO DEL JSON DEL CANVAS
const String _BASE_DATA_JSON = '''
{
  "usuaris": [
    {
      "id": 1,
      "nom": "Usuari Principal",
      "tags": ["Fantasia", "Thriller"],
      "pendents": [
        {"id": 3}
      ],
      "llegits": [
        {"id": 0}
      ],
      "reserves": [
        {"id": 100}
      ],
      "seguidors": [
        {"id": 2, "nom": "Maria F."},
        {"id": 3, "nom": "Jordi L."}
      ],
      "amics": [
        {"id": 2, "nom": "Maria F."}
      ]
    },
    {
      "id": 2,
      "nom": "Maria F.",
      "tags": ["Romance", "Clásico"],
      "pendents": [
        {"id": 2}
      ],
      "llegits": [
        {"id": 1}
      ],
      "reserves": [
        {"id": 101}
      ],
      "seguidors": [
        {"id": 1, "nom": "Usuari Principal"}
      ],
      "amics": [
        {"id": 1, "nom": "Usuari Principal"},
        {"id": 4, "nom": "Laura P."}
      ]
    },
    {
      "id": 3,
      "nom": "Jordi L.",
      "tags": ["Ciència-Ficció", "Distopia"],
      "pendents": [],
      "llegits": [
        {"id": 3}
      ],
      "reserves": [],
      "seguidors": [],
      "amics": []
    },
    {
      "id": 4,
      "nom": "Laura P.",
      "tags": ["Misteri", "Història"],
      "pendents": [],
      "llegits": [],
      "reserves": [],
      "seguidors": [
        {"id": 2, "nom": "Maria F."}
      ],
      "amics": [
        {"id": 2, "nom": "Maria F."}
      ]
    },
    {
      "id": 5,
      "nom": "Enric R.",
      "tags": ["Aventura", "Acció"],
      "pendents": [
        {"id": 4}
      ],
      "llegits": [],
      "reserves": [],
      "seguidors": [],
      "amics": []
    }
  ],
  "llibres": [
    {
      "id": 0,
      "titol": "1984",
      "autor": "George Orwell",
      "idioma": "Español",
      "playlist": [
        {"id": 0}
      ],
      "stock": 5,
      "valoracions": [
        {"id": 200, "puntuacio": 4.5, "review": "Una trama excel·lent amb un ritme trepidant.", "usuari": {"id": 2, "nom": "Maria F."}},
        {"id": 201, "puntuacio": 5.0, "review": "El millor llibre sobre distopies. Visió increïble.", "usuari": {"id": 3, "nom": "Jordi L."}}
      ],
      "urlImatge": "https://imagessl4.casadellibro.com/a/l/s5/44/9780141036144.webp",
      "tags": ["Distopia", "Política", "Societat"]
    },
    {
      "id": 1,
      "titol": "El Principito",
      "autor": "Antoine de Saint-Exupéry",
      "idioma": "Francés",
      "playlist": [
        {"id": 3}
      ],
      "stock": 3,
      "valoracions": [
        {"id": 202, "puntuacio": 4.8, "review": "Perfecte per a totes les edats. Un clàssic atemporal.", "usuari": {"id": 1, "nom": "Usuari Principal"}}
      ],
      "urlImatge": "https://m.media-amazon.com/images/I/711MY86KW9L._AC_UF1000,1000_QL80_.jpg",
      "tags": ["Infantil", "Fábula", "Filosofia"]
    },
    {
      "id": 2,
      "titol": "Cien Años de Soledad",
      "autor": "Gabriel García Márquez",
      "idioma": "Español",
      "playlist": [
        {"id": 2}
      ],
      "stock": 2,
      "valoracions": [],
      "urlImatge": null,
      "tags": ["Realismo mágico", "Història", "Drama"]
    },
    {
      "id": 3,
      "titol": "El Codi Da Vinci",
      "autor": "Dan Brown",
      "idioma": "Anglès",
      "playlist": [
        {"id": 4}
      ],
      "stock": 1,
      "valoracions": [
        {"id": 203, "puntuacio": 3.9, "review": "Un thriller ràpid, però la història és qüestionable.", "usuari": {"id": 4, "nom": "Laura P."}}
      ],
      "urlImatge": "https://m.media-amazon.com/images/I/71PR0C4XNjL._AC_UF1000,1000_QL80_.jpg",
      "tags": ["Thriller", "Misteri", "Religió"]
    },
    {
      "id": 4,
      "titol": "Dune",
      "autor": "Frank Herbert",
      "idioma": "Anglès",
      "playlist": [
        {"id": 1}
      ],
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
      "id": 0,
      "minuts": "02:30",
      "lletra": "Les pantalles et miren...",
      "urlImatge": "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg9ySvrB8CnHBBJoA7F45REbfH96dJRTAh-Hp4GFt6kQzEw_7AV3t4fWil4dj3fgok8JygeDrt8L031Z9sjDnPEe5WCPnaEGkZf_6iWMge5vd-pNAu6UVNWx9LSdV_tdI-72dwdZKtFtkGk/s1600/caratula-cd-gh16-640x491.jpg",
      "tags": ["Distopia", "Vigilància", "Tensió"]
    },
    {
      "titol": "Polvo y Arena",
      "autor": "The K.",
      "id": 1,
      "minuts": "04:10",
      "lletra": "El foc no s'apaga...",
      "urlImatge": null,
      "tags": ["Ciència-Ficció", "Èpica", "Aventura"]
    },
    {
      "titol": "Ritmos Calientes",
      "autor": "Gabo",
      "id": 2,
      "minuts": "03:15",
      "lletra": "Records de Macondo...",
      "urlImatge": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpMa9qxL2q2Yi9i6bBigjEjD-qslR-9cH_9Q&s",
      "tags": ["Realismo mágico", "Història", "Drama"]
    },
    {
      "titol": "Simple i Bonica",
      "autor": "El Meu Petit",
      "id": 3,
      "minuts": "01:50",
      "lletra": "Quan era petit tot era fàcil...",
      "urlImatge": null,
      "tags": ["Infantil", "Calma", "Fábula"]
    },
    {
      "titol": "Codis i Símbols",
      "autor": "Anon",
      "id": 4,
      "minuts": "03:45",
      "lletra": "Saps el que amagues?...",
      "urlImatge": null,
      "tags": ["Misteri", "Thriller", "Conspiració"]
    }
  ],
  "reserves": [
    {
      "id": 100,
      "llibre": {"id": 1, "titol": "El Principito"},
      "data_reserva": "2024-11-20T10:00:00.000",
      "data_venciment": "2024-12-20T10:00:00.000"
    },
    {
      "id": 101,
      "llibre": {"id": 2, "titol": "Cien Años de Soledad"},
      "data_reserva": "2025-11-01T15:00:00.000",
      "data_venciment": "2025-11-30T15:00:00.000"
    }
  ],
  "llistes_personalitzades": [
    {
      "id": 10,
      "nom": "Lectura Actual",
      "llibres": [
        {"id": 1},
        {"id": 3}
      ],
      "usuaris": [
        {"id": 1, "nom": "Usuari Principal"}
      ]
    },
    {
      "id": 11,
      "nom": "Novel·les Grans",
      "llibres": [
        {"id": 2},
        {"id": 4}
      ],
      "usuaris": [
        {"id": 4, "nom": "Laura P."}
      ]
    }
  ]
}
''';

// FUNCIÓ PRINCIPAL PER CARREGAR EL MAPA DE DADES RAW (PÚBLICA)
Map<String, dynamic> loadAllDataMap() {
  return jsonDecode(_BASE_DATA_JSON) as Map<String, dynamic>;
}

// FUNCIÓ PER OBTENIR TOTS ELS LLIBRES (PÚBLICA)
List<Llibre> getAllLlibres() {
  final Map<String, dynamic> data = loadAllDataMap();
  final List<dynamic> llibresJson = data['llibres'] ?? [];

  return llibresJson.map<Llibre>((e) => Llibre.fromJson(e)).toList();
}

// NOVA FUNCIÓ PER OBTENIR TOTES LES CANÇONS (PÚBLICA)
List<Canco> getAllCancons() {
  final Map<String, dynamic> data = loadAllDataMap();
  final List<dynamic> canconsJson = data['cancons'] ?? [];

  // Utilitza Canco.fromJson per deserialitzar la llista
  return canconsJson.map<Canco>((e) => Canco.fromJson(e)).toList();
}

// Mètode per carregar i resoldre les dades de l'Usuari Principal (ID: 1)
Map<String, dynamic> _loadUserData() {
  // 1. Carreguem el mapa de dades complet
  final Map<String, dynamic> allData = loadAllDataMap();
  // 2. Carreguem TOTS els llibres resolts
  final List<Llibre> allLlibres = getAllLlibres();
  // 3. Carreguem TOTES les reserves resoltes (ja que Reserva.fromJson resol Llibre referenciat)
  final List<Reserva> allReserves =
      (allData['reserves'] as List<dynamic>?)
          ?.map((r) => Reserva.fromJson(r as Map<String, dynamic>))
          .toList() ??
      [];

  // 4. Trobem l'Usuari Principal (ID 1)
  final userJson = (allData['usuaris'] as List<dynamic>?)?.firstWhere(
    (u) => u['id'] == 1,
    orElse: () => null,
  );

  if (userJson == null) {
    return {
      'llibresPendents': [],
      'llibresLlegits': [],
      'reserves': [],
      'llistesPersonalitzades': [],
    };
  }

  // Funció auxiliar per obtenir un Llibre per ID des de la llista completa de llibres
  Llibre? _getLlibreById(int id) {
    try {
      return allLlibres.firstWhere((l) => l.id == id);
    } catch (e) {
      return null; // Llibre no trobat
    }
  }

  // 5. Resoldre llibres pendents i llegits a partir dels IDs de l'usuari (OBTENINT OBJECTE COMPLET)
  final List<Llibre> llibresPendents =
      (userJson['pendents'] as List<dynamic>?)
          ?.map((ref) => _getLlibreById(ref['id']))
          .where((l) => l != null)
          .toList()
          .cast<Llibre>() ??
      [];

  final List<Llibre> llibresLlegits =
      (userJson['llegits'] as List<dynamic>?)
          ?.map((ref) => _getLlibreById(ref['id']))
          .where((l) => l != null)
          .toList()
          .cast<Llibre>() ??
      [];

  // 6. Resoldre reserves (OBTENINT OBJECTE COMPLET DESPRÉS DE SER RESOLT A allReserves)
  final List<Reserva> reservesUsuari = allReserves
      .where(
        (r) => userJson['reserves']?.any((ref) => ref['id'] == r.id) ?? false,
      )
      .toList();

  // 7. Resoldre llistes personalitzades de l'usuari (Necessitem resoldre els llibres interns)
  final List<LlistaPersonalitzada> llistesPersonalitzades =
      (allData['llistes_personalitzades'] as List<dynamic>?)
          ?.where((ll) => ll['usuaris']?.any((u) => u['id'] == 1) ?? false)
          .map((llJson) {
            // Reemplacem les referències d'ID a llibres amb els objectes Llibre complets
            List<Llibre> llibresEnLlista =
                (llJson['llibres'] as List<dynamic>?)
                    ?.map((ref) => _getLlibreById(ref['id']))
                    .where((l) => l != null)
                    .toList()
                    .cast<Llibre>() ??
                [];

            // Creem la LlistaPersonalitzada amb els objectes Llibre complets i Usuaris simples
            return LlistaPersonalitzada(
              id: llJson['id'] ?? -1,
              nom: llJson['nom'] ?? 'Llista Desconeguda',
              llibres: llibresEnLlista,
              usuaris:
                  (llJson['usuaris'] as List<dynamic>?)
                      ?.map(
                        (u) => Usuari(
                          id: u['id'] ?? -1,
                          nom: u['nom'] ?? 'Usuari Llista Desconeguda',
                        ),
                      )
                      .toList() ??
                  [],
            );
          })
          .toList() ??
      [];

  return {
    'llibresPendents': llibresPendents,
    'llibresLlegits': llibresLlegits,
    'reserves': reservesUsuari,
    'llistesPersonalitzades': llistesPersonalitzades,
  };
}

// CARREGANT LES LLISTES FINALS A PARTIR DE LA BBDD SIMULADA (EXECUCIÓ ÚNICA)
final Map<String, dynamic> _data = _loadUserData();

final List<Llibre> llibresPendents = _data['llibresPendents'];
final List<Reserva> reserves = _data['reserves'];
final List<Llibre> llibresLlegits = _data['llibresLlegits'];
final List<LlistaPersonalitzada> llistesPersonalitzades =
    _data['llistesPersonalitzades'];
