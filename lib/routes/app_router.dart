import 'package:flutter/material.dart';
import 'package:flutter_pulpoapp/pages/home_page.dart';
import 'package:flutter_pulpoapp/pages/inventory_page.dart';
import 'package:flutter_pulpoapp/pages/login_page.dart';
import 'package:flutter_pulpoapp/pages/register_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/inventory':
        return MaterialPageRoute(builder: (_) => const InventoryPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Página no encontrada')),
          ),
        );
    }
  }
}
