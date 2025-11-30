// [PantallaUsuaris.dart]
import 'package:flutter/material.dart';
import '../clases/usuari.dart';
import '../clases/llibre.dart';
import '../clases/reserva.dart';
import 'PantallaLlibre.dart';

// Definició de les llistes de l'Usuari per simplificar l'accés
// Nota: L'Usuari ja conté les seves pròpies llistes (pendents, llegits, reserves)

class PantallaUsuari extends StatefulWidget {
  static String route = '/PantallaUsuaris';
  final Usuari usuari;

  const PantallaUsuari({super.key, required this.usuari});

  @override
  State<PantallaUsuari> createState() => _PantallaUsuariState();
}

class _PantallaUsuariState extends State<PantallaUsuari>
    with SingleTickerProviderStateMixin {
  // Inicialitzem TabController amb 2 pestanyes (Activitat i Recomanacions)
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 2 pestanyes: Activitat Recent i Recomanacions
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla d'usuari combina scroll vertical per al perfil amb una TabBarView per als llibres.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuari.nom),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navegar a configuració
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuració de l\'Usuari')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // CORRECCIÓ: Centrar tota la columna principal
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
        // CORRECCIÓ: Centrar horitzontalment els elements de la columna
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto de perfil
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              widget.usuari.nom.isNotEmpty
                  ? widget.usuari.nom[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nom d'usuari
          Text(
            widget.usuari.nom,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign:
                TextAlign.center, // Assegurem que el text estigui centrat
          ),
          const SizedBox(height: 4),
          // ID d'usuari
          Text(
            'ID: ${widget.usuari.id}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign:
                TextAlign.center, // Assegurem que el text estigui centrat
          ),
          const SizedBox(height: 16),
          // Botó d'editar perfil
          OutlinedButton.icon(
            onPressed: () {
              // Navegar a editar perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funció d\'editar perfil')),
              );
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
      // Centrar la targeta es fa mitjançant el CrossAxisAlignment.center a la columna principal
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
      // Centrar la targeta es fa mitjançant el CrossAxisAlignment.center a la columna principal
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
                  backgroundColor: Theme.of(context).colorScheme.secondary
                      .withOpacity(0.1), // Ús de color del tema
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

  // Secció de llibres amb tabs (Ara Activitat i Recomanacions)
  Widget _buildSeccioLlibres(BuildContext context) {
    return Card(
      // Centrar la targeta es fa mitjançant el CrossAxisAlignment.center a la columna principal
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
              Tab(
                text: 'Activitat',
                icon: Icon(Icons.timeline),
              ), // NOVA PESTANYA
              Tab(
                text: 'Recomanacions',
                icon: Icon(Icons.star),
              ), // NOVA PESTANYA
            ],
          ),
          // Necessitem un SizedBox amb alçada fixa per contenir TabBarView dins del SingleChildScrollView
          SizedBox(
            height: 400, // Altura suficient per veure el contingut de la llista
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Activitat Recent
                ActivitatRecentTab(),

                // 2. Recomanacions Personalitzades
                RecomanacionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modal per mostrar llista de seguidors/seguint (necessari per _buildEstadistiques)
  void _mostrarLlistaUsuaris(
    BuildContext context,
    String titol,
    List<Usuari> usuaris,
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
                // Handle i títol
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
                // Llista d'usuaris
                Expanded(
                  child: usuaris.isEmpty
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
                          itemCount: usuaris.length,
                          itemBuilder: (context, index) {
                            final usuari = usuaris[index];
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
// NOUS WIDGETS AUXILIARS (Substitueixen BookListTab i Reserves)
// -----------------------------------------------------------

class ActivitatRecentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Sense activitat recent per mostrar.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class RecomanacionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_library,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          const Text(
            'Recomanacions basades en els teus tags.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
