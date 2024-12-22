import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterEmailController {
  final TextEditingController emailController = TextEditingController();

  Future<void> sendOTP(BuildContext context) async {
    String email = emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      // Generate OTP
      String otp = (10000 + (99999 - 10000) * (DateTime.now().millisecond / 1000)).toStringAsFixed(0);
      
      // Save OTP in Firestore
      await FirebaseFirestore.instance.collection('otp').doc(email).set({'otp': otp});

      // Show OTP in a custom OverlayEntry at the top of the screen
      showCustomOverlay(context, 'Your OTP code is: $otp');

      // Navigate to OTP verification page
      Navigator.pushNamed(context, '/verify-code', arguments: email);
    } catch (e) {
      print(e);
      showTopSnackBar(context, 'Failed to send OTP. Please try again.');
    }
  }

  void showTopSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).size.height - 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showCustomOverlay(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1, // Adjust to set the overlay near the top
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Automatically remove overlay after a duration
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}