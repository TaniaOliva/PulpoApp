import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsPage extends StatelessWidget {
  final String providerName;

  const ProductsPage({Key? key, required this.providerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Productos de $providerName"),
        backgroundColor: const Color(0xFFD9A7A0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('productos')
              .where('supplier', isEqualTo: providerName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var products = snapshot.data!.docs;

            if (products.isEmpty) {
              return const Center(
                child: Text("No hay productos de este proveedor",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              );
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return Card(
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(product['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("Cantidad: ${product['quantity']}"),
                    leading: const Icon(Icons.shopping_bag, color: Colors.teal),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
