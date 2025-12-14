// [PantallaRegistrarse.dart] - Disseny actualitzat i corregit
import 'package:flutter/material.dart';

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
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Llista de gèneres disponibles per als tags
  final List<String> _availableGenres = [
    'Fantasia',
    'Ciència-ficció',
    'Clàssics',
    'Thriller',
    'Romanç',
    'Històric',
    'Terror',
    'Aventura',
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
        // Opcional: lògica si no hi ha gèneres
      }

      setState(() => _isLoading = true);

      // Simular delay de registre
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // Torna a la pantalla de login un cop registrat
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registre exitós! Ja pots iniciar sessió.'),
          ),
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
            // CORREGIDO: withValues
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person_add_alt_1_outlined,
            size: 35,
            // CORREGIDO: withValues
            color: colorScheme.secondary.withValues(alpha: 0.8),
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
            // CORREGIDO: withValues
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              // CORREGIDO: withValues
              prefixIcon: Icon(
                Icons.person_outline,
                color: colorScheme.secondary.withValues(alpha: 0.8),
              ),
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
              // CORREGIDO: withValues
              prefixIcon: Icon(
                Icons.email_outlined,
                color: colorScheme.secondary.withValues(alpha: 0.8),
              ),
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
              // CORREGIDO: withValues
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colorScheme.secondary.withValues(alpha: 0.8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  // CORREGIDO: withValues
                  color: colorScheme.secondary.withValues(alpha: 0.8),
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
              // CORREGIDO: withValues
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colorScheme.secondary.withValues(alpha: 0.8),
              ),
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        // CORREGIDO: withValues
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 20,
                color: colorScheme.primary,
              ),
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
              // CORREGIDO: withValues
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: _availableGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                // CORREGIDO: withValues
                selectedColor: colorScheme.primary.withValues(alpha: 0.1),
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  fontSize: 15,
                  // CORREGIDO: withValues
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: isSelected
                    ? Icon(Icons.check, size: 16, color: colorScheme.primary)
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
                  // CORREGIDO: withValues
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
