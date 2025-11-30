import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/canço.dart';

class PantallaLlibre extends StatefulWidget {
  final Llibre llibre;

  const PantallaLlibre({super.key, required this.llibre});

  @override
  State<PantallaLlibre> createState() => _PantallaLlibreState();
}

class _PantallaLlibreState extends State<PantallaLlibre> {
  bool jaReservat = false; // Controla si el usuario ya reservó este libro

  @override
  Widget build(BuildContext context) {
    final llibre = widget.llibre;

    return Scaffold(
      appBar: AppBar(title: Text(llibre.titol)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del libro
            Center(
              child: llibre.urlImatge != null
                  ? Image.network(llibre.urlImatge!, height: 200)
                  : const Icon(Icons.book, size: 150),
            ),
            const SizedBox(height: 16),

            // Título y autor
            Text(
              llibre.titol,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'de ${llibre.autor}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),

            // Idioma y stock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Idioma: ${llibre.idioma}'),
                Text('Stock: ${llibre.stock}'),
              ],
            ),
            const SizedBox(height: 8),

            // Puntuación media
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  llibre.mitjanaPuntuacio() != null
                      ? llibre.mitjanaPuntuacio()!.toStringAsFixed(1)
                      : "Sin puntuación",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            if (llibre.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: llibre.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Botón reservar
            ElevatedButton(
              onPressed: (llibre.disponible() && !jaReservat)
                  ? () {
                      setState(() {
                        llibre.disminuirStock(1);
                        jaReservat = true;
                      });
                    }
                  : null,
              child: Text(jaReservat ? 'Ya reservado' : 'Reservar'),
            ),
            const SizedBox(height: 30),

            // Playlist asociada
            if (llibre.playlist.isNotEmpty) ...[
              Text(
                'Playlist asociada al libro:',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: llibre.playlist.map((canco) {
                  return ListTile(
                    leading: canco.urlImatge != null
                        ? Image.network(canco.urlImatge!, width: 50, fit: BoxFit.cover)
                        : const Icon(Icons.music_note),
                    title: Text(canco.titol),
                    subtitle: Text(canco.autor),
                    trailing: Text('${canco.minuts.inMinutes}:${(canco.minuts.inSeconds % 60).toString().padLeft(2, '0')}'),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
