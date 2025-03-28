import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, int> previousQuantities = {};

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _listenToInventoryChanges();
    _checkSupplierArrivals();
  }

  void _listenToInventoryChanges() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('productos')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        int cantidad = (doc.data()['quantity'] ?? 0);
        String nombreProducto = doc.data()['name'] ?? 'Producto';

        String docId = doc.id;
        int previous = previousQuantities[docId] ?? cantidad;

        if (previous > 0 && cantidad == 0) {
          _sendNotification(
              'Stock agotado', 'El producto "$nombreProducto" se ha agotado');
        }

        previousQuantities[docId] = cantidad;
      }
    });
  }

  void _checkSupplierArrivals() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    Map<String, String> dayTranslations = {
      "Lunes": "Monday",
      "Martes": "Tuesday",
      "Miércoles": "Wednesday",
      "Jueves": "Thursday",
      "Viernes": "Friday",
      "Sábado": "Saturday",
      "Domingo": "Sunday",
    };

    String todayEnglish = DateFormat('EEEE').format(DateTime.now());

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('proveedores')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        String proveedorNombre = doc.data()['name'] ?? 'Proveedor';
        List<dynamic> diasLlegada = doc.data()['days'] ?? [];

        List<String> diasEnIngles =
            diasLlegada.map((dia) => dayTranslations[dia] ?? '').toList();

        if (diasEnIngles.contains(todayEnglish)) {
          _sendNotification(
              'Llegada de proveedor', '$proveedorNombre viene hoy');
        }
      }
    });
  }

  Future<void> _sendNotification(String title, String body) async {
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
