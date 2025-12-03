import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../Models/TicketModel.dart';

// === MODEL KHUSUS DROPDOWN (UI Helper) ===
class EventOption {
  final String id;
  final String title;

  EventOption({required this.id, required this.title});

  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(id: json['id'].toString(), title: json['title']);
  }
}

class AllTicketsPage extends StatefulWidget {
  const AllTicketsPage({Key? key}) : super(key: key);

  @override
  State<AllTicketsPage> createState() => _AllTicketsPageState();
}

class _AllTicketsPageState extends State<AllTicketsPage> {
  // Gunakan 10.0.2.2 untuk Emulator Android
  final String baseUrl = "http://127.0.0.1:8000";

  List<Ticket> _allTickets = [];
  List<Ticket> _filteredTickets = [];
  List<EventOption> _userEvents = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllData();
    });
    _searchController.addListener(_filterTickets);
  }

  Future<void> fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([fetchTickets(), fetchUserEvents()]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _filterTickets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        return ticket.eventTitle.toLowerCase().contains(query) ||
            ticket.ticketType.toLowerCase().contains(query);
      }).toList();
    });
  }

  // === 1. FETCH DATA TIKET ===
  Future<void> fetchTickets() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/ticketing/tickets/data/');
      final ticketEntry = TicketEntry.fromJson(response);
      if (mounted) {
        setState(() {
          _allTickets = ticketEntry.tickets;
          _filteredTickets = ticketEntry.tickets;
        });
      }
    } catch (e) {
      print("Error Fetch Tickets: $e");
    }
  }

  // === 2. FETCH EVENTS FOR DROPDOWN ===
  Future<void> fetchUserEvents() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/ticketing/get-user-events/');
      List<EventOption> list = [];
      if (response['events'] != null) {
        for (var d in response['events']) {
          list.add(EventOption.fromJson(d));
        }
      }
      if (mounted) {
        setState(() {
          _userEvents = list;
        });
      }
    } catch (e) {
      print("Error Fetch Events: $e");
    }
  }

  // === 3. CREATE & EDIT TICKET ===
  Future<void> saveTicket({
    required bool isCreate,
    int? ticketId,
    required String eventId,
    required String ticketType,
    required double price,
    required int available,
  }) async {
    final request = context.read<CookieRequest>();

    String url = isCreate
        ? '$baseUrl/ticketing/create-ticket/'
        : '$baseUrl/ticketing/edit_ticket_ajax/$ticketId/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode(<String, dynamic>{
          'event': eventId,
          'ticket_type': ticketType,
          'price': price,
          'available': available,
        }),
      );

      if (response['success'] == true || response['status'] == 'success') {
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              isCreate ? "Tiket berhasil dibuat!" : "Tiket berhasil disimpan!",
            ),
          ),
        );
        fetchTickets(); // Refresh data
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // === 4. DELETE TICKET ===
  Future<void> deleteTicket(int ticketId) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/ticketing/delete_ticket_ajax/$ticketId/';

    try {
      final response = await request.post(url, {});
      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Tiket berhasil dihapus!"),
          ),
        );
        fetchTickets();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menghapus tiket.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // === 5. BOOK TICKET ===
  Future<void> bookTicket(Ticket ticket, int quantity) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/ticketing/book/${ticket.eventId}/';

    try {
      final response = await request.post(url, {
        'ticket': ticket.id.toString(),
        'quantity': quantity.toString(),
      });

      if (response['status'] == 'success') {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("🎉 ${response['message']}"),
          ),
        );
        fetchTickets();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error koneksi: $e")));
    }
  }

  // === UI DIALOGS ===

  //  DIALOG KONFIRMASI HAPUS
  void showDeleteConfirmation(int ticketId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text(
            "Hapus Tiket",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus tiket ini? Tindakan ini tidak dapat dibatalkan.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog konfirmasi
                deleteTicket(ticketId); // Jalankan fungsi hapus
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showTicketFormDialog({Ticket? ticket}) {
    bool isCreate = ticket == null;
    final _formKey = GlobalKey<FormState>();

    if (isCreate && _userEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "Anda belum memiliki Event. Buat Event terlebih dahulu!",
          ),
        ),
      );
      return;
    }

    // Controller Setup
    TextEditingController _priceController = TextEditingController(
      text: ticket?.price.toString() ?? "",
    );
    TextEditingController _availableController = TextEditingController(
      text: ticket?.available.toString() ?? "",
    );

    String _ticketType = ticket?.ticketType ?? "Regular";
    String? _selectedEventId = ticket?.eventId;

    if (isCreate && _userEvents.isNotEmpty) {
      _selectedEventId = _userEvents.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: Text(
                isCreate ? "Buat Tiket Baru" : "Edit Tiket",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Event Dropdown
                      if (isCreate) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pilih Event",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedEventId,
                          dropdownColor: const Color(0xFF374151),
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          items: _userEvents.map((EventOption event) {
                            return DropdownMenuItem<String>(
                              value: event.id,
                              child: Text(
                                event.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setStateDialog(() => _selectedEventId = val),
                          validator: (val) => val == null
                              ? "Pilih event terlebih dahulu"
                              : null,
                        ),
                      ] else ...[
                        TextFormField(
                          initialValue: ticket?.eventTitle,
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

                      // Ticket Type Dropdown
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tipe Tiket",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: ["Regular", "VIP"].contains(_ticketType)
                            ? _ticketType
                            : "Regular",
                        dropdownColor: const Color(0xFF374151),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        items: ["Regular", "VIP"].map((String val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) =>
                            setStateDialog(() => _ticketType = val!),
                      ),
                      const SizedBox(height: 15),

                      // Price & Stock
                      TextFormField(
                        controller: _priceController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Harga (Rp)",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.isEmpty ? "Harga wajib diisi" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _availableController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Stok Tiket",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.isEmpty ? "Stok wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveTicket(
                        isCreate: isCreate,
                        ticketId: ticket?.id,
                        eventId: isCreate ? _selectedEventId! : ticket!.eventId,
                        ticketType: _ticketType,
                        price: double.parse(_priceController.text),
                        available: int.parse(_availableController.text),
                      );
                    }
                  },
                  child: Text(
                    isCreate ? "Buat" : "Simpan",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showBookingDialog(Ticket ticket) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final total = ticket.price * quantity;
            return AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: const Text(
                "Pesan Tiket",
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.eventTitle,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tipe: ${ticket.ticketType}",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jumlah:",
                        style: TextStyle(color: Colors.white),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              if (quantity > 1)
                                setStateDialog(() => quantity--);
                            },
                          ),
                          Text(
                            "$quantity",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.greenAccent,
                            ),
                            onPressed: () {
                              if (quantity < ticket.available)
                                setStateDialog(() => quantity++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Text(
                    "Total: Rp $total",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Batal"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  onPressed: () => bookTicket(ticket, quantity),
                  child: const Text(
                    "Konfirmasi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("🎫 Semua Tiket"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchAllData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        onPressed: () => showTicketFormDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari Ticket ...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Grid View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
                ? const Center(
                    child: Text(
                      "Tidak ada tiket tersedia 😔",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _filteredTickets[index];
                      final isAvailable = ticket.available > 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.eventTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ticket.ticketType,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Rp ${ticket.price}",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Sisa: ${ticket.available}",
                                style: TextStyle(
                                  color: isAvailable ? Colors.grey : Colors.red,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 8),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailable
                                        ? Colors.blue[600]
                                        : Colors.grey[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: isAvailable
                                      ? () => showBookingDialog(ticket)
                                      : null,
                                  child: Text(
                                    isAvailable ? "Pesan" : "Habis",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                              if (ticket.canEdit) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber[700],
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 36),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => showTicketFormDialog(
                                          ticket: ticket,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[700],
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 36),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        // 🛑 DI SINI KITA PANGGIL KONFIRMASI 🛑
                                        onPressed: () =>
                                            showDeleteConfirmation(ticket.id),
                                        child: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
