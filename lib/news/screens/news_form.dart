import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';

class NewsFormPage extends StatefulWidget {
  final NewsEntry? news;

  const NewsFormPage({super.key, this.news});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _thumbnailController;
  String _category = 'sepakbola'; // Default

  // Warna Tema
  final Color _bgPrimary = const Color(0xFF111827);
  final Color _inputFill = const Color(0xFF374151);
  final Color _textPrimary = const Color(0xFFF9FAFB);
  final Color _textSecondary = const Color(0xFF9CA3AF); // Added missing color
  final Color _accentBlue = const Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    // Isi data awal jika sedang mode Edit
    _titleController = TextEditingController(text: widget.news?.fields.title ?? "");
    _contentController = TextEditingController(text: widget.news?.fields.content ?? "");
    _thumbnailController = TextEditingController(text: widget.news?.fields.thumbnail ?? "");
    if (widget.news != null) {
      _category = widget.news!.fields.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.news != null;

    return Scaffold(
      backgroundColor: _bgPrimary,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Berita" : "Buat Berita Baru"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Judul"),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: _textPrimary),
                decoration: _inputDecoration("Masukkan judul berita"),
                validator: (value) => value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Kategori"),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _category,
                dropdownColor: _inputFill,
                style: TextStyle(color: _textPrimary),
                decoration: _inputDecoration("Pilih Kategori"),
                items: ['sepakbola', 'f1', 'moto gp', 'raket', 'olahraga lain']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              _buildLabel("Konten"),
              TextFormField(
                controller: _contentController,
                style: TextStyle(color: _textPrimary),
                maxLines: 10,
                decoration: _inputDecoration("Tulis isi berita..."),
                validator: (value) => value!.isEmpty ? "Konten tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("URL Thumbnail (Gambar)"),
              TextFormField(
                controller: _thumbnailController,
                style: TextStyle(color: _textPrimary),
                decoration: _inputDecoration("https://example.com/image.jpg"),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Tentukan URL dan Payload
                      String url = isEdit 
                          ? "https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/edit-flutter/${widget.news!.pk}/"
                          : "https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/create-flutter/"; 
                      
                      final response = await request.postJson(
                        url,
                        jsonEncode({
                          "title": _titleController.text,
                          "content": _contentController.text,
                          "category": _category,
                          "thumbnail": _thumbnailController.text,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Berita berhasil disimpan!")),
                          );
                          // Kembali ke list dan refresh
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const NewsEntryListPage()),
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response['message'] ?? "Gagal menyimpan")),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    isEdit ? "Simpan Perubahan" : "Publikasikan",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: _textSecondary, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: _inputFill,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}