import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_core/firebase_options.dart';
import 'widgets/appBiblio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(AppBiblio());
}
