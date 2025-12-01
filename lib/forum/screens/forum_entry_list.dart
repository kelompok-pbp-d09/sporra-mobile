import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/forum/models/forum_entry.dart';
import 'package:sporra_mobile/forum/widgets/forum_entry_card.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';

class ForumEntryListPage extends StatefulWidget {
  final String newsId;
  const ForumEntryListPage({super.key, required this.newsId});

  @override
  State<ForumEntryListPage> createState() => _ForumEntryListPageState();
}

class _ForumEntryListPageState extends State<ForumEntryListPage> {
  late Future<ForumEntry> _forumData;
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _forumData = fetchForumData();
  }

  void _refreshForumData() {
    setState(() {
      _forumData = fetchForumData();
    });
  }

  Future<ForumEntry> fetchForumData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/json/${widget.newsId}/',
      );
      return ForumEntry.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching forum data: $e');
      throw Exception('Gagal memuat data forum. Silakan coba lagi.');
    }
  }

  Future<void> postComment() async {
    final request = context.read<CookieRequest>();
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong.')),
      );
      return;
    }

    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk berkomentar.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final response = await request.postJson(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/add_comment_flutter/${widget.newsId}/',
        jsonEncode({'content': content}),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          _commentController.clear();
          _refreshForumData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Komentar berhasil ditambahkan!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal menambahkan komentar.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error posting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan. Coba lagi nanti.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // --- LOGIKA UNTUK EDIT DAN DELETE ---
  void _handleDeleteComment(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final request = context.read<CookieRequest>();
              final response = await request.postJson(
                'https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/delete_comment_flutter/$commentId/',
                jsonEncode({}), // Kirim body kosong jika diperlukan
              );
              if (mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar berhasil dihapus.')),
                  );
                  _refreshForumData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Gagal menghapus komentar.')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleEditComment(Comment comment) {
    final editController = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Komentar'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: null, // Memungkinkan input multiline
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final newContent = editController.text.trim();
              if (newContent.isEmpty) return;

              final request = context.read<CookieRequest>();
              final response = await request.postJson(
                'https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/edit_comment_flutter/${comment.id}/',
                jsonEncode({'content': newContent}),
              );

              if (mounted) {
                if (response['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar berhasil diperbarui.')),
                  );
                  _refreshForumData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Gagal mengedit komentar.')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgDark = const Color(0xFF111827);
    final Color cardDark = const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        backgroundColor: cardDark,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ForumEntry>(
        future: _forumData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center));
          } else if (snapshot.hasData) {
            final forumData = snapshot.data!;
            final NewsEntry article = forumData.article;
            final List<Comment> comments = forumData.comments;

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      _buildArticleHeader(article, cardDark),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Komentar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (comments.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final currentComment = comments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: ForumEntryCard(
                                  comment: currentComment,
                                  onEdit: () => _handleEditComment(currentComment),
                                  onDelete: () => _handleDeleteComment(currentComment.id),
                                ),
                              );
                            },
                            childCount: comments.length,
                          ),
                        )
                      else
                        const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('Jadilah yang pertama berkomentar!', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildCommentInputField(cardDark),
              ],
            );
          } else {
            return const Center(child: Text('Data tidak ditemukan.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildArticleHeader(NewsEntry article, Color cardDark) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.fields.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8), 
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Text(article.fields.content, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputField(Color cardDark) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: cardDark,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 8),
          _isPosting
              ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
              : IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: postComment),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}