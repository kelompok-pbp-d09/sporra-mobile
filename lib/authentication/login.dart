import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/main.dart';
import 'package:sporra_mobile/screens/register.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        useMaterial3: true,
        // Mengatur scheme agar sesuai dengan nuansa gelap/biru
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue-600
          background: const Color(0xFF111827), // Gray-900 (Background Body)
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Warna custom berdasarkan Tailwind CSS
  final Color _gray800 = const Color(0xFF1F2937); // Card Background
  final Color _gray300 = const Color(0xFFD1D5DB); // Label Text
  final Color _gray100 = const Color(0xFFF3F4F6); // Input Background
  final Color _blue600 = const Color(0xFF2563EB); // Button Color
  final Color _blue400 = const Color(0xFF60A5FA); // Link Color

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      // Background gelap seperti di HTML (di luar card)
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: _gray800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            // Card Background: bg-gray-800
            color: _gray800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // rounded-lg
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0), // p-8
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul Login
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 30.0, // text-3xl
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // text-white
                    ),
                  ),
                  const SizedBox(height: 24.0), // mb-6
                  // Form Input Username
                  _buildInputLabel("Username"),
                  const SizedBox(height: 4.0), // mb-1 spacing
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(
                      color: Colors.black87,
                    ), // text-gray-900
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _gray100, // bg-gray-100
                      hintText: 'Enter your username',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ), // px-4 py-2
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ), // focus:ring-blue-500
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0), // Spacing antar input
                  // Form Input Password
                  _buildInputLabel("Password"),
                  const SizedBox(height: 4.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _gray100,
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[500]),
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
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32.0),

                  // Tombol Login
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String password = _passwordController.text;

                      // Ganti URL sesuai environment Anda (localhost vs 10.0.2.2)
                      final response = await request.login(
                        "http://localhost:8000/profile_user/auth/login/",
                        {'username': username, 'password': password},
                      );

                      if (request.loggedIn) {
                        String message = response['message'];
                        String uname = response['username'];
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: 'Hayuuuu'),
                            ),
                          );
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text("$message Welcome, $uname."),
                              ),
                            );
                        }
                      } else {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Login Failed'),
                              content: Text(response['message']),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue600, // bg-blue-600
                      foregroundColor: Colors.white, // text-white
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // rounded-lg
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Link Register
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.0,
                        ), // text-gray-400
                        children: [
                          const TextSpan(text: "Don't have an account yet? "),
                          TextSpan(
                            text: "Register Now",
                            style: TextStyle(
                              color: _blue400, // text-blue-400
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk Label input agar rapi di atas text field
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: _gray300, // text-gray-300
          fontWeight: FontWeight.w500, // font-medium
          fontSize: 14.0, // text-sm
        ),
      ),
    );
  }
}
