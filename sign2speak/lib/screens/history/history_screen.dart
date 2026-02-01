import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import '../../widgets/base_scaffold.dart';
import '../../utils/sign_to_urdu.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<dynamic> _predictions = [];

  static const String apiUrl =
      "http://192.168.10.9:5000/api/fetchPredictions/predictions/me";

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ---------------- FETCH HISTORY ----------------

  Future<void> _fetchHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch history");
      }

      final data = jsonDecode(response.body);

      setState(() {
        _predictions = data["predictions"] ?? [];
        _loading = false;
      });
    } catch (e) {
      debugPrint("History fetch error: $e");
      setState(() => _loading = false);
    }
  }

  // ---------------- URDU TTS ----------------

  Future<void> _speakUrdu(String signKey) async {
    final urduText =
        signToUrdu[signKey.toUpperCase()] ??
        signKey.replaceAll("_", " ");

    await _flutterTts.setLanguage("ur-PK");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(urduText);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'History',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ),

          /// History List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _predictions.isEmpty
                    ? const Center(
                        child: Text(
                          "No history yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _predictions.length,
                        itemBuilder: (_, index) {
                          final p = _predictions[index];

                          final String signKey = p["sign"].toString();

                          final String urduText =
                              signToUrdu[signKey.toUpperCase()] ??
                              signKey.replaceAll("_", " ");

                          final DateTime date =
                              DateTime.parse(p["createdAt"]);

                          final String formattedDate =
                              DateFormat("dd MMM yyyy, hh:mm a")
                                  .format(date);

                          return _HistoryItem(
                            title: urduText,
                            date: formattedDate,
                            onSpeak: () => _speakUrdu(signKey),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ---------------- HISTORY ITEM ----------------

class _HistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onSpeak;

  const _HistoryItem({
    required this.title,
    required this.date,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          /// Urdu text + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ RTL-safe Urdu rendering
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                /// Date (LTR)
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          /// Volume Icon
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: onSpeak,
          ),
        ],
      ),
    );
  }
}
