import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/authentication/login.dart';
import 'package:sporra_mobile/forum/models/forum_entry.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/screens/news_detail.dart';
import 'package:sporra_mobile/forum/screens/forum_form.dart';


typedef ForumRefresh = Future<void> Function();

class ForumEntryCard extends StatefulWidget {
  final String articleId;
  final Color cardBg;
  final Color accentBlue;
  final Color textPrimary;
  final ForumRefresh? onRefresh;

  const ForumEntryCard({
    super.key,
    required this.articleId,
    required this.cardBg,
    required this.accentBlue,
    required this.textPrimary,
    this.onRefresh,
  });

  @override
  State<ForumEntryCard> createState() => ForumEntryCardState();
}

class ForumEntryCardState extends State<ForumEntryCard> {
  bool isLoading = true;
  List<dynamic> topForums = [];
  List<NewsEntry> hottestArticles = [];
  List<dynamic> comments = [];
  String sort = "Best";

  @override
  void initState() {
    super.initState();
    fetchForum();
  }

  Future<void> refresh() async => fetchForum();

  Future<void> fetchForum() async {
    try {
      final request = context.read<CookieRequest>();
      final data = await request.get(
          "https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/${widget.articleId}/json/"
      );

      final forum = ForumEntry.fromJson(data);

      final safeComments = forum.comments.map((c) => {
        "id": c.id,
        "author": c.author,
        "content": c.content,
        "score": c.score,
        "created_at": c.createdAt.toIso8601String(),
        "user_vote": c.userVote,
        "can_modify": c.canModify,
      }).toList();

      final safeTopForums =
          (data["top_forums"] as List?)
              ?.where((f) => f != null && f["article"] != null)
              .toList()
              ?? [];

      final safeHottest =
          (data["hottest_articles"] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => NewsEntry.fromJson(e))
              .toList()
              ?? [];

      setState(() {
        comments = safeComments;
        topForums = safeTopForums;
        hottestArticles = safeHottest;
        _applySorting();
        isLoading = false;
      });
    } catch (e, s) {
      setState(() {
        isLoading = false;
      });
    }
  }



  // SORTING
  void _applySorting() {
    if (sort == "Best") {
      comments.sort((a, b) => (b["score"] ?? 0).compareTo(a["score"] ?? 0));
    } else if (sort == "New") {
      comments.sort((a, b) {
        final da = DateTime.tryParse(a["created_at"] ?? "") ?? DateTime(2000);
        final db = DateTime.tryParse(b["created_at"] ?? "") ?? DateTime(2000);
        return db.compareTo(da);
      });
    }
  }

  // TIME AGO
  String timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${t.day}/${t.month}/${t.year}";
  }

  // EDIT
  Future<void> _editCommentRequest(int id, String newContent) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      "https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/edit_comment/$id/",
      {"content": newContent},
    );

    if (response["success"] == true) {
      await fetchForum();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment successfully changed")),
      );
    }
  }

  // DELETE
  Future<void> _deleteCommentRequest(int id) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      "https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/delete_comment/$id/",
      {},
    );

    if (response["success"] == true) {
      await fetchForum();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment successfully deleted")),
      );
    }
  }

  // VOTING
  Future<void> _voteComment(int id, int value) async {
    final req = context.read<CookieRequest>();

    if (!req.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must log in to vote.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    final idx = comments.indexWhere((c) => c["id"] == id);
    int prev = idx != -1 ? comments[idx]["user_vote"] ?? 0 : 0;

    String type;
    if (value == 1) type = "up";
    else if (value == -1) type = "down";
    else type = prev == 1 ? "up" : prev == -1 ? "down" : "up";

    final res = await req.post(
      "https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/post/$id/vote/",
      {"vote": type},
    );

    if (res.containsKey("score")) {
      setState(() {
        comments[idx]["score"] = res["score"];
        comments[idx]["user_vote"] = res["user_vote"];
        _applySorting();
      });
    }
  }

  // POPUP MENU
  void _showEditDialog(dynamic c) {
    final ctrl = TextEditingController(text: c["content"] ?? "");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: widget.cardBg,
        title: const Text("Edit Comment", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Write a comment...",
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _editCommentRequest(c["id"], ctrl.text.trim());
              }
            },
            child: Text("Save", style: TextStyle(color: widget.accentBlue)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(dynamic c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: widget.cardBg,
        title: const Text("Delete comment?", style: TextStyle(color: Colors.white)),
        content: const Text("This action can't be undone", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCommentRequest(c["id"]);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Discussion (${comments.length})",
            style: TextStyle(
              color: widget.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<String>(
            value: sort,
            dropdownColor: widget.cardBg,
            underline: Container(height: 0),
            icon: Icon(Icons.sort, color: Colors.grey[400]),
            style: TextStyle(color: Colors.grey[300]),
            items: const ["Best", "New"]
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() {
              sort = v!;
              _applySorting();
            }),
          ),
        ],
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      color: widget.accentBlue,
      backgroundColor: widget.cardBg,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),

            if (comments.isEmpty)
              _buildEmptyState(),

            if (comments.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (_, i) => _buildCommentCard(comments[i]),
              ),

            // 🔥 FORM TAMBAH KOMENTAR
            ForumForm(
              articleId: widget.articleId,
              onSuccess: () async {
                await fetchForum();
              },
            ),

            const SizedBox(height: 16),

            _buildTopForums(),
            _buildHottestArticles(),
          ],
        ),
      ),
    );
  }


    // EMPTY STATE
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:

      20, vertical: 30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF27272A)),
        ),
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              "No discussions yet",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Be the first to start this interesting discussion!",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // COMMENT CARD
  Widget _buildCommentCard(dynamic c) {
    final created = DateTime.tryParse(c["created_at"] ?? "") ?? DateTime.now();
    final request = context.read<CookieRequest>();
    final currentUser = request.jsonData["username"];
    final isOwner = c["author"] == currentUser;
    final canModify = c["can_modify"] ?? false;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262626)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT VOTE COLUMN
          Column(
            children: [
              GestureDetector(
                onTap: () => _voteComment(c["id"], 1),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 28,
                  color: c["user_vote"] == 1 ? Colors.blue : Colors.grey[400],
                ),
              ),
              Text(
                (c["score"] ?? 0).toString(),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              GestureDetector(
                onTap: () => _voteComment(c["id"], -1),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 28,
                  color: c["user_vote"] == -1 ? Colors.red : Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // COMMENT BODY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            c["author"] ?? "unknown",
                            style: TextStyle(
                              color: widget.accentBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• ${timeAgo(created)}",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Popup menu stays vertically centered
                    if (isOwner || canModify)
                      PopupMenuButton<int>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
                        color: widget.cardBg,
                        onSelected: (value) {
                          if (value == 1) _showEditDialog(c);
                          if (value == 2) _confirmDelete(c);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 1,
                            child: Text("Edit", style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  c["content"] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),

                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopForums() {
    if (topForums.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Forum",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(topForums.length, (i) {
            final f = topForums[i];
            final articleJson = f["article"];

            if (articleJson is! Map<String, dynamic>) {
              return const SizedBox();
            }

            final news = NewsEntry.fromJson(articleJson);


            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailPage(news: news),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${i + 1}",
                      style: TextStyle(
                        color: widget.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.fields.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${f["post_count"]} Komentar",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }




  Widget _buildHottestArticles() {
    if (hottestArticles.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hot Articles",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...hottestArticles.map((news) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailPage(news: news),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  news.fields.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }



}