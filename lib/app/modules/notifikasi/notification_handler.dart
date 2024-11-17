import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model untuk notifikasi
class Notification {
  final String title;
  final String body;

  Notification({required this.title, required this.body});
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permission untuk iOS (jika diperlukan)
    await _firebaseMessaging.requestPermission();

    // Inisialisasi pengaturan notifikasi lokal
    const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitialization,
    );

    // Inisialisasi plugin notifikasi lokal dengan callback saat notifikasi diklik
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Handle notifikasi saat aplikasi berada di Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Set background message handler untuk kondisi Background dan Terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Fungsi untuk menampilkan notifikasi lokal
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: 'navigate_to_notification', // Menambahkan payload untuk navigasi
    );

    // Simpan notifikasi ke Firestore
    await _saveNotificationToFirestore(message);
  }

  // Simpan notifikasi ke Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final notificationData = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('notifications').add(notificationData);
  }

  // Fungsi untuk menangani klik notifikasi
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Cek payload untuk navigasi ke halaman yang sesuai
    if (response.payload == 'navigate_to_notification') {
      Get.toNamed('/notifications'); // Arahkan ke halaman notification.dart
    }
  }

  // Ambil notifikasi dari Firestore
  Stream<List<Notification>> getNotifications() {
    return _firestore.collection('notifications').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notification(
          title: doc['title'],
          body: doc['body'],
        );
      }).toList();
    });
  }
}

// Fungsi untuk menangani notifikasi yang diterima di Background dan Terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
