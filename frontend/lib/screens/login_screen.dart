import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_city, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("Civic Works", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 16),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña")),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Provider.of<AuthService>(context, listen: false).login(emailCtrl.text, passCtrl.text),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Text("INGRESAR"),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Crear Cuenta (Ciudadano o Empresa)"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
