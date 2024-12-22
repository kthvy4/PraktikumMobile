import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionController extends GetxController {
  // Observable untuk status koneksi (online/offline)
  var isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Mulai memantau status koneksi
    _monitorConnection();

    // Tampilkan snackbar saat status koneksi berubah
    ever(isConnected, (connected) {
      if (connected == true) {
        Get.snackbar(
          "Koneksi Tersambung",
          "Anda kembali online.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Tidak Ada Koneksi",
          "Anda sedang offline.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  void _monitorConnection() {
    // Mendengarkan perubahan status koneksi
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Jika koneksi ada (bukan none), set isConnected ke true
      isConnected.value = result != ConnectivityResult.none;
    });

    // Periksa koneksi saat inisialisasi
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      //memeriksa koneksi
      var connectivityResult = await Connectivity().checkConnectivity();
      isConnected.value = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // Jika terjadi error, asumsikan tidak ada koneksi
      isConnected.value = false;
    }
  }
}
