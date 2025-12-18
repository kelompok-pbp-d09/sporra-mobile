import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../Models/TicketModel.dart'; 

class BookingDialog extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onSuccess;

  const BookingDialog({
    Key? key,
    required this.ticket,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  int _quantity = 1;
  final String baseUrl = "https://afero-aqil-sporra.pbp.cs.ui.ac.id";

  Future<void> _bookTicket() async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/ticketing/book/${widget.ticket.eventId}/';

    try {
      final response = await request.post(url, {
        'ticket': widget.ticket.id.toString(),
        'quantity': _quantity.toString(),
      });

      if (response['status'] == 'success') {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Ticket booked successfully! Thank you!"), 
          ),
        );
        widget.onSuccess(); // Refresh main page
      } else {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("❌ ${response['message']}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")), // EN
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.ticket.price * _quantity;
    final isVIP = widget.ticket.ticketType == "VIP";

    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Book Ticket", // EN
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.ticket.eventTitle,
            style: const TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVIP ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isVIP ? Colors.amber : Colors.blueAccent,
              ),
            ),
            child: Text(
              widget.ticket.ticketType,
              style: TextStyle(
                color: isVIP ? Colors.amber : Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Quantity:", style: TextStyle(color: Colors.white70)), // EN
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle,
                        color: _quantity > 1 ? Colors.redAccent : Colors.grey),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(
                    "$_quantity",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: _quantity < widget.ticket.available
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                    onPressed: () {
                      if (_quantity < widget.ticket.available) {
                        setState(() => _quantity++);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:", style: TextStyle(color: Colors.white, fontSize: 16)), // EN
              Text(
                "Rp ${total.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)), // EN
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
          onPressed: _bookTicket,
          child: const Text("Confirm", style: TextStyle(color: Colors.white)), // EN
        ),
      ],
    );
  }
}