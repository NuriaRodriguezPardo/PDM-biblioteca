import 'package:biblioteca/widgets/PantallaPerfilUsuari.dart';
import 'package:flutter/material.dart';
import '../clases/llibre.dart';
import '../clases/usuari.dart';
import 'PantallaLlibre.dart';
import '../InternalLists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String queryLibros = '';
  String queryUsuarios = '';

  @override
  Widget build(BuildContext context) {
    // LÓGICA BÚSQUEDA LIBROS (Tal cual la tenías)
    List<Llibre> resultadosLibros;
    if (queryLibros.isEmpty) {
      resultadosLibros = llistaLlibresGlobal.take(5).toList();
    } else {
      resultadosLibros = llistaLlibresGlobal.where((llibre) {
        final queryLower = queryLibros.toLowerCase();
        return llibre.titol.toLowerCase().contains(queryLower) ||
            llibre.autor.toLowerCase().contains(queryLower);
      }).toList();
    }
    /*
    // LÓGICA BÚSQUEDA USUARIOS
    List<Usuari> resultadosUsuarios;
    if (queryUsuarios.isEmpty) {
      resultadosUsuarios = llistaUsuarisGlobal.take(5).toList();
    } else {
      resultadosUsuarios = llistaUsuarisGlobal.where((u) {
        final queryLower = queryUsuarios.toLowerCase();
        return u.nom.toLowerCase().contains(queryLower) ||
            u.email!.toLowerCase().contains(queryLower);
      }).toList();
    }
*/
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cercar'),
          centerTitle: true,
          // Pestañas en horizontal arriba (Estilo Windows/Tabs)
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Llibres'),
              Tab(icon: Icon(Icons.people), text: 'Persones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- PESTAÑA 1: LIBROS ---
            Column(
              children: [
                _buildSearchBar(
                  hint: 'Títol o autor...',
                  onChanged: (value) => setState(() => queryLibros = value),
                ),
                Expanded(child: _buildListaLibros(resultadosLibros)),
              ],
            ),

            // --- PESTAÑA 2: PERSONAS ---
            Column(
              children: [
                _buildSearchBar(
                  hint: 'Nom o correu...',
                  onChanged: (value) => setState(() => queryUsuarios = value),
                ),
                Expanded(child: _buildListaUsuarios()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget de barra de búsqueda reutilizable
  Widget _buildSearchBar({
    required String hint,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  // Vista de Lista de Libros (Mantiene tu estética)
  Widget _buildListaLibros(List<Llibre> libros) {
    if (libros.isEmpty) return _buildEmptyState();
    return ListView.builder(
      itemCount: libros.length,
      itemBuilder: (context, index) {
        final llibre = libros[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: llibre.urlImatge != null
                ? Image.network(llibre.urlImatge!, width: 40, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 40),
          ),
          title: Text(llibre.titol),
          subtitle: Text(llibre.autor),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PantallaLlibre(llibre: llibre)),
          ),
        );
      },
    );
  }

  // Vista de Lista de Usuarios (Nueva sección)
  Widget _buildListaUsuarios() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuaris').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        // Convertimos documentos a objetos Usuari
        List<Usuari> todosLosUsuarios = snapshot.data!.docs
            .map((doc) => Usuari.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Aplicamos tu filtro original sobre la lista a tiempo real
        List<Usuari> resultadosUsuarios;
        if (queryUsuarios.isEmpty) {
          resultadosUsuarios = todosLosUsuarios.take(5).toList();
        } else {
          resultadosUsuarios = todosLosUsuarios.where((user) {
            final queryLower = queryUsuarios.toLowerCase();
            return user.nom.toLowerCase().contains(queryLower) ||
                (user.email != null &&
                    user.email!.toLowerCase().contains(queryLower));
          }).toList();
        }

        if (resultadosUsuarios.isEmpty) return _buildEmptyState();

        return ListView.builder(
          itemCount: resultadosUsuarios.length,
          itemBuilder: (context, index) {
            final user = resultadosUsuarios[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                // Intentamos cargar la imagen de la red
                backgroundImage:
                    (user.fotoUrl != null && user.fotoUrl!.isNotEmpty)
                    ? NetworkImage(user.fotoUrl!)
                    : null,
                // Si no hay imagen (backgroundImage es null), se muestra el child (la inicial)
                child: (user.fotoUrl == null || user.fotoUrl!.isEmpty)
                    ? Text(
                        user.nom[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(user.nom),
              subtitle: Text(user.email!),
              trailing: const Icon(Icons.person_add_alt_1, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaPerfilUsuari(usuari: user),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 10),
          Text('No s\'han trobat resultats'),
        ],
      ),
    );
  }
}
