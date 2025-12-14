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

              // Opció 1: Afegir a Pendents
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.bookmark_add, color: Colors.white),
                ),
                title: const Text('Afegir a Pendents'),
                subtitle: const Text('Marca un llibre per llegir més tard'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarSeleccioLlibrePerAfegir(context, 'pendents');
                },
              ),
              const Divider(),

              // Opció 2: Marcar com Llegit
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check_circle, color: Colors.white),
                ),
                title: const Text('Marcar com a Llegit'),
                subtitle: const Text(
                  'Afegeix un llibre a la llista de llegits',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarSeleccioLlibrePerAfegir(context, 'llegits');
                },
              ),
              const Divider(),

              // Opció 3: Crear nova llista
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.create_new_folder,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Crear nova llista'),
                subtitle: const Text('Crea una llista personalitzada nova'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialegNovaLlista(context);
                },
              ),
              const Divider(),

              // Opció 4: Afegir llibre a llista existent
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.playlist_add, color: Colors.white),
                ),
                title: const Text('Afegir a llista personalitzada'),
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

  // Seleccionar llibre per afegir a Pendents o Llegits
  void _mostrarSeleccioLlibrePerAfegir(BuildContext context, String tipus) {
    final String titol = tipus == 'pendents'
        ? 'Afegir a Pendents'
        : 'Marcar com a Llegit';
    final IconData icona = tipus == 'pendents'
        ? Icons.bookmark_add
        : Icons.check_circle;
    final Color color = tipus == 'pendents' ? Colors.orange : Colors.green;

    // Filtrar llibres que ja estan a la llista corresponent
    final List<Llibre> llibresDisponibles = totsElsLlibres.where((llibre) {
      if (tipus == 'pendents') {
        return !llibresPendents.any((l) => l.id == llibre.id);
      } else {
        return !llibresLlegits.any((l) => l.id == llibre.id);
      }
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icona, color: color),
              const SizedBox(width: 8),
              Text(titol),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: llibresDisponibles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tipus == 'pendents'
                              ? 'Tots els llibres ja estan a pendents!'
                              : 'Tots els llibres ja estan llegits!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: llibresDisponibles.length,
                    itemBuilder: (context, index) {
                      final llibre = llibresDisponibles[index];
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
                        title: Text(
                          llibre.titol,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(llibre.autor),
                        onTap: () {
                          setState(() {
                            if (tipus == 'pendents') {
                              llibresPendents.add(llibre);
                            } else {
                              llibresLlegits.add(llibre);
                              // Treure de pendents si hi era
                              llibresPendents.removeWhere(
                                (l) => l.id == llibre.id,
                              );
                            }
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tipus == 'pendents'
                                    ? '"${llibre.titol}" afegit a pendents'
                                    : '"${llibre.titol}" marcat com a llegit',
                              ),
                              backgroundColor: color,
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

                    final novaLlista = LlistaPersonalitzada(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nom: nomController.text.trim(),
                      llibres: llibresSeleccionats.toList(),
                      usuaris: ["1"],
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

  // Eliminar llibre de pendents
  void _eliminarDePendents(Llibre llibre) {
    setState(() {
      llibresPendents.removeWhere((l) => l.id == llibre.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${llibre.titol}" eliminat de pendents'),
        action: SnackBarAction(
          label: 'Desfer',
          onPressed: () {
            setState(() {
              llibresPendents.add(llibre);
            });
          },
        ),
      ),
    );
  }

  // Eliminar llibre de llegits
  void _eliminarDeLlegits(Llibre llibre) {
    setState(() {
      llibresLlegits.removeWhere((l) => l.id == llibre.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${llibre.titol}" eliminat de llegits'),
        action: SnackBarAction(
          label: 'Desfer',
          onPressed: () {
            setState(() {
              llibresLlegits.add(llibre);
            });
          },
        ),
      ),
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
            // Pendents amb opció d'eliminar
            BookListTabWithActions(
              llibres: llibresPendents,
              onDelete: _eliminarDePendents,
              onMarkAsRead: (llibre) {
                setState(() {
                  llibresPendents.removeWhere((l) => l.id == llibre.id);
                  llibresLlegits.add(llibre);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${llibre.titol}" marcat com a llegit'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              emptyMessage: 'No tens llibres pendents.\nPrem + per afegir-ne!',
              emptyIcon: Icons.bookmark_border,
            ),

            // Reservats
            ReservesTab(
              reserves: reserves,
              onCancelReserva: (reserva) {
                setState(() {
                  reserves.removeWhere((r) => r.id == reserva.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva cancel·lada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),

            // Llegits amb opció d'eliminar
            BookListTabWithActions(
              llibres: llibresLlegits,
              onDelete: _eliminarDeLlegits,
              emptyMessage:
                  'No has llegit cap llibre encara.\nPrem + per marcar-ne un!',
              emptyIcon: Icons.check_circle_outline,
            ),

            // Llistes personalitzades
            CustomLists(
              llistes: llistesPersonalitzades,
              onLlistaModificada: () => setState(() {}),
              onEliminarLlista: (llista) {
                setState(() {
                  llistesPersonalitzades.removeWhere((l) => l.id == llista.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Llista "${llista.nom}" eliminada')),
                );
              },
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

// --- WIDGETS AUXILIARS MILLORATS ---

// Widget per mostrar llistes de Llibres amb accions
class BookListTabWithActions extends StatelessWidget {
  final List<Llibre> llibres;
  final Function(Llibre) onDelete;
  final Function(Llibre)? onMarkAsRead;
  final String emptyMessage;
  final IconData emptyIcon;

  const BookListTabWithActions({
    Key? key,
    required this.llibres,
    required this.onDelete,
    this.onMarkAsRead,
    required this.emptyMessage,
    required this.emptyIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llibres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: llibres.length,
      itemBuilder: (context, index) {
        final llibre = llibres[index];
        return Dismissible(
          key: Key(llibre.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: onMarkAsRead != null
              ? Container(
                  color: Colors.green,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                )
              : Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              onDelete(llibre);
              return false;
            } else if (onMarkAsRead != null) {
              onMarkAsRead!(llibre);
              return false;
            } else {
              onDelete(llibre);
              return false;
            }
          },
          child: ListTile(
            leading: llibre.urlImatge != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      llibre.urlImatge!,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.book, size: 40),
                    ),
                  )
                : const Icon(Icons.book, size: 40),
            title: Text(llibre.titol),
            subtitle: Text(llibre.autor),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onMarkAsRead != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Marcar com llegit',
                    onPressed: () => onMarkAsRead!(llibre),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => onDelete(llibre),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaLlibre(llibre: llibre),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Widget per mostrar la llista de Reserves amb cancel·lació
class ReservesTab extends StatelessWidget {
  final List<Reserva> reserves;
  final Function(Reserva) onCancelReserva;

  const ReservesTab({
    Key? key,
    required this.reserves,
    required this.onCancelReserva,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reserves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tens cap reserva activa.\nVes a un llibre i prem "Reservar"!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
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

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isVencuda
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              child: Icon(
                Icons.assignment,
                color: isVencuda ? Colors.red : Colors.green,
              ),
            ),
            title: Text(llibreObjecte.titol),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vencimentText),
                Text(
                  'Reservat: ${reserva.dataReserva.day}/${reserva.dataReserva.month}/${reserva.dataReserva.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Cancel·lar reserva',
              onPressed: () => onCancelReserva(reserva),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaLlibre(llibre: llibreObjecte),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Widget per mostrar la llista de Llistes Personalitzades
class CustomLists extends StatelessWidget {
  final List<LlistaPersonalitzada> llistes;
  final VoidCallback? onLlistaModificada;
  final Function(LlistaPersonalitzada)? onEliminarLlista;

  const CustomLists({
    Key? key,
    required this.llistes,
    this.onLlistaModificada,
    this.onEliminarLlista,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (llistes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Encara no has creat cap llista.\nPrem + per crear-ne una!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: llistes.length,
      itemBuilder: (context, index) {
        final llista = llistes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: const Icon(Icons.folder_shared_outlined),
            title: Text(llista.nom),
            subtitle: Text('${llista.numLlibres} llibres'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar llista?'),
                    content: Text('Vols eliminar la llista "${llista.nom}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel·lar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onEliminarLlista?.call(llista);
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
              },
            ),
            children: llista.llibres.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aquesta llista està buida',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ]
                : llista.llibres.map((idLlibre) {
                    final Llibre llibreObjecte = _obtenirLlibrePerId(idLlibre);
                    return ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 30,
                        right: 16,
                      ),
                      leading: const Icon(Icons.book_outlined, size: 20),
                      title: Text(llibreObjecte.titol),
                      subtitle: Text(llibreObjecte.autor),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PantallaLlibre(llibre: llibreObjecte),
                          ),
                        );
                      },
                    );
                  }).toList(),
          ),
        );
      },
    );
  }
}

// --- FUNCIONS HELPERS ---

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
