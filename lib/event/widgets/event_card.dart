import 'package:flutter/material.dart';
import 'package:sporra_mobile/event/models/event_entry.dart' as event_model;
import 'package:sporra_mobile/event/screens/event_detail.dart';

class EventCard extends StatelessWidget {
  final event_model.Event event;
  final bool isPast;
  final int? currentUserId;
  final VoidCallback onTapDetail;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.isPast,
    required this.currentUserId,
    required this.onTapDetail,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPast
        ? const Color(0xFF374151).withOpacity(0.8)
        : const Color(0xFF1F2937);

    final dateColor = isPast ? Colors.red[300] : Colors.grey[300];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTapDetail,
        child: Card(
          color: bgColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isPast ? Colors.grey.shade700 : Colors.grey.shade800,
            ),
          ),
          child: Stack(
            children: [
              // Delete
              if (currentUserId != null &&
                  event.userId != null &&
                  currentUserId == event.userId)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Divider(
                      color: isPast ? Colors.grey[500] : Colors.grey[700],
                      thickness: 1,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      event.kategoriDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 5),

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
                            event.lokasi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          isPast ? Icons.cancel : Icons.access_time,
                          size: 16,
                          color: dateColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.dateFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: dateColor),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTapDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Selengkapnya",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
