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

  final Color _gray800 = const Color(0xFF1F2937);
  final Color _gray300 = const Color(0xFFD1D5DB);
  final Color _gray100 = const Color(0xFFF3F4F6);
  final Color _blue600 = const Color(0xFF2563EB);
  final Color _blue400 = const Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: _gray800,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: _gray800,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildInput(
                        controller: _usernameController,
                        label: "Nama Pengguna",
                        helper:
                            "Wajib. 150 karakter atau sedikit. Hanya huruf, angka, dan @/./+/-/_.",
                      ),
                      const SizedBox(height: 16),

                      _buildInput(
                        controller: _fullNameController,
                        label: "Full Name",
                      ),
                      const SizedBox(height: 16),

                      _buildInput(
                        controller: _phoneController,
                        label: "Nomor HP",
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      _buildInput(
                        controller: _password1Controller,
                        label: "Sandi",
                        isPassword: true,
                        helper:
                            """Sandi anda tidak dapat terlalu mirip terhadap informasi pribadi anda.
Kata sandi Anda harus memuat setidaknya 8 karakter.
Sandi anda tidak dapat berupa sandi umum digunakan.
Sandi anda tidak bisa sepenuhnya numerik.""",
                      ),
                      const SizedBox(height: 16),

                      _buildInput(
                        controller: _password2Controller,
                        label: "Konfirmasi Sandi",
                        isPassword: true,
                        helper:
                            "Masukkan sandi yang sama seperti sebelumnya, untuk verifikasi.",
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);
                                  String username = _usernameController.text;
                                  String fullName = _fullNameController.text;
                                  String phone = _phoneController.text;
                                  String password1 = _password1Controller.text;
                                  String password2 = _password2Controller.text;

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

                                  setState(() => _isLoading = false);

                                  if (!context.mounted) return;

                                  if (response["status"] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response["message"]),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response["message"].toString(),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white70),
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
                                color: _blue400,
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
        ),
      ),
    );
  }

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
            color: _gray300,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          style: const TextStyle(color: Colors.black87),

          decoration: InputDecoration(
            filled: true,
            fillColor: _gray100,

            hintText: label,
            hintStyle: TextStyle(color: Colors.grey[500]),

            helperText: helper,
            helperMaxLines: 3,
            helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _blue600, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
