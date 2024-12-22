import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyOTPController {
  final List<TextEditingController> otpControllers = List.generate(5, (_) => TextEditingController());
  DateTime? lastResendTime; // Menyimpan waktu terakhir pengiriman ulang OTP

  Future<void> verifyOTP(BuildContext context, String email) async {
    String enteredOTP = otpControllers.map((c) => c.text).join();

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('otp').doc(email).get();
      String savedOTP = snapshot.get('otp');

      if (enteredOTP == savedOTP) {
        Navigator.pushNamed(context, '/change-password', arguments: email);
      } else {
        showTopSnackBar(context, 'Invalid OTP');
      }
    } catch (e) {
      print(e);
      showTopSnackBar(context, 'An error occurred. Please try again.');
    }
  }

  Future<void> resendOTP(BuildContext context, String email) async {
    // Cek apakah 10 detik telah berlalu sejak pengiriman terakhir
    if (lastResendTime != null && DateTime.now().difference(lastResendTime!).inSeconds < 10) {
      showTopSnackBar(context, 'Please wait for 10 seconds before requesting a new OTP.');
      return;
    }

    // Menghasilkan OTP baru
    String newOtp = (10000 + (99999 - 10000) * (DateTime.now().millisecond / 1000)).toStringAsFixed(0);
    await FirebaseFirestore.instance.collection('otp').doc(email).update({'otp': newOtp});

    // Simpan waktu pengiriman terakhir
    lastResendTime = DateTime.now();

    // Tampilkan snackbar dengan OTP baru
    showTopSnackBar(context, 'A new OTP has been sent: $newOtp');
  }

  void showTopSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).size.height - 100),
        duration: Duration(seconds: 8),
      ),
    );
  }
}