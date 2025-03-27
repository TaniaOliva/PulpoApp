import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String scannedData = "Escanea un código";
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String? selectedCategory;
  String? selectedSupplier;
  TextEditingController categoryController = TextEditingController();

  String get userId => _auth.currentUser?.uid ?? '';

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void _fetchProductData(String barcode) async {
    if (userId.isEmpty) return;

    try {
      DocumentSnapshot document = await _firestore
          .collection('users')
          .doc(userId)
          .collection('productos')
          .doc(barcode)
          .get();

      if (!mounted) return;

      if (document.exists) {
        setState(() {
          scannedData = barcode;
          nameController.text = document['name'] ?? '';
          priceController.text = document['price']?.toString() ?? '';
          quantityController.text = document['quantity']?.toString() ?? '';
          selectedCategory = document['category'];
          selectedSupplier = document['supplier'];
        });
      } else {
        _fetchFromAPI(barcode);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        nameController.clear();
        priceController.clear();
        quantityController.clear();
        selectedCategory = null;
        selectedSupplier = null;
      });
    }
  }

  Future<void> _fetchFromAPI(String barcode) async {
    final String apiUrl =
        "https://world.openfoodfacts.org/api/v0/product/$barcode.json";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final product = data['product'];

        if (product != null) {
          setState(() {
            scannedData = barcode;
            nameController.text = product['product_name'] ?? '';
            priceController.text = product['price']?.toString() ?? '';
            quantityController.text = '';
            selectedCategory = null;
            selectedSupplier = null;
          });
        } else {
          _clearFields();
        }
      } else {
        _clearFields();
      }
    } catch (e) {
      _clearFields();
    }
  }

  void _clearFields() {
    setState(() {
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      selectedCategory = null;
      selectedSupplier = null;
    });
  }

  void _saveProductData() async {
    if (scannedData == "Escanea un código" || userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('productos')
        .doc(scannedData)
        .set({
      'name': nameController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'category': selectedCategory,
      'supplier': selectedSupplier,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Producto guardado correctamente")),
    );
  }

  void _addNewCategory() async {
    String newCategory = categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categorias')
          .add({'name': newCategory});
      setState(() {
        selectedCategory = newCategory;
      });
      categoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 248, 243),
      appBar: AppBar(
        title: const Text("Escáner de Inventario"),
        backgroundColor: const Color(0xFFD9A7A0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      if (!mounted) return;
                      setState(() {
                        scannedData = barcode.rawValue!;
                      });
                      _fetchProductData(barcode.rawValue!);
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Precio"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: "Cantidad"),
                    keyboardType: TextInputType.number,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('categorias')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      var categories = snapshot.data!.docs
                          .map((doc) => doc['name'].toString())
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: const Text("Seleccionar categoría"),
                            onChanged: (value) =>
                                setState(() => selectedCategory = value),
                            items: categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                          ),
                          TextField(
                            controller: categoryController,
                            decoration: InputDecoration(
                              labelText: "Nueva categoría",
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addNewCategory,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('proveedores')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      var suppliers = snapshot.data!.docs
                          .map((doc) => doc['name'].toString())
                          .toList();

                      return DropdownButtonFormField<String>(
                        value: selectedSupplier,
                        hint: const Text("Seleccionar proveedor"),
                        onChanged: (value) =>
                            setState(() => selectedSupplier = value),
                        items: suppliers.map((sup) {
                          return DropdownMenuItem<String>(
                            value: sup,
                            child: Text(sup),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveProductData,
                    child: const Text("Guardar"),
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
