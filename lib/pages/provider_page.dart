import 'package:flutter/material.dart';

class ProviderPage extends StatelessWidget {
  const ProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario")),
      body: const Center(child: Text("Aquí va el inventario")),
    );
  }
}
