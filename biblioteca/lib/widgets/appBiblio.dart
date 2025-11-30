import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/PantallaLlibre.dart';
import 'package:biblioteca/models/llibre.dart';

class AppBiblio extends StatelessWidget {
  const AppBiblio({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ Creamos un libro por defecto para mostrar en la app
    final Llibre libroInicial = Llibre(
      id: 1,
      titol: 'L\'ombra del vent',
      autor: 'Carlos Ruiz Zafón',
      idioma: 'Català',
      stock: 5,
      mitjanaPuntuacio: 4.5,
      urlImatge: 'https://m.media-amazon.com/images/I/91r1eQ4JwpL.jpg',
      tags: ['misteri', 'novel·la', 'clàssic']

    );

    return MaterialApp(
      title: 'App Llibres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color.fromARGB(255, 221, 212, 199),
      ),

      // 👉 Iniciamos directamente PantallaLlibre con un libro concreto
      home: PantallaLlibre(llibre: libroInicial),
    );
  }
}
