import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../screens/welcome/welcome_screen.dart';
import '../screens/profile/profile_details_screen.dart';
import '../screens/home/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  Widget _screen = const SizedBox();

  static const String backendBaseUrl = "http://192.168.10.9:5000";

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    // ❌ Not logged in
    if (user == null) {
      setState(() {
        _screen = const WelcomeScreen();
        _loading = false;
      });
      return;
    }

    try {
      final token = await user.getIdToken(true);

      final response = await http.get(
        Uri.parse("$backendBaseUrl/api/users/me"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Backend auth failed");
      }

      final data = jsonDecode(response.body);
      final bool profileCompleted = data["user"]["profileCompleted"];

      setState(() {
        _screen = profileCompleted
            ? const HomeScreen()
            : const ProfileDetailsScreen();
        _loading = false;
      });
    } catch (_) {
      // If anything goes wrong, force re-login
      await FirebaseAuth.instance.signOut();
      setState(() {
        _screen = const WelcomeScreen();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _screen;
  }
}
