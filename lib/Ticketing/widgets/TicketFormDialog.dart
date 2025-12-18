import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../Models/TicketModel.dart'; 
import '../other/EventOption.dart';

class TicketFormDialog extends StatefulWidget {
  final Ticket? ticket;
  final List<EventOption> userEvents;
  final List<Ticket> existingTickets; // <--- TAMBAHAN: Data tiket yg sudah ada
  final VoidCallback onSuccess;

  const TicketFormDialog({
    Key? key,
    this.ticket,
    required this.userEvents,
    required this.existingTickets, // <--- Wajib diisi
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

  // === FUNGSI VALIDASI DUPLIKAT ===
  bool _isDuplicate() {
    // Cek apakah ada tiket lain dengan Event ID sama DAN Tipe Tiket sama
    bool exists = widget.existingTickets.any((t) {
      // Jangan cek tiket diri sendiri saat mode Edit
      if (widget.ticket != null && t.id == widget.ticket!.id) {
        return false; 
      }
      return t.eventId == _selectedEventId && t.ticketType == _ticketType;
    });

    return exists;
  }

  Future<void> _saveTicket() async {
    // 1. CEK VALIDASI DUPLIKAT DISINI
    if (_isDuplicate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal: Tiket $_ticketType untuk event ini sudah ada!"),
        ),
      );
      return; // Stop, jangan lanjut ke backend
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
            content: Text(isCreate ? "Tiket berhasil dibuat!" : "Tiket berhasil disimpan!"),
          ),
        );
        widget.onSuccess();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Gagal: ${response['error'] ?? response['message']}"),
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
        isCreate ? "Buat Tiket Baru" : "Edit Tiket",
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
                  child: Text("Pilih Event",
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
                      val == null ? "Pilih event terlebih dahulu" : null,
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
                child: Text("Tipe Tiket",
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
                  labelText: "Harga (Rp)",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Harga wajib diisi";
                  if (double.tryParse(val) == null) return "Harus angka valid";
                  if (double.parse(val) < 0) return "Tidak boleh negatif";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _availableController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Stok Tiket",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Stok wajib diisi";
                  if (int.tryParse(val) == null) return "Harus angka bulat";
                  if (int.parse(val) < 0) return "Tidak boleh negatif";
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Batal", style: TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _saveTicket();
            }
          },
          child: Text(isCreate ? "Buat" : "Simpan",
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}