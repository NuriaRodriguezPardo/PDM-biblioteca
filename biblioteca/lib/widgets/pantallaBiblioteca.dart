import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../clases/llista_personalitzada.dart';
import 'PantallaLlibre.dart';
import '../InternalLists.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({Key? key}) : super(key: key);

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  final String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  // --- LÓGICA DE SINCRONIZACIÓN CON FIREBASE ---

  // Elimina libros de las listas automáticas del usuario (Llegits/Pendents)
  void _eliminarDeLlistaUsuari(String llistaTipus, String idLlibre) async {
    final usuari = getUsuariById(currentUser ?? "");
    if (usuari == null) return;

    setState(() {
      if (llistaTipus == 'llegits') usuari.llegits.remove(idLlibre);
      if (llistaTipus == 'pendents') usuari.pendents.remove(idLlibre);
    });

    await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(currentUser)
        .update({'llegits': usuari.llegits, 'pendents': usuari.pendents});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Llibre eliminat de $llistaTipus')));
  }

  // Cancela una reserva, borra el documento y devuelve el stock
  void _cancelarReserva(String idReserva) async {
    final reserva = llistaReservesGlobal.firstWhere((r) => r.id == idReserva);
    final llibre = getLlibreById(reserva.llibre);
    final usuari = getUsuariById(currentUser ?? "");

    setState(() {
      llistaReservesGlobal.removeWhere((r) => r.id == idReserva);
      usuari?.reserves.remove(idReserva);
      llibre?.augmentarStock(1); // Devolvemos el libro al inventario
    });

    // Operaciones en Firebase
    await FirebaseFirestore.instance
        .collection('reserves')
        .doc(idReserva)
        .delete();
    await FirebaseFirestore.instance
        .collection('usuaris')
        .doc(currentUser)
        .update({'reserves': usuari?.reserves});

    if (llibre != null) {
      await FirebaseFirestore.instance
          .collection('libros')
          .doc(llibre.id)
          .update({'stock': llibre.stock});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva cancel·lada i stock actualitzat')),
    );
  }

  // Elimina un libro de una lista creada por el usuario
  void _eliminarDeLlistaPersonalitzada(
    LlistaPersonalitzada llista,
    String idLlibre,
  ) async {
    setState(() {
      llista.llibres.remove(idLlibre);
    });

    await FirebaseFirestore.instance
        .collection('llistes_personalitzades')
        .doc(llista.id)
        .update({'llibres': llista.llibres});
  }

  @override
  Widget build(BuildContext context) {
    final usuariActual = getUsuariById(currentUser ?? "");
    final reservesUsuari = llistaReservesGlobal
        .where((r) => usuariActual?.reserves.contains(r.id) ?? false)
        .toList();
    final llistesUsuari = llistesPersonalitzadesGlobals
        .where((l) => l.usuaris.contains(currentUser))
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('La meva Biblioteca'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true, // Permite que se muevan si hay muchos
            tabs: [
              Tab(icon: Icon(Icons.bookmark), text: 'Reserves'),
              Tab(icon: Icon(Icons.check_circle), text: 'Llegits'),
              Tab(icon: Icon(Icons.watch_later), text: 'Pendents'),
              Tab(icon: Icon(Icons.list_alt), text: 'Llistes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Vista 1: Reserves
            _buildLlistaSimple(
              ids: reservesUsuari.map((r) => r.llibre).toList(),
              esReserva: true,
              reservesIds: reservesUsuari.map((r) => r.id).toList(),
            ),
            // Vista 2: Llegits
            _buildLlistaSimple(
              ids: usuariActual?.llegits ?? [],
              onDelete: (id) => _eliminarDeLlistaUsuari('llegits', id),
            ),
            // Vista 3: Pendents
            _buildLlistaSimple(
              ids: usuariActual?.pendents ?? [],
              onDelete: (id) => _eliminarDeLlistaUsuari('pendents', id),
            ),
            // Vista 4: Llistes Personalitzades
            _buildVistaLlistes(llistesUsuari),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarOpcionsAfegir(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLlistaSimple({
    required List<String> ids,
    Function(String)? onDelete,
    bool esReserva = false,
    List<String>? reservesIds,
  }) {
    if (ids.isEmpty)
      return const Center(child: Text('No hi ha llibres en aquesta secció'));

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: ids.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final llibre = getLlibreById(ids[index]);
        return ListTile(
          leading: llibre!.urlImatge != null
              ? Image.network(llibre.urlImatge!, width: 40, fit: BoxFit.cover)
              : const Icon(Icons.book),
          title: Text(llibre.titol),
          subtitle: Text(llibre.autor),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => esReserva
                ? _cancelarReserva(reservesIds![index])
                : onDelete!(ids[index]),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PantallaLlibre(llibre: llibre)),
          ),
        );
      },
    );
  }

  Widget _buildVistaLlistes(List<LlistaPersonalitzada> llistes) {
    if (llistes.isEmpty)
      return const Center(child: Text('No has creat cap llista'));

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: llistes.length,
      itemBuilder: (context, index) {
        final llista = llistes[index];
        return Card(
          child: ExpansionTile(
            title: Text(llista.nom),
            subtitle: Text('${llista.llibres.length} llibres'),
            children: llista.llibres.map((id) {
              final llibre = getLlibreById(id);
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child:
                      llibre?.urlImatge != null && llibre!.urlImatge!.isNotEmpty
                      ? Image.network(
                          llibre.urlImatge!,
                          width: 30,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 30,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, size: 20),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, size: 20),
                        ),
                ),
                title: Text(llibre!.titol),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _eliminarDeLlistaPersonalitzada(llista, id),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaLlibre(llibre: llibre),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Modal para crear una nueva lista en Firebase
  void _mostrarOpcionsAfegir(BuildContext context) {
    final TextEditingController _nomController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nova Llista Personalitzada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom de la llista',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nomController.text.isEmpty || currentUser == null)
                    return;
                  final docRef = FirebaseFirestore.instance
                      .collection('llistes_personalitzades')
                      .doc();
                  final nova = LlistaPersonalitzada(
                    id: docRef.id,
                    nom: _nomController.text,
                    llibres: [],
                    usuaris: [currentUser!],
                  );
                  await docRef.set(nova.toJson());
                  setState(() => llistesPersonalitzadesGlobals.add(nova));
                  Navigator.pop(context);
                },
                child: const Text('Crear Llista'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
