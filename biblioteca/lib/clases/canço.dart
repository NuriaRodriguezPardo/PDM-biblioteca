import 'dart:convert';
import 'dart:io';

class Canco {
  String titol;
  String autor;
  int id;
  Duration minuts;
  // cada vegada que volem guardar o llegir els minuts, fem la conversió amb la funció duracio.
  String? lletra;
  // int _likes;
  String? urlImatge;
  DateTime? _escoltada;
  List<String> tags;

  Canco({
    required this.titol,
    required this.autor,
    required this.id,
    required this.minuts,
    required this.lletra,
    this.urlImatge,
    DateTime? escoltada = null,
    required this.tags,
  }) : // _likes = likes,
       _escoltada = escoltada;

  Canco.fromJson(Map<String, dynamic> json)
    : titol = json["titol"],
      autor = json["autor"],
      id = json["id"],
      minuts = duracio(json["minuts"]),
      lletra = json["lletra"],
      // _likes = json["likes"],
      urlImatge = json["urlImatge"],
      _escoltada = json["escoltada"],
      tags = json["tags"] = List<String>.from(json["tags"]);

  Map<String, dynamic> toJson() => {
    "titol": titol,
    "autor": autor,
    "id": id,
    "minuts": duracioToString(minuts),
    "lletra": lletra,
    // "likes": _likes,
    "urlImatge": urlImatge,
    "escoltada": _escoltada,
    "tags": tags,
  };

  DateTime? get escoltada => _escoltada;
  void reproduir() => _escoltada = DateTime.now();

  @override
  String toString() =>
      '''Canco
    titol: $titol,
    autor: $autor,
    id: $id,
    minuts: $minuts,
    lletra: $lletra,
    urlImatge: $urlImatge
    ''';

  // De moment no es fan servir
  /*
  static List<Canco> readCanconsFromJsonFile(String path) {
    File f = File(path);
    String json = f.readAsStringSync();
    List<dynamic> lObjetosDart = jsonDecode(json);
    return lObjetosDart.map<Canco>((e) => Canco.fromJson(e)).toList();
  }

  static void writeCanconsToJsonFile(List<Canco> cancons, String path) {
    File f = File(path);
    String json = jsonEncode(cancons);
    f.writeAsStringSync(json);
  }
  */
}

