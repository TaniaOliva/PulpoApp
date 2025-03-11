import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsPage extends StatelessWidget {
  final String providerName;

  const ProductsPage({Key? key, required this.providerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Productos de $providerName")),
      body: Center(
          child: Text("Aquí se mostrarán los productos de $providerName")),
    );
  }
}
