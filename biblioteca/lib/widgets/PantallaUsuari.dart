import 'package:flutter/material.dart';
import '../clases/usuari.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import '../carregaDeDades.dart'; // Importat per accedir a les dades globals i loadAllDataMap
import 'PantallaEditarPerfil.dart';
import '../clases/carregaDeHistorial.dart';
import '../internalLists.dart';

class PantallaUsuari extends StatefulWidget {
  static String route = '/PantallaUsuaris';
  final Usuari usuari;

  const PantallaUsuari({super.key, required this.usuari});

  @override
  State<PantallaUsuari> createState() => _PantallaUsuariState();
}

class _PantallaUsuariState extends State<PantallaUsuari>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Usuari _usuariVisualitzat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _usuariVisualitzat = widget.usuari;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Helper per obtenir un objecte Usuari a partir del seu ID (String).
  Usuari _getUsuariById(String id) {
    final allData = loadAllDataMap();
    final usersList = allData['usuaris'] as List<dynamic>;

    final userJson = usersList.firstWhere(
      (u) => u['id'].toString() == id,
      orElse: () => null,
    );

    if (userJson != null) {
      return Usuari.fromJson(userJson);
    } else {
      return Usuari(id: id, nom: 'Usuari Desconegut');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuari.nom),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuració de l\'Usuari')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Informació Principal de l'Usuari
            _buildCapcalera(context),
            _buildEstadistiques(context),
            _buildTags(context),

            const SizedBox(height: 16),

            // 2. Secció de Llibres (Utilitza TabBar)
            _buildSeccioLlibres(context),
          ],
        ),
      ),
    );
  }

  // Capçalera amb foto de perfil i info personal
  Widget _buildCapcalera(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            // SI TENIM URL, LA MOSTREM. SI NO, NULL (i es veurà la lletra)
            backgroundImage:
                (_usuariVisualitzat.fotoUrl != null &&
                    _usuariVisualitzat.fotoUrl!.isNotEmpty)
                ? NetworkImage(_usuariVisualitzat.fotoUrl!)
                : null,

            // CHILD: Només mostrem la inicial si NO hi ha foto
            child:
                (_usuariVisualitzat.fotoUrl == null ||
                    _usuariVisualitzat.fotoUrl!.isEmpty)
                ? Text(
                    _usuariVisualitzat.nom.isNotEmpty
                        ? _usuariVisualitzat.nom[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null, // Si hi ha foto, child és null
          ),
          const SizedBox(height: 12),
          Text(
            widget.usuari.nom,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${widget.usuari.id}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // NAVEGACIÓ A PANTALLA EDITAR PERFIL
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaEditarPerfil(usuari: widget.usuari),
                ),
              ).then((_) {
                // Quan tornem, refresquem la pantalla per si han canviat els tags
                setState(() {});
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }

  // Estadístiques: Seguidors, Amics, Llibres llegits
  Widget _buildEstadistiques(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEstadistica(
              context,
              'Seguidors',
              widget.usuari.seguidors.length,
              Icons.people,
              () => _mostrarLlistaUsuaris(
                context,
                'Seguidors',
                widget.usuari.seguidors,
              ),
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Seguint',
              widget.usuari.amics.length,
              Icons.person_add,
              () => _mostrarLlistaUsuaris(
                context,
                'Seguint',
                widget.usuari.amics,
              ),
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Llegits',
              widget.usuari.llegits.length,
              Icons.check_circle_outline,
              null,
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Pendents',
              widget.usuari.pendents.length,
              Icons.bookmark_border,
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisor() {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  Widget _buildEstadistica(
    BuildContext context,
    String etiqueta,
    int valor,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 4),
            Text(
              valor.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              etiqueta,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Tags / Interessos
  Widget _buildTags(BuildContext context) {
    if (widget.usuari.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Interessos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.usuari.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  // CORRECCIÓ: Substituït withOpacity(0.1) per withValues(alpha: 0.1)
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Secció de llibres amb tabs
  Widget _buildSeccioLlibres(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Activitat', icon: Icon(Icons.timeline)),
              Tab(text: 'Recomanacions', icon: Icon(Icons.star)),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                ActivitatRecentTab(),
                RecomanacionsTab(tagsUsuari: widget.usuari.tags),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modal per mostrar llista de seguidors/seguint
  void _mostrarLlistaUsuaris(
    BuildContext context,
    String titol,
    List<String> idsUsuaris,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        titol,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: idsUsuaris.isEmpty
                      ? Center(
                          child: Text(
                            'No hi ha $titol',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: idsUsuaris.length,
                          itemBuilder: (context, index) {
                            final id = idsUsuaris[index];
                            final usuari = _getUsuariById(id);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                child: Text(
                                  usuari.nom.isNotEmpty
                                      ? usuari.nom[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                usuari.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('ID: ${usuari.id}'),
                              trailing: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PantallaUsuari(usuari: usuari),
                                    ),
                                  );
                                },
                                child: const Text('Veure perfil'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------
// WIDGETS AUXILIARS
// -----------------------------------------------------------

class ActivitatRecentTab extends StatelessWidget {
  const ActivitatRecentTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Si la lista está vacía, mostramos el mensaje de siempre
    if (historialActivitat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text(
              'Aún no has realizado ninguna actividad.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Si hay datos, mostramos la lista
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: historialActivitat.length,
      itemBuilder: (context, index) {
        final item = historialActivitat[index];
        // Formatear hora simple (HH:MM)
        final hora =
            "${item.data.hour.toString().padLeft(2, '0')}:${item.data.minute.toString().padLeft(2, '0')}";

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: Icon(item.icona, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              item.titol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.subtitol),
            trailing: Text(
              hora,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class RecomanacionsTab extends StatelessWidget {
  final List<String> tagsUsuari;

  const RecomanacionsTab({super.key, required this.tagsUsuari});

  @override
  Widget build(BuildContext context) {
    final List<Llibre> recomanats = llistaLlibresGlobal.where((llibre) {
      return llibre.tags.any((tagLlibre) => tagsUsuari.contains(tagLlibre));
    }).toList();

    if (recomanats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_library_outlined,
              size: 50,
              // CORRECCIÓ: Substituït withOpacity(0.5) per withValues(alpha: 0.5)
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'No tenim recomanacions pels teus interessos actuals.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: recomanats.length,
      itemBuilder: (context, index) {
        final llibre = recomanats[index];
        return Card(
          child: ListTile(
            leading: llibre.urlImatge != null
                ? Image.network(
                    llibre.urlImatge!,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.book),
                  )
                : const Icon(Icons.book),
            title: Text(llibre.titol),
            subtitle: Text(llibre.autor),
            trailing: const Icon(Icons.arrow_forward),
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