String jsonCancons = '''
[
    {
        "titol": "Si tu supieras",
        "autor": "F & BB",
        "id": 0,
        "minuts": "02:30",
        "lletra": "M'he estic tornant boig és el que hi ha\\nDiuen que estic perdent el temps, pero ja m'hes igual\\nTengo un porro pa' fumar cuando no llama\\nY arañazos de tus uñas en la almohada\\nLa melancolía de tu puta cara\\nY el disco de Dellafuente que escuchabas\\nY tenía a la chica más guapa 'e toda la ciudad\\nA su la'o los edificios no eran tan altos\\nPero no supero cuando la veo llorar\\nOjalá ninguno te joda tanto\\nSi supiera que cada noche que pasa lloro porque no está\\nSi se viera con los ojos que la veo dejaría de llorar\\nSi supiera que me siento una mierda\\nQue por ser un tonto puedo perderla\\nVolvería a ser todo cómo se merece\\nY si tú me vieras llorar\\nCuando dices que no puedes verme\\nDejarías de preguntar si te voy a querer para siempre\\nY aunque el mundo se pueda romper\\nY aunque nada te pueda prometer\\nLo único que sé, lo único que sé\\nEs que tú no sabes nada\\nTengo tu foto en la cartera junto a la de mamá\\nY un par de vestidos tuyos que quiero quemar\\nUn olor en mi ropa penetrante\\nY bote lleno de desmaquillante\\nDicen de mí to's mis amigos\\nQue si no pienso en tu cadera, no escribo\\nDicen de mí, que estoy jodido\\nY que lo nuestro es amor de vampiro\\nY es que somos lo contrario al puto amor reglamentario\\nPorque somos dos niñatos raros, te pillo un litro en tu aniversario\\nPorque siempre hemos sido el motivo de envidia de to' los niños del barrio\\nNecesito una oportunidad pa' sobrevivir, es necesario\\nY si tú me vieras llorar\\nCuando dices que no puedes verme\\nDejarías de preguntar si te voy a querer para siempre\\nY aunque el mundo se pueda romper\\nY aunque nada te pueda prometer\\nLo único que sé, lo único que sé\\nEs que tú no sabes nada\\nSi supiera que cada noche que pasa lloro porque no está\\nSi se viera con los ojos que la veo dejaría de llorar\\nY no sabe que me siento una mierda\\nQue por ser un tonto puedo perderla\\nQuiero que todo vuelva a ser cómo antes\\nWoh oh oh",
        "urlImatge": "https://cdn-images.dzcdn.net/images/cover/573e6445237d43e173ca0186140e310e/0x1900-000000-80-0-0.jpg"
        "tags:": ["romantica", "trist"]
    },
    {
        "titol": "En la otra vida",
        "autor": "Funzo",
        "id": 1,
        "minuts": "02:45",
        "lletra": "Yo no pedía tanto, un hombro pa' llorar \\nUn sol pa' amanecer y unos brazos para bailar \\nY ahora que te tengo me queda preguntar: \\n¿Pa' qué quiere una diosa bailar con un mortal? Woah \\nSin ti la casa es una fábrica, una selva, una oficina \\nCuando te sientes fea, yo siento que vas divina \\nAlgún favor me debe el destino de la otra vida \\nPara que lo tenga todo sin ganar la lotería, baby \\nNo llores más corazón \\nQue eres más fuerte que yo \\nEs injusto pa'l mundo que tengas complejos \\nTe veo de lejos y sé que algo bueno tengo que haber hecho \\nEn la otra vida \\nPa' que el destino te ponga al la'o mía \\nMe diste vida y ahora moriría por ti \\nMe había vuelto gris, me diste color \\nNo te vayas, del resto me encargo yo \\nPa' encontrarnos otra vez en la otra vida \\nSerá cosa de Dios, del karma o el destino \\nEl vínculo que hay entre nosotros es divino \\nPodría estar mirándote en silencio \\nApreciando y componiendo \\nCanciones que sobrevivan al tiempo (Woah-woah-woah-woah) \\nQuién te enseña a vivir no se muere \\nNacen flores los días que llueve \\nTodo cobra valor si te quieren \\nYo tengo un ángel, que el cielo se entere \\nNo llores más corazón \\nQue eres más fuerte que yo \\nEs injusto pa'l mundo que tengas complejos \\nTe veo de lejos y sé que algo bueno tengo que haber hecho \\nEn la otra vida \\nPa' que el destino te ponga al la'o mía \\nMe diste vida y ahora moriría por ti \\nMe había vuelto gris, me diste color \\nNo te vayas, del resto me encargo yo \\nPa' encontrarnos otra vez en la otra vida",
        "urlImatge": "https://i.scdn.co/image/ab67616d0000b2732b4e9369979022cc974b9753"
        "taggs": ["romantic", "trist"]
    },
    {
        "titol": "Remember",
        "autor": "F & BB",
        "id": 2,
        "minuts": "03:15",
        "lletra": "Ella no puede ser de este planeta \\nEl iPhone me recuerda momentos entre tú y yo (entre tú y yo) \\nMensajes destacados de nuestra conversación \\nTe dejaste en la cama tu tanga marrón \\nTía, ya te había olvidao, pero el cielo se alineó \\nSe alineó, se alineó \\nSe ha puesto de acuerdo todo el universo \\nPa acordarme de tu olor, y como no guardo rencor \\nAunque la caguemo', vamo' a hacer un remember \\nElla no puede ser de este planeta \\nLe da color a toa la discoteca \\nQuiero perrear con su silueta \\nVamo' a hacer un remember, aunque me arrepienta \\nY ella no puede ser de este planeta \\nSe nos queda pequeña la discoteca \\nQuiero perrear con su silueta \\nVamo' hacer un remember, aunque me arrepienta \\nWah-wah-wah-wah \\nY estar fumado de mayo a septiembre en la playa de Benidorm \\nEscuchando trap latino de antes, PXXR GVNG y La Vendicion \\nTete, es que esa piba le mete (¡uh!) \\nYa no será lo de antes, no será lo de 2017 (no) \\nPero lo podemo' intentar \\nYo qué sé, la época de \\"Qué Bonito Fue\\" \\nYa no somos dos jóvenes to locos \\nPero yo creo que puede estar bien, ¡wah! \\nY de lo malo ya ni me acuerdo \\nLo eliminó mi cerebro \\nMe duele, pero me hace feliz \\nPorque ella no puede ser de este planeta \\nLe da color a toa la discoteca \\nQuiero perrear con su silueta \\nVamo' a hacer un remember, aunque me arrepienta \\nY ella no puede ser de este planeta \\nSe nos queda pequeña la discoteca \\nQuiero perrear con su silueta \\nVamo' hacer un remember, aunque me arrepienta \\nFunzo & Baby Loud \\nCon la magia de Tunvao \\nToma bachata pa que la bailes \\nPa que la bailes",
        "urlImatge": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZPwFlGB_gAhctegsVGrA7s0yHEw_A_zRGyQ&s"
        "tags": ["romantic", "feliç"]
    }
]
''';

