import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../onboarding/onboarding_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? googlePhotoUrl;
  bool _isSubmitting = false;

  /// CHANGE THIS IP IF YOUR PC IP CHANGES
  static const String backendBaseUrl = "http://192.168.10.9:5000";

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    googlePhotoUrl = user?.photoURL;
    nameController.text = user?.displayName ?? "";
  }

  // Date picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // Submit profile to backend
  Future<void> _submitProfile() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        dobController.text.isEmpty ||
        cityController.text.isEmpty ||
        countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final token = await user.getIdToken(true);
      if (token == null) throw Exception("Token null");

      final response = await http.put(
        Uri.parse("$backendBaseUrl/api/users/me/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "phoneNumber": phoneController.text.trim(),
          "dateOfBirth": dobController.text.trim(),
          "city": cityController.text.trim(),
          "country": countryController.text.trim(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Profile update failed");
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'Profile Details',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Google Photo (READ ONLY)
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: googlePhotoUrl != null
                        ? NetworkImage(googlePhotoUrl!)
                        : null,
                    child: googlePhotoUrl == null
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.black54)
                        : null,
                  ),

                  const SizedBox(height: 30),

                  _buildInputField(
                    label: 'Name',
                    controller: nameController,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Phone Number',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    label: 'Date of Birth',
                    controller: dobController,
                    readOnly: true,
                    hintText: 'DD / MM / YYYY',
                    suffixIcon: Icons.calendar_today,
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: 'City',
                          controller: cityController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          label: 'Country',
                          controller: countryController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon:
                suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
            filled: true,
            fillColor: Colors.grey.shade300,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
