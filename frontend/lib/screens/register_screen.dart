import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/location_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email='', pass='', name='', addr='';
  bool isCompany = false;
  
  String selectedCountry = "Argentina";
  String? selectedProv;
  String? selectedLoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SwitchListTile(
              title: const Text("¿Registrarse como Empresa?"),
              subtitle: const Text("Para ejecutar obras propuestas"),
              value: isCompany,
              onChanged: (v) => setState(() => isCompany = v),
            ),
            const Divider(),
            TextFormField(decoration: InputDecoration(labelText: isCompany ? "Nombre de la Empresa" : "Nombre Completo"), onSaved: (v) => name=v!),
            const SizedBox(height: 10),
            TextFormField(decoration: const InputDecoration(labelText: "Email"), onSaved: (v) => email=v!),
            const SizedBox(height: 10),
            TextFormField(decoration: const InputDecoration(labelText: "Contraseña"), obscureText:true, onSaved: (v) => pass=v!),
            const SizedBox(height: 20),
            const Text("Ubicación Principal", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              decoration: const InputDecoration(labelText: "País"),
              items: LocationData.countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() { selectedCountry = v!; selectedProv = null; selectedLoc = null; }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedProv,
              decoration: const InputDecoration(labelText: "Provincia"),
              items: (LocationData.provinces[selectedCountry] ?? []).map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() { selectedProv = v; selectedLoc = null; }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedLoc,
              decoration: const InputDecoration(labelText: "Localidad"),
              items: (selectedProv != null ? (LocationData.localities[selectedProv] ?? []) : []).map((l) => DropdownMenuItem<String>(value: l, child: Text(l))).toList().cast<DropdownMenuItem<String>>(),
              onChanged: (v) => setState(() => selectedLoc = v),
            ),
            const SizedBox(height: 10),
            TextFormField(decoration: const InputDecoration(labelText: "Domicilio (Calle y Altura)"), onSaved: (v) => addr=v!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate() && selectedLoc != null){
                  _formKey.currentState!.save();
                  final data = {
                      'email': email, 'password': pass, 'fullName': name,
                      'country': selectedCountry, 'province': selectedProv, 'locality': selectedLoc, 'address': addr,
                      'role': isCompany ? 'COMPANY' : 'CITIZEN'
                  };
                  bool ok = await Provider.of<AuthService>(context, listen: false).register(data);
                  if(ok && mounted) Navigator.pop(context);
                }
              },
              child: const Text("REGISTRARSE"),
            )
          ],
        ),
      ),
    );
  }
}
