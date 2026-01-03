import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/appBiblio.dart';
import 'InternalLists.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    // Intenta cargar los datos pero pon un tiempo límite o maneja el error
    await inicialitzarDadesGlobals();
  } catch (e) {
    print("Error cargando datos: $e");
  }
  await inicialitzarDadesGlobals();
  runApp(AppBiblio());
}
