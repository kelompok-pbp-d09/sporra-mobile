// ignore_for_file: deprecated_member_use
// TODO: Connect forum API ke news

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsDetailPage extends StatefulWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final Color _bgPrimary = const Color(0xFF111827);
  final Color _textPrimary = const Color(0xFFF9FAFB);
  final Color _textSecondary = const Color(0xFF9CA3AF);
  final Color _accentBlue = const Color(0xFF2563EB);
  final Color _cardBg = const Color(0xFF1F2937);

  bool isLoading = true;
  List<dynamic> comments = [];
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchForum();
  }

  Future<void> fetchForum() async {
    final articleId = widget.news.pk;
    final url = Uri.parse("http://localhost:8000/forum/$articleId/json/");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          comments = data["comments"];
          commentCount = comments.length;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = widget.news;
    final String formattedDate =
    DateFormat('dd MMM yyyy, HH:mm').format(news.fields.createdAt);

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryPill(news),
                  const SizedBox(height: 16),
                  Text(
                    news.fields.title,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAuthorInfo(formattedDate, news),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[800]),
                  const SizedBox(height: 24),
                  Text(
                    news.fields.content,
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

          // --- HEADER DISKUSI ---
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Diskusi ($commentCount)",
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: "Best",
                    dropdownColor: _cardBg,
                    underline: Container(),
                    icon: Icon(Icons.sort, color: _textSecondary),
                    style: TextStyle(color: _textSecondary),
                    items: ["Best", "New", "Top"].map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),

          // --- KOMENTAR ---
          _buildCommentSection(),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Share.share(
            "Baca berita menarik di Sporra!\n\n${news.fields.title}\nhttp://localhost:8000/news/",
            subject: news.fields.title,
          );
        },
        backgroundColor: _accentBlue,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  // ===============================================================
  // WIDGET COMMENT SECTION
  // ===============================================================

  Widget _buildCommentSection() {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48, color: Colors.grey[600]),
              const SizedBox(height: 16),
              const Text(
                "Belum ada diskusi",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Jadilah yang pertama memulai diskusi menarik ini!",
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Jika ada komentar
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final c = comments[index];
          return _buildCommentCard(c);
        },
        childCount: comments.length,
      ),
    );
  }

  Widget _buildCommentCard(dynamic c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c["author"],
            style: TextStyle(
              color: _accentBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            c["content"],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                c["score"].toString(),
                style: TextStyle(color: Colors.grey[300]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUPPORTING WIDGETS
  // ===============================================================

  Widget _buildCategoryPill(NewsEntry news) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accentBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentBlue.withOpacity(0.5)),
      ),
      child: Text(
        news.fields.category.toUpperCase(),
        style: TextStyle(
          color: _accentBlue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(String formattedDate, NewsEntry news) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _accentBlue,
          backgroundImage: (news.fields.authorPfp.isNotEmpty)
              ? NetworkImage(news.fields.authorPfp)
              : null,
          child: (news.fields.authorPfp.isEmpty)
              ? Text(
            news.fields.author.isNotEmpty
                ? news.fields.author[0].toUpperCase()
                : "A",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.fields.author,
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final news = widget.news;

    return SliverAppBar(
      expandedHeight: 300,
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
            news.fields.thumbnail.isNotEmpty
                ? Image.network(
              'http://localhost:8000/news/proxy-image/?url=${Uri.encodeComponent(news.fields.thumbnail)}',
              fit: BoxFit.cover,
            )
                : Container(color: _accentBlue),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xAA111827),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}