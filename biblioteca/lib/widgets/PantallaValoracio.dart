import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/valoracio.dart';
import '../clases/usuari.dart';


final List<Valoracio> valoracionsData = [
  Valoracio(
    id: 0,
    usuari: Usuari(id: 6, nom: "Maria F."),
    llibre: Llibre(id: 0, titol: "1984", autor: "George Orwell", idioma: "Espanyol",
    playlist: null, stock: 5, mitjanaPuntuacio: 4.5,  urlImatge: null, tags: null,),
    puntuacio: 4.5,
    review:
        "Una trama excel·lent amb un ritme trepidant. El desenvolupament dels personatges és molt profund. Lectura totalment recomanada!",
  )
];

class ReviewCard extends StatelessWidget {
   static String route = '/PantallaValoracio';
  final Valoracio review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

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
                      Text(
                        review.llibre.titol,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'per ${review.llibre.autor}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: review.getEstrelles()),
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
            const Divider(height: 25),

  
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.amber.shade400,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                '"${review.review}"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
            
            const SizedBox(height: 15),

      
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.black54),
                const SizedBox(width: 5),
                Text(
                  review.usuari.nom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' (ID: ${review.usuari.id})',
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use Catalonian text for the title
      title: 'Pantalla de Valoracions',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto', // Default font family
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Valoracions del Catàleg'),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: valoracionsData.length,
          itemBuilder: (context, index) {
            final review = valoracionsData[index];
            return ReviewCard(review: review);
          },
        ),
      ),
    );
  }
}
