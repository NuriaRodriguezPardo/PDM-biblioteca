import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../clases/llista_personalitzada.dart';
import 'PantallaLlibre.dart';
import '../InternalLists.dart';
import '../clases/usuari.dart';

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
    // Simplemente actualizamos Firebase
    await FirebaseFirestore.instance
        .collection('llistes_personalitzades')
        .doc(llista.id)
        .update({
          'llibres': FieldValue.arrayRemove([
            idLlibre,
          ]), // Forma atómica y segura de borrar
        });
  }

  @override
  Widget build(BuildContext context) {
    final usuariActual = getUsuariById(currentUser ?? "");
    final reservesUsuari = llistaReservesGlobal
        .where((r) => usuariActual?.reserves.contains(r.id) ?? false)
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
            _buildVistaLlistes(),
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

  Widget _buildVistaLlistes() {
    return StreamBuilder<QuerySnapshot>(
      // Escuchamos solo las listas donde el usuario actual es miembro
      stream: FirebaseFirestore.instance
          .collection('llistes_personalitzades')
          .where('usuaris', arrayContains: currentUser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Error al carregar'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('No has creat cap llista'));

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            // Convertimos el documento de Firebase a nuestro objeto de clase
            final llista = LlistaPersonalitzada.fromJson(
              docs[index].data() as Map<String, dynamic>,
            );

            return Card(
              child: ExpansionTile(
                title: Text(llista.nom),
                subtitle: Text('${llista.llibres.length} llibres'),
                trailing: Wrap(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1, size: 20),
                      onPressed: () => _gestionarUsuarisLlista(context, llista),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.exit_to_app,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _confirmarSortirLlista(context, llista),
                    ),
                    const Icon(Icons.expand_more),
                  ],
                ),
                children: llista.llibres.map((id) {
                  final llibre = getLlibreById(id);
                  if (llibre == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child:
                          llibre.urlImatge != null &&
                              llibre.urlImatge!.isNotEmpty
                          ? Image.network(
                              llibre.urlImatge!,
                              width: 30,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.book),
                    ),
                    title: Text(llibre.titol),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () =>
                          _eliminarDeLlistaPersonalitzada(llista, id),
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
      },
    );
  }
  // --- NUEVAS FUNCIONES DE LÓGICA ---

  void _gestionarUsuarisLlista(
    BuildContext context,
    LlistaPersonalitzada llista,
  ) {
    String filtreCerca = "";
    // Empezamos con los usuarios que ya están en la lista (excepto yo)
    List<String> seleccionats = List.from(llista.usuaris)..remove(currentUser);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gestionar Usuaris: ${llista.nom}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Cerca amics...'),
                onChanged: (val) =>
                    setModalState(() => filtreCerca = val.toLowerCase()),
              ),
              // ... dentro del StatefulBuilder de _gestionarUsuarisLlista ...
              SizedBox(
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuaris')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final usuariosRealtime = snapshot.data!.docs.map((doc) {
                      return Usuari.fromJson(
                        doc.data() as Map<String, dynamic>,
                      );
                    }).toList();

                    return ListView(
                      children: usuariosRealtime
                          .where((u) {
                            bool esAmic =
                                u.seguidors.contains(currentUser) &&
                                u.seguint.contains(currentUser);
                            return esAmic &&
                                u.nom.toLowerCase().contains(filtreCerca) &&
                                u.id != currentUser;
                          })
                          .map((amic) {
                            return CheckboxListTile(
                              title: Text(amic.nom),
                              secondary: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  amic.fotoUrl ?? '',
                                ),
                              ),
                              value: seleccionats.contains(amic.id),
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true)
                                    seleccionats.add(amic.id);
                                  else
                                    seleccionats.remove(amic.id);
                                });
                              },
                            );
                          })
                          .toList(),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<String> novaLlistaUsuaris = [
                    currentUser!,
                    ...seleccionats,
                  ];
                  await FirebaseFirestore.instance
                      .collection('llistes_personalitzades')
                      .doc(llista.id)
                      .update({'usuaris': novaLlistaUsuaris});

                  setState(() => llista.setUsuaris(novaLlistaUsuaris));
                  Navigator.pop(context);
                },
                child: const Text('Actualitzar'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarSortirLlista(
    BuildContext context,
    LlistaPersonalitzada llista,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sortir de la llista'),
        content: Text(
          'Segur que vols deixar de formar part de "${llista.nom}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          TextButton(
            onPressed: () async {
              final docRef = FirebaseFirestore.instance
                  .collection('llistes_personalitzades')
                  .doc(llista.id);

              if (llista.usuaris.length <= 1) {
                await docRef.delete();
              } else {
                await docRef.update({
                  'usuaris': FieldValue.arrayRemove([currentUser]),
                });
              }
              Navigator.pop(
                context,
              ); // El StreamBuilder se encargará de quitarlo de la pantalla
            },
            child: const Text('Sortir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionsAfegir(BuildContext context) {
    final TextEditingController _nomController = TextEditingController();
    // Lista temporal para guardar los IDs de los amigos seleccionados
    List<String> amicsSeleccionats = [];
    String filtreCerca = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        // Necesario para actualizar la lista de amigos dentro del modal
        builder: (context, setModalState) => Padding(
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

              // SECCIÓN DE AMIGOS
              // ... dentro del StatefulBuilder del modal ...
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Compartir amb amics:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Cerca amic per nom...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) =>
                    setModalState(() => filtreCerca = val.toLowerCase()),
              ),
              const SizedBox(height: 10),

              // --- LISTA A TIEMPO REAL ---
              SizedBox(
                height: 150,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuaris')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    // Convertimos los documentos en objetos Usuari dinámicamente
                    final usuariosRealtime = snapshot.data!.docs.map((doc) {
                      return Usuari.fromJson(
                        doc.data() as Map<String, dynamic>,
                      );
                    }).toList();

                    final amicsFiltrats = usuariosRealtime.where((u) {
                      // Lógica de Amigo: Reciprocidad y filtro de nombre
                      bool esAmic =
                          currentUser != null &&
                          u.seguidors.contains(currentUser) &&
                          u.seguint.contains(currentUser);

                      bool coincideNom = u.nom.toLowerCase().contains(
                        filtreCerca,
                      );
                      return esAmic && coincideNom && u.id != currentUser;
                    }).toList();

                    if (amicsFiltrats.isEmpty) {
                      return const Center(child: Text("No s'han trobat amics"));
                    }

                    return ListView(
                      children: amicsFiltrats.map((amic) {
                        final estaSeleccionat = amicsSeleccionats.contains(
                          amic.id,
                        );
                        return CheckboxListTile(
                          title: Text(amic.nom),
                          secondary: CircleAvatar(
                            backgroundImage: NetworkImage(amic.fotoUrl ?? ''),
                          ),
                          value: estaSeleccionat,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true)
                                amicsSeleccionats.add(amic.id);
                              else
                                amicsSeleccionats.remove(amic.id);
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
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

                    // Creamos la lista incluyendo al creador + amigos seleccionados
                    final llistaUsuarisFinal = [
                      currentUser!,
                      ...amicsSeleccionats,
                    ];

                    final nova = LlistaPersonalitzada(
                      id: docRef.id,
                      nom: _nomController.text,
                      llibres: [],
                      usuaris: llistaUsuarisFinal, // Se guarda para todos
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
      ),
    );
  }
}
