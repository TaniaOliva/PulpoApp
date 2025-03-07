import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo (luego se reemplazan con datos de Firebase)
    const String userName = "Usuario Ejemplo";
    const String userEmail = "usuario@ejemplo.com";

    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal, // Color de fondo
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            accountName: Text(userName, style: TextStyle(fontSize: 18)),
            accountEmail: Text(userEmail),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Cambiar contraseña"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Cerrar sesión",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              // Aquí irá la lógica de cierre de sesión con Firebase
            },
          ),
        ],
      ),
    );
  }
}
