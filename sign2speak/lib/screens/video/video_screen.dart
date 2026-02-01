import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../main.dart';
import '../../utils/sign_to_urdu.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;

  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isStopping = false;
  bool _isInferencing = false;

  int _cameraIndex = 0;
  XFile? _recordedVideo;

  final FlutterTts _flutterTts = FlutterTts();

  static const String apiUrl =
      "http://192.168.10.9:5000/api/predict"; // keep configurable later

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ---------------- CAMERA ----------------

  Future<void> _initializeCamera() async {
    try {
      final controller = CameraController(
        cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false, // ❗ audio not needed
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _speakUrdu(String signKey) async {
  final urduText =
      signToUrdu[signKey.toUpperCase()] ??
      signKey.replaceAll("_", " ");

  await _flutterTts.setLanguage("ur-PK");
  await _flutterTts.setSpeechRate(0.45);
  await _flutterTts.setPitch(1.0);
  await _flutterTts.speak(urduText);
}


  Future<void> _resetCamera() async {
    _isCameraInitialized = false;
    setState(() {});

    await _cameraController?.dispose();
    _cameraController = null;

    await Future.delayed(const Duration(milliseconds: 300));
    await _initializeCamera();
  }

  Future<void> _switchCamera() async {
    if (_isRecording || cameras.length < 2) return;

    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    await _resetCamera();
  }

  // ---------------- RECORDING ----------------

  Future<void> _startRecording() async {
    if (!_isCameraInitialized || _isRecording || _isStopping) return;

    await _cameraController!.prepareForVideoRecording();
    await _cameraController!.startVideoRecording();

    setState(() => _isRecording = true);

    // ⏱ Auto stop after 3 seconds (ML-safe)
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (_isRecording) {
    //     _stopRecording();
    //   }
    // });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isStopping) return;

    _isStopping = true;

    final video = await _cameraController!.stopVideoRecording();

    setState(() {
      _recordedVideo = video;
      _isRecording = false;
    });

    _isStopping = false;
    _showPreviewPopup();
  }

  // ---------------- BACKEND INFERENCE ----------------

  Future<void> _sendVideoForInference(File videoFile) async {
    setState(() => _isInferencing = true);

    try {

      final token =
        await FirebaseAuth.instance.currentUser!.getIdToken();

      final request =
          http.MultipartRequest("POST", Uri.parse(apiUrl));

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath("video", videoFile.path),
      );

      final response = await request.send().timeout(
            const Duration(seconds: 20),
          );

      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception("Inference failed");
      }

      final data = jsonDecode(body);
      final String sign = data["sign"];
      final double confidence =
          (data["confidence"] as num).toDouble();

      if (!mounted) return;

      if (confidence < 0.30) {
        _showResult("Unknown Sign");
      } else {
        _showResult(sign);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inference failed")),
      );
    } finally {
      setState(() => _isInferencing = false);
      if (videoFile.existsSync()) {
        await videoFile.delete(); // 🧹 cleanup
      }
    }
  }

void _showResult(String signKey) {
  final urduText =
      signToUrdu[signKey.toUpperCase()] ??
      signKey.replaceAll("_", " ");

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Detected Sentence"),
      content: Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Text(
                urduText,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speakUrdu(signKey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

  // ---------------- PREVIEW POPUP ----------------

  Future<void> _showPreviewPopup() async {
    _videoPlayerController =
        VideoPlayerController.file(File(_recordedVideo!.path));

    await _videoPlayerController!.initialize();
    _videoPlayerController!.setLooping(true);
    _videoPlayerController!.play();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recorded Video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            AspectRatio(
              aspectRatio:
                  _videoPlayerController!.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),

            const SizedBox(height: 20),

            if (_isInferencing)
              const CircularProgressIndicator(),

            if (!_isInferencing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _videoPlayerController?.dispose();
                        _videoPlayerController = null;
                        _recordedVideo = null;
                        await _resetCamera();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Discard',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final file = File(_recordedVideo!.path);
                        await _videoPlayerController?.dispose();
                        _videoPlayerController = null;
                        await _sendVideoForInference(file);
                        await _resetCamera();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- LIFECYCLE ----------------

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Video',
          style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              SizedBox(
                height:
                    kToolbarHeight + MediaQuery.of(context).padding.top + 20,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isCameraInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  CameraPreview(_cameraController!),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(Icons.cameraswitch,
                            color: Colors.white, size: 28),
                        onPressed: _switchCamera,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding:
                    const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isRecording ? _stopRecording : _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRecording ? Colors.red : Colors.grey.shade300,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isRecording
                          ? 'Stop Recording'
                          : 'Start Recording',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            _isRecording ? Colors.white : Colors.black,
                      ),
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
