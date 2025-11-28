import 'package:flutter/material.dart';
// importar pantalles

class Biblioteca extends StatelessWidget {
  const Biblioteca({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: false),
      initialRoute: // Pantalla inicial '/',
      routes: {
        // Pantalles
      },
    );
  }
}
