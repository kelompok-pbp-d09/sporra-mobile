import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel untuk menyimpan input user
  String _title = "";
  String _content = "";
  String _category = "football";
  String _thumbnail = "";

  // Daftar kategori (sesuaikan dengan choices di Django models.py)
  final List<String> _categories = [
    'football',
    'f1',
    'moto gp',
    'bulu tangkis',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Background Gelap
      appBar: AppBar(
        title: const Text('Add New Article'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- 1. TITLE INPUT ---
              const Text("Title", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Enter article title"),
                onChanged: (String? value) {
                  setState(() {
                    _title = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Title cannot be empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- 2. CATEGORY DROPDOWN ---
              const Text("Category", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1F2937), // Warna dropdown menu
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Select Category"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category.toUpperCase(), // Biar rapi
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- 3. CONTENT INPUT (MULTILINE) ---
              const Text("Content", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Write your article content here..."),
                maxLines: 5, // Agar kotak input lebih besar
                onChanged: (String? value) {
                  setState(() {
                    _content = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Content cannot be empty!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- 4. THUMBNAIL URL ---
              const Text("Thumbnail URL", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("https://example.com/image.jpg"),
                onChanged: (String? value) {
                  setState(() {
                    _thumbnail = value!;
                  });
                },
              ),

              const SizedBox(height: 40),

              // --- 5. SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kirim data ke Django
                      final response = await request.postJson(
                        "https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/create-flutter/",
                        jsonEncode(<String, String>{
                          'title': _title,
                          'content': _content,
                          'category': _category,
                          'thumbnail': _thumbnail,
                        }),
                      );

                      if (context.mounted) {
                        // PERBAIKAN DI SINI: Cek 'status' == true
                        if (response['status'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("News successfully created!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Kembali ke main menu dan refresh
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainMenu()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              // Tampilkan pesan error dari server jika ada
                              content: Text(response['message'] ?? "Failed to create news."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Submit Article",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk styling input agar rapi dan seragam
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1F2937), // Warna kotak input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }
}