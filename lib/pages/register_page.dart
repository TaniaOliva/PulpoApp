import 'package:flutter/material.dart';
import 'package:flutter_pulpoapp/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    AuthProvider auth = AuthProvider();
    var user =
        await auth.register(_emailController.text, _passwordController.text);
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error en el registro")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 217, 217, 218), // Fondo gris claro
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de usuario
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            // Título
            const Text(
              "Registro",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Campo de correo
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            // Campo de contraseña
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Contraseña",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            // Confirmar contraseña
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscurePassword,
              decoration:
                  const InputDecoration(labelText: "Repetir Contraseña"),
            ),
            const SizedBox(height: 20),
            // Botón de registro
            ElevatedButton(
              onPressed: _register,
              child: const Text("Registrar"),
            ),
            // Opción para ir a iniciar sesión
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
