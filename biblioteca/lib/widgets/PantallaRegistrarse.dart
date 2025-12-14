// [PantallaRegistrarse.dart] - Disseny actualitzat segons la imatge de "Crear compte"
import 'package:flutter/material.dart';

import 'AppBiblio.dart';

class PantallaRegistrarse extends StatefulWidget {
  static const String route = '/registrarse';

  const PantallaRegistrarse({super.key});

  @override
  State<PantallaRegistrarse> createState() => _PantallaRegistrarseState();
}

class _PantallaRegistrarseState extends State<PantallaRegistrarse> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false; // Nou camp
  bool _isLoading = false;

  // Llista de gèneres disponibles per als tags
  final List<String> _availableGenres = [
    'Fantasia', 'Ciència-ficció', 'Clàssics', 
    'Thriller', 'Romanç', 'Històric', 
    'Terror', 'Aventura',
  ];
  // Conjunt per emmagatzemar els gèneres seleccionats
  final Set<String> _selectedGenres = {}; 

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      if (_selectedGenres.isEmpty) {
        // Opcional: Mostrar advertència si no es selecciona cap gènere (malgrat que la imatge diu "opcional")
        // No obstant, seguirem la indicació de la imatge i només validarem la resta.
      }

      setState(() => _isLoading = true);
      
      // Simular delay de registre
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      
      // Torna a la pantalla de login un cop registrat
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registre exitós! Ja pots iniciar sessió.')),
        );
      }
    } else if (!_acceptTerms) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Has d\'acceptar els termes i condicions.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(colorScheme),
              const SizedBox(height: 30),
              // Formulari de Registre
              _buildRegisterForm(colorScheme),
              const SizedBox(height: 30),
              // Secció de Gèneres
              _buildGenreSelection(colorScheme),
              const SizedBox(height: 30),
              // Acceptar Termes
              _buildTermsAndConditions(colorScheme),
              const SizedBox(height: 30),
              // Botó de Registre
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Capçalera adaptada a la imatge
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        // Icona de Creació de Compte
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1), // Blau-verd molt clar
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person_add_alt_1_outlined,
            size: 35,
            color: colorScheme.secondary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Uneix-te a la comunitat!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary, // Marró Suau per al títol
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea el teu compte per descobrir nous llibres',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 1. Nom complet
          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: 'Nom complet',
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.person_outline, color: colorScheme.secondary.withOpacity(0.8)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Si us plau, introdueix el teu nom complet';
              }
              return null;
            },
          ),
          const SizedBox(height: 13),

          // 2. Correu electrònic
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Correu electrònic',
              labelText: 'Correu electrònic',
              prefixIcon: Icon(Icons.email_outlined, color: colorScheme.secondary.withOpacity(0.8)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Si us plau, introdueix un correu vàlid';
              }
              return null;
            },
          ),
          const SizedBox(height: 13),
          
          // 3. Contrasenya
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Contrasenya',
              labelText: 'Contrasenya',
              prefixIcon: Icon(Icons.lock_outline, color: colorScheme.secondary.withOpacity(0.8)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colorScheme.secondary.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'La contrasenya ha de tenir almenys 6 caràcters';
              }
              return null;
            },
          ),
          const SizedBox(height: 13),

          // 4. Confirmar Contrasenya
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Confirmar contrasenya',
              labelText: 'Confirmar contrasenya',
              prefixIcon: Icon(Icons.lock_outline, color: colorScheme.secondary.withOpacity(0.8)),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les contrasenyes no coincideixen';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Secció de Selecció de Gèneres
  Widget _buildGenreSelection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // Fons clar
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark_outline, size: 20, color: colorScheme.primary), // Icona de marcador
              const SizedBox(width: 8),
              Text(
                'Quins gèneres t\'interessen?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona almenys 1 gènere (opcional)',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          // [PantallaRegistrarse.dart] - Fragment de _buildGenreSelection() actualitzat

  // ... (Abans del Wrap)

          const SizedBox(height: 12),
          Wrap(
            spacing: 4.0, 
            runSpacing: 4.0, 
            children: _availableGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                // REDUIR EL FARCIMENT PER AJUNTAR ELS CHIPS HORITZONTALMENT
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), 
                selectedColor: colorScheme.primary.withOpacity(0.1),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : Colors.grey.shade300,
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  // REDUIR LA MIDA DE LLETRA
                  fontSize: 15, // Mida més petita
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: isSelected 
                    ? Icon(Icons.check, size: 16, color: colorScheme.primary) // Icona de verificació també més petita
                    : null,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  // Secció d'Acceptació de Termes
  Widget _buildTermsAndConditions(ColorScheme colorScheme) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (bool? newValue) {
            setState(() {
              _acceptTerms = newValue ?? false;
            });
          },
          activeColor: colorScheme.primary, // Marró Suau
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptTerms = !_acceptTerms);
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Accepto els '),
                  TextSpan(
                    text: 'termes i condicions ',
                    style: TextStyle(
                      color: colorScheme.secondary, // Blau-verd
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: 'i la '),
                  TextSpan(
                    text: 'política de privacitat',
                    style: TextStyle(
                      color: colorScheme.secondary, // Blau-verd
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Botó de Registre
  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Crear compte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}