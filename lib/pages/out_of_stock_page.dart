import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OutOfStockPage extends StatefulWidget {
  const OutOfStockPage({Key? key}) : super(key: key);

  @override
  _OutOfStockPageState createState() => _OutOfStockPageState();
}

class _OutOfStockPageState extends State<OutOfStockPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedQuantity = 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E5D6),
      appBar: AppBar(
        title: const Text("Productos sin Stock",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD9A7A0),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo.png', height: 40),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text("Filtrar productos con cantidad ≤ ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: selectedQuantity,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 139, 9, 9)),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.filter_list,
                        color: Color.fromARGB(255, 9, 9, 9)),
                    items: [0, 1, 2, 3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("≤ $value"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedQuantity = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _userId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(_userId)
                          .collection('productos')
                          .where('quantity',
                              isLessThanOrEqualTo: selectedQuantity)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var products = snapshot.data!.docs;

                        if (products.isEmpty) {
                          return const Center(
                            child: Text("No hay productos con esta cantidad",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          );
                        }

                        return ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];
                            return Card(
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(product['name'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                subtitle:
                                    Text("Cantidad: ${product['quantity']}"),
                                leading: const Icon(Icons.warning,
                                    color: Colors.redAccent),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
