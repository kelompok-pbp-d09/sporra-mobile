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
  Future<void> _deleteEvent(CookieRequest request) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/event/event/${widget.event.id}/delete/',
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
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menghapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Hapus Event?', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                const TextSpan(text: 'Event "'),
                TextSpan(
                  text: widget.event.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      '" akan dihapus secara permanen dan tidak dapat dikembalikan.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              onPressed: () {
                Navigator.pop(context);
                _deleteEvent(request);
              },
              child: const Text('Hapus Event'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final bgColor = widget.hasEnded
        ? const Color(0xFF374151).withOpacity(0.8)
        : const Color(0xFF1F2937);

    final dateColor = widget.hasEnded ? Colors.red[300] : Colors.grey[300];

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("SPORRA"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            FloatingActionButton(
              mini: true,
              backgroundColor: Colors.grey[700]?.withOpacity(0.8),
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.hasEnded
                      ? Colors.grey.shade700
                      : Colors.grey.shade800,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.judul,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: widget.hasEnded
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    thickness: 1,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.event.kategoriDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.event.lokasi,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        widget.hasEnded ? Icons.cancel : Icons.access_time,
                        size: 16,
                        color: dateColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.event.dateFormatted,
                          style: TextStyle(color: dateColor, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.deskripsi,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Join
                  if (!widget.hasEnded)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                  if (widget.hasEnded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Acara ini telah selesai. Terima kasih atas ketertarikannya!",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    "Pembuat acara: ${widget.event.username ?? 'Anonymous'}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  if (widget.isOwnerOrAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventEditPage(event: widget.event),
                                ),
                              );
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Edit Event"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                            ),
                            onPressed: () {
                              _showDeleteConfirmation(context, request);
                            },
                            child: const Text("Hapus Event"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
