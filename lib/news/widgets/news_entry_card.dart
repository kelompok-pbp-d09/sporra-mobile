import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryCard({super.key, required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Memberi jarak antar kartu agar background scaffold (gelap banget) terlihat sebagai pemisah
      margin: const EdgeInsets.only(bottom: 8.0), 
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937), // Warna Card (Dark Gray - mirip Reddit Dark Mode)
        // Tidak perlu border radius besar ala Reddit mobile web, 
        // tapi kalau mau rounded sedikit di sudut:
        // borderRadius: BorderRadius.circular(0), 
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- 1. HEADER (Author, Time, Menu) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Avatar Kecil
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue[700], // Warna aksen
                    child: Text(
                      news.fields.author != null ? "A" : "U", // Inisial Author (Dummy)
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Nama Author / Subreddit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "u/${news.fields.author}", // Format ala Reddit
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Tombol Join / Titik Tiga
                  Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                ],
              ),
            ),

            // --- 2. JUDUL BERITA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                news.fields.title,
                style: const TextStyle(
                  color: Colors.white, // Judul Putih Terang
                  fontSize: 18, // Sedikit lebih besar
                  fontWeight: FontWeight.w600,
                  height: 1.3, // Jarak antar baris teks
                ),
              ),
            ),
            
            // --- 3. GAMBAR / KONTEN (Dynamic Height) ---
            const SizedBox(height: 12),
            if (news.fields.thumbnail.isNotEmpty)
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 500, // Batasi tinggi maksimal agar gambar super panjang tidak merusak UI
                ),
                width: double.infinity,
                child: Image.network(
                  // URL Proxy
                  'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/proxy-image/?url=${Uri.encodeComponent(news.fields.thumbnail)}',
                  
                  // Fit.contain atau fitWidth membiarkan aspek rasio asli
                  fit: BoxFit.cover, 
                  
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200, // Tinggi placeholder saat loading
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Jika error, sembunyikan gambar (return empty box)
                    return const SizedBox.shrink(); 
                  },
                ),
              ),

            // --- 4. FOOTER (Action Buttons ala Reddit) ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Vote Pill
                  _buildActionPill(
                    children: [
                      const Icon(Icons.arrow_upward, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "${news.fields.newsViews}", // Menggunakan Views sebagai 'Vote' count
                        style: const TextStyle(
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
                    ],
                  ),

                  // Tombol Comment Pill
                  _buildActionPill(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Comments", 
                        style: TextStyle(
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),

                  // Tombol Share Pill
                  _buildActionPill(
                    children: [
                      const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        "Share", 
                        style: TextStyle(
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold
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
        color: Colors.transparent, // Reddit modern pakai transparan atau abu sangat gelap
        border: Border.all(color: Colors.grey[800]!), // Border tipis
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: children,
      ),
    );
  }
}