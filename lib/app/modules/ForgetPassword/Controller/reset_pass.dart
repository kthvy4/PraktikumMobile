import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordController {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();

  Future<void> updatePassword(BuildContext context, String email) async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      showTopSnackBar(context, 'Passwords do not match');
      return;
    }

    if (newPassword.length < 6) {
      showTopSnackBar(context, 'Password must be at least 6 characters long');
      return;
    }

    try {
      // Re-authenticate user to ensure session validity
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );

      // Update password
      await userCredential.user!.updatePassword(newPassword);

      // Navigate to success page
      Navigator.pushReplacementNamed(context, '/password-changed');
      showTopSnackBar(context, 'Password successfully updated');
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            showTopSnackBar(context, 'The current password is incorrect');
            break;
          case 'user-not-found':
            showTopSnackBar(context, 'User not found');
            break;
          case 'weak-password':
            showTopSnackBar(context, 'Password is too weak');
            break;
          default:
            showTopSnackBar(context, 'An error occurred: ${e.message}');
        }
      } else {
        showTopSnackBar(context, 'An unexpected error occurred');
      }
    }
  }

  void showTopSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height - 100,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
