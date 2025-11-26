import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/authentication/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF1F2937), // bg-gray-800
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Register"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2130), // darker gray
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 28),

                _buildInput("Username", _usernameController),
                const SizedBox(height: 14),

                _buildInput("Full Name", _fullNameController),
                const SizedBox(height: 14),

                _buildInput("Phone", _phoneController),
                const SizedBox(height: 14),

                _buildInput("Password", _password1Controller, isPassword: true),
                const SizedBox(height: 14),

                _buildInput(
                  "Confirm Password",
                  _password2Controller,
                  isPassword: true,
                ),
                const SizedBox(height: 22),

                // Register Button
                GestureDetector(
                  onTap: () async {
                    String username = _usernameController.text;
                    String fullName = _fullNameController.text;
                    String phone = _phoneController.text;
                    String password1 = _password1Controller.text;
                    String password2 = _password2Controller.text;

                    final response = await request.postJson(
                      "http://127.0.0.1:8000/auth/register/",
                      jsonEncode({
                        "username": username,
                        "full_name": fullName,
                        "phone": phone,
                        "password1": password1,
                        "password2": password2,
                      }),
                    );

                    if (!context.mounted) return;

                    if (response["status"] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response["message"])),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response["message"].toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A), // green-600
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login Now",
                    style: TextStyle(
                      color: Color(0xFF60A5FA), // blue-400
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Input Builder (mirip Tailwind form)
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD1D5DB), // gray-300
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB), // input bg
            hintText: label,
            hintStyle: const TextStyle(color: Colors.black45),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
          ),
        ),
      ],
    );
  }
}
