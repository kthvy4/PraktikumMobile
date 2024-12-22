import 'package:demo_mobile/app/modules/login/views/login_view.dart';
import 'package:flutter/material.dart';

class PasswordChangedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or title at the top
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.coffee, // Placeholder for the "DO! COFFEE" logo
                            size: 40,
                            color: Colors.black,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cat Care',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30), // Spacing

                    // Success message
                    const Text(
                      'Your Password Has Been\nSuccessfully Changed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 30), // Spacing

                    // Checkmark icon
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 30), // Spacing

                    // Back to Login button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: () {
                        // Navigate back to login screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>LoginView()),
                        );
                      },
                      child: const Text(
                        'Back To Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}