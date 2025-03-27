import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({Key? key}) : super(key: key);

  @override
  _ProvidersPageState createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";

  String get userId => _auth.currentUser?.uid ?? '';

  void _addProvider() async {
    String name = _providerController.text.trim();
    if (name.isNotEmpty && userId.isNotEmpty) {
      List<String> selectedDays = await _selectDaysDialog();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('proveedores')
          .add({
        'name': name,
        'days': selectedDays,
      });
      _providerController.clear();
      Navigator.pop(context);
    }
  }

  void _editProvider(
      String id, String currentName, List<String> currentDays) async {
    _providerController.text = currentName;
    List<String> selectedDays =
        await _selectDaysDialog(initialDays: currentDays);

    if (_providerController.text.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('proveedores')
          .doc(id)
          .update({
        'name': _providerController.text.trim(),
        'days': selectedDays,
      });
    }
  }

  Future<List<String>> _selectDaysDialog({List<String>? initialDays}) async {
    List<String> daysOfWeek = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo"
    ];
    List<String> selectedDays = List.from(initialDays ?? []);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleccionar días de visita"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: daysOfWeek.map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: selectedDays.contains(day),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, []),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedDays),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    return selectedDays;
  }

  void _confirmDeleteProvider(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Proveedor"),
        content:
            const Text("¿Estás seguro de que deseas eliminar este proveedor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteProvider(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sí"),
          ),
        ],
      ),
    );
  }

  void _deleteProvider(String id) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('proveedores')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 241, 237),
      appBar: AppBar(
        title: const Text("Proveedores",
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
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
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
            const Text("Proveedores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Color.fromARGB(255, 199, 178, 178)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('proveedores')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var providers = snapshot.data!.docs.where((doc) {
                    String name = doc['name'].toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  if (providers.isEmpty) {
                    return const Center(child: Text("No hay proveedores aún"));
                  }

                  return ListView.builder(
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      var doc = providers[index];
                      String id = doc.id;
                      String name = doc['name'];
                      List<String> days = (doc.data() as Map<String, dynamic>)
                              .containsKey('days')
                          ? List<String>.from(doc['days'])
                          : [];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text(days.isNotEmpty
                              ? "Días: ${days.join(', ')}"
                              : "Días: No especificado"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.black),
                                onPressed: () => _editProvider(id, name, days),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteProvider(id),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(context, '/products',
                              arguments: name),
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
