import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/PantallaLlibre.dart';
import 'package:biblioteca/clases/llibre.dart';

class AppBiblio extends StatelessWidget {
  const AppBiblio({super.key});

  @override
  Widget build(BuildContext context) {
    // Creamos un libro por defecto para mostrar en la app

    final Llibre libroInicial = Llibre(
      id: 1,
      titol: 'L\'ombra del vent',
      autor: 'Carlos Ruiz Zafón',
      idioma: 'Català',
      stock: 5,
      valoracions: null,
      urlImatge: 'https://m.media-amazon.com/images/I/91r1eQ4JwpL.jpg',
      tags: ['misteri', 'novel·la', 'clàssic'],
    );
    return MaterialApp(
      title: 'App Llibres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color.fromARGB(255, 221, 212, 199),
      ),

      // Iniciamos directamente PantallaLlibre con un libro concreto de la lista de PantallaLlibre
      home: PantallaLlibre(llibre: libroInicial),
    );
  }
}
