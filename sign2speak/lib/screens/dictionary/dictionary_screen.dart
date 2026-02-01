import 'package:flutter/material.dart';
import '../../widgets/sign_video_popup.dart';
import '../../widgets/base_scaffold.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  void _openPopup(
    BuildContext context, {
    required String title,
    required String videoPath,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SignVideoPopup(
        title: title,
        videoPath: videoPath,
      ),
    );
  }

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

          /// AppBar (transparent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Dictionary',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ),

          /// Dictionary Items
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight +
                  MediaQuery.of(context).padding.top +
                  20,
            ),
            child: Column(
              children: [
                _dictionaryItem(
                  context,
                  title: 'Alif',
                  videoPath: 'assets/videos/alif.mp4',
                ),
                _dictionaryItem(
                  context,
                  title: 'Bay',
                  videoPath: 'assets/videos/bay.mp4',
                ),
                _dictionaryItem(
                  context,
                  title: 'Pay',
                  videoPath: 'assets/videos/pay.mp4',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dictionaryItem(
    BuildContext context, {
    required String title,
    required String videoPath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GestureDetector(
        onTap: () => _openPopup(
          context,
          title: title,
          videoPath: videoPath,
        ),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
