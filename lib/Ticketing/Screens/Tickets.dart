import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../Models/Ticketmodel.dart'; 

class AllTicketsPage extends StatefulWidget {
  const AllTicketsPage({Key? key}) : super(key: key);

  @override
  State<AllTicketsPage> createState() => _AllTicketsPageState();
}

class _AllTicketsPageState extends State<AllTicketsPage> {
  // Gunakan 10.0.2.2 untuk Emulator Android, atau localhost untuk Web
  final String baseUrl = "http://localhost:8000"; 
  
  List<Ticket> _allTickets = [];
  List<Ticket> _filteredTickets = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTickets();
    });
    _searchController.addListener(_filterTickets);
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

  // === FETCH DATA ===
  Future<void> fetchTickets() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);
    
    try {
      // request.get otomatis mengembalikan JSON Decode (Map<String, dynamic>)
      final response = await request.get('$baseUrl/ticketing/tickets/data/');
      
      // Parsing menggunakan Model TicketEntry
      final ticketEntry = TicketEntry.fromJson(response);
      
      setState(() {
        _allTickets = ticketEntry.tickets;
        _filteredTickets = ticketEntry.tickets; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    }
  }

  // === BOOKING FUNCTION ===
  Future<void> bookTicket(Ticket ticket, int quantity) async {
    final request = context.read<CookieRequest>();
    // URL menggunakan UUID Event ID sesuai Ticket model
    final url = '$baseUrl/ticketing/book/${ticket.eventId}/';

    try {
      final response = await request.post(url, {
        'ticket': ticket.id.toString(), // ID Tiket (Integer)
        'quantity': quantity.toString(),
      });

      if (response['status'] == 'success') {
        Navigator.pop(context); // Tutup Dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("🎉 ${response['message']}"),
          backgroundColor: Colors.green,
        ));
        fetchTickets(); // Refresh data stok
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ ${response['message']}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error koneksi")));
    }
  }

  // === DIALOG UI ===
  void showBookingDialog(Ticket ticket) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final total = ticket.price * quantity;
          return AlertDialog(
            backgroundColor: const Color(0xFF1F2937), // Gray-800
            title: const Text("Pesan Tiket", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.eventTitle, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Text("Tipe: ${ticket.ticketType}", style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jumlah:", style: TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                          onPressed: () {
                            if (quantity > 1) setStateDialog(() => quantity--);
                          },
                        ),
                        Text("$quantity", style: const TextStyle(color: Colors.white, fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                          onPressed: () {
                            if (quantity < ticket.available) setStateDialog(() => quantity++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.grey),
                Text("Total: Rp $total", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(child: const Text("Batal"), onPressed: () => Navigator.pop(context)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                onPressed: () => bookTicket(ticket, quantity),
                child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Gray-900
      appBar: AppBar(
        title: const Text("🎫 Semua Tiket"),
        backgroundColor: const Color(0xFF1F2937), // Gray-800
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchTickets)
        ],
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
                hintText: "Cari event...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Grid View
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTickets.isEmpty
                ? const Center(child: Text("Tidak ada tiket tersedia 😔", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
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
                              Text(ticket.eventTitle, 
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(ticket.ticketType, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
                              const Spacer(),
                              Text("Rp ${ticket.price}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                              Text("Sisa: ${ticket.available}", 
                                style: TextStyle(color: isAvailable ? Colors.grey : Colors.red, fontSize: 12)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailable ? Colors.blue[600] : Colors.grey[700],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: isAvailable ? () => showBookingDialog(ticket) : null,
                                  child: Text(isAvailable ? "Pesan" : "Habis", style: const TextStyle(color: Colors.white)),
                                ),
                              )
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