import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({Key? key}) : super(key: key);

  @override
  _ProvidersPageState createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  final TextEditingController _providerController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar proveedor a Firebase
  void _addProvider() async {
    String name = _providerController.text.trim();
    if (name.isNotEmpty) {
      await _firestore.collection('providers').add({'name': name});
      _providerController.clear();
    }
  }

  // Eliminar proveedor de Firebase
  void _deleteProvider(String id) async {
    await _firestore.collection('providers').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E5D6), // Fondo beige claro
      appBar: AppBar(
        title: const Text("Proveedor",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD9A7A0), // Color del encabezado
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
            // Buscador
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar proveedor...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Título
            const Text("Proveedores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),

            // Lista de proveedores desde Firebase
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('providers').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var providers = snapshot.data!.docs;
                  if (providers.isEmpty)
                    return const Center(child: Text("No hay proveedores aún"));

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: providers.map((doc) {
                      String id = doc.id;
                      String name = doc['name'];

                      return GestureDetector(
                        onLongPress: () =>
                            _deleteProvider(id), // Eliminar con pulsación larga
                        onTap: () => Navigator.pushNamed(context, '/products',
                            arguments: name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Text(name, style: const TextStyle(fontSize: 16)),
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Agregar Proveedor"),
              content: TextField(
                controller: _providerController,
                decoration:
                    const InputDecoration(labelText: "Nombre del proveedor"),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar")),
                ElevatedButton(
                    onPressed: _addProvider, child: const Text("Agregar")),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
