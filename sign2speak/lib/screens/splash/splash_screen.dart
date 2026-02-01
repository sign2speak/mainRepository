// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../welcome/welcome_screen.dart';


// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           /// Background Image
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/splash.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),

//           Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 140),

//               /// Lottie Animation
//               Lottie.asset(
//                 'assets/animations/sign2speak.json',
//                 height: 140,
//                 repeat: true,
//               ),

//               /// Continue Button
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 40),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Navigation later
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const WelcomeScreen())
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey.shade300,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Continue',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// Content (same pattern as Welcome screen)
          Column(
            children: [
              const SizedBox(height: 140),

              /// CENTERED Lottie (key fix)
              Center(
                child: Lottie.asset(
                  'assets/animations/sign2speak.json',
                  height: MediaQuery.of(context).size.height * 0.3,
                  repeat: true,
                ),
              ),

              const Spacer(),

              /// Button (same structure as Welcome)
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
