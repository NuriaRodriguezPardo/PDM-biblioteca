import 'package:flutter/material.dart';
import 'PantallaPrincipal.dart';

class AppBiblio extends StatelessWidget {
  const AppBiblio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Llibres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFEDE7DC),
      ),
      home: const PantallaPrincipal(),
    );
  }
}
