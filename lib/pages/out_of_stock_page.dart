import 'package:flutter/material.dart';

class OutOfStockPage extends StatelessWidget {
  const OutOfStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario")),
      body: const Center(child: Text("Aquí va el inventario")),
    );
  }
}
