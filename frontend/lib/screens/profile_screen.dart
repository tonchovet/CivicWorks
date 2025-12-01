import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _expanded = false;
  List<User> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeam();
    });
  }

  void _loadTeam() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if(auth.currentUser?.isCompany == true) {
      final members = await auth.getTeamMembers();
      setState(() => _teamMembers = members);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: user == null ? const SizedBox() : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, child: Icon(user.isCompany ? Icons.business : Icons.person, size: 50)),
            const SizedBox(height: 10),
            Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.isCompany ? "EMPRESA REGISTRADA" : "CIUDADANO", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            
            if(user.isCompany)
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Card(
                   color: Colors.green.shade50,
                   child: ListTile(
                     leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
                     title: Text("\$ ${user.wallet.toStringAsFixed(2)}"),
                     subtitle: const Text("Saldo en Billetera"),
                   ),
                 ),
               ),

            const Divider(),
            ListTile(title: const Text("Ubicación"), subtitle: Text("${user.locality}, ${user.province}, ${user.country}")),
            ListTile(title: const Text("Domicilio"), subtitle: Text(user.address)),
            
            if(user.isCompany) ...[
               const Divider(),
               ExpansionTile(
                 title: const Text("Gestión de Equipo"),
                 subtitle: Text("${_teamMembers.length} empleados registrados"),
                 leading: const Icon(Icons.group),
                 children: [
                    ..._teamMembers.map((m) => ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person, size: 16)),
                      title: Text(m.fullName),
                      subtitle: Text(m.email),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Empleado"),
                        onPressed: () => _showAddTeamDialog(context),
                      ),
                    )
                 ],
               ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(onPressed: auth.logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("SALIR"))
          ],
        ),
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Agregar Miembro"),
        content: SizedBox(
          width: double.maxFinite,
          child: Autocomplete<User>(
            displayStringForOption: (User option) => option.email,
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text == '') {
                return const Iterable<User>.empty();
              }
              final auth = Provider.of<AuthService>(context, listen: false);
              return await auth.searchUsers(textEditingValue.text);
            },
            onSelected: (User selection) async {
               String msg = await Provider.of<AuthService>(context, listen: false).addTeamMember(selection.email);
               Navigator.pop(ctx);
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
               _loadTeam();
            },
            fieldViewBuilder: (ctx, textCtrl, focusNode, onFieldSubmitted) {
              return TextField(
                 controller: textCtrl,
                 focusNode: focusNode,
                 decoration: const InputDecoration(
                   labelText: "Buscar por Email",
                   hintText: "Escribe para buscar..."
                 ),
              );
            },
          ),
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR"))
        ],
      )
    );
  }
}
