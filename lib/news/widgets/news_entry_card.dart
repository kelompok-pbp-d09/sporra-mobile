// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/screens/news_detail.dart';
import 'package:sporra_mobile/news/screens/edit_news_form.dart';
import 'package:sporra_mobile/authentication/user_provider.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh; // 1. Tambahkan parameter ini

  const NewsEntryCard({
    super.key,
    required this.news,
    this.onTap,
    this.onRefresh, // 2. Masukkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();

    String currentUsername = userProvider.username;
    bool isAdmin = userProvider.isAdmin;

    bool isAuthor = currentUsername.isNotEmpty && news.fields.author == currentUsername;
    bool showMenu = isAdmin || isAuthor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(color: Color(0xFF1F2937)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Membuka profil: ${news.fields.author}")),
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
                              style: const TextStyle(fontSize: 12, color: Colors.white),
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

                    // --- MENU TITIK TIGA ---
                    if (showMenu)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                        color: const Color(0xFF374151),
                        padding: EdgeInsets.zero,
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNewsPage(news: news),
                              ),
                            );
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, request);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.white),
                              title: Text('Edit', style: TextStyle(color: Colors.white)),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.redAccent),
                              title: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
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

              const SizedBox(height: 12),

              // --- GAMBAR ---
              if (news.fields.thumbnail != null && news.fields.thumbnail.trim().isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  width: double.infinity,
                  child: Image.network(
                    'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/proxy-image/?url=${Uri.encodeComponent(news.fields.thumbnail)}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.grey[800]),
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
                        const Icon(Icons.remove_red_eye_sharp, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "${news.fields.newsViews}",
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    _buildActionPill(
                      onTap: () {
                        Share.share(
                          "Read interesting sport news on Sporra!\n\n${news.fields.title}\nOleh: ${news.fields.author}\n\nhttps://afero-aqil-sporra.pbp.cs.ui.ac.id/news/",
                          subject: news.fields.title,
                        );
                      },
                      children: [
                        const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text("Share", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- DIALOG KONFIRMASI DELETE ---
  void _showDeleteConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text('News deletion confirmation', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this news?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _deleteNews(context, request);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI API DELETE ---
  Future<void> _deleteNews(BuildContext context, CookieRequest request) async {
    final url = 'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/delete-flutter/${news.pk}/';

    try {
      final response = await request.post(url, {});

      // 3. PERBAIKAN: Gunakan boolean `true`
      if (response['status'] == true || response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("News successfully deleted!"),
            backgroundColor: Colors.green,
          ),
        );

        // 4. PANGGIL CALLBACK PARENT UNTUK REFRESH
        if (onRefresh != null) {
          onRefresh!();
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete: ${response['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildActionPill({required List<Widget> children, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
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