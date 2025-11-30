import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/llista_personalitzada.dart';
import '../clases/reserva.dart';

// dades simulades
final llibresPendents = [
  Llibre(id: 1, titol: "El Principito", autor: "Antoine de Saint-Exupéry", idioma: "Francés", stock: 3),
  Llibre(id: 2, titol: "Cien Años de Soledad", autor: "Gabriel García Márquez", idioma: "Castellà", stock: 0),
];

final reserves = [
  Reserva(
    id: 10,
    llibre: Llibre(id: 20, titol: "El Nom del Vent", autor: "Patrick Rothfuss", idioma: "Anglès", stock: 1),
    dataReserva: DateTime.now(),
    dataVenciment: DateTime.now().add(const Duration(days: 30)),
  ),
];

final llibresLlegits = [
  Llibre(id: 0, titol: "1984", autor: "George Orwell", idioma: "Castellà", stock: 5),
  Llibre(id: 5, titol: "Mujercitas", autor: "Louisa May Alcott", idioma: "Anglés", stock: 1),
];

final llistesPersonalitzades = [
  LlistaPersonalitzada(id: 20, nom: "Fantasia Èpica", llibres: [llibresPendents[0]]),
  LlistaPersonalitzada(id: 17, nom: "Clàssics Moderns", llibres: [llibresLlegits[1], llibresPendents[1]]),
];

class Biblioteca extends StatelessWidget {
  static String route = '/PantallaBiblioteca';
  final Llibre llibre;
  final String? subtitleExtra;
  final Color? subtitleColor;

  const Biblioteca({
    Key? key,
    required this.llibre,
    this.subtitleExtra,
    this.subtitleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.book_rounded,
          color: Theme.of(context).colorScheme.secondary,
          size: 40,
        ),
        title: Text(
          llibre.titol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Autor: ${llibre.autor}'),
            if (subtitleExtra != null)
              Text(
                subtitleExtra!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: subtitleColor ?? Colors.black87,
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
        onTap: () {
          // Acció al clicar el llibre
          print('Obrir detalls de ${llibre.titol}');
        },
      ),
    );
  }
}

class BookListTab extends StatelessWidget {
  final List<Llibre> llibres;

  const BookListTab({Key? key, required this.llibres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llibres.isEmpty) {
      return const Center(
        child: Text("Encara no tens llibres en aquesta llista!", style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: llibres.length,
      itemBuilder: (context, index) {
        return Biblioteca(llibre: llibres[index]);
      },
    );
  }
}

class Reserves extends StatelessWidget {
  final List<Reserva> reserves;

  const Reserves({Key? key, required this.reserves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reserves.isEmpty) {
      return const Center(
        child: Text("No tens cap préstec o reserva activa.", style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: reserves.length,
      itemBuilder: (context, index) {
        final reserva = reserves[index];
        final bool isVencuda = reserva.dataVenciment.isBefore(DateTime.now());
        final String vencimentText = isVencuda
            ? 'VENCUDA: ${reserva.dataVenciment.day}/${reserva.dataVenciment.month}'
            : 'Venç: ${reserva.dataVenciment.day}/${reserva.dataVenciment.month}/${reserva.dataVenciment.year}';
        
        return Biblioteca(
          llibre: reserva.llibre,
          subtitleExtra: vencimentText,
          subtitleColor: isVencuda ? Colors.red.shade700 : Colors.green.shade700,
        );
      },
    );
  }
}

class CustomLists extends StatelessWidget {
  final List<LlistaPersonalitzada> llistes;

  const CustomLists({Key? key, required this.llistes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llistes.isEmpty) {
      return const Center(
        child: Text(
          "No has creat cap llista personalitzada encara.", 
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey)
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: llistes.length,
      itemBuilder: (context, index) {
        final llista = llistes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              Icons.folder_open,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            title: Text(llista.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${llista.numLlibres} llibres'),
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              print('Obrir llista: ${llista.nom}');
            },
          ),
        );
      },
    );
  }
}

class BibliotecaScreen extends StatelessWidget {
  const BibliotecaScreen({Key? key}) : super(key: key);

  void _crearNovaLlista(BuildContext context) {
    // Implementar la lògica de creació de llista (e.g., obrir un diàleg)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nova llista personalitzada creada!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('La Meva Biblioteca'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pendents', icon: Icon(Icons.bookmark_border)),
              Tab(text: 'Reservats', icon: Icon(Icons.assignment)),
              Tab(text: 'Llegits', icon: Icon(Icons.check_circle_outline)),
              Tab(text: 'Llistes', icon: Icon(Icons.folder_shared_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Pendents
            BookListTab(llibres: llibresPendents),
            
            // 2. Reservats (Préstecs)
            Reserves(reserves: reserves),
            
            // 3. Llegits
            BookListTab(llibres: llibresLlegits),
            
            // 4. Llistes Personalitzades
            CustomLists(llistes: llistesPersonalitzades),
          ],
        ),
        
        // Icona '+' per crear llistes personalitzades
        floatingActionButton: FloatingActionButton(
          onPressed: () => _crearNovaLlista(context),
          tooltip: 'Crear nova llista',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}


class BibliotecaApp extends StatelessWidget {
  const BibliotecaApp({Key? key}) : super(key: key);

  //Paleta de colors personalitzada
  static const Color primaryCustom = Color(0xFF8F7561); // 8F7561
  static const Color secondaryCustom = Color(0xFF5DA0A7); // 5DA0A7
  static const Color errorCustom = Color(0xFFA25353); // A25353
  static const Color backgroundDark = Color(0xFF47594E); // 47594E

  @override
  Widget build(BuildContext context) {
    // Definició del ColorScheme amb els colors personalitzats
    final ColorScheme customColorScheme = ColorScheme.light(
      primary: primaryCustom, 
      onPrimary: Colors.white,
      secondary: secondaryCustom, 
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: errorCustom,
    );

    return MaterialApp(
      title: 'La Meva Biblioteca',
      theme: ThemeData(
        colorScheme: customColorScheme,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const BibliotecaScreen(),
    );
  }
}