import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  // Datos de ejemplo
  String _userName = "Usuario Ejemplo";
  String _userEmail = "usuario@example.com";

  String get userName => _userName;
  String get userEmail => _userEmail;

  // Aquí en el futuro se conectará Firebase
  void loadUserData() {
    // Simulación de carga de datos de Firebase
    _userName = "Nombre Firebase";
    _userEmail = "correo@firebase.com";
    notifyListeners();
  }
}
