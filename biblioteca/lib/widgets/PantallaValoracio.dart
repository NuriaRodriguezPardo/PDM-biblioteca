// [PantallaValoracio.dart]
import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/valoracio.dart';
import '../clases/usuari.dart';

// Dades simulades per utilitzar en Valoracio
final Usuari usuariSimulat = Usuari(id: 6, nom: "Maria F.");
final Llibre llibreSimulat = Llibre(
  id: 0,
  titol: "1984",
  autor: "George Orwell",
  idioma: "Espanyol",
  stock: 5,
  valoracions: [],
);

final List<Valoracio> valoracionsData = [
  Valoracio(
    id: 0,
    puntuacio: 4.5,
    review:
        "Una trama excel·lent amb un ritme trepidant. El desenvolupament dels personatges és molt profund. Lectura totalment recomanada!",
    usuari: usuariSimulat,
  ),
];

class ReviewCard extends StatelessWidget {
  static String route = '/PantallaValoracio';
  final Valoracio review;
  // Hem d'afegir llibre i usuari ja que la classe Valoracio original no els té.
  final Llibre llibre;
  final Usuari usuari;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.llibre,
    required this.usuari,
  }) : super(key: key);

  // Nou mètode privat per generar la llista de widgets d'estrella
  List<Widget> _buildEstrelles(double puntuacio) {
    final fullStars = puntuacio.floor();
    // Corregit: Simplificació de la lògica de mitja estrella.
    final bool hasHalfStar = (puntuacio - fullStars) >= 0.5;
    final emptyStars = 5 - (fullStars + (hasHalfStar ? 1 : 0));

    final stars = <Widget>[];

    // Estrelles completes
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 20));
    }
    // Mitja estrella
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 20));
    }
    // Estrelles buides
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.grey, size: 20));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CORRECCIÓ: Descomentat llibre.titol i llibre.autor
                      Text(
                        llibre.titol,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'Autor: ${llibre.autor}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // visualitzacio de la puntuacio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // crida al nou metode
                    Row(children: _buildEstrelles(review.puntuacio)),
                    Text(
                      review.puntuacio.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.amber.shade400, width: 3),
                ),
              ),
              child: Text(
                '"${review.review}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.black54),
                const SizedBox(width: 5),
                // CORRECCIÓ: Descomentat usuari.nom i usuari.id
                Text(
                  usuari.nom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' (ID: ${usuari.id})',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ValoracionsApp extends StatelessWidget {
  const ValoracionsApp({Key? key}) : super(key: key);

  // Paleta de colors personalitzada
  static const Color primaryCustom = Color(0xFF8F7561); // 8F7561
  static const Color secondaryCustom = Color(0xFF5DA0A7); // 5DA0A7
  static const Color errorCustom = Color(0xFFA25353); // A25353
  static const Color backgroundDark = Color(0xFF47594E); // 47594E

  @override
  Widget build(BuildContext context) {
    // Definició del ColorScheme amb els colors personalitzats
    final ColorScheme customColorScheme = ColorScheme.light(
      primary: primaryCustom, // Color principal (AppBar, títols)
      onPrimary: Colors.white, // Text sobre el color principal
      secondary: secondaryCustom, // Color per Floating Action Buttons
      onSecondary: Colors.white,
      surface: Colors.white, // Color de les Cards
      onSurface: Colors.black87,
      error: errorCustom, // Color d'error
    );

    return MaterialApp(
      title: 'Pantalla de Valoracions',
      theme: ThemeData(
        // aplicacio de la paleta personalitzada
        colorScheme: customColorScheme,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Valoracions del Catàleg'),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: valoracionsData.length,
          itemBuilder: (context, index) {
            final review = valoracionsData[index];
            // CORRECCIÓ: Cal passar un llibre i un usuari a la ReviewCard
            return ReviewCard(
              review: review,
              llibre: llibreSimulat,
              usuari: usuariSimulat,
            );
          },
        ),
      ),
    );
  }
}
