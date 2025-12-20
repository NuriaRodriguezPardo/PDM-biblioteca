import 'package:biblioteca/widgets/PantallaLogin.dart';
import 'package:biblioteca/widgets/PantallaPrincipal.dart';
import 'package:flutter/material.dart';

class AppBiblio extends StatelessWidget {
  const AppBiblio({super.key});

  // Definició de la paleta de colors
  static const Color primaryCustom = Color(0xFF8F7561); // Marró Suau
  static const Color secondaryCustom = Color(0xFF5DA0A7); // Blau-verd
  static const Color errorCustom = Color(0xFFA25353); // Vermell Fosc
  static const Color backgroundCustom = Color(0xFFEDE7DC); // Fons clar original
  static const Color accentCustom = Color(0xFFD7676D); // Accent / Text destacat
  static const Color darkTextCustom = Color(0xFF47594E); // Text Fosc/Botons

  @override
  Widget build(BuildContext context) {
    // Definició del ColorScheme amb els colors personalitzats
    final ColorScheme customColorScheme = ColorScheme.light(
      primary: primaryCustom, // Color principal (AppBar, títols)
      onPrimary: Colors.white,
      secondary: secondaryCustom, // Color per Floating Action Buttons
      onSecondary: Colors.white,
      surface: Colors.white, // Color de les Cards
      onSurface: darkTextCustom, // Text sobre la superfície
      error: errorCustom, // Color d'error
      //background: backgroundCustom, // Fons general
    );

    return MaterialApp(
      title: 'App Llibres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Utilitzem el ColorScheme personalitzat
        colorScheme: customColorScheme,
        // Apliquem colors a elements clau per a consistència
        appBarTheme: const AppBarTheme(
          //color: primaryCustom,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryCustom,
          foregroundColor: Colors.white,
        ),
        // Color del fons (si es vol canviar del scaffoldBackgroundColor)
        scaffoldBackgroundColor: backgroundCustom,
        useMaterial3: false,
      ),
      home: const PantallaPrincipal(),
    );
  }
}
