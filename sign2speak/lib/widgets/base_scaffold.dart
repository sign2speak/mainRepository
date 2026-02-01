import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_drawer.dart';

class BaseScaffold extends StatefulWidget {
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.body,
  });

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  static const String backendBaseUrl = "http://192.168.10.9:5000";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken(true);

    final response = await http.get(
      Uri.parse("$backendBaseUrl/api/users/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _userData = jsonDecode(response.body)["user"];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: AppDrawer(
        userName: _userData!["profile"]["name"],
        photoUrl: _userData!["photoURL"],
      ),
      body: widget.body,
    );
  }
}
