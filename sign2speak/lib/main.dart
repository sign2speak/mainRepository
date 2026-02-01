import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: AuthGate(),
    );
  }
}
