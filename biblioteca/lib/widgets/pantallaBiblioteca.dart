import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/llista_personalitzada.dart';
import '../clases/reserva.dart';
import 'PantallaLlibre.dart';
import '../carregaDeDades.dart';

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
            // Assumim que 'llibresPendents' a carregaDeDades ja és una List<Llibre>.
            // Si fos List<String>, caldria fer la conversió com a les llistes de sota.
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

// --- WIDGETS AUXILIARS ---

// Widget per mostrar llistes de Llibres (Pendents i Llegits)
class BookListTab extends StatelessWidget {
  final List<Llibre> llibres;
  const BookListTab({Key? key, required this.llibres}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llibres.isEmpty) {
      return const Center(child: Text('No hi ha llibres en aquesta llista.'));
    }
    return ListView.builder(
      itemCount: llibres.length,
      itemBuilder: (context, index) {
        final llibre = llibres[index];
        return ListTile(
          leading: llibre.urlImatge != null
              ? Image.network(llibre.urlImatge!, width: 50, fit: BoxFit.cover)
              : const Icon(Icons.book, size: 40),
          title: Text(llibre.titol),
          subtitle: Text(llibre.autor),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PantallaLlibre(llibre: llibre)),
            );
          },
        );
      },
    );
  }
}

// Widget per mostrar la llista de Reserves
class Reserves extends StatelessWidget {
  final List<Reserva> reserves;
  const Reserves({Key? key, required this.reserves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reserves.isEmpty) {
      return const Center(child: Text('No tens cap préstec o reserva activa.'));
    }
    return ListView.builder(
      itemCount: reserves.length,
      itemBuilder: (context, index) {
        final reserva = reserves[index];

        // CORRECCIÓ: 'reserva.llibre' ara és un String (ID).
        // Necessitem trobar l'objecte Llibre real per mostrar títol i passar-lo a la pantalla següent.
        final Llibre llibreObjecte = _obtenirLlibrePerId(reserva.llibre);

        final bool isVencuda = reserva.dataVenciment.isBefore(DateTime.now());
        final String vencimentText = isVencuda
            ? 'VENCUDA: ${reserva.dataVenciment.day}/${reserva.dataVenciment.month}/${reserva.dataVenciment.year}'
            : 'Venç: ${reserva.dataVenciment.day}/${reserva.dataVenciment.month}/${reserva.dataVenciment.year}';

        return ListTile(
          leading: Icon(
            Icons.assignment,
            color: isVencuda ? Colors.red : Colors.green,
          ),
          // Ara usem llibreObjecte per obtenir el títol
          title: Text(llibreObjecte.titol),
          subtitle: Text(vencimentText),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Passem l'objecte Llibre recuperat
                builder: (_) => PantallaLlibre(llibre: llibreObjecte),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget per mostrar la llista de Llistes Personalitzades
class CustomLists extends StatelessWidget {
  final List<LlistaPersonalitzada> llistes;
  const CustomLists({Key? key, required this.llistes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llistes.isEmpty) {
      return const Center(child: Text('Encara no has creat cap llista.'));
    }
    return ListView.builder(
      itemCount: llistes.length,
      itemBuilder: (context, index) {
        final llista = llistes[index];
        return ExpansionTile(
          leading: const Icon(Icons.folder_shared_outlined),
          title: Text(llista.nom),
          // 'numLlibres' funciona bé perquè és un getter sobre la longitud de la llista d'IDs
          subtitle: Text('${llista.numLlibres} llibres'),
          children: llista.llibres.map((idLlibre) {
            // CORRECCIÓ: 'llista.llibres' és una List<String>.
            // El 'map' ens dona un 'idLlibre' (String), hem de buscar l'objecte.
            final Llibre llibreObjecte = _obtenirLlibrePerId(idLlibre);

            return ListTile(
              contentPadding: const EdgeInsets.only(left: 30, right: 16),
              leading: const Icon(Icons.book_outlined, size: 20),
              title: Text(llibreObjecte.titol),
              subtitle: Text(llibreObjecte.autor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaLlibre(llibre: llibreObjecte),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// --- FUNCIONS HELPERS ---

Llibre _obtenirLlibrePerId(String id) {
  try {
    // Usem la llista global 'totsElsLlibres' exportada des de carregaDeDades.dart
    return totsElsLlibres.firstWhere(
      (l) => l.id == id,
      orElse: () => Llibre(
        id: '-1',
        titol: 'Llibre no trobat ($id)',
        autor: '-',
        idioma: '-',
        playlist: [],
        tags: [],
        stock: 0,
        valoracions: [],
      ),
    );
  } catch (e) {
    return Llibre(
      id: '-1',
      titol: 'Error',
      autor: '-',
      idioma: '-',
      playlist: [],
      tags: [],
      stock: 0,
      valoracions: [],
    );
  }
}
