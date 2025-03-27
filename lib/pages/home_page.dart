import 'package:flutter/material.dart';
import 'package:flutter_pulpoapp/widgets/drawer.dart';
import 'package:flutter_pulpoapp/pages/inventory_page.dart';
import 'package:flutter_pulpoapp/pages/proveedores_page.dart';
import 'package:flutter_pulpoapp/pages/out_of_stock_page.dart';
import 'package:flutter_pulpoapp/pages/scanner_page.dart';
import 'package:flutter_pulpoapp/pages/popular_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9A7A0),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "PULPO APP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Positioned(
            left: 15,
            top: 50,
            child: _HomeButton(
              icon: Icons.inventory,
              text: "Inventario",
              color: Colors.blue,
              width: 180,
              height: 130,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryPage()),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 50,
            child: _HomeButton(
              icon: Icons.business,
              text: "Proveedor",
              color: Colors.orange,
              width: 140,
              height: 220,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProvidersPage()),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 200,
            child: _HomeButton(
              icon: Icons.warning,
              text: "Sin stock",
              color: Colors.red,
              width: 180,
              height: 230,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OutOfStockPage()),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 285,
            child: _HomeButton(
              icon: Icons.qr_code_scanner,
              text: "Scanner",
              color: Colors.purple,
              width: 135,
              height: 145,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScannerPage()),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 100,
            child: _HomeButton(
              icon: Icons.star,
              text: "Populares",
              color: Colors.green,
              width: 300,
              height: 120,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PopularesPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _HomeButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(2, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
