import 'package:flutter/material.dart';
import '../clases/usuari.dart';
import '../clases/carregaDeHistorial.dart';

class PantallaEditarPerfil extends StatefulWidget {
  final Usuari usuari;

  const PantallaEditarPerfil({super.key, required this.usuari});

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  // Controladors per als camps de text
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _imatgeUrlController;
  late TextEditingController _nouTagController;

  // Llista local de tags per editar
  List<String> _tagsActuals = [];

  @override
  void initState() {
    super.initState();
    // Inicialitzem els controladors amb les dades actuals
    _nomController = TextEditingController(text: widget.usuari.nom);

    // Dades simulades (ja que la classe Usuari no té email/pass/foto)
    _emailController = TextEditingController(text: "usuari@exemple.com");
    _passwordController = TextEditingController(text: "12345678");
    _imatgeUrlController = TextEditingController(text: "");
    _nouTagController = TextEditingController();

    // Copiem els tags actuals per poder modificar-los localment
    _tagsActuals = List.from(widget.usuari.tags);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _imatgeUrlController.dispose();
    _nouTagController.dispose();
    super.dispose();
  }

  // Funció per guardar els canvis
  void _guardarCanvis() {
    // 1. Validació bàsica
    if (_nomController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nom no pot estar buit')));
      return;
    }

    // 2. Actualització de dades
    // NOTA: Com que 'nom' és final a la classe Usuari, aquí no el podem canviar directament
    // sobre l'objecte 'widget.usuari' sense crear una nova instància.
    // Tanmateix, les llistes com 'tags' sí que les podem modificar si no són const.

    setState(() {
      widget.usuari.nom = _nomController.text;
      widget.usuari.fotoUrl = _imatgeUrlController.text.isNotEmpty
          ? _imatgeUrlController.text
          : null;
      //widget.usuari.tags.clear();
      widget.usuari.tags.addAll(_tagsActuals);
    });

    // 3. Feedback i tornar enrere
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualitzat correctament (Simulat)'),
        backgroundColor: Colors.green,
      ),
    );

    registrarActivitat(
      "Perfil Actualizado",
      "Has modificado tus datos personales.",
      Icons.person_outline,
    );

    // Tornem a la pantalla anterior
    Navigator.pop(context);
  }

  // Funció per afegir un tag
  void _afegirTag() {
    final text = _nouTagController.text.trim();
    if (text.isNotEmpty && !_tagsActuals.contains(text)) {
      setState(() {
        _tagsActuals.add(text);
        _nouTagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCanvis,
            tooltip: 'Guardar canvis',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓ FOTO DE PERFIL ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: _imatgeUrlController.text.isNotEmpty
                        ? NetworkImage(_imatgeUrlController.text)
                        : null,
                    child: _imatgeUrlController.text.isEmpty
                        ? Text(
                            widget.usuari.nom.isNotEmpty
                                ? widget.usuari.nom[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        onPressed: () {
                          // Lògica per canviar foto (obrir diàleg URL o galeria)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funció de canviar foto no implementada',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- CAMPS DE TEXT ---
            const Text(
              "Informació Personal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Nom
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'usuari',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // URL Imatge (Simulat per provar la foto)
            TextField(
              controller: _imatgeUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de la foto (opcional)',
                prefixIcon: Icon(Icons.image),
                border: OutlineInputBorder(),
                helperText: "Enganxa una URL per provar l'avatar",
              ),
              onChanged: (val) => setState(() {}), // Per refrescar l'avatar
            ),
            const SizedBox(height: 15),

            // Correu (Simulat)
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correu electrònic',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Contrasenya (Simulat)
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contrasenya',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            const SizedBox(height: 30),

            // --- SECCIÓ INTERESSOS (TAGS) ---
            const Text(
              "Els teus interessos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Input per afegir tags
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nouTagController,
                    decoration: const InputDecoration(
                      hintText: 'Afegir nou interès (ex: Thriller)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _afegirTag(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _afegirTag,
                  icon: const Icon(Icons.add_circle, size: 32),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Llista de Chips (Tags)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _tagsActuals.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _tagsActuals.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // Botó Guardar Gran
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarCanvis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'GUARDAR CANVIS',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
