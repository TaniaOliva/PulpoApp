import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_pulpoapp/widgets/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<Map<String, String>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return {
        'name': userData['username'] ?? 'Usuario',
        'email': user.email ?? 'Sin correo',
      };
    }
    return {'name': 'Usuario desconocido', 'email': 'Sin correo'};
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          String userName = snapshot.data?['name'] ?? 'Cargando...';
          String userEmail = snapshot.data?['email'] ?? 'Cargando...';

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.teal),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                accountName:
                    Text(userName, style: const TextStyle(fontSize: 18)),
                accountEmail: Text(userEmail),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Configuración"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text("Cerrar sesión",
                    style: TextStyle(color: Colors.red)),
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
