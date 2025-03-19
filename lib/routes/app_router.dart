import 'package:flutter/material.dart';
import 'package:flutter_pulpoapp/pages/edit_product_page.dart';
import 'package:flutter_pulpoapp/pages/home_page.dart';
import 'package:flutter_pulpoapp/pages/inventory_page.dart';
import 'package:flutter_pulpoapp/pages/login_page.dart';
import 'package:flutter_pulpoapp/pages/out_of_stock_page.dart';
import 'package:flutter_pulpoapp/pages/register_page.dart';
import 'package:flutter_pulpoapp/pages/products_page.dart';

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
        return MaterialPageRoute(builder: (_) => InventoryPage());
      case '/out_of_stock':
        return MaterialPageRoute(builder: (_) => const OutOfStockPage());
      case '/products':
        return MaterialPageRoute(
          builder: (context) =>
              ProductsPage(providerName: settings.arguments as String),
        );
      case '/edit_product':
        return MaterialPageRoute(
          builder: (context) =>
              EditProductPage(productId: settings.arguments as String),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Página no encontrada')),
          ),
        );
    }
  }
}
