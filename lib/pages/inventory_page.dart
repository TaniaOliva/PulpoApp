import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pulpoapp/pages/add_product_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  void _updateQuantity(String productId, String productName, int change) {
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('productos')
        .doc(productId);

    docRef.get().then((doc) {
      if (doc.exists) {
        int currentQuantity = doc['quantity'] ?? 0;
        int newQuantity =
            (currentQuantity + change).clamp(0, double.infinity).toInt();
        docRef.update({'quantity': newQuantity});

        _firestore
            .collection('users')
            .doc(_userId)
            .collection('actividad_productos')
            .add({
          'productId': productId,
          'name': productName,
          'change': change,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  void _deleteProduct(String productId) {
    _firestore
        .collection('users')
        .doc(_userId)
        .collection('productos')
        .doc(productId)
        .delete();
  }

  void _confirmDelete(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text("¿Estás seguro de que quieres eliminar '$productName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _deleteProduct(productId);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 241, 234),
      appBar: AppBar(
        title: const Text("Inventario",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD9A7A0),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo.png', height: 40),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar producto...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filtrar por categoría",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _userId == null
                    ? const CircularProgressIndicator()
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(_userId)
                            .collection('productos')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Cargando...");
                          }

                          var products = snapshot.data!.docs;
                          var categories = <String>{'Todas'};

                          for (var doc in products) {
                            String category =
                                doc['category'] ?? 'Sin categoría';
                            categories.add(category);
                          }

                          return DropdownButton<String>(
                            value: _selectedCategory,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                            items: categories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        },
                      ),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: _userId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(_userId)
                          .collection('productos')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var products = snapshot.data!.docs.where((doc) {
                          String category = doc['category'] ?? 'Sin categoría';
                          String name = doc['name']?.toLowerCase() ?? '';
                          bool matchesCategory = _selectedCategory == 'Todas' ||
                              category == _selectedCategory;
                          bool matchesSearch = name.contains(_searchQuery);
                          return matchesCategory && matchesSearch;
                        }).toList();

                        return ListView(
                          children: products.map((doc) {
                            String id = doc.id;
                            String name = doc['name'] ?? 'Sin nombre';
                            String price = doc['price']?.toString() ?? '0';
                            int quantity = doc['quantity'] ?? 0;

                            return GestureDetector(
                              onLongPress: () => _confirmDelete(id, name),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${price} Lps",
                                                style: const TextStyle(
                                                    fontSize: 17)),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: () =>
                                                      _updateQuantity(
                                                          id, name, -1),
                                                ),
                                                Text(quantity.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16)),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () =>
                                                      _updateQuantity(
                                                          id, name, 1),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/edit_product',
                                                    arguments: id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
