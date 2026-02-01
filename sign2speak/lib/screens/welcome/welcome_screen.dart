import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../auth/auth_gate.dart';

import '../../services/google_auth_service.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  try {
    final user = await GoogleAuthService().signInWithGoogle();

    if (user == null) return;

    // ✅ Get Firebase ID token
    final token = await user.getIdToken(true);

    if (token == null) throw Exception("Token null");

    // 🔥 CALL BACKEND DIRECTLY
    final response = await http.post(
      Uri.parse("http://192.168.10.9:5000/api/users/me/login"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("BACKEND STATUS: ${response.statusCode}");
    print("BACKEND BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Backend auth failed");
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed: $e")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// Content
          Column(
            children: [
              const SizedBox(height: 140),

              /// Animated App Logo
              Center(
                child: Lottie.asset(
                  'assets/animations/sign2speak.json',
                  height: MediaQuery.of(context).size.height * 0.3,
                  repeat: true,
                ),
              ),

              const SizedBox(height: 40),

              /// Welcome Text
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              /// Google Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 22,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
