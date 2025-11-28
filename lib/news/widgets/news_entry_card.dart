import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(color: Color(0xFF1F2937)),
      child: InkWell(
        onTap: onTap,
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
                      // TODO: Redirect ke halaman Profile Author
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Membuka profil: ${news.fields.author}",
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        // Avatar Kecil
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
                        // Nama Author
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

                  Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                ],
              ),
            ),

            // ---  JUDUL BERITA ---
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

            // --- GAMBAR / KONTEN---
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
                      const Icon(
                        Icons.arrow_upward,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${news.fields.newsViews}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_downward,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  _buildActionPill(
                    children: [
                      const Icon(
                        Icons.mode_comment_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Comments",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildActionPill(
                    children: [
                      const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Share",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
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

  // Widget Helper untuk membuat tombol "Pill" (Lonjong)
  Widget _buildActionPill({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: children),
    );
  }
}
