// [PantallaLogin.dart] - Colors i estils actualitzats
import 'package:flutter/material.dart';

import 'AppBiblio.dart'; // Importem per utilitzar els colors estàtics si cal
import 'PantallaRegistrarse.dart';
import 'PantallaPrincipal.dart'; 

class PantallaLogin extends StatefulWidget {
  static const String route = '/login';

  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, PantallaPrincipal.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildHeader(colorScheme),
              const SizedBox(height: 40),
              _buildLoginForm(colorScheme),
              const SizedBox(height: 24),
              _buildLoginButton(colorScheme),
              const SizedBox(height: 16),
              _buildForgotPassword(colorScheme),
              const SizedBox(height: 60),
              _buildRegisterLink(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        // Icona central amb color secundari (Blau-verd)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.book_outlined,
            size: 40,
            color: colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Benvingut/da!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // Text Fosc
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sessió per continuar',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme colorScheme) {
    // Els camps de text ja utilitzen el tema definit a AppBiblio, només cal especificar les icones
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Correu electrònic
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correu electrònic',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: colorScheme.secondary.withOpacity(0.8), // Blau-verd
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Si us plau, introdueix el correu';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Contrasenya
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contrasenya',
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colorScheme.secondary.withOpacity(0.8), // Blau-verd
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colorScheme.secondary.withOpacity(0.8), // Blau-verd
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Si us plau, introdueix la contrasenya';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme) {
    // El botó utilitza l'estil global d'ElevatedButton (Marró Suau)
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
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
                'Iniciar sessió',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPassword(ColorScheme colorScheme) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalitat de recuperació')),
        );
      },
      child: Text(
        'Has oblidat la contrasenya?',
        style: TextStyle(
          color: colorScheme.secondary, // Blau-verd
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No tens compte? ',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        GestureDetector(
          onTap: () {
            // Navegació a la pantalla de Registre
            Navigator.pushNamed(context, PantallaRegistrarse.route);
          },
          child: Text(
            'Registra\'t',
            style: TextStyle(
              color: colorScheme.primary, // Marró Suau
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}