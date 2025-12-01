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

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- PALET WARNA SPORRA (Sama dengan Login) ---
  final Color _bgPrimary = const Color(0xFF111827); // Background Gelap Utama
  final Color _bgCard = const Color(0xFF1F2937); // Background Card
  final Color _inputFill = const Color(0xFF374151); // Warna Kolom Input
  final Color _textPrimary = const Color(0xFFF9FAFB); // Putih
  final Color _textSecondary = const Color(0xFF9CA3AF); // Abu-abu Teks
  final Color _accentBlue = const Color(0xFF2563EB); // Biru Utama

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- HEADER ---
              Image.asset(
                'assets/images/logotxt.png',
                height: 200, // Adjust size
                width: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join the Sporra community today",
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // --- CARD ---
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  color: _bgCard,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    // ignore: deprecated_member_use
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInput(
                            controller: _usernameController,
                            label: "Username",
                            helper:
                                "Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.",
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: _fullNameController,
                            label: "Full Name",
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: _phoneController,
                            label: "Phone Number",
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: _password1Controller,
                            label: "Password",
                            isPassword: true,
                            helper:
                                "Your password must contain at least 8 characters.",
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: _password2Controller,
                            label: "Confirm Password",
                            isPassword: true,
                            helper:
                                "Enter the same password as before, for verification.",
                          ),
                          const SizedBox(height: 32),

                          // --- REGISTER BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      // Validasi Form Lokal
                                      if (_password1Controller.text !=
                                          _password2Controller.text) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Passwords do not match!",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => _isLoading = true);

                                      String username =
                                          _usernameController.text;
                                      String fullName =
                                          _fullNameController.text;
                                      String phone = _phoneController.text;
                                      String password1 =
                                          _password1Controller.text;
                                      String password2 =
                                          _password2Controller.text;

                                      try {
                                        final response = await request.post(
                                          "http://localhost:8000/profile_user/auth/register/",
                                          {
                                            "username": username,
                                            "full_name": fullName,
                                            "phone": phone,
                                            "password1": password1,
                                            "password2": password2,
                                          },
                                        );

                                        if (!context.mounted) return;

                                        if (response["status"] == true) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response["message"],
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          // Redirect ke Login setelah sukses
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const LoginPage(),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response["message"] ??
                                                    "Registration failed",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Error: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                disabledBackgroundColor: _accentBlue
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- LOGIN LINK ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(color: _textSecondary),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: _accentBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Input Field
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    String? helper,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          style: TextStyle(color: _textPrimary), // Warna teks input putih
          decoration: InputDecoration(
            filled: true,
            fillColor: _inputFill, // Warna latar gelap
            hintText: "Enter your $label",
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),

            helperText: helper,
            helperMaxLines: 3,
            helperStyle: TextStyle(color: Colors.grey[600], fontSize: 11),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _accentBlue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
