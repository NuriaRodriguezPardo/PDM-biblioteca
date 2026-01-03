/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PantallaPrincipal.dart';

class PantallaRegistrarse extends StatefulWidget {
  const PantallaRegistrarse({super.key});

  @override
  State<PantallaRegistrarse> createState() => _PantallaRegistrarseState();
}

class _PantallaRegistrarseState extends State<PantallaRegistrarse> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _tagsDisponibles = [
    'Ficció',
    'Aventura',
    'Drama',
    'Romance',
    'Ciència Ficció',
    'Històrica',
    'Thriller',
    'Fantasia',
    'Misteri',
    'Biografia',
  ];

  final List<String> _tagsSeleccionats = [];

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registre() async {
    // 1. Validar el formulario y que haya al menos un interés
    if (!_formKey.currentState!.validate()) return;

    if (_tagsSeleccionats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona almenys un interès')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Crear el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final String uid = userCredential.user!.uid;

      // 3. Guardar el nombre en el perfil de Auth
      await userCredential.user!.updateDisplayName(_nomController.text.trim());

      // 4. Crear el documento en la colección 'usuaris' de Firestore
      // [Image of Cloud Firestore document structure with nested lists for user profiles]
      await FirebaseFirestore.instance.collection('usuaris').doc(uid).set({
        'uid': uid,
        'nom': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'interessos': _tagsSeleccionats, // Guardamos los tags seleccionados
        'fotoUrl': null,
        'pendents': [], // Inicializamos las listas necesarias para tu app
        'llegits': [],
        'reserves': [],
        'seguidors': [],
        'amics': [],
        'dataRegistre': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte creat correctament!'),
            backgroundColor: Colors.green,
          ),
        );

        // 5. Ir a la pantalla principal limpiando el historial
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error en el registre';
      if (e.code == 'email-already-in-use')
        mensaje = 'Aquest correu ja està en ús';
      if (e.code == 'weak-password') mensaje = 'La contrasenya és massa feble';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Uneix-te a la nostra biblioteca',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Introdueix el teu nom' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correu electrònic',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email no vàlid' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contrasenya',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Mínim 6 caràcters' : null,
              ),

              const SizedBox(height: 30),
              const Text(
                'Què t\'agrada llegir? (Interessos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children: _tagsDisponibles.map((tag) {
                  final isSelected = _tagsSeleccionats.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: colorScheme.secondary.withValues(alpha: 0.3),
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
                }).toList(),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTRAR-ME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
import 'package:flutter/material.dart';
import 'PantallaPrincipal.dart';
import '../usuarios/auth.dart'; // Importamos el archivo de lógica

class PantallaRegistrarse extends StatefulWidget {
  const PantallaRegistrarse({super.key});

  @override
  State<PantallaRegistrarse> createState() => _PantallaRegistrarseState();
}

class _PantallaRegistrarseState extends State<PantallaRegistrarse> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

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

  Future<void> _registre() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tagsSeleccionats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona almenys un interès')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Llamamos a la función signUp unificada de auth.dart
      await signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nomController.text.trim(),
        _tagsSeleccionats,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Uneix-te a la nostra biblioteca',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Introdueix el teu nom' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correu electrònic',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email no vàlid' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contrasenya',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => v!.length < 6 ? 'Mínim 6 caràcters' : null,
              ),

              const SizedBox(height: 30),
              const Text(
                'Què t\'agrada llegir? (Interessos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children: _tagsDisponibles.map((tag) {
                  final isSelected = _tagsSeleccionats.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: colorScheme.secondary.withValues(alpha: 0.3),
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
                }).toList(),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTRAR-ME',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
