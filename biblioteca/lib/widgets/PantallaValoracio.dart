import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/llibre.dart';
import '../clases/valoracio.dart';
import '../clases/usuari.dart';

class ReviewCard extends StatelessWidget {
  static String route = '/PantallaValoracio';
  final Valoracio review;
  final Llibre llibre;
  final Usuari usuari;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.llibre,
    required this.usuari,
  }) : super(key: key);

  // Mantenemos tu lógica original de dibujo de estrellas
  List<Widget> _buildEstrelles(double puntuacio) {
    final fullStars = puntuacio.floor();
    final bool hasHalfStar = (puntuacio - fullStars) >= 0.5;
    final emptyStars = 5 - (fullStars + (hasHalfStar ? 1 : 0));

    final stars = <Widget>[];

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 20));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 20));
    }
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                Text(
                  usuari.nom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' (ID: ${usuari.id.substring(0, min(usuari.id.length, 5))})', // Mostramos ID corto si es de Firebase
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valoracions del Catàleg'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuchamos la colección real de Firebase en tiempo real
        stream: FirebaseFirestore.instance
            .collection('valoracions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Encara no hi ha valoracions.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // Mapeo dinámico desde los documentos de Firestore
              final review = Valoracio(
                puntuacio: (data['puntuacio'] ?? 0).toDouble(),
                review: data['review'] ?? '',
                idUsuari: data['idUsuari'] ?? '',
                idLlibre: data['idLlibre'] ?? '',
              );

              // Reconstruimos el objeto Llibre y Usuari con los datos del documento
              // Es recomendable guardar nomUsuari y titolLlibre en la misma colección de valoraciones para no hacer múltiples peticiones
              return ReviewCard(
                review: review,
                llibre: Llibre(
                  id: review.idLlibre,
                  titol: data['titolLlibre'] ?? 'Llibre',
                  autor: data['autorLlibre'] ?? 'Autor',
                  idioma: '-',
                  playlist: [],
                  tags: [],
                  stock: 0,
                  valoracions: [],
                ),
                usuari: Usuari(
                  id: review.idUsuari,
                  nom: data['nomUsuari'] ?? 'Usuari Anònim',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Helper simple para el substring del ID
int min(int a, int b) => a < b ? a : b;
