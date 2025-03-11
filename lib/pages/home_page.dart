import 'package:flutter/material.dart';
import 'package:flutter_pulpoapp/pages/products_page.dart';
import 'package:flutter_pulpoapp/widgets/drawer.dart';
import 'package:flutter_pulpoapp/pages/inventory_page.dart';
import 'package:flutter_pulpoapp/pages/proveedores_page.dart';
import 'package:flutter_pulpoapp/pages/out_of_stock_page.dart';
import 'package:flutter_pulpoapp/pages/scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9B7A5), // Color del encabezado
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "PULPO APP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/logo.png', // Asegúrate de colocar el logo en assets
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(), // Menú lateral
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Botones organizados en un Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _HomeButton(
                    icon: Icons.inventory,
                    text: "Inventario",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InventoryPage()),
                    ),
                  ),
                  _HomeButton(
                    icon: Icons.business,
                    text: "Proveedor",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProvidersPage()),
                    ),
                  ),
                  _HomeButton(
                    icon: Icons.warning,
                    text: "Sin stock",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OutOfStockPage()),
                    ),
                  ),
                  _HomeButton(
                    icon: Icons.qr_code_scanner,
                    text: "Scanner",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de botón reutilizable con navegación
class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _HomeButton(
      {required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange[300],
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap, // Ahora cada botón tiene su propia acción de navegación
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}
