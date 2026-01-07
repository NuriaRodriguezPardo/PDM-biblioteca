import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PantallaPrincipal.dart';
import '../clases/usuari.dart';
import '../InternalLists.dart';

class PantallaSeleccioTags extends StatefulWidget {
  const PantallaSeleccioTags({super.key});

  @override
  State<PantallaSeleccioTags> createState() => _PantallaSeleccioTagsState();
}

class _PantallaSeleccioTagsState extends State<PantallaSeleccioTags> {
  final List<String> _tagsDisponibles = [
    'Acción',
    'Ajedrez',
    'Amigos',
    'Amistad',
    'Angustia',
    'Arte',
    'Atraco',
    'Autoayuda',
    'Aventura',
    'Bailes',
    'Biografía',
    'Bully',
    'Café',
    'Campus',
    'Catalán',
    'Ciberseguridad',
    'Ciencia Ficción',
    'Cine',
    'Clásico',
    'Comedia',
    'Contemporáneo',
    'Crimen',
    'Cuentos',
    'Dark Romance',
    'Deporte',
    'Deportes',
    'Desaparición',
    'Distopía',
    'Doctorado',
    'Dolor',
    'Doméstico',
    'Dragones',
    'Drama',
    'Emotivo',
    'Enemigos',
    'Erótica',
    'Familia',
    'Fantasía',
    'Final',
    'Fútbol',
    'Guerra',
    'Histórica',
    'Hockey',
    'Humor',
    'Instituto',
    'Intriga',
    'Inédito',
    'Juvenil',
    'Londres',
    'Magia',
    'Maldiciones',
    'Matrimonio',
    'Misterio',
    'Moda',
    'Monstruos',
    'Navidad',
    'New Adult',
    'No Ficción',
    'Novedad',
    'Obsesión',
    'Otoño',
    'Pasión',
    'Patinaje',
    'Playa',
    'Poder',
    'Policiaca',
    'Política',
    'Psicología',
    'Psicológico',
    'Psiquiatría',
    'Realeza',
    'Realismo',
    'Redención',
    'Reencuentro',
    'Roma',
    'Romance',
    'Romance Histórico',
    'Rugby',
    'Secretos',
    'Secuela',
    'Segunda Oportunidad',
    'Sentimental',
    'Slow-burn',
    'Sociedad',
    'Supervivencia',
    'Suspense',
    'Thriller',
    'Tragedia',
    'Traición',
    'Trilogía',
    'Universidad',
    'Vampiros',
    'Venganza',
    'Época',
  ];

  final List<String> _tagsSeleccionats = [];
  String _busqueda = "";
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filtramos la lista según lo que el usuario escriba
    final listaFiltrada = _tagsDisponibles
        .where((tag) => tag.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tria els teus interessos"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "¿Qué t'agrada llegir?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Selecciona els temes que més t'interessen."),
            const SizedBox(height: 20),

            // BUSCADOR
            TextField(
              decoration: InputDecoration(
                hintText: "Cerca un tag...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => _busqueda = val),
            ),

            const SizedBox(height: 20),

            // CONTENEDOR CUADRADO CON SCROLL
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: listaFiltrada.map((tag) {
                      final selected = _tagsSeleccionats.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        selected: selected,
                        onSelected: (bool value) {
                          setState(() {
                            value
                                ? _tagsSeleccionats.add(tag)
                                : _tagsSeleccionats.remove(tag);
                          });
                        },
                        selectedColor: colorScheme.primary,
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN CONTINUAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _isSaving ? null : _guardarTags,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "COMENÇAR A LLEGIR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarTags() async {
    if (_tagsSeleccionats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona almenys un interès')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final userAuth = FirebaseAuth.instance.currentUser;

    try {
      if (userAuth != null) {
        // 1. ACTUALIZAR EN FIREBASE
        // Usamos set con merge: true para asegurar que escriba en el documento
        // que ya existe sin borrar el nombre/email/foto.
        await FirebaseFirestore.instance
            .collection('usuaris')
            .doc(userAuth.uid)
            .set({'interessos': _tagsSeleccionats}, SetOptions(merge: true));

        // 2. ACTUALIZAR EN TU LISTA LOCAL (InternalLists.dart)
        // Buscamos al usuario que ya existe en la lista global
        try {
          // Buscamos la referencia exacta del usuario en tu llistaUsuarisGlobal
          final usuariLocal = llistaUsuarisGlobal.firstWhere(
            (u) => u.id == userAuth.uid,
          );

          // Actualizamos sus tags directamente en la memoria
          usuariLocal.tags = List.from(_tagsSeleccionats);
        } catch (e) {
          // Si por alguna razón no estuviera en la lista, lo añadimos ahora
          final doc = await FirebaseFirestore.instance
              .collection('usuaris')
              .doc(userAuth.uid)
              .get();
          if (doc.exists) {
            llistaUsuarisGlobal.add(Usuari.fromJson(doc.data()!));
          }
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          );
        }
      }
    } catch (e) {
      print("Error guardant tags: $e");
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }
}
