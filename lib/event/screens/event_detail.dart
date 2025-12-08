import 'package:flutter/material.dart';
import 'package:sporra_mobile/event/models/event_entry.dart';
import 'package:sporra_mobile/event/screens/edit_event.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  final bool hasEnded;
  final bool isOwnerOrAdmin;

  const EventDetailPage({
    super.key,
    required this.event,
    required this.hasEnded,
    required this.isOwnerOrAdmin,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final Color _bgPrimary = const Color(0xFF111827);
  final Color _cardBg = const Color(0xFF1F2937);
  final Color _accentBlue = const Color(0xFF2563EB);

  Future<void> _deleteEvent(CookieRequest request) async {
    try {
      final response = await request.post(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/event/${widget.event.id}/delete/',
        {},
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // error handling
    }
  }

  void _showDeleteConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text(
          'Hapus Event?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Event akan dihapus permanen.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(request);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final dateColor = widget.hasEnded ? Colors.red[300] : Colors.grey[300];

    return Scaffold(
      backgroundColor: _bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
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
              background: Container(
                color: _cardBg,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event, size: 80, color: Colors.grey[700]),
                      if (widget.hasEnded)
                        Text(
                          "EVENT ENDED",
                          style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Detail
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.judul,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accentBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentBlue.withOpacity(0.5)),
                    ),
                    child: Text(
                      widget.event.kategoriDisplay.toUpperCase(),
                      style: TextStyle(
                        color: _accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInfoRow(
                    Icons.location_on,
                    widget.event.lokasi,
                    Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    widget.hasEnded ? Icons.cancel : Icons.access_time,
                    widget.event.dateFormatted,
                    dateColor!,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Created by: ${widget.event.username ?? 'Anonymous'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[800]),
                  const SizedBox(height: 24),

                  Text(
                    widget.event.deskripsi,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (!widget.hasEnded)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "🎟️ Join Sekarang!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (widget.isOwnerOrAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventEditPage(event: widget.event),
                                  ),
                                );

                                if (result == true && context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Edit"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showDeleteConfirmation(context, request),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                              ),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 15)),
        ),
      ],
    );
  }
}
