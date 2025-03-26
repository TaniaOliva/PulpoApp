import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class PopularesPage extends StatelessWidget {
  const PopularesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Productos Populares'),
        backgroundColor: const Color(0xFFD9B7A5),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPopularProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos populares.'));
          }

          var products = snapshot.data!.entries.toList();
          products.sort((a, b) =>
              b.value['movimientos'].compareTo(a.value['movimientos']));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.local_offer,
                              color: Colors.orange),
                          title: Text(product.value['name'] ?? 'Sin nombre',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Movimientos: ${product.value['movimientos']}'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: _generateBarData(products),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < products.length) {
                                String firstWord =
                                    products[index].value['name'].split(' ')[0];
                                return Text(
                                  firstWord,
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchPopularProducts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot activitySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('actividad_productos')
        .get();

    Map<String, dynamic> productCounts = {};

    for (var doc in activitySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String productId = data['productId'];
      String name = data['name'] ?? 'Sin nombre';

      if (!productCounts.containsKey(productId)) {
        productCounts[productId] = {
          'name': name,
          'movimientos': 0,
        };
      }
      productCounts[productId]['movimientos'] += 1;
    }

    return productCounts;
  }

  List<BarChartGroupData> _generateBarData(
      List<MapEntry<String, dynamic>> products) {
    return List.generate(products.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: products[index].value['movimientos'].toDouble(),
            color: Colors.orange,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
