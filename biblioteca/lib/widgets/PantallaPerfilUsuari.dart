import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/usuari.dart';
import '../InternalLists.dart';
import 'PantallaLlibre.dart';

class PantallaPerfilUsuari extends StatefulWidget {
  final Usuari usuari;

  const PantallaPerfilUsuari({super.key, required this.usuari});

  @override
  State<PantallaPerfilUsuari> createState() => _PantallaPerfilUsuariState();
}

class _PantallaPerfilUsuariState extends State<PantallaPerfilUsuari> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool siguiendo = false;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    // Comprobar si el usuario actual ya sigue a este perfil
    _comprobarSeguimiento();
  }

  void _comprobarSeguimiento() {
    // 1. Buscamos al usuario actual (tú) en la lista global de memoria
    final yo = getUsuariById(currentUserId ?? "");

    if (yo != null) {
      setState(() {
        // Comprobamos si el ID del perfil que visitamos está en MI lista de seguidos
        siguiendo = yo.seguint.contains(widget.usuari.id);
        cargando = false;
      });
    }
  }

  // Lógica de Amigos: Mutuo seguimiento
  int get contadorAmigos {
    return widget.usuari.seguidors.where((idSeguidor) {
      return widget.usuari.seguint.contains(idSeguidor);
    }).length;
  }

  // --- LÓGICA DE FIREBASE PARA SEGUIR/DEJAR DE SEGUIR ---
  Future<void> _toggleSeguimiento() async {
    if (currentUserId == null) return;

    final miDoc = FirebaseFirestore.instance
        .collection('usuaris')
        .doc(currentUserId);
    final suDoc = FirebaseFirestore.instance
        .collection('usuaris')
        .doc(widget.usuari.id);

    if (!siguiendo) {
      // SEGUIR
      setState(() {
        siguiendo = true;
        widget.usuari.seguidors.add(currentUserId!);
      });

      await miDoc.update({
        'seguint': FieldValue.arrayUnion([widget.usuari.id]),
      });
      await suDoc.update({
        'seguidors': FieldValue.arrayUnion([currentUserId]),
      });
    } else {
      // DEJAR DE SEGUIR
      setState(() {
        siguiendo = false;
        widget.usuari.seguidors.remove(currentUserId);
      });

      await miDoc.update({
        'seguint': FieldValue.arrayRemove([widget.usuari.id]),
      });
      await suDoc.update({
        'seguidors': FieldValue.arrayRemove([currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 105, 84, 68),
                          Color.fromARGB(255, 123, 116, 103),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (widget.usuari.fotoUrl != null &&
                                widget.usuari.fotoUrl!.isNotEmpty)
                            ? NetworkImage(widget.usuari.fotoUrl!)
                            : null,
                        child:
                            (widget.usuari.fotoUrl == null ||
                                widget.usuari.fotoUrl!.isEmpty)
                            ? Text(
                                widget.usuari.nom[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.usuari.nom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.usuari.email ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          "Seguidors",
                          widget.usuari.seguidors.length.toString(),
                        ),
                        _buildStat("Amics", contadorAmigos.toString()),
                        _buildStat(
                          "Llegits",
                          widget.usuari.llegits.length.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (currentUserId != widget.usuari.id)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: siguiendo
                                ? Colors.grey.shade300
                                : Color.fromARGB(244, 126, 77, 20),
                            foregroundColor: siguiendo
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _toggleSeguimiento,
                          child: Text(siguiendo ? "Seguint" : "Seguir"),
                        ),
                      ),
                  ],
                ),
              ),

              _buildSectionTitle("Interessos"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  children: widget.usuari.tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            183,
                            238,
                          ).withValues(alpha: 0.1),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              _buildHorizontalBookList(
                "Llibres Llegits",
                widget.usuari.llegits,
              ),
              _buildHorizontalBookList(
                "Lectures Pendents",
                widget.usuari.pendents,
              ),
              _buildHorizontalListSection(
                "Les seves Llistes",
                widget.usuari.id,
              ),

              const SizedBox(height: 50),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalBookList(String title, List<String> bookIds) {
    if (bookIds.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: bookIds.length,
            itemBuilder: (context, index) {
              final llibre = getLlibreById(bookIds[index]);
              if (llibre == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaLlibre(llibre: llibre),
                  ),
                ),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: llibre.urlImatge != null
                              ? Image.network(
                                  llibre.urlImatge!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.book),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        llibre.titol,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget para mostrar las listas personalizadas con un desplegable (ExpansionTile)
  Widget _buildHorizontalListSection(String title, String userId) {
    // Filtramos las listas donde este usuario participa
    final llistes = llistesPersonalitzadesGlobals
        .where((l) => l.usuaris.contains(userId))
        .toList();

    if (llistes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        // Usamos un ListView vertical sin scroll (shrinkWrap) para que quepan los desplegables
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: llistes.length,
          itemBuilder: (context, index) {
            final llista = llistes[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                // Estética del encabezado del desplegable
                leading: const Icon(
                  Icons.format_list_bulleted,
                  color: Colors.blue,
                ),
                title: Text(
                  llista.nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "${llista.llibres.length} llibres en aquesta llista",
                ),
                shape: const Border(), // Quita la línea divisoria por defecto
                children: [
                  // Contenido que aparece al abrir el desplegable
                  if (llista.llibres.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Aquesta llista està buida.",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ...llista.llibres.map((idLlibre) {
                      final llibre = getLlibreById(idLlibre);
                      if (llibre == null) return const SizedBox.shrink();

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: llibre.urlImatge != null
                              ? Image.network(
                                  llibre.urlImatge!,
                                  width: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book, size: 40),
                        ),
                        title: Text(
                          llibre.titol,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          llibre.autor,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaLlibre(llibre: llibre),
                            ),
                          );
                        },
                      );
                    }).toList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
