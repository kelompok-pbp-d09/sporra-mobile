// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/screens/menu.dart';

class EditNewsPage extends StatefulWidget {
  final NewsEntry news;

  const EditNewsPage({super.key, required this.news});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel state untuk menampung data
  late String _title;
  late String _content;
  late String _category;
  late String _thumbnail;

  // Daftar kategori (sesuaikan dengan choices di Django)
  final List<String> _categories = [
    'football',
    'f1',
    'moto gp',
    'bulu tangkis',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Pre-fill data dari object news yang dikirim
    _title = widget.news.fields.title;
    _content = widget.news.fields.content;
    _thumbnail = widget.news.fields.thumbnail;
    
    String existingCategory = "football"; // Default fallback
    
    if (_categories.contains(existingCategory)) {
        _category = existingCategory;
    } else {
        _category = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('Edit Article'),
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
                initialValue: _title, // Isi data awal
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
                value: _category, // Isi data awal
                dropdownColor: const Color(0xFF1F2937),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Select Category"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category.toUpperCase(),
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

              // --- 3. CONTENT INPUT ---
              const Text("Content", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _content, // Isi data awal
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("Write your article content here..."),
                maxLines: 5,
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
                initialValue: _thumbnail, // Isi data awal
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration("https://example.com/image.jpg"),
                onChanged: (String? value) {
                  setState(() {
                    _thumbnail = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Thumbnail cannot be empty';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // --- 5. SAVE BUTTON ---
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

                      // URL API Edit
                      final url = 'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/edit-flutter/${widget.news.pk}/';

                      final response = await request.postJson(
                        url,
                        jsonEncode(<String, String>{
                          'title': _title,
                          'content': _content,
                          'category': _category,
                          'thumbnail': _thumbnail,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("News successfully updated!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Kembali ke main menu dan refresh halaman (hapus stack sebelumnya)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainMenu()),
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to update: ${response['message']}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Save Changes",
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

  // Helper Styling
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1F2937),
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