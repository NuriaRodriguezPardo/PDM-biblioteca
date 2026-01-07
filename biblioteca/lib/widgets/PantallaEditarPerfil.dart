import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/usuari.dart';
import '../clases/carregaDeHistorial.dart';

class PantallaEditarPerfil extends StatefulWidget {
  final Usuari usuari;
  const PantallaEditarPerfil({super.key, required this.usuari});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  late TextEditingController _nomController;
  late TextEditingController _imatgeUrlController; // Controlador para la URL
  String _busquedaTags = "";
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.usuari.nom);
    _imatgeUrlController = TextEditingController(
      text: widget.usuari.fotoUrl ?? "",
    );
    // Inicializamos los tags seleccionados con los del usuario
    _tagsSeleccionats.addAll(widget.usuari.tags);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _imatgeUrlController.dispose();
    //_nouTagController.dispose();
    super.dispose();
  }

  Future<void> _guardarCanvis() async {
    if (_nomController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nom no pot estar buit')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No s'ha trobat l'usuari");

      final List<String> tagsAGuardar = List<String>.from(_tagsSeleccionats);

      // Guardamos en Firestore
      await FirebaseFirestore.instance.collection('usuaris').doc(user.uid).set({
        'nom': _nomController.text.trim(),
        'fotoUrl': _imatgeUrlController.text
            .trim(), // Guardamos la URL del campo de texto
        'interessos': tagsAGuardar,
      }, SetOptions(merge: true));

      // Actualizamos también el perfil de Auth para consistencia
      await user.updateDisplayName(_nomController.text.trim());
      if (_imatgeUrlController.text.isNotEmpty) {
        await user.updatePhotoURL(_imatgeUrlController.text.trim());
      }

      widget.usuari.nom = _nomController.text.trim();
      widget.usuari.fotoUrl = _imatgeUrlController.text.trim();
      widget.usuari.tags = tagsAGuardar;

      registrarActivitat(
        "Perfil Actualitzat",
        "Canvis desats amb èxit.",
        Icons.person,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil guardat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          if (!_isSaving)
            IconButton(icon: const Icon(Icons.save), onPressed: _guardarCanvis),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Previsualización de la imagen basada en la URL del controlador
                  Center(
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: _imatgeUrlController.text.isNotEmpty
                          ? NetworkImage(_imatgeUrlController.text)
                          : null,
                      child: _imatgeUrlController.text.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Campo para el Nombre
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom d\'usuari',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Campo para la URL de la imagen
                  TextField(
                    controller: _imatgeUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la imatge de perfil',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                      hintText: 'https://ejemplo.com/foto.jpg',
                    ),
                    onChanged: (value) {
                      // Refrescamos la UI para mostrar la nueva imagen mientras se escribe
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Els teus interessos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Els teus interessos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // BUSCADOR
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Cerca interessos...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (val) =>
                              setState(() => _busquedaTags = val),
                        ),
                        const SizedBox(height: 10),
                        // CONTENEDOR CON SCROLL
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: Wrap(
                              spacing: 8.0,
                              children: _tagsDisponibles
                                  .where(
                                    (tag) => tag.toLowerCase().contains(
                                      _busquedaTags.toLowerCase(),
                                    ),
                                  )
                                  .map((tag) {
                                    final isSelected = _tagsSeleccionats
                                        .contains(tag);
                                    return FilterChip(
                                      label: Text(tag),
                                      selected: isSelected,
                                      selectedColor: colorScheme.secondary
                                          .withValues(alpha: 0.3),
                                      checkmarkColor: colorScheme.secondary,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          if (selected) {
                                            _tagsSeleccionats.add(tag);
                                          } else {
                                            _tagsSeleccionats.remove(tag);
                                          }
                                        });
                                      },
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
