// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sporra_mobile/forum/widgets/forum_entry_card.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsEntry news;
  final bool scrollToForum; // Fitur ini tetap kita simpan

  const NewsDetailPage({
    super.key, 
    required this.news, 
    this.scrollToForum = false,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  // ✅ GlobalKey disimpan di State agar tidak berubah-ubah saat rebuild
  final GlobalKey<ForumEntryCardState> forumKey = GlobalKey<ForumEntryCardState>();

  // --- PALET WARNA ---
  final Color _bgPrimary = const Color(0xFF111827);
  final Color _textPrimary = const Color(0xFFF9FAFB);
  final Color _textSecondary = const Color(0xFF9CA3AF);
  final Color _accentBlue = const Color(0xFF2563EB);
  final Color _cardBg = const Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();

    // ✅ Fitur Auto Scroll dikembalikan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollToForum) {
        forumKey.currentState?.scrollToForum();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(widget.news.fields.createdAt);

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh di child widget (ForumEntryCard)
          await forumKey.currentState?.refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryPill(),
                    const SizedBox(height: 16),
                    Text(
                      widget.news.fields.title,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAuthorInfo(formattedDate),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey[800]),
                    const SizedBox(height: 24),
                    Text(
                      widget.news.fields.content,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                    Divider(color: Colors.grey[800]),
                  ],
                ),
              ),
            ),

            // FORUM SECTION
            SliverToBoxAdapter(
              child: ForumEntryCard(
                key: forumKey, // Key disambungkan ke sini
                articleId: widget.news.pk, // Perhatikan akses widget.news.pk
                cardBg: _cardBg,
                accentBlue: _accentBlue,
                textPrimary: _textPrimary,
                
                // Opsional: Jika ingin scroll terjadi setelah data forum selesai loading
                onLoaded: () {
                   if (widget.scrollToForum) {
                     forumKey.currentState?.scrollToForum();
                   }
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Share.share(
            "Baca berita menarik di Sporra!\n\n${widget.news.fields.title}\nhttps://afero-aqil-sporra.pbp.cs.ui.ac.id/news/",
            subject: widget.news.fields.title,
          );
        },
        backgroundColor: _accentBlue,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accentBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentBlue.withOpacity(0.5)),
      ),
      child: Text(
        widget.news.fields.category.toUpperCase(),
        style: TextStyle(
          color: _accentBlue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(String formattedDate) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _accentBlue,
          backgroundImage: (widget.news.fields.authorPfp.isNotEmpty)
              ? NetworkImage(widget.news.fields.authorPfp)
              : null,
          child: (widget.news.fields.authorPfp.isEmpty)
              ? Text(
                  widget.news.fields.author.isNotEmpty
                      ? widget.news.fields.author[0].toUpperCase()
                      : "A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.news.fields.author,
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: _bgPrimary,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black54,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.news.fields.thumbnail.isNotEmpty
                ? Image.network(
                    'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/proxy-image/?url=${Uri.encodeComponent(widget.news.fields.thumbnail)}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  )
                : Container(color: _accentBlue),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xAA111827)],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}