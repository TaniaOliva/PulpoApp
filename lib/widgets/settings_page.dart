import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userEmail = user.email ?? "";
        userName = userDoc["username"] ?? "Usuario";
      });
    }
  }

  void _changeUserName() {
    TextEditingController nameController =
        TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar nombre de usuario"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nuevo nombre"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = _auth.currentUser;
              if (user != null) {
                await _firestore.collection('users').doc(user.uid).update({
                  "username": nameController.text,
                });
                setState(() {
                  userName = nameController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar contraseña"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Nueva contraseña"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = _auth.currentUser;
              if (user != null) {
                await user.updatePassword(passwordController.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reportar un error"),
        content: const Text(
            "Para reportar un error, enviar correo a Taniaoliva1214@gmail.com"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(Map<Permission, PermissionStatus> statuses) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permisos de la app"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.entries.map((entry) {
              return ListTile(
                title: Text(entry.key.toString().split(".").last),
                subtitle:
                    Text(entry.value.isGranted ? "Concedido" : "Denegado"),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.notification,
    ].request();

    _showPermissionDialog(statuses);
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(userName, style: const TextStyle(fontSize: 18)),
              subtitle: Text(userEmail),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Cambiar nombre de usuario"),
              onTap: _changeUserName,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Cambiar contraseña"),
              onTap: _changePassword,
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Permisos de la app"),
              onTap: _checkPermissions,
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text("Reportar un error"),
              onTap: _reportIssue,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Cerrar sesión",
                  style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
