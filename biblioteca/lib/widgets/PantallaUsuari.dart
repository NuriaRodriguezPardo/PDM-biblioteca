import 'package:biblioteca/usuarios/auth.dart';
import 'package:biblioteca/widgets/PantallaPerfilUsuari.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener el ID actual
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/usuari.dart';
import '../clases/llibre.dart';
import 'PantallaLlibre.dart';
import 'PantallaEditarPerfil.dart';
import '../clases/carregaDeHistorial.dart';
import '../InternalLists.dart';
import 'PantallaLogin.dart';

class PantallaUsuari extends StatefulWidget {
  static String route = '/PantallaUsuaris';

  // Cambio: Quitamos el 'required' y lo hacemos opcional con '?'
  final Usuari? usuari;

  const PantallaUsuari({super.key, this.usuari});

  @override
  State<PantallaUsuari> createState() => _PantallaUsuariState();
}

class _PantallaUsuariState extends State<PantallaUsuari>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Usuari? _usuariVisualitzat;
  bool _isLoading = true; // Para mostrar un cargando

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    // Asegúrate de que _tabController esté inicializado si lo usas
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    // 1. Obtenemos el ID del usuario a visualizar
    final String userId =
        widget.usuari?.id ?? FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isNotEmpty) {
      try {
        // 2. Consultamos Firestore para tener los datos más recientes (especialmente tags)
        final doc = await FirebaseFirestore.instance
            .collection('usuaris')
            .doc(userId)
            .get();

        if (doc.exists) {
          setState(() {
            _usuariVisualitzat = Usuari.fromJson(doc.data()!);
          });
        } else {
          // --- MANEJO DE USUARIO NO ENCONTRADO ---
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No s'ha trobat la informació de l'usuari."),
              ),
            );
            // Si es el perfil propio y no existe, cerramos sesión por seguridad
            if (widget.usuari == null) {
              await signOut();
              Navigator.pushReplacementNamed(context, PantallaLogin.route);
            }
          }
        }
      } catch (e) {
        print("Error carregant usuari: $e");
        // Si falla la red, usamos el que tenemos por parámetro como respaldo
        _usuariVisualitzat = widget.usuari;
      }
    } else {
      // --- SI NO HAY ID (USUARIO NO LOGUEADO) ---
      if (mounted) {
        Navigator.pushReplacementNamed(context, PantallaLogin.route);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_usuariVisualitzat == null) {
      return const Scaffold(
        body: Center(child: Text("No s'ha pogut carregar el perfil")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_usuariVisualitzat!.nom),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await signOut(); // Llama a la función que ahora limpia el historial

              if (context.mounted) {
                // Usamos pushAndRemoveUntil para limpiar el stack de pantallas
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaLogin(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCapcalera(context),
            _buildEstadistiques(context),
            _buildTags(context),
            const SizedBox(height: 16),
            _buildSeccioLlibres(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCapcalera(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            backgroundImage:
                (_usuariVisualitzat!.fotoUrl != null &&
                    _usuariVisualitzat!.fotoUrl!.isNotEmpty)
                ? NetworkImage(_usuariVisualitzat!.fotoUrl!)
                : null,
            child:
                (_usuariVisualitzat!.fotoUrl == null ||
                    _usuariVisualitzat!.fotoUrl!.isEmpty)
                ? Text(
                    _usuariVisualitzat!.nom.isNotEmpty
                        ? _usuariVisualitzat!.nom[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            _usuariVisualitzat!.nom,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PantallaEditarPerfil(usuari: _usuariVisualitzat!),
                ),
              );
              // Al volver, recargamos para ver los cambios
              _cargarDatos();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }

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
              _usuariVisualitzat!.seguidors.length,
              Icons.people,
              () => _mostrarLlistaUsuaris(
                context,
                'Seguidors',
                _usuariVisualitzat!.seguidors,
              ),
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Seguint',
              _usuariVisualitzat!.seguint.length,
              Icons.person_add,
              () => _mostrarLlistaUsuaris(
                context,
                'Seguint',
                _usuariVisualitzat!.seguint,
              ),
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Llegits',
              _usuariVisualitzat!.llegits.length,
              Icons.check_circle_outline,
              null,
            ),
            _buildDivisor(),
            _buildEstadistica(
              context,
              'Pendents',
              _usuariVisualitzat!.pendents.length,
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

  Widget _buildTags(BuildContext context) {
    if (_usuariVisualitzat!.tags.isEmpty) {
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
              children: _usuariVisualitzat!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
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
                const ActivitatRecentTab(),
                RecomanacionsTab(tagsUsuari: _usuariVisualitzat!.tags),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarLlistaUsuaris(
    BuildContext context,
    String titol,
    List<String> idsUsuaris,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Permite bordes redondeados en el modal
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Barra estética superior del modal
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      titol,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: idsUsuaris.isEmpty
                        ? Center(
                            child: Text("No hi ha usuaris en aquesta llista"),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: idsUsuaris.length,
                            itemBuilder: (context, index) {
                              final String id = idsUsuaris[index];

                              // USAMOS EL HELPER DE INTERNALLISTS
                              // Si no existe en la lista, creamos uno temporal con el ID
                              final usuari =
                                  getUsuariById(id) ??
                                  Usuari(id: id, nom: "Usuari desconegut");
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  backgroundImage:
                                      (usuari.fotoUrl != null &&
                                          usuari.fotoUrl!.isNotEmpty)
                                      ? NetworkImage(usuari.fotoUrl!)
                                      : null,
                                  child:
                                      (usuari.fotoUrl == null ||
                                          usuari.fotoUrl!.isEmpty)
                                      ? Text(
                                          usuari.nom.isNotEmpty
                                              ? usuari.nom[0].toUpperCase()
                                              : "?",
                                        )
                                      : null,
                                ),
                                title: Text(usuari.nom),
                                subtitle: Text(
                                  usuari.id ==
                                          FirebaseAuth.instance.currentUser?.uid
                                      ? "Tu"
                                      : "",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () async {
                                  Navigator.pop(context); // Cierra el modal

                                  if (_usuariVisualitzat?.id == usuari.id)
                                    return;

                                  // CAMBIO AQUÍ: Esperamos a que el usuario vuelva de la otra pantalla
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PantallaPerfilUsuari(usuari: usuari),
                                    ),
                                  );

                                  // Al volver, refrescamos los datos de Firebase para ver los nuevos contadores
                                  _cargarDatos();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------
// NO TOCAR ESTOS WIDGETS: SÓN INDEPENDIENTES
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
