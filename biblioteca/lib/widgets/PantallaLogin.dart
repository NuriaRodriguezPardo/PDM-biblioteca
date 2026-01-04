import 'package:flutter/material.dart';
import 'PantallaRegistrarse.dart';
import 'PantallaPrincipal.dart';
import '/usuarios/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Lógica de inicio de sesión con Firebase (Correo)
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Llamamos a la función de auth.dart
        await signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _isLoading = true);
    try {
      User? user =
          await signInWithGoogle(); // Llamada a la función de auth.dart

      print("Usuario recibido: $user");

      // Si el login es exitoso y el widget sigue activo
      if (user != null && mounted) {
        // Navegar a la pantalla principal
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              const SizedBox(height: 40),
              _buildHeader(colorScheme),
              const SizedBox(height: 40),
              _buildLoginForm(colorScheme),
              const SizedBox(height: 24),
              _buildLoginButton(colorScheme),
              const SizedBox(height: 16),

              // Divisor visual para login social
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "O",
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              _buildGoogleButton(colorScheme),

              const SizedBox(height: 40),
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
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            // Si el logo tiene fondo transparente, puedes mantener o quitar el color:
            // color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              15,
            ), // Para que la imagen respete las esquinas redondeadas
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit
                  .contain, // 'contain' asegura que el logo se vea entero sin recortarse
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Benvingut/da!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sessió per continuar',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correu electrònic',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: colorScheme.secondary,
              ),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Introdueix el correu'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contrasenya',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colorScheme.secondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Introdueix la contrasenya'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Iniciar sessió',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildGoogleButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _loginGoogle,
        icon: const Icon(
          Icons.g_mobiledata,
          size: 30,
        ), // Puedes usar un logo de Google Asset aquí
        label: const Text(
          "Continua amb Google",
          style: TextStyle(fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.5)),
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
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantallaRegistrarse(),
            ),
          ),
          child: Text(
            'Registra\'t',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
