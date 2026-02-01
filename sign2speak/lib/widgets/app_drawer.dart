import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/history/history_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/dictionary/dictionary_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String? photoUrl;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.photoUrl,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade300,
      child: SafeArea(
        child: Column(
          children: [
            /// User Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  /// Google Photo
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl!) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 30)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  /// Dynamic Name
                  Expanded(
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            _drawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.play_arrow,
              title: 'Previous Signs',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.menu_book,
              title: 'PSL Dictionary',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                );
              },
            ),

            const Spacer(),
            const Divider(),

            _drawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _logout(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
