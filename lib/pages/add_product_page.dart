import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSupplier;
  String? _newCategory;

  String get userId => _auth.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Producto"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: "Nombre del producto"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese un nombre" : null,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('categorias')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  var categories =
                      snapshot.data!.docs.map((doc) => doc['name']).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text("Seleccionar categoría"),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                  );
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: "Nueva categoría (opcional)"),
                onChanged: (value) => _newCategory = value,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('proveedores')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  var suppliers =
                      snapshot.data!.docs.map((doc) => doc['name']).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedSupplier,
                    hint: const Text("Seleccionar proveedor"),
                    onChanged: (value) =>
                        setState(() => _selectedSupplier = value),
                    items: suppliers.map((sup) {
                      return DropdownMenuItem<String>(
                        value: sup,
                        child: Text(sup),
                      );
                    }).toList(),
                  );
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese un precio" : null,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cantidad"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese una cantidad" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text("Guardar Producto"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate() && userId.isNotEmpty) {
      String category = _newCategory != null && _newCategory!.isNotEmpty
          ? _newCategory!
          : _selectedCategory!;

      if (_newCategory != null && _newCategory!.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('categorias')
            .add({'name': category});
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('productos')
          .add({
        'name': _nameController.text,
        'category': category,
        'supplier': _selectedSupplier,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
      });

      Navigator.pop(context);
    }
  }
}
