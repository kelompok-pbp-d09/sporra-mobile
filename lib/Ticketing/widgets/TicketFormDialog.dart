import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../Models/TicketModel.dart'; 
import '../other/EventOption.dart';

class TicketFormDialog extends StatefulWidget {
  final Ticket? ticket;
  final List<EventOption> userEvents;
  final List<Ticket> existingTickets;
  final VoidCallback onSuccess;

  const TicketFormDialog({
    Key? key,
    this.ticket,
    required this.userEvents,
    required this.existingTickets,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<TicketFormDialog> createState() => _TicketFormDialogState();
}

class _TicketFormDialogState extends State<TicketFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late TextEditingController _availableController;
  late String _ticketType;
  String? _selectedEventId;
  
  final String baseUrl = "https://afero-aqil-sporra.pbp.cs.ui.ac.id";

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.ticket?.price.toString() ?? "");
    _availableController = TextEditingController(text: widget.ticket?.available.toString() ?? "");
    _ticketType = widget.ticket?.ticketType ?? "Regular";
    _selectedEventId = widget.ticket?.eventId;

    if (widget.ticket == null && widget.userEvents.isNotEmpty) {
      _selectedEventId = widget.userEvents.first.id;
    }
  }

  // === VALIDASI DUPLIKAT ===
  bool _isDuplicate() {
    bool exists = widget.existingTickets.any((t) {
      if (widget.ticket != null && t.id == widget.ticket!.id) {
        return false; 
      }
      return t.eventId == _selectedEventId && t.ticketType == _ticketType;
    });
    return exists;
  }

  Future<void> _saveTicket() async {
    if (_isDuplicate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed: $_ticketType ticket for this event already exists!"), // EN
        ),
      );
      return;
    }

    final request = context.read<CookieRequest>();
    bool isCreate = widget.ticket == null;

    String url = isCreate
        ? '$baseUrl/ticketing/create-ticket/'
        : '$baseUrl/ticketing/edit_ticket_ajax/${widget.ticket!.id}/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode(<String, dynamic>{
          'event': isCreate ? _selectedEventId : widget.ticket!.eventId,
          'ticket_type': _ticketType,
          'price': double.parse(_priceController.text),
          'available': int.parse(_availableController.text),
        }),
      );

      if (response['success'] == true || response['status'] == 'success') {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(isCreate ? "Ticket created successfully!" : "Ticket updated successfully!"), // EN
          ),
        );
        widget.onSuccess();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed: ${response['error'] ?? response['message']}"), // EN
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCreate = widget.ticket == null;

    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        isCreate ? "Create New Ticket" : "Edit Ticket", // EN
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCreate) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Select Event", // EN
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedEventId,
                  dropdownColor: const Color(0xFF374151),
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                  items: widget.userEvents.map((EventOption event) {
                    return DropdownMenuItem<String>(
                      value: event.id,
                      child: Text(event.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedEventId = val),
                  validator: (val) =>
                      val == null ? "Please select an event first" : null, // EN
                ),
              ] else ...[
                TextFormField(
                  initialValue: widget.ticket?.eventTitle,
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(
                    labelText: "Event",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Ticket Type", // EN
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              DropdownButtonFormField<String>(
                value: ["Regular", "VIP"].contains(_ticketType)
                    ? _ticketType
                    : "Regular",
                dropdownColor: const Color(0xFF374151),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                ),
                items: ["Regular", "VIP"].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(() => _ticketType = val!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Price (Rp)", // EN
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Price is required"; // EN
                  if (double.tryParse(val) == null) return "Must be a valid number"; // EN
                  if (double.parse(val) < 0) return "Price cannot be negative"; // EN
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _availableController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Ticket Stock", // EN
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Stock is required"; // EN
                  if (int.tryParse(val) == null) return "Must be a whole number"; // EN
                  if (int.parse(val) < 0) return "Stock cannot be negative"; // EN
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)), // EN
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _saveTicket();
            }
          },
          child: Text(isCreate ? "Create" : "Save", // EN
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}