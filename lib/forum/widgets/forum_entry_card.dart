import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/forum_entry.dart';

class ForumEntryCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ForumEntryCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ForumEntryCard> createState() => _ForumEntryCardState();
}

class _ForumEntryCardState extends State<ForumEntryCard> {
  late int score;

  @override
  void initState() {
    super.initState();
    score = widget.comment.score;
  }

  Future<void> _sendVote(String voteType) async {
    // Akses 'context' langsung dari properti State
    final request = context.read<CookieRequest>();

    final response = await request.postJson(
      "https://afero-aqil-sporra.pbp.cs.ui.ac.id/forum/post/${widget.comment.id}/vote/",
      {"vote": voteType},
    );

    if (!mounted) return;

    if (response["status"] == "success") {
      setState(() {
        score = response["new_score"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[600],
          content: Text("Gagal vote: ${response['message'] ?? 'error'}"),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    String currentUser = "";
    bool isAdmin = false;

    if (request.loggedIn && request.jsonData.containsKey('username')) {
      currentUser = request.jsonData['username'];
      isAdmin = request.jsonData['is_superuser'] ?? false;
    }

    bool canEdit = (currentUser == widget.comment.author || isAdmin);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- Voting Column -----
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _sendVote("up"),
                    child: const Icon(Icons.arrow_drop_up,
                        color: Colors.grey, size: 32),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      "$score",
                      key: ValueKey(score),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _sendVote("down"),
                    child: const Icon(Icons.arrow_drop_down,
                        color: Colors.grey, size: 32),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // ----- Content Area -----
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AUTHOR + MENU
                    Row(
                      children: [
                        Text(
                          "@${widget.comment.author}",
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (canEdit)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz,
                                color: Colors.grey, size: 20),
                            color: const Color(0xFF374151),
                            onSelected: (value) {
                              if (value == "edit" && widget.onEdit != null) {
                                widget.onEdit!();
                              }
                              if (value == "delete" && widget.onDelete != null) {
                                widget.onDelete!();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Text("Edit",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text("Delete",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                      ],
                    ),

                    const SizedBox(height: 6),

                    // COMMENT TEXT
                    Text(
                      widget.comment.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _formatDate(widget.comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];

    return "${dt.day} ${months[dt.month - 1]} ${dt.year}, "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
