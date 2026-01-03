import 'package:biblioteca/widgets/PantallaLogin.dart';
import 'package:flutter/material.dart';

class AppBiblio extends StatelessWidget {
  const AppBiblio({super.key});

  // --- TUS COLORES ORIGINALES (INTACTOS) ---
  static const Color primaryCustom = Color(0xFF8F7561); // Marró Suau
  static const Color secondaryCustom = Color(0xFF5DA0A7); // Blau-verd
  static const Color errorCustom = Color(0xFFA25353); // Vermell Fosc
  static const Color backgroundCustom = Color(0xFFEDE7DC); // Fons clar original
  static const Color accentCustom = Color(0xFFD7676D); // Accent / Text destacat
  static const Color darkTextCustom = Color(0xFF47594E); // Text Fosc/Botons

  @override
  Widget build(BuildContext context) {
    // Definició del ColorScheme amb els teus colors
    final ColorScheme customColorScheme = ColorScheme.light(
      primary: primaryCustom,
      onPrimary: Colors.white,
      secondary: secondaryCustom,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: darkTextCustom,
      error: errorCustom,
    );

    return MaterialApp(
      title: 'App Llibres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: customColorScheme,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondaryCustom,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundCustom, // Tu fondo original
        useMaterial3: false,
      ),
      // LÓGICA DE AUTO-LOGIN MANTENIENDO EL DISEÑO
      // En tu archivo AppBiblio o main.dart
      home: PantallaLogin(),
    );
  }
}
