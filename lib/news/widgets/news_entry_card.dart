// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/screens/news_detail.dart';
import 'package:sporra_mobile/news/screens/news_form.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback? onTap;
  
  const NewsEntryCard({super.key, required this.news, this.onTap});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // --- LOGIKA CEK OTORITAS ---
    String currentUser = "";
    bool isAdmin = false;

    if (request.loggedIn && request.jsonData.containsKey('username')) {
      currentUser = request.jsonData['username'];
      isAdmin = request.jsonData['is_superuser'] ?? false;
    }

    // User boleh edit/delete jika dia adalah Author ATAU Admin
    bool canEdit = (currentUser == news.fields.author || isAdmin);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(color: Color(0xFF1F2937)),
      child: InkWell(
        // --- NAVIGASI KE DETAIL PAGE ---
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(news: news),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (Author, Time, Menu) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // --- AVATAR & AUTHOR CLICKABLE AREA ---
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Membuka profil: ${news.fields.author}"),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue[700],
                          backgroundImage: news.fields.authorPfp.isNotEmpty
                              ? NetworkImage(news.fields.authorPfp)
                              : null,
                          child: news.fields.authorPfp.isEmpty
                              ? Text(
                                  news.fields.author.isNotEmpty
                                      ? news.fields.author[0].toUpperCase()
                                      : "A",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          news.fields.author,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // --- MENU EDIT / DELETE (3 DOTS) ---
                  if (canEdit)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                      color: const Color(0xFF374151), // Warna dropdown gelap
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Aksi Edit: Ke NewsFormPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsFormPage(news: news),
                            ),
                          );
                        } else if (value == 'delete') {
                          // Aksi Delete: Tampilkan Dialog Konfirmasi
                          _showDeleteConfirmation(context, request, news);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue),
                            title: Text('Edit', style: TextStyle(color: Colors.white)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete', style: TextStyle(color: Colors.white)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    )
                  else
                    // Jika bukan author/admin, tampilkan icon biasa atau kosong
                    Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                ],
              ),
            ),

            // --- JUDUL BERITA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                news.fields.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),

            // --- GAMBAR / KONTEN ---
            const SizedBox(height: 12),
            if (news.fields.thumbnail.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                width: double.infinity,
                child: Image.network(
                  'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/proxy-image/?url=${Uri.encodeComponent(news.fields.thumbnail)}',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionPill(
                    children: [
                      const Icon(Icons.arrow_upward, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "${news.fields.newsViews}",
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
                    ],
                  ),
                  _buildActionPill(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Komentar segera hadir!")),
                      );
                    },
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Comments",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  // --- TOMBOL SHARE ---
                  _buildActionPill(
                    onTap: () {
                      Share.share(
                        "Baca berita menarik di Sporra!\n\n"
                        "${news.fields.title}\n"
                        "Oleh: ${news.fields.author}\n\n"
                        "https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/",
                        subject: news.fields.title,
                      );
                    },
                    children: [
                      const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Share",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA HAPUS BERITA ---
  void _showDeleteConfirmation(BuildContext context, CookieRequest request, NewsEntry news) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text("Hapus Berita", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Apakah Anda yakin ingin menghapus berita ini? Tindakan ini tidak dapat dibatalkan.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                
                // Panggil endpoint delete
                final response = await request.postJson(
                  "https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/delete-flutter/${news.pk}/",
                  jsonEncode({}),
                );

                if (context.mounted) {
                  if (response['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berita berhasil dihapus")),
                    );
                    // Refresh halaman list dengan cara navigasi ulang
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NewsEntryListPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? "Gagal menghapus")),
                    );
                  }
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionPill({required List<Widget> children, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.grey[800]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: children),
      ),
    );
  }
}