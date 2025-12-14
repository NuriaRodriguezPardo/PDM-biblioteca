import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/llista_personalitzada.dart';
import '../clases/reserva.dart';
import 'PantallaLlibre.dart';
import '../carregaDeDades.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({Key? key}) : super(key: key);

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  void _mostrarOpcionsAfegir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Què vols fer?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Opció 1: Crear nova llista
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                title: const Text('Crear nova llista'),
                subtitle: const Text('Crea una llista personalitzada nova'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialegNovaLlista(context);
                },
              ),
              const Divider(),

              // Opció 2: Afegir llibre a llista existent
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.playlist_add, color: Colors.white),
                ),
                title: const Text('Afegir llibre a llista'),
                subtitle: const Text('Afegeix un llibre a una llista existent'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarSeleccioLlibre(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialegNovaLlista(BuildContext context) {
    final TextEditingController nomController = TextEditingController();
    final Set<String> llibresSeleccionats = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear nova llista'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la llista',
                        hintText: 'Ex: Lectures d\'estiu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selecciona llibres (opcional):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: totsElsLlibres.length,
                        itemBuilder: (context, index) {
                          final llibre = totsElsLlibres[index];
                          final isSelected = llibresSeleccionats.contains(
                            llibre.id,
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              llibre.titol,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(llibre.autor),
                            secondary: llibre.urlImatge != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      llibre.urlImatge!,
                                      width: 40,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.book),
                                    ),
                                  )
                                : const Icon(Icons.book),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  llibresSeleccionats.add(llibre.id);
                                } else {
                                  llibresSeleccionats.remove(llibre.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel·lar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nomController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El nom de la llista no pot estar buit',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Crear la nova llista
                    final novaLlista = LlistaPersonalitzada(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nom: nomController.text.trim(),
                      llibres: llibresSeleccionats.toList(),
                      usuaris: ["1"], // Usuari principal
                    );

                    setState(() {
                      llistesPersonalitzades.add(novaLlista);
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Llista "${novaLlista.nom}" creada amb ${llibresSeleccionats.length} llibres',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarSeleccioLlibre(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona un llibre'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: totsElsLlibres.length,
              itemBuilder: (context, index) {
                final llibre = totsElsLlibres[index];
                return ListTile(
                  leading: llibre.urlImatge != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            llibre.urlImatge!,
                            width: 40,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.book),
                          ),
                        )
                      : const Icon(Icons.book),
                  title: Text(llibre.titol, overflow: TextOverflow.ellipsis),
                  subtitle: Text(llibre.autor),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarSeleccioLlista(context, llibre);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarSeleccioLlista(BuildContext context, Llibre llibre) {
    if (llistesPersonalitzades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tens cap llista. Crea\'n una primer!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Afegir "${llibre.titol}" a:'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: llistesPersonalitzades.length,
              itemBuilder: (context, index) {
                final llista = llistesPersonalitzades[index];
                final jaConte = llista.llibres.contains(llibre.id);

                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: jaConte
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(llista.nom),
                  subtitle: Text(
                    jaConte
                        ? 'Ja conté aquest llibre'
                        : '${llista.numLlibres} llibres',
                  ),
                  enabled: !jaConte,
                  onTap: jaConte
                      ? null
                      : () {
                          setState(() {
                            llista.llibres.add(llibre.id);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '"${llibre.titol}" afegit a "${llista.nom}"',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
          ],
        );
      },
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
            BookListTab(llibres: llibresPendents),
            Reserves(reserves: reserves),
            BookListTab(llibres: llibresLlegits),
            CustomLists(
              llistes: llistesPersonalitzades,
              onLlistaModificada: () => setState(() {}),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarOpcionsAfegir(context),
          tooltip: 'Afegir',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARS ---

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
          title: Text(llibreObjecte.titol),
          subtitle: Text(vencimentText),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaLlibre(llibre: llibreObjecte),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomLists extends StatelessWidget {
  final List<LlistaPersonalitzada> llistes;
  final VoidCallback? onLlistaModificada;

  const CustomLists({Key? key, required this.llistes, this.onLlistaModificada})
    : super(key: key);

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
          subtitle: Text('${llista.numLlibres} llibres'),
          children: llista.llibres.map((idLlibre) {
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

Llibre _obtenirLlibrePerId(String id) {
  try {
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
