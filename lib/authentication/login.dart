import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/screens/menu.dart';
import 'package:sporra_mobile/authentication/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- PALET WARNA SPORRA ---
  final Color _bgPrimary = const Color(0xFF111827); // Background Gelap Utama
  final Color _bgCard = const Color(0xFF1F2937); // Background Card
  final Color _inputFill = const Color(
    0xFF374151,
  ); // Warna Kolom Input (Gray 700)
  final Color _textPrimary = const Color(0xFFF9FAFB); // Putih (Gray 50)
  final Color _textSecondary = const Color(
    0xFF9CA3AF,
  ); // Abu-abu Teks (Gray 400)
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
              // --- LOGO ---
              Image.asset(
                'assets/images/logotxt.png',
                height: 200, // Adjust size
                width: 200,
              ),
              const SizedBox(height: 20),

              const Text(
                'Login',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),

              // --- CARD LOGIN ---
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  color: _bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    // ignore: deprecated_member_use
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Please sign in to continue.',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // USERNAME INPUT
                        _buildInputLabel("Username"),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _usernameController,
                          style: TextStyle(color: _textPrimary),
                          decoration: _inputDecoration("Enter your username"),
                        ),

                        const SizedBox(height: 20.0),

                        // PASSWORD INPUT
                        _buildInputLabel("Password"),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: _textPrimary),
                          decoration: _inputDecoration("Enter your password"),
                        ),

                        const SizedBox(height: 32.0),

                        // LOGIN BUTTON
                        ElevatedButton(
                          onPressed: () async {
                            String username = _usernameController.text;
                            String password = _passwordController.text;

                            if (username.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Username and password cannot be empty",
                                  ),
                                ),
                              );
                              return;
                            }

                            final response = await request.login(
                              "http://localhost:8000/profile_user/auth/login/",
                              {'username': username, 'password': password},
                            );

                            if (request.loggedIn) {
                              String message = response['message'];
                              String uname = response['username'];
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainMenu(),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "$message Welcome, $uname.",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                              }
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: _bgCard,
                                    title: const Text(
                                      'Login Failed',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      response['message'],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4,
                            // ignore: deprecated_member_use
                            shadowColor: _accentBlue.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // --- REGISTER LINK (Tombol Register) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: _textSecondary),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: _textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: _inputFill,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
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
    );
  }
}
