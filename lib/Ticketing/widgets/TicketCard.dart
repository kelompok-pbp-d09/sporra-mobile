import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../Models/TicketModel.dart';

class TicketCard extends StatefulWidget {
  final Ticket ticket;
  final CookieRequest request;
  final VoidCallback onBook;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool Function() requireLogin;

  const TicketCard({
    Key? key,
    required this.ticket,
    required this.request,
    required this.onBook,
    required this.onEdit,
    required this.onDelete,
    required this.requireLogin,
  }) : super(key: key);

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final isAvailable = ticket.available > 0;
    final isVIP = ticket.ticketType.toUpperCase() == "VIP";
    final themeColor = isVIP ? const Color(0xFFFFD700) : Colors.blueAccent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isVIP ? Colors.amber.withOpacity(0.5) : Colors.grey[800]!,
                width: isVIP ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // === 1. DEKORASI BACKGROUND (WATERMARK) ===
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Transform.rotate(
                    angle: -0.2, // Miringkan sedikit
                    child: Icon(
                      isVIP ? Icons.star : Icons.confirmation_number,
                      size: 140, // Ukuran SANGAT BESAR
                      color: isVIP
                          ? Colors.amber.withOpacity(0.05)
                          : Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),

                // === 2. KONTEN UTAMA ===
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.local_activity, size: 16, color: themeColor),
                          Text(ticket.ticketType.toUpperCase(),
                              style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // JUDUL EVENT
                            Text(
                              ticket.eventTitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isVIP ? const Color(0xFFFFE082) : Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.1,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                            const SizedBox(height: 8),

                            // HARGA
                            Text("Rp ${ticket.price.toStringAsFixed(0)}",
                                style: TextStyle(
                                    color: Colors.green[400],
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18)),
                            
                            const SizedBox(height: 4),
                            
                            // STOK
                            Row(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 14,
                                    color: isAvailable ? Colors.grey : Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                    isAvailable
                                        ? "${ticket.available} Available" // EN
                                        : "Sold Out", // EN
                                    style: TextStyle(
                                        color: isAvailable ? Colors.grey : Colors.red,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAvailable ? themeColor : Colors.grey[700],
                                foregroundColor:
                                    (isVIP && isAvailable) ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                              ),
                              onPressed: isAvailable
                                  ? () {
                                      if (!widget.requireLogin()) return;
                                      widget.onBook();
                                    }
                                  : null,
                              child: Text(
                                isAvailable ? "Book Now" : "Sold Out", // EN
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          if (widget.request.loggedIn && widget.ticket.canEdit) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildIconButton(
                                    icon: Icons.edit,
                                    color: Colors.white,
                                    bgColor: Colors.grey[800]!,
                                    onTap: widget.onEdit,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildIconButton(
                                    icon: Icons.delete,
                                    color: Colors.red[300]!,
                                    bgColor: Colors.red[900]!.withOpacity(0.3),
                                    onTap: widget.onDelete,
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      required Color color,
      required Color bgColor,
      required VoidCallback onTap}) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}