List<Canco> getCancons() {
  List<dynamic> lObjetosDart = jsonDecode(jsonCancons);
  return lObjetosDart.map<Canco>((e) => Canco.fromJson(e)).toList();
}

/*
List<Canco> classificar(List<Canco> cancons, int? eleccio) {
  /*
  null => totes
  1 => les 5 últimes (recents)
  2 => avui
  3 => mai escoltades
  */
  DateTime ara = DateTime.now();
  List<Canco> filtrades = [];

  if (eleccio == null) {
    // totes
    filtrades = cancons;
  } else if (eleccio == 1) {
    // les 5 últimes
    filtrades.clear();
    List<Canco> escoltades = cancons
        .where((canco) => canco.escoltada != null)
        .toList();
    escoltades.sort((a, b) => b.escoltada!.compareTo(a.escoltada!));
    filtrades.addAll(escoltades.take(5));
  } else if (eleccio == 2) {
    // avui
    filtrades = cancons
        .where(
          (canco) =>
              canco.escoltada != null &&
              canco.escoltada!.day == ara.day &&
              canco.escoltada!.month == ara.month &&
              canco.escoltada!.year == ara.year,
        )
        .toList();
  } else if (eleccio == 3) {
    // mai escoltades
    filtrades = cancons.where((canco) => canco.escoltada == null).toList();
  }

  return filtrades;
}
*/
/// Parsea un string en formato "MM:SS" a un objeto Duration.
///
/// Si el formato no es válido, devuelve Duration.zero.
Duration duracio(String temps) {
  try {
    // 1. Divide el string por los dos puntos
    final parts = temps.split(':');

    // 2. Asegura que tengamos exactamente dos partes (minutos y segundos)
    if (parts.length == 2) {
      // 3. Convierte las partes a enteros
      final minuts = int.tryParse(parts[0]) ?? 0;
      final segons = int.tryParse(parts[1]) ?? 0;

      // 4. Crea y devuelve la Duration
      return Duration(minutes: minuts, seconds: segons);
    }
  } catch (e) {}

  // Si el formato no era "MM:SS"
  return Duration.zero;
}

/// Convierte un Duration a un string "MM:SS".
String duracioToString(Duration duration) {
  // 'remainder(60)' asegura que no ponga "2:120" (180 segundos)
  final minuts = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final segons = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minuts:$segons';
}
