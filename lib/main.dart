import 'package:demo_mobile/app/modules/Halaman_Utama/halamanutama_view.dart';
import 'package:demo_mobile/app/modules/notifikasi/notification_handler.dart';
import 'package:demo_mobile/app/routes/app_pages.dart';
import 'package:demo_mobile/app/routes/app_routes.dart';
import 'package:demo_mobile/dependencies_injection.dart';
import 'package:demo_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

// Handler untuk pesan Firebase di background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Pesan diterima di background: ${message.messageId}");
}

Future<void> main() async {
  await GetStorage.init(); // Inisialisasi GetStorage
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Daftarkan handler background untuk pesan Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi notifikasi service
  NotificationService();

  // Dapatkan FCM token untuk debug/log
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  // Pastikan layanan lokasi tersedia dan izin diberikan
  await _checkAndRequestLocationPermissions();

  // Inisialisasi dependensi aplikasi
  DependencyInjection.init();

  runApp(MyApp());
}

Future<void> _checkAndRequestLocationPermissions() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Periksa apakah layanan lokasi diaktifkan
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Future.microtask(() {
      Get.snackbar(
        'Layanan Lokasi Tidak Aktif',
        'Harap aktifkan layanan lokasi untuk menggunakan aplikasi ini.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
    throw Exception('Layanan lokasi tidak aktif.');
  }

  // Periksa status izin lokasi
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Future.microtask(() {
        Get.snackbar(
          'Izin Lokasi Ditolak',
          'Aplikasi membutuhkan akses lokasi untuk berfungsi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      throw Exception('Izin lokasi ditolak.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Future.microtask(() {
      Get.snackbar(
        'Izin Lokasi Ditolak Permanen',
        'Harap aktifkan izin lokasi secara manual di pengaturan perangkat Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
    throw Exception('Izin lokasi ditolak secara permanen.');
  }

  // Jika semuanya baik, lanjutkan
  print("Layanan lokasi tersedia dan izin diberikan.");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CatCare App',
      initialRoute: AppRoutes.SplashScreen,
      getPages: AppPages.pages,
    );
  }
